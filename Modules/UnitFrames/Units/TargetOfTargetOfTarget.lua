--[[

	s:UI Unit Frame Layout Settings: Target of Target of Target

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

UnitFramesLayout:SetUnitFrameConfiguration("TargetOfTargetOfTarget", {
	-- Base
	tAnchorPoints = { 0.5, 1, 0.5, 1 },
	tAnchorOffsets = { -127, -240, -23, -218 },
	-- Health Bar
	strTagsTextLeft = "[TClassColor][Name][TClose][Sezz:Role]",
	strTagsTextRight = "[Sezz:HPMinimal]",
});
