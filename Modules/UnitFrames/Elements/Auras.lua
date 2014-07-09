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

local knBuffBarTypeBuffs = 0;
local knBuffBarTypeDebuffs = 1;
local knBuffBarTypeCombined = 2;

-----------------------------------------------------------------------------

local tBuffPrototype = {
	WidgetType = "Window",
	AnchorPoints = { 0, 0, 0, 0 },
	AnchorOffsets = { 0, 0, 34, 51 },
	Children = {
		{
			Name = "Duration",
			Class = "Window",
			Text = "",
			TextColor = "ffffffff",
			Font = "CRB_Pixel_O", -- CRB_Interface9_O
			DT_VCENTER = true,
			DT_CENTER = true,
			DT_SINGLELINE = true,
			AutoScaleTextOff = true,
			AnchorPoints = { 0, 0, 1, 0 },
			AnchorOffsets = { -2, -2, 2, 19 },
			IgnoreMouse = true,
			Overlapped = true,
		}, {
			Name = "Border",
			Class = "Window",
			AnchorPoints = { 0, 1, 1, 1 },
			AnchorOffsets = { 0, -34, 0, 0 },
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
					AnchorOffsets = { 3, 3, -3, -3 },
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
tDebuffPrototype.Children[2].BGColor = "ff791104";

-----------------------------------------------------------------------------

local CreateAuraBar = function(strUnit, tSettings, eStyle)
	-- Initialize
	local strName;
	local tAnchorPoints, tAnchorOffsets, tStyles;
	local tXmlData = tSettings.tXmlData;

	if (eStyle == knBuffBarTypeCombined) then
		strName = "Auras";
		tStyles = S:Clone(tSettings.tAurasStyles);
		tAnchorPoints = tSettings.tAurasAnchorPoints;
		tAnchorOffsets = tSettings.tAurasAnchorOffsets;
		table.insert(tStyles, "BeneficialBuffs");
		table.insert(tStyles, "HarmfulBuffs");
	elseif (eStyle == knBuffBarTypeBuffs) then
		strName = "Buffs";
		tStyles = S:Clone(tSettings.tBuffsStyles);
		tAnchorPoints = tSettings.tBuffsAnchorPoints;
		tAnchorOffsets = tSettings.tBuffsAnchorOffsets;
		table.insert(tStyles, "BeneficialBuffs");
	elseif (eStyle == knBuffBarTypeDebuffs) then
		strName = "Debuffs";
		tStyles = S:Clone(tSettings.tDebuffsStyles);
		tAnchorPoints = tSettings.tDebuffsAnchorPoints;
		tAnchorOffsets = tSettings.tDebuffsAnchorOffsets;
		table.insert(tStyles, "HarmfulBuffs");
	end

	-- Container
	tXmlData[strName .. "Container"] = UnitFramesLayout.xmlDoc:NewFormNode(UnitFramesLayout:GetUnitFramePrefix(strUnit)..strName, {
		AnchorPoints = tAnchorPoints,
		AnchorOffsets = tAnchorOffsets,
		Picture = false,
--		Sprite = "WhiteFill",
--		BGColor = "ff000000",
		IgnoreMouse = true,
	});

	-- Bar
	local tData = {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		TooltipType = "OnCursor",
		IgnoreMouse = true,
	};

	for _, strStyle in ipairs(tStyles) do
		tData[strStyle] = 1;
	end

	tXmlData[strName] = UnitFramesLayout.xmlDoc:NewControlNode(strName, "BuffContainerWindow", tData);
	tXmlData[strName .. "Container"]:AddChild(tXmlData[strName]);

	-- Add as root element
	UnitFramesLayout.xmlDoc:GetRoot():AddChild(tXmlData[strName .. "Container"]);

	-- NEW!1

	UnitFramesLayout:SetUnitFrameAttribute(strUnit, "AuraPrototypeBuff", tBuffPrototype);
	UnitFramesLayout:SetUnitFrameAttribute(strUnit, "AuraPrototypeDebuff", tDebuffPrototype);
end

function UnitFramesLayout:CreateAurasElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	local tXmlData = self.tSettings[strUnit].tXmlData;

	if (tSettings.bAurasEnabled) then
		CreateAuraBar(strUnit, tSettings, knBuffBarTypeCombined);
	end

	if (tSettings.bBuffsEnabled) then
		CreateAuraBar(strUnit, tSettings, knBuffBarTypeBuffs);
	end

	if (tSettings.bDebuffsEnabled) then
		CreateAuraBar(strUnit, tSettings, knBuffBarTypeDebuffs);
	end
end
