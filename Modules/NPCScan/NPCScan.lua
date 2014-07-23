--[[

	s:UI NPC Scan

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("NPCScan");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	self:RegisterEvent("UnitCreated");
end

function M:OnDisable()
	self:UnregisterEvent("UnitCreated");
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

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
			Sound.Play(Sound.PlayUISoldierHoldoutAchieved);
--			Sound.Play(Sound.PlayUIStoryPanelUrgent);
		end
	end
end
