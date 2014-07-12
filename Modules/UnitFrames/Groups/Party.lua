--[[

	s:UI Unit Frame Layout Settings: Player

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

local tSettings = {
	-- Base
	strDirection = "BOTTOMTOP",
	tAnchorPoints = { 0.5, 1, 0.5, 1 },
	tAnchorOffsets = { 129, -126, 299, -98 },
	-- Health Bar
	strTagsTextLeft = "[Sezz:Difficulty][Sezz:Level< ][Sezz:ClassColor][Name][ >Sezz:Role][ >Sezz:RaidGroup]",
	strTagsTextRight = "[Sezz:HPMinimalParty]",
	-- Shield Bar
	bShieldBarEnabled = true,
	-- Auras
	bAurasEnabled = true,
	tAurasAnchorPoints = { 0.5, 1, 0.5, 1 },
	tAurasAnchorOffsets = { 301, -126, 601, -98 },
	bAurasAnchorLeft = true,
};

-- Auras
tSettings.tAuraPrototypeBuff = S:Clone(UnitFramesLayout.tDefaults.tAuraPrototypeBuff);
tSettings.tAuraPrototypeDebuff = S:Clone(UnitFramesLayout.tDefaults.tAuraPrototypeDebuff);
tSettings.tAuraPrototypeBuff.AnchorOffsets = { 0, 0, 28, 28 };
tSettings.tAuraPrototypeDebuff.AnchorOffsets = { 0, 0, 28, 28 };
tSettings.tAurasFilter = S:Clone(S.DB.Modules.Buffs.Filter);
tSettings.tAurasFilter["Buff"] = true;

-- Set Configuration
UnitFramesLayout:SetUnitFrameConfiguration("Party", tSettings);
