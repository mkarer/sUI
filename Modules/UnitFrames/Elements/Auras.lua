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
