--[[

	s:UI Unit Frame Layout Settings: Focus Target Of Target

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

UnitFramesLayout:SetUnitFrameConfiguration("FocusTargetOfTarget", {
	-- Base
	tAnchorPoints = { 0.5, 0.5, 0.5, 0.5 },
	tAnchorOffsets = { 707, -92, 873, -58 },
	-- Health Bar
	strTagsTextLeft = "[Sezz:Difficulty][Sezz:ClassColor][Name][ >Sezz:Role]",
	strTagsTextRight = "[Sezz:HPMinimalParty]",
	-- Cast Bar
	bCastBarEnabled = true,
	tCastBarAnchorPoints = { 0.5, 0.5, 0.5, 0.5 };
	tCastBarAnchorOffsets = { 707, -114, 873, -94 };
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Threat Bar
	bThreatBarEnabled = true,
});
