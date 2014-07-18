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
	tAnchorOffsets = { 259, 0, 334, 35 },
	-- Health Bar
	strTagsTextLeft = "[TClassColor][ >Sezz:RaidName][TClose][Sezz:Role]",
	strTagsTextRight = "[Sezz:HPMinimalParty]",
	-- Shield Bar
	bShieldBarEnabled = true,
};

-- Set Configuration
UnitFramesLayout:SetUnitFrameConfiguration("Raid", tSettings);
