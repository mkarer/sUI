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
--	fOutOfRangeOpacity = 0.5,
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
	tAurasFilter = S.DB.Modules.Buffs.Filter, -- { [nBuffId] = 1, [nBuffId] = 1 }
	bAurasAnchorLeft = false,
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
	-------------------------------------------------------------------------
	-- Power Bar
	-------------------------------------------------------------------------
--	bPowerBarEnabled = true,
	nPowerBarHeight = 2,



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
UnitFramesLayout.tColors = {};

-- Aura Prototypes
UnitFramesLayout.tDefaults.tAuraPrototypeBuff = {
	WidgetType = "Window",
	AnchorPoints = { 0, 0, 0, 0 },
	AnchorOffsets = { 0, 0, 34, 34 },
	Children = {
		{
			Name = "Border",
			Class = "Window",
			AnchorPoints = { 0, 0, 1, 1 },
			AnchorOffsets = { 0, 0, 0, 0 },
			Picture = true,
			BGColor = "33ffffff", --ff791104
			Sprite = "ClientSprites:WhiteFill",
			IgnoreMouse = true,
			Children = {
				{
					Name = "Background",
					BGColor = "ff000000",
					Sprite = "ClientSprites:WhiteFill",
					Class = "Window",
					Picture = true,
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 2, 2, -2, -2 },
					IgnoreMouse = false,
					Children = {
						{
							Name = "Icon",
							Class = "Window",
							Picture = true,
							AnchorPoints = { 0, 0, 1, 1 },
							AnchorOffsets = { 0, 0, 0, 0 },
							IgnoreMouse = false,
							Children = {
								{
									Name = "IconOverlay",
									Class = "ProgressBar",
									AnchorPoints = { 0, 0, 1, 1 },
									AnchorOffsets = { 0, 0, 0, 0 },
									Picture = true,
									BGColor = "bb000000",
									ProgressFull = "ClientSprites:WhiteFill",
									IgnoreMouse = true,
									RadialBar = true,
									UsePercent = true,
									SwallowMouseClicks = true,
									RadialMin = 90,
									RadialMax = 450,
									Children = {
										{
											Name = "Count",
											Class = "Window",
											Text = "",
											TextColor = "ffffffff",
											Font = "CRB_Interface12_BO",
											DT_RIGHT = true,
											DT_BOTTOM = true,
											AnchorPoints = { 0, 0, 1, 1 },
											AnchorOffsets = { 0, 0, -2, 0 },
											IgnoreMouse = true,
										}, {
											Name = "Duration",
											Class = "Window",
											Text = "",
											TextColor = "ffffffff",
											Font = "CRB_Pixel_O", -- CRB_Interface9_O
											DT_VCENTER = true,
											DT_CENTER = true,
											DT_SINGLELINE = true,
											AutoScaleTextOff = true,
											AnchorPoints = { 0, 0, 1, 1 },
											AnchorOffsets = { -2, -2, 2, 2 },
											IgnoreMouse = true,
										},

									},

								},
							},
						},
					},
				},
			},
		},
	},
};

UnitFramesLayout.tDefaults.tAuraPrototypeDebuff = S:Clone(UnitFramesLayout.tDefaults.tAuraPrototypeBuff);
UnitFramesLayout.tDefaults.tAuraPrototypeDebuff.Children[1].BGColor = "ff791104";

-- Settings Initialization
function UnitFramesLayout:SetUnitFrameConfiguration(strUnit, tSettings)
	self.tSettings[strUnit] = setmetatable(tSettings, { __index = self.tDefaults });
	self.tSettings[strUnit].strUnit = strUnit;

	return self.tSettings[strUnit];
end
