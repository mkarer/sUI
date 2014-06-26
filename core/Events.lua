--[[

	s:UI Core Events & Messages

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "GameLib";
require "Apollo";
require "ActionSetLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:InitializePlayer()
	self:RegisterEvent("CharacterCreated", "OnCharacterCreated");
	Apollo.RegisterTimerHandler("SezzUITimer_DelayedInit", "OnCharacterCreated", self);
	Apollo.CreateTimer("SezzUITimer_DelayedInit", 0.10, false);
	self:OnCharacterCreated();
end

function S:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit();
	
	if (GameLib.IsCharacterLoaded() and not self.bCharacterLoaded and unitPlayer and unitPlayer:IsValid()) then
		self.bCharacterLoaded = true;
		Apollo.StopTimer("SezzUITimer_DelayedInit");
		self:UnregisterEvent("CharacterCreated");

		self.myRealm = GameLib:GetRealmName();
		self.myClassId = unitPlayer:GetClassId();
		self.myClass = self:GetClassName(self.myClassId);
		self.myLevel = unitPlayer:GetLevel();
		self.myName = unitPlayer:GetName();
		self.inCombat = unitPlayer:IsInCombat();
		self.myCharacter = unitPlayer;

		self:UpdateLimitedActionSetData();
		self:RegisterEvent("AbilityBookChange", "OnAbilityBookChange");
		self:RegisterEvent("UnitEnteredCombat", "HandleCombatChanges");
		self:RegisterEvent("ChangeWorld", "HandleCombatChanges");
		self:RegisterEvent("ShowResurrectDialog", "HandleCombatChanges");
		self:RegisterEvent("PlayerChanged", "OnPlayerChanged");

		S.Log:debug("%s@%s (Level %d %s)", self.myName, self.myRealm, self.myLevel, self.myClass);
		self:SendMessage("CHARACTER_LOADED");
		self:FireCombatMessage();
	else
		Apollo.StartTimer("SezzUITimer_DelayedInit");
	end
end

function S:GetClassName(classId)
	for k, v in pairs(GameLib.CodeEnumClass) do
		if (classId == v) then
			return k;
		end
	end

	return "Unknown";
end

function S:OnPlayerChanged()
	self.myCharacter = GameLib.GetPlayerUnit();
end

-----------------------------------------------------------------------------
-- Limited Action Set Data
-- Timer workaround, because AbilityBookChange fires too soon.
-----------------------------------------------------------------------------

local timerLASUpdateTicks = 0;
local timerLASUpdate;

function S:UpdateLimitedActionSetData(timedUpdate)
	local initialUpdate = false;
	local changed = false;

	-- Stop Timer if called by Event while Timer is still active
	if (not timedUpdate and timerLASUpdate) then
--		S.Log:debug("Stopping LAS Update Timer (should not be running anymore)");
		self:CancelTimer(timerLASUpdate);
		timerLASUpdate = nil;
	end

	-- Retrieve LAS and compare current set with previous data
	local currentLAS = ActionSetLib.GetCurrentActionSet();
	if (not currentLAS) then
		-- Propably Zoning
		S.Log:debug("ZONING?");
		if (timerLASUpdate) then
			self:CancelTimer(timerLASUpdate);
			timerLASUpdate = nil;
		end
		return;
	end
	if (not self.myLAS) then
		initialUpdate = true;
		self.myLAS = {};
	end

	for i = 1, 8 do
		if (not initialUpdate) then
			if (not changed and currentLAS[i] ~= self.myLAS[i]) then
				changed = true;
			end
		end

		self.myLAS[i] = currentLAS[i];
	end

	-- Start Timer if no change was detected and timer isn't active
--	if (not initialUpdate) then
--		S.Log:debug("LAS Changed: "..(changed and "YES" or "NO"));
--	end

	if (not changed and not initialUpdate and not timedUpdate) then
--		S.Log:debug("Resetting LAS Update Timer Ticks");
		timerLASUpdateTicks = 0;
		if (not timerLASUpdate) then
--			S.Log:debug("Starting LAS Update Timer");
			timerLASUpdate = self:ScheduleRepeatingTimer("LASUpdateTimerTick", 0.1);
		end
	end

	-- Stop timer when LAS changed or the timer ticked too often	
	if (timedUpdate and timerLASUpdate) then
		if (changed or timerLASUpdateTicks >= 5) then
			-- LAS Change detected or Timeout
--			S.Log:debug("Stopping LAS Update Timer, Ticks: "..timerLASUpdateTicks);
			self:CancelTimer(timerLASUpdate);
			timerLASUpdate = nil;
		end
	end

	-- Send Message
	if (changed or initialUpdate) then
		S.Log:debug("LIMITED_ACTION_SET_CHANGED");
		self:SendMessage("LIMITED_ACTION_SET_CHANGED");
	end

	return changed;
end

function S:LASUpdateTimerTick()
	timerLASUpdateTicks = timerLASUpdateTicks + 1;
--	S.Log:debug("Ticks: "..timerLASUpdateTicks);
	self:UpdateLimitedActionSetData(true);
end

function S:OnAbilityBookChange()
	-- This Event fires ALL THE F***ING TIME while zoning! TODO: Bug Carbone to events for PlayerLeftWorld/PlayerEnteredWorld
--	S.Log:debug("OnAbilityBookChange");
	if (not self.myCharacter or (self.myCharacter and not self.myCharacter:IsValid())) then
		-- Wait for PlayerChanged
	else
		self:UpdateLimitedActionSetData();
	end
end

-----------------------------------------------------------------------------
-- Player Combat State
-----------------------------------------------------------------------------

S.FireCombatMessage = function(self)
	if (self.inCombat) then
		self.Log:debug("PLAYER_REGEN_DISABLED");
		self:SendMessage("PLAYER_REGEN_DISABLED");
	else
		self.Log:debug("PLAYER_REGEN_ENABLED");
		self:SendMessage("PLAYER_REGEN_ENABLED");
	end
end

S.HandleCombatChanges = function(self, event, unit, inCombat)
	if (not self.bCharacterLoaded) then return; end
	local inCombatState = self.inCombat;

	if (event == "UnitEnteredCombat") then
		if (unit and unit == self.myCharacter) then
			inCombatState = inCombat;
		end
	elseif (event == "ChangeWorld" or event == "ShowResurrectDialog") then
		inCombatState = false;
	end

	if (inCombatState ~= self.inCombat) then
		self.Log:debug("%s: %s", event, (inCombatState and "True" or "False"));
		self.inCombat = inCombatState;
		self:FireCombatMessage();
	end
end

-----------------------------------------------------------------------------
-- External Addon Load Information
-----------------------------------------------------------------------------

local tAddonLoadingInformation = {
	InterfaceMenuList = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "tMenuAlerts", "tMenuData", "tPinnedAddons" },
	},
};

function S:CheckExternalAddon(name)
	if (type(name) == "table") then
		-- Try to identify the addon
		local caller = name;

		for id, config in pairs(tAddonLoadingInformation) do
			if (config.properties and #config.properties > 0) then
				local found = true;
				for _, property in pairs(config.properties) do
					found = found and caller[property] ~= nil;
				end

				if (found) then
					self:CheckExternalAddon(id);
					return;
				end
			end
		end

		return;
	end

	-- Check Addon
	local config = tAddonLoadingInformation[name];
	if (config) then
		local addon = Apollo.GetAddon(name);
		if (not addon) then
			-- Addon won't be loaded, remove from list
			tAddonLoadingInformation[name] = nil;
		else
			-- Unhook
			self:Unhook(addon, config.hook);

			-- Addon available
			if (addon[config.window]) then
				-- Main window exists, addon is initialized + enabled!
				tAddonLoadingInformation[name] = nil;
				S.Log:debug("ADDON_LOADED "..name);
				self:SendMessage("ADDON_LOADED", name);
			else
				-- Main window doesn't exist yet, hook creation
				self:PostHook(addon, config.hook, "CheckExternalAddon");
			end
		end
	end
end

function S:CheckExternalAddons()
	for name in pairs(tAddonLoadingInformation) do
		self:CheckExternalAddon(name);
	end
end

function S:IsAddOnLoaded(name)
	local config = tAddonLoadingInformation[name];
	if (config) then
		local addon = Apollo.GetAddon(name);
		return addon and addon[config.window];
	else
		S.Log:warn("Addon %s is not supported by IsAddOnLoaded()", name);
		return Apollo.GetAddon(name) and true;
	end
end

-- Recall
function S:GetRecallAbilitiesList()
	local tAbilities = {};

	-- Default Bind Point
	if (GameLib.HasBindPoint() == true) then
		table.insert(tAbilities, GameLib.CodeEnumRecallCommand.BindPoint);
	end
	
	-- Housing
	if (HousingLib.IsResidenceOwner() == true) then
		table.insert(tAbilities, GameLib.CodeEnumRecallCommand.House);
	end

	-- WarParty
	for key, guildCurr in pairs(GuildLib.GetGuilds()) do
		if (guildCurr:GetType() == GuildLib.GuildType_WarParty) then
			table.insert(tAbilities, GameLib.CodeEnumRecallCommand.Warplot);
			break
		end
	end
	
	-- Capital City
	for idx, tSpell in pairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Misc) or {}) do
		if (tSpell.bIsActive and tSpell.nId == GameLib.GetTeleportIlliumSpell():GetBaseSpellId()) then
			-- Illum
			table.insert(tAbilities, GameLib.CodeEnumRecallCommand.Illium);
		elseif (tSpell.bIsActive and tSpell.nId == GameLib.GetTeleportThaydSpell():GetBaseSpellId()) then
			-- Thayd
			table.insert(tAbilities, GameLib.CodeEnumRecallCommand.Thayd);
		end
	end

	return tAbilities;
end
