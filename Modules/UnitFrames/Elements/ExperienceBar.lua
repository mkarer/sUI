--[[

	s:UI Unit Frame Layout Generation: Experience Bar Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateExperienceBarElement(strUnit, tSettings)
	if (strUnit ~= "Player" or not tSettings.bExperienceBarEnabled) then return; end

	local tColors = self.tUnitFrameController.tColors;

	-- Resize Health Bar
	local tHealthOffsets = tSettings.tElements["Health"].AnchorOffsets;
	tHealthOffsets[4] = tHealthOffsets[4] - tSettings.nExperienceBarHeight - tSettings.nBarSpacing;

	-- Add Experience Bar
	tinsert(tSettings.tElements["Main"].Children, {
		Name = "Experience",
		AnchorPoints = { 0, 1, 1, 1 },
		AnchorOffsets = { 2, -4, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
		TooltipType = "OnCursor",
		Children = {
			{
				-- Experience Bar
				Class = "ProgressBar",
				Name = "ExperienceBarRested",
				AnchorPoints = { 0, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				AutoSetText = false,
				UseValues = true,
				SetTextToProgress = false,
				ProgressFull = "sUI:ProgressBar",
				IgnoreMouse = "true",
				BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.Experience.Normal),
				UserData = {
					Element = "ExperienceBarRested",
				},
			},
			{
				-- Rested Experience Bar
				Class = "ProgressBar",
				Name = "ExperienceBar",
				AnchorPoints = { 0, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				AutoSetText = false,
				UseValues = true,
				SetTextToProgress = false,
				ProgressFull = "sUI:ProgressBar",
				IgnoreMouse = "true",
				BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.Experience.Rested),
				UserData = {
					Element = "ExperienceBar",
				},
			},
		},
	});
end
