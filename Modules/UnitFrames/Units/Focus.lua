--[[

	s:UI Unit Frame Layout Settings: Focus

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

local tSettings = {
	-- Base
	tAnchorPoints = { 0.5, 0.5, 0.5, 0.5 },
	tAnchorOffsets = { 283, -92, 537, -58 },
	-- Health Bar
	strTagsTextLeft = "[Sezz:Difficulty][Sezz:Level< ][Sezz:ClassColor][Name][ >Sezz:Role]",
	strTagsTextRight = "[Sezz:HP]",
	-- Cast Bar
	bCastBarEnabled = true,
	tCastBarAnchorPoints = { 0.5, 0.5, 0.5, 0.5 };
	tCastBarAnchorOffsets = { 283, -114, 537, -94 };
	-- Auras
	bAurasEnabled = true,
	tAurasAnchorPoints = { 0.5, 0.5, 0.5, 0.5 },
	tAurasAnchorOffsets = { -19, -92, 281, -58 },
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Threat Bar
	bThreatBarEnabled = true,
};

tSettings.tAurasFilter = S:Clone(S.DB.Modules.Buffs.Filter);
tSettings.tAurasFilter["Buff"] = true;

UnitFramesLayout:SetUnitFrameConfiguration("Focus", tSettings);
