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

function UnitFramesLayout:CreateAurasElement(strUnit, tSettings)
	local tXmlData = tSettings.tXmlData;

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
	UnitFramesLayout:SetUnitFrameAttribute(tSettings.strUnitBase or strUnit, "AuraPrototypeBuff", tSettings.tAuraPrototypeBuff);
	UnitFramesLayout:SetUnitFrameAttribute(tSettings.strUnitBase or strUnit, "AuraPrototypeDebuff", tSettings.tAuraPrototypeDebuff);
	UnitFramesLayout:SetUnitFrameAttribute(tSettings.strUnitBase or strUnit, "AuraFilter", tSettings.tAurasFilter);
	UnitFramesLayout:SetUnitFrameAttribute(tSettings.strUnitBase or strUnit, "AuraAnchorLeft", tSettings.bAurasAnchorLeft);
end
