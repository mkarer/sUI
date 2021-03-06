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
	strTagsTextLeft = "[TDifficultyColor][Level][Classification][TClose][TClassColor][ >Name][TClose][Sezz:Role]",
	strTagsTextRight = "[Sezz:HP]",
	-- Cast Bar
	bCastBarEnabled = true,
--	tCastBarAnchorPoints = { 0.5, 0.15, 0.5, 0.15 },
	tCastBarAnchorPoints = { 0.5, -23, 0.5, -23 },
	tCastBarAnchorOffsets = { -200, 0, 200, 36 },
	-- Auras
	bAurasEnabled = true,
	tAurasAnchorPoints = { 0, 0, 0, 1 },
	tAurasAnchorOffsets = { -302, 0, -2, 0 },
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Threat Bar
	bThreatBarEnabled = true,
	-- Power Bar
	bPowerBarEnabled = true,
});
