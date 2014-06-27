--[[

	s:UI Player Helper Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------
-- Generic Player Data
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
		S.Log:debug("CHARACTER_LOADED");
		self:SendMessage("CHARACTER_LOADED");
		self:FireCombatMessage();
	else
		Apollo.StartTimer("SezzUITimer_DelayedInit");
	end
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
-- Recall Abilities
-----------------------------------------------------------------------------

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
	for _, tGuild in pairs(GuildLib.GetGuilds()) do
		if (tGuild:GetType() == GuildLib.GuildType_WarParty) then
			table.insert(tAbilities, GameLib.CodeEnumRecallCommand.Warplot);
			break
		end
	end
	
	-- Capital City
	for _, tSpell in pairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Misc) or {}) do
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

-----------------------------------------------------------------------------
-- Inventory
-----------------------------------------------------------------------------

function S:GetInventory()
	return self.myCharacter:GetInventoryItems() or {};
end

function S:GetInventoryByCategory(nCategoryId)
	-- 48: Consumable
	local tInventoryFiltered = {};
	local tInventory = self:GetInventory();

	for _, tItemData in pairs(tInventory) do
		if (tItemData and tItemData.itemInBag and tItemData.itemInBag:GetItemCategory() == nCategoryId) then
			local tItem = tItemData.itemInBag;
			local nItemId = tItem:GetItemId();

			if (tInventoryFiltered[nItemId] == nil) then
				tInventoryFiltered[nItemId] = {
					tItem = tItem,
					nCount = tItem:GetStackCount(),
				};
			else
				tInventoryFiltered[nItemId].nCount = tInventoryFiltered[nItemId].nCount + tItem:GetStackCount();
			end
		end
	end

	return tInventoryFiltered;
end

-----------------------------------------------------------------------------
-- Path Abilities
-----------------------------------------------------------------------------

function S:GetPathAbilities()
	local tPathAbilities = {};

	if (self.myCharacter) then
		for _, tSpell in pairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Path) or {}) do
			if (tSpell.bIsActive and tSpell.nCurrentTier > 0) then
				tPathAbilities[tSpell.nId] = tSpell;
			end
		end
	end

	return tPathAbilities;
end

function S:ChangePathAbility(nAbilityId)
	local tActionSet = ActionSetLib.GetCurrentActionSet();
	if (not tActionSet) then return { eResult = ActionSetLib.CodeEnumLimitedActionSetResult.InvalidUnit }; end

	tActionSet[10] = nAbilityId;
	return ActionSetLib.RequestActionSetChanges(tActionSet);
end
