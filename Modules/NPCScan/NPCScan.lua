--[[

	s:UI NPC Scan

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("NPCScan");
local Apollo = Apollo;
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	Apollo.RegisterTimerHandler("SezzUITimer_NPCScan", "RestoreVolume", self);

	self:RegisterEvent("UnitCreated");
end

function M:OnDisable()
	self:UnregisterEvent("UnitCreated");
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

local fVolumeMaster = Apollo.GetConsoleVariable("sound.volumeMaster");
local tWatchedUnits = {
	["Goldensun Dawngrazer"] = true,
	["Scorchwing"] = true,
--	["Softsnow Jabbit"] = true,
};

function M:UnitCreated(event, unit)
	if (unit and unit:IsValid() and not unit:IsACharacter()) then
		local strName = unit:GetName();
		if (strName and tWatchedUnits[strName] and S.bCharacterLoaded) then
			Print(string.format("Found Unit: %s", strName));
			S.myCharacter:SetAlternateTarget(unit);

			if (not self.bAlertPlaying) then
				self.bAlertPlaying = true;
				fVolumeMaster = Apollo.GetConsoleVariable("sound.volumeMaster");
				Apollo.SetConsoleVariable("sound.volumeMaster", 1);
				Sound.Play(Sound.PlayUISoldierHoldoutAchieved);
				Apollo.CreateTimer("SezzUITimer_NPCScan", 1, false);
			end
--			Sound.Play(Sound.PlayUIStoryPanelUrgent);
		end
	end
end

function M:RestoreVolume()
	self.bAlertPlaying = false;
	Apollo.SetConsoleVariable("sound.volumeMaster", fVolumeMaster);
end
