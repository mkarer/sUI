--[[

	s:UI Unit Frame Layout Settings: Raid

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

local tSettings = {
	-- Base
	fOutOfRangeOpacity = 0.5,
	strDirection = "TOPBOTTOM",
	nUnitsPerColumn = 5,
	strDirectionColumn = "LEFTRIGHT",
	tAnchorPoints = { 0.5, 0.5, 0.5, 0.5 },
--	tAnchorOffsets = { 259, 0, 334, 35 },
	tAnchorOffsets = { 259, 0, 336, 37 },
	-- Health Bar
	strTagsTextRight = "[Sezz:RaidHP]",
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Role
	bRoleEnabled = true,
	tRoleAnchorPoints = { 0.5, 1, 0.5, 1 },
	tRoleAnchorOffsets = { -6, -13, 6, -1 },
	-- Leader/Assistant
	bLeaderEnabled = true,
	tLeaderAnchorPoints = { 0, 1, 0, 1 },
	tLeaderAnchorOffsets = { 1, -8, 13, 0 },
};

-- Set Configuration
UnitFramesLayout:SetUnitFrameConfiguration("Raid", tSettings);
