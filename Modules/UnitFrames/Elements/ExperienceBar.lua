--[[

	s:UI Unit Frame Layout Generation: Experience Bar Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateExperienceBarElement(strUnit, tSettings)
	if (strUnit ~= "Player" or not tSettings.bExperienceBarEnabled) then return; end

	local tXmlData = tSettings.tXmlData;
	local tColors = self.tUnitFrameController.tColors;

	-------------------------------------------------------------------------
	-- Bar Background
	-------------------------------------------------------------------------

	-- Resize Health Bar
	local tHealthOffsets = tSettings.tXmlData["HealthBarBG"]:Attribute("AnchorOffsets")
	tHealthOffsets[4] = tHealthOffsets[4] - tSettings.nExperienceBarHeight - tSettings.nBarSpacing;

	-- Add Experience Bar Background
	tXmlData["ExperienceBarBG"] = self.xmlDoc:NewControlNode("Experience", "Window", {
		AnchorPoints = { 0, 1, 1, 1 },
		AnchorOffsets = { 2, -4, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
		TooltipType = "OnCursor",
	});

	tXmlData["Root"]:AddChild(tXmlData["ExperienceBarBG"]);

	-------------------------------------------------------------------------
	-- Rested Experience Bar
	-------------------------------------------------------------------------

	tXmlData["RestedExperienceBar"] = self.xmlDoc:NewControlNode("ProgressRested", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.Experience.Rested),
	});

	tXmlData["ExperienceBarBG"]:AddChild(tXmlData["RestedExperienceBar"]);

	-------------------------------------------------------------------------
	-- Experience Bar
	-------------------------------------------------------------------------

	tXmlData["ExperienceBar"] = self.xmlDoc:NewControlNode("Progress", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.Experience.Normal),
	});

	tXmlData["ExperienceBarBG"]:AddChild(tXmlData["ExperienceBar"]);
end
