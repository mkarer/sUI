--[[

	s:UI Unit Frame Layout Generation: Shield Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateShieldBarElement(strUnit, tSettings)
	if (not tSettings.bShieldBarEnabled) then return; end

	local tXmlData = tSettings.tXmlData;
	local tColors = self.tUnitFrameController.tColors;

	-------------------------------------------------------------------------
	-- Shield Bar
	-------------------------------------------------------------------------

	tXmlData["ShieldBar"] = self.xmlDoc:NewControlNode("Shield", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 0 },
		AnchorOffsets = { 0, 0, 0, tSettings.nShieldBarHeight },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.Shield),
	});

	tXmlData["HealthBar"]:AddChild(tXmlData["ShieldBar"]);

end
