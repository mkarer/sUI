--[[

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	Core Events & Messages

--]]

require "GameLib";
require "Apollo";

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
		S.Log:debug("Stopping LAS Update Timer (should not be running anymore)");
		self:CancelTimer(timerLASUpdate);
		timerLASUpdate = nil;
	end

	-- Retrieve LAS and compare current set with previous data
	local currentLAS = ActionSetLib.GetCurrentActionSet();
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
	if (not initialUpdate) then
		S.Log:debug("LAS Changed: "..(changed and "YES" or "NO"));
	end

	if (not changed and not initialUpdate and not timedUpdate) then
		S.Log:debug("Resetting LAS Update Timer Ticks");
		timerLASUpdateTicks = 0;
		if (not timerLASUpdate) then
			S.Log:debug("Starting LAS Update Timer");
			timerLASUpdate = self:ScheduleRepeatingTimer("LASUpdateTimerTick", 0.1);
		end
	end

	-- Stop timer when LAS changed or the timer ticked too often	
	if (timedUpdate and timerLASUpdate) then
		if (changed or timerLASUpdateTicks >= 5) then
			-- LAS Change detected or Timeout
			S.Log:debug("Stopping LAS Update Timer, Ticks: "..timerLASUpdateTicks);
			self:CancelTimer(timerLASUpdate);
			timerLASUpdate = nil;
		end
	end

	-- Send Message
	if (changed or initialUpdate) then
		self:SendMessage("LIMITED_ACTION_SET_CHANGED");
	end

	return changed;
end

function S:LASUpdateTimerTick()
	timerLASUpdateTicks = timerLASUpdateTicks + 1;
	S.Log:debug("Ticks: "..timerLASUpdateTicks);
	self:UpdateLimitedActionSetData(true);
end

function S:OnAbilityBookChange()
	self:UpdateLimitedActionSetData();
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
