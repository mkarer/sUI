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
--	tAurasStyles = { "AutoAddBuffs", "AlignBuffsRight", "PulseWhenExpiring", "BuffNonDispelRightClick", "ShowMS" },
	-------------------------------------------------------------------------
	-- Buffs
	-------------------------------------------------------------------------
--	bBuffsEnabled = true,
--	tBuffsAnchorPoints = { 0, 0, 0, 0 },
--	tBuffsAnchorOffsets = { 0, 0, 200, 30 },
--	tBuffsStyles = { "AutoAddBuffs", "AlignBuffsRight", "PulseWhenExpiring", "BuffNonDispelRightClick", "ShowMS" },
	-------------------------------------------------------------------------
	-- Buffs
	-------------------------------------------------------------------------
--	bDebuffsEnabled = true,
--	tDebuffsAnchorPoints = { 0, 0, 0, 0 },
--	tDebuffsAnchorOffsets = { 0, 0, 200, 30 },
--	tDebuffsStyles = { "AutoAddBuffs", "AlignBuffsRight", "PulseWhenExpiring", "BuffNonDispelRightClick", "ShowMS" },


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
	HealthSmooth = { 255/255, 38/255, 38/255, 255/255, 38/255, 38/255, 38/255, 38/255, 38/255 },
	VulnerabilitySmooth = { 255/255, 38/255, 255/255, 255/255, 38/255, 255/255, 38/255, 38/255, 38/255 },
	Tagged = { 153/255, 153/255, 153/255 },
	Experience = {
		Normal = { 45/255 - 0.1, 85/255 + 0.2, 137/255 },
		Rested = { 45/255 + 0.2, 85/255 - 0.1, 137/255 - 0.1 },
	},
	Castbar = {
		Normal = { 0.43, 0.75, 0.44 },
	},
	Class = setmetatable({
		["Default"]								= { 255/255, 255/255, 255/255 },
		["Object"]								= { 0, 1, 0 },
		[GameLib.CodeEnumClass.Engineer]		= { 164/255,  26/255,  49/255 },
		[GameLib.CodeEnumClass.Esper]			= { 116/255, 221/255, 255/255 },
		[GameLib.CodeEnumClass.Medic]			= { 255/255, 255/255, 255/255 },
		[GameLib.CodeEnumClass.Stalker]			= { 221/255, 212/255,  95/255 },
		[GameLib.CodeEnumClass.Spellslinger]	= { 130/255, 111/255, 172/255 },
		[GameLib.CodeEnumClass.Warrior]			= { 171/255, 133/255,  94/255 },
	}, { __index = function(t, k) return rawget(t, k) or rawget(t, "Default"); end }),
};

-- Settings Initialization
function UnitFramesLayout:SetUnitFrameConfiguration(strUnit, tSettings)
	self.tSettings[strUnit] = setmetatable(tSettings, {
	    __index = function(t, k) return (rawget(t, k) or self.tDefaults[k]); end
	});

	self.tSettings[strUnit].strUnit = strUnit;

	return self.tSettings[strUnit];
end
