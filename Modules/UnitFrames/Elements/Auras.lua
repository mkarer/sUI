--[[

	s:UI Unit Frame Layout Generation: Auras Element

	Auras (Combined Buffs + Debuffs)
	Buffs
	Debuffs

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

local tBuffPrototype = {
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

local tDebuffPrototype = S:Clone(tBuffPrototype);
tDebuffPrototype.Children[1].BGColor = "ff791104";

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateAurasElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	local tXmlData = self.tSettings[strUnit].tXmlData;

	if (not tSettings.bAurasEnabled) then return; end

	-- Create Container
	tXmlData["Auras"] = self.xmlDoc:NewFormNode(UnitFramesLayout:GetUnitFramePrefix(strUnit).."Auras", {
		AnchorPoints = tSettings.tAurasAnchorPoints,
		AnchorOffsets = tSettings.tAurasAnchorOffsets,
--		Sprite = "ClientSprites:WhiteFill",
--		Picture = true,
--		BGColor = "5500ff00",
		IgnoreMouse = true,
	});

	-- Add as root element
	UnitFramesLayout.xmlDoc:GetRoot():AddChild(tXmlData["Auras"]);

	-- Set Prototypes
	UnitFramesLayout:SetUnitFrameAttribute(strUnit, "AuraPrototypeBuff", tBuffPrototype);
	UnitFramesLayout:SetUnitFrameAttribute(strUnit, "AuraPrototypeDebuff", tDebuffPrototype);
	UnitFramesLayout:SetUnitFrameAttribute(strUnit, "AuraFilter", tSettings.tAurasFilter);
end
