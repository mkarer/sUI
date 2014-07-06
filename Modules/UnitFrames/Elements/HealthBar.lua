--[[

	s:UI Unit Frame Layout Generation: Health Bar/Text Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateHealthBarElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	local tXmlData = self.tSettings[strUnit].tXmlData;
	local tColors = self.tUnitFrameController.tColors;

	-------------------------------------------------------------------------
	-- Health Bar Background
	-------------------------------------------------------------------------

	tXmlData["HealthBarBG"] = self.xmlDoc:NewControlNode("Health", "Window", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 2, 2, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
	});

	tXmlData["Root"]:AddChild(tXmlData["HealthBarBG"]);

	-------------------------------------------------------------------------
	-- Health Bar
	-------------------------------------------------------------------------

	tXmlData["HealthBar"] = self.xmlDoc:NewControlNode("Progress", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = self.tUnitFrameController:RGBColorToHex(tColors.HealthSmooth[1], tColors.HealthSmooth[2], tColors.HealthSmooth[3]),
	});

	tXmlData["HealthBarBG"]:AddChild(tXmlData["HealthBar"]);

	-------------------------------------------------------------------------
	-- Right Text Element
	-------------------------------------------------------------------------

	if (tSettings.strTagsTextRight) then
--		tXmlData["TextRight"] = self.xmlDoc:NewControlNode("TextRight", "Window", {
--			AnchorPoints = { 0.5, 0, 1, 1 },
--			AnchorOffsets = { 0, 0, -4, 0 },
--			TextColor = "white",
--			DT_VCENTER = true,
--			DT_RIGHT = true,
--			Text = "28.6k",
--			IgnoreMouse = "true",
--			Font = "CRB_Pixel_O",
--		});

		-- MLWindow allows colors, but it doesn't care about DT_VCENTER/DT_RIGHT/Font
		tXmlData["TextRight"] = self.xmlDoc:NewControlNode("TextRight", "MLWindow", {
			AnchorPoints = { (tSettings.strTagsTextLeft and 0.5 or 0), 0.5, 1, 0.5 },
			AnchorOffsets = { (tSettings.strTagsTextLeft and 0 or 4), -7, -4, 7 },
			TextColor = "white",
			Text = "",
			IgnoreMouse = "true",
			Font = "CRB_Pixel_O",
		});

		tXmlData["HealthBar"]:AddChild(tXmlData["TextRight"]);
	end

	-------------------------------------------------------------------------
	-- Left Text Element
	-------------------------------------------------------------------------

	if (tSettings.strTagsTextLeft) then
--		tXmlData["TextLeft"] = self.xmlDoc:NewControlNode("TextLeft", "Window", {
--			AnchorPoints = { 0, 0, 0.5, 1 },
--			AnchorOffsets = { 4, 0, 0, 0 },
--			TextColor = "white",
--			DT_VCENTER = true,
--			Text = "Elke",
--			IgnoreMouse = "true",
--			Font = "CRB_Pixel_O",
--		});

		-- MLWindow allows colors, but it doesn't care about DT_VCENTER/DT_RIGHT/Font
		tXmlData["TextLeft"] = self.xmlDoc:NewControlNode("TextLeft", "MLWindow", {
			AnchorPoints = { 0, 0.5, (tSettings.strTagsTextRight and 0.5 or 1), 0.5 },
			AnchorOffsets = { 4, -7, (tSettings.strTagsTextRight and 0 or -4), 7 },
			TextColor = "white",
			Text = "",
			IgnoreMouse = "true",
			Font = "CRB_Pixel_O",
		});

		tXmlData["HealthBar"]:AddChild(tXmlData["TextLeft"]);
	end
end
