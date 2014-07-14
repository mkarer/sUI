--[[

	s:UI Unit Frame Layout Settings: Focus Target

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

UnitFramesLayout:SetUnitFrameConfiguration("FocusTarget", {
	-- Base
	tAnchorPoints = { 0.5, 0.5, 0.5, 0.5 },
	tAnchorOffsets = { 539, -92, 705, -58 },
	-- Health Bar
	strTagsTextLeft = "[Sezz:Difficulty][Sezz:ClassColor][Name][ >Sezz:Role]",
	strTagsTextRight = "[Sezz:HPMinimalParty]",
	-- Cast Bar
	bCastBarEnabled = true,
	tCastBarAnchorPoints = { 0.5, 0.5, 0.5, 0.5 };
	tCastBarAnchorOffsets = { 539, -114, 705, -94 };
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Threat Bar
	bThreatBarEnabled = true,
});