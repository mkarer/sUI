--[[

	s:UI Unit Frame Layout Generation: Threat Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateThreatBarElement(strUnit, tSettings)
	if (not tSettings.bThreatBarEnabled) then return; end

	local tXmlData = tSettings.tXmlData;
	local tColors = self.tUnitFrameController.tColors;

	-------------------------------------------------------------------------
	-- Threat Bar
	-------------------------------------------------------------------------

	tXmlData["ThreatBar"] = self.xmlDoc:NewControlNode("Threat", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 0 },
		AnchorOffsets = { 0, 0, 0, tSettings.nThreatBarHeight },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
	});

	tXmlData["HealthBar"]:AddChild(tXmlData["ThreatBar"]);

end
