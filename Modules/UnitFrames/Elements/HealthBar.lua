--[[

	s:UI Unit Frame Layout Generation: Health Bar/Text Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateHealthBarElement(strUnit, tSettings)
	local tColors = self.tUnitFrameController.tColors;

	-------------------------------------------------------------------------
	-- Health Bar
	-------------------------------------------------------------------------

	local tHealth = {
		Name = "Health",
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 2, 2, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
		UserData = {
			Element = "Health",
		},
		Children = {
			{
				Class = "ProgressBar",
				Name = "HealthBar",
				AnchorPoints = { 0, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				AutoSetText = false,
				UseValues = true,
				SetTextToProgress = false,
				ProgressFull = "sUI:ProgressBar",
				IgnoreMouse = "true",
				BarColor = self.tUnitFrameController:RGBColorToHex(tColors.HealthSmooth[1], tColors.HealthSmooth[2], tColors.HealthSmooth[3]),
				UserData = {
					Element = "HealthBar",
				},
				Children = {},
			},
		},
	};

	tinsert(tSettings.tElements["Main"].Children, tHealth);
	tSettings.tElements["Health"] = tHealth;
	tSettings.tElements["HealthBar"] = tHealth.Children[1];

	-------------------------------------------------------------------------
	-- Right Text Element
	-------------------------------------------------------------------------

	if (tSettings.strTagsTextRight) then
		local tTextRight = {
			Class = "MLWindow",
			Name = "HealthTextRight",
			AnchorPoints = { 0, 0.5, 1, 0.5 },
			AnchorOffsets = { 4, -7, -4, 7 },
			TextColor = "white",
			IgnoreMouse = "true",
			Font = "CRB_Pixel_O",
			UserData = {
				Element = "Text",
				Tags = tSettings.strTagsTextRight,
				Align = "Right",
			},
		};

		tinsert(tSettings.tElements["HealthBar"].Children, tTextRight);
	end

	-------------------------------------------------------------------------
	-- Left Text Element
	-------------------------------------------------------------------------

	if (tSettings.strTagsTextLeft) then
		local tTextLeft = {
			Class = "MLWindow",
			Name = "HealthTextLeft",
			AnchorPoints = { 0, 0.5, 1, 0.5 },
			AnchorOffsets = { 4, -7, -4, 7 },
			TextColor = "white",
			IgnoreMouse = "true",
			Font = "CRB_Pixel_O",
			UserData = {
				Element = "Text",
				Tags = tSettings.strTagsTextLeft,
			},
		};

		tinsert(tSettings.tElements["HealthBar"].Children, tTextLeft);
	end
end
