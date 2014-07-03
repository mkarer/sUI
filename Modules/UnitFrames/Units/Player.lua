--[[

	s:UI Unit Frame Layout Settings: Player

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

UnitFramesLayout:SetUnitFrameConfiguration("Player", {
	-- Base
	tAnchorPoints = { 0.5, 1, 0.5, 1 },
	tAnchorOffsets = { -127, -126, 127, -92 },
	-- Health Bar
	strTagsTextLeft = "[Sezz:Difficulty][Sezz:ClassColor][Name][ >Sezz:Role][ >Sezz:RaidGroup]",
	strTagsTextRight = "[Sezz:HP]",
	-- Cast Bar
	bCastBarEnabled = true,
	tCastBarAnchorPoints = { 0.5, 1, 0.5, 1 };
	tCastBarAnchorOffsets = { -127, -86, 127, -66 };
	-- Experience Bar
	bExperienceBarEnabled = true,
});
