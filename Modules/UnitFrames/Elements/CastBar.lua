--[[

	s:UI Unit Frame Layout Generation: Cast Bar Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateCastBarElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	local tXmlData = self.tSettings[strUnit].tXmlData;

	if (not tSettings.bCastBarEnabled) then
		return;
	end

	-------------------------------------------------------------------------

	local nHeight = tSettings.tCastBarAnchorOffsets[4] - tSettings.tCastBarAnchorOffsets[2]; -- Icon Size

	-------------------------------------------------------------------------
	-- Element Container (White BG)
	-------------------------------------------------------------------------

	tXmlData["CastBarContainer"] = self.xmlDoc:NewFormNode(self:GetUnitFramePrefix(strUnit).."CastBar", {
		AnchorPoints = tSettings.tCastBarAnchorPoints,
		AnchorOffsets = tSettings.tCastBarAnchorOffsets,
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "33ffffff",
		Moveable = true,
	});

	-------------------------------------------------------------------------
	-- Icon + Container (Black BG)
	-------------------------------------------------------------------------

	tXmlData["CastBarIconBG"] = self.xmlDoc:NewControlNode("IconBackground", "Window", {
		AnchorPoints = { 0, 0, 0, 1 },
		AnchorOffsets = { 2, 2, nHeight, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
	});

	tXmlData["CastBarIcon"] = self.xmlDoc:NewControlNode("Icon", "Window", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		Picture = true,
		Sprite = "",
		IgnoreMouse = "true",
	});

	tXmlData["CastBarContainer"]:AddChild(tXmlData["CastBarIconBG"]);
	tXmlData["CastBarIconBG"]:AddChild(tXmlData["CastBarIcon"]);

	-------------------------------------------------------------------------
	-- Bar + Container (Black BG)
	-------------------------------------------------------------------------

	tXmlData["CastBarBG"] = self.xmlDoc:NewControlNode("Background", "Window", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { nHeight + 2, 2, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
	});

	tXmlData["CastBar"] = self.xmlDoc:NewControlNode("Progress", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = self.tUnitFrameController:ColorArrayToHex(self.tColors.Castbar.Normal),
	});

	tXmlData["CastBarContainer"]:AddChild(tXmlData["CastBarBG"]);
	tXmlData["CastBarBG"]:AddChild(tXmlData["CastBar"]);

	-------------------------------------------------------------------------
	-- Text Elements
	-------------------------------------------------------------------------

	tXmlData["CastBarTextLeft"] = self.xmlDoc:NewControlNode("Text", "Window", {
		AnchorPoints = { 0, 0, 0.75, 1 },
		AnchorOffsets = { 4, -2, 0, 0 },
		TextColor = "white",
		DT_VCENTER = true,
		Text = "",
		IgnoreMouse = "true",
		Font = "CRB_Pixel_O",
	});

	tXmlData["CastBarTextRight"] = self.xmlDoc:NewControlNode("Time", "Window", {
		AnchorPoints = { 0.75, 0, 1, 1 },
		AnchorOffsets = { 0, -2, -4, 0 },
		TextColor = "white",
		DT_VCENTER = true,
		DT_RIGHT = true,
		Text = "",
		IgnoreMouse = "true",
		Font = "CRB_Pixel_O",
	});

	tXmlData["CastBar"]:AddChild(tXmlData["CastBarTextLeft"]);
	tXmlData["CastBar"]:AddChild(tXmlData["CastBarTextRight"]);

	-------------------------------------------------------------------------
	-- Add as Root Element
	-------------------------------------------------------------------------

	self.xmlDoc:GetRoot():AddChild(tXmlData["CastBarContainer"]);
end
