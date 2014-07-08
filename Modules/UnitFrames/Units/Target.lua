--[[

	s:UI Unit Frame Layout Settings: Target

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

UnitFramesLayout:SetUnitFrameConfiguration("Target", {
	-- Base
	tAnchorPoints = { 0.5, 1, 0.5, 1 },
	tAnchorOffsets = { -127, -214, 127, -180 },
	-- Health Bar
	strTagsTextLeft = "[Sezz:Difficulty][Sezz:Level< ][Sezz:ClassColor][Name][ >Sezz:Role][ >Sezz:RaidGroup][ >Sezz:ComboPoints]",
	strTagsTextRight = "[Sezz:HP]",
	-- Cast Bar
	bCastBarEnabled = true,
	tCastBarAnchorPoints = { 0.5, 0.15, 0.5, 0.15 };
	tCastBarAnchorOffsets = { -200, 0, 200, 36 };
	-- Auras
	bAurasEnabled = true,
	tAurasAnchorPoints = { 0.5, 1, 0.5, 1 },
	tAurasAnchorOffsets = { -127 - 200, -214, -127, -180 },
	tAurasStyles = { "AutoAddAuras", "AlignAurasRight", "PulseWhenExpiring", "ShowMS" },
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Threat Bar
	bThreatBarEnabled = true,
});
