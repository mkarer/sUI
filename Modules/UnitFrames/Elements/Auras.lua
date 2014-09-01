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

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateAurasElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bAurasEnabled) then return; end

	-- Create Container
	local tAuras = {
		Name = "Auras",
		AnchorPoints = tSettings.tAurasAnchorPoints,
		AnchorOffsets = tSettings.tAurasAnchorOffsets,
		IgnoreMouse = true,
		NoClip = true,
		UserData = {
			Element = "Auras",
			AuraPrototypeBuff = tSettings.tAuraPrototypeBuff,
			AuraPrototypeDebuff = tSettings.tAuraPrototypeDebuff,
			AuraFilter = tSettings.tAurasFilter,
			AuraAnchorLeft = tSettings.bAurasAnchorLeft,
		},
	};

	tinsert(tSettings.tElements["Main"].Children, tAuras);
	tSettings.tElements["Auras"] = tAuras;
end
