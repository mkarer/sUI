--[[

	s:UI Unit Frame Layout Generation: Cast Bar Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateCastBarElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bCastBarEnabled) then return; end

	local tColors = self.tUnitFrameController.tColors;
	local nHeight = tSettings.tCastBarAnchorOffsets[4] - tSettings.tCastBarAnchorOffsets[2] - 2; -- Icon Size

	-------------------------------------------------------------------------
	-- Element Container (White BG)
	-------------------------------------------------------------------------

	local tCastBar = {
		Name = "CastBarContainer",
		AnchorPoints = tSettings.tCastBarAnchorPoints,
		AnchorOffsets = tSettings.tCastBarAnchorOffsets,
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "33ffffff",
		IgnoreMouse = true,
		NoClip = true,
		Children = {},
		UserData = {
			Element = "CastBarContainer",
		},
	};

	tinsert(tSettings.tElements["Main"].Children, tCastBar);

	-------------------------------------------------------------------------
	-- Icon + Container (Black BG)
	-------------------------------------------------------------------------

	tinsert(tCastBar.Children, {
		AnchorPoints = { 0, 0, 0, 1 },
		AnchorOffsets = { 2, 2, nHeight, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
		Children = {
			{
				Name = "CastBarIcon",
				AnchorPoints = { 0, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Picture = true,
				Sprite = "",
				IgnoreMouse = "true",
				UserData = {
					Element = "CastBarIcon",
				},
			},
		},
	});

	tSettings.tElements["CastBarIcon"] = tCastBar.Children[#tCastBar.Children].Children[1];

	-------------------------------------------------------------------------
	-- Bar + Container (Black BG)
	-------------------------------------------------------------------------

	tinsert(tCastBar.Children, {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { nHeight + 2, 2, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
		Children = {
			{
				Class = "ProgressBar",
				Name = "CastBar",
				AnchorPoints = { 0, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				AutoSetText = false,
				UseValues = true,
				SetTextToProgress = false,
				ProgressFull = "sUI:ProgressBar",
				IgnoreMouse = "true",
				BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.CastBar.Normal),
				Children = {},
				UserData = {
					Element = "CastBar",
				},
			},
		},
	});

	tSettings.tElements["CastBar"] = tCastBar.Children[#tCastBar.Children].Children[1];

	-------------------------------------------------------------------------
	-- Text Elements
	-------------------------------------------------------------------------

	tinsert(tSettings.tElements["CastBar"].Children, {
		Name = "CastBarTextSpell",
		AnchorPoints = { 0, 0, 0.75, 1 },
		AnchorOffsets = { 4, -2, 0, 0 },
		TextColor = "white",
		DT_VCENTER = true,
		Text = "",
		IgnoreMouse = "true",
		Font = "CRB_Pixel_O",
		UserData = {
			Element = "CastBarTextSpell",
		},
	});

	tinsert(tSettings.tElements["CastBar"].Children, {
		Name = "CastBarTextDuration",
		AnchorPoints = { 0.75, 0, 1, 1 },
		AnchorOffsets = { 0, -2, -4, 0 },
		TextColor = "white",
		DT_VCENTER = true,
		DT_RIGHT = true,
		Text = "",
		IgnoreMouse = "true",
		Font = "CRB_Pixel_O",
		UserData = {
			Element = "CastBarTextDuration",
		},
	});
end
