--[[

	s:UI Unit Frame Layout Defaults

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

-- Default Frame Settings
UnitFramesLayout.tDefaults = {
	-------------------------------------------------------------------------
	-- Base
	-------------------------------------------------------------------------
	nBarSpacing = 1,
--	tAnchorPoints = {},
--	tAnchorOffsets = {},
	-------------------------------------------------------------------------
	-- Health Bar
	-------------------------------------------------------------------------
--	strTagsTextLeft = "[Sezz:Difficulty][Sezz:ClassColor][Name][ >Sezz:Role][ >Sezz:RaidGroup]",
--	strTagsTextRight = "[Sezz:HP]",
	-------------------------------------------------------------------------
	-- Cast Bar
	-------------------------------------------------------------------------
--	bCastBarEnabled = true,
--	tCastBarAnchorPoints = {},
--	tCastBarAnchorOffsets = {},
	-------------------------------------------------------------------------
	-- Experience Bar
	-------------------------------------------------------------------------
--	bExperienceBarEnabled = true,
	nExperienceBarHeight = 2,
	-------------------------------------------------------------------------
	-- Auras (Combined Buffs + Debuffs)
	-------------------------------------------------------------------------
--	bAurasEnabled = true,
--	tAurasAnchorPoints = { 0, 0, 0, 0 },
--	tAurasAnchorOffsets = { 0, 0, 200, 30 },
	-------------------------------------------------------------------------
	-- Shield Bar
	-------------------------------------------------------------------------
--	bShieldBarEnabled = true,
	nShieldBarHeight = 1,
	-------------------------------------------------------------------------
	-- Threat Bar
	-------------------------------------------------------------------------
--	bThreatBarEnabled = true,
	nThreatBarHeight = 2,



--	rangeCheck = { insideAlpha = 1, outsideAlpha = 0.5 },
	-- Power Bar
--	powerBarEnabled = true,
	powerBarHeight = 2,
	powerBarTextSize = 11,
	powerBarTextHover = true,
	-- Combined Bar for Experience/Reputation
--	multiBarEnabled = true,
	multiBarHeight = 2,
	-- Alternate Power Bar
	altPowerBarHeight = 14,
	altPowerBarWidth = nil, -- (Frame width will be used when nil)
--	altPowerBarEnabled = true,
--	altPowerBarAnchors = { "BOTTOM", addon:GetUnitFrameName("player"), "TOP", 0, 36 },
	altPowerBarTextSize = 12,
	-- 3D Portrait
--	portraitEnabled = true,
	-- Class Icons
--	classIconsEnabled = true,
	-- Threat Bar
--	threatBarEnabled = true,
	threatBarHeight = 2,
	-- Auras
	aurasEnabled = false,
	aurasCustomFilter = false,
	aurasPosition = "L", -- L: Left, R: Right
	aurasBuffs = 8,
	aurasDebuffs = 8,
--	aurasDebuffFilter = "PLAYER|HARMFUL",
	-- Combat Text
	combatFeedbackEnabled = false,
};

-- Colors
UnitFramesLayout.tColors = {
};

-- Settings Initialization
function UnitFramesLayout:SetUnitFrameConfiguration(strUnit, tSettings)
	self.tSettings[strUnit] = setmetatable(tSettings, { __index = self.tDefaults });
	self.tSettings[strUnit].strUnit = strUnit;

	return self.tSettings[strUnit];
end
