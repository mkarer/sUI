--[[

	s:UI Unit Frame Layout Generation: Power Bar Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreatePowerBarElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bPowerBarEnabled) then return; end

	-- Resize Health Bar
	local tHealthOffsets = tSettings.tElements["Health"].AnchorOffsets;
	tHealthOffsets[4] = tHealthOffsets[4] - tSettings.nPowerBarHeight - tSettings.nBarSpacing;

	-- Experience Bar Offset
	local nOffsetY = 0;
	if (strUnit == "Player" and tSettings.bExperienceBarEnabled) then
		nOffsetY = tSettings.nExperienceBarHeight + tSettings.nBarSpacing;
	end

	-- Add Power Bar
	tinsert(tSettings.tElements["Main"].Children, {
		Name = "Power",
		AnchorPoints = { 0, 1, 1, 1 },
		AnchorOffsets = { 2, -4 - nOffsetY, -2, -2 - nOffsetY },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
		TooltipType = "OnCursor",
		Children = {
			{
				-- Power Bar
				Class = "ProgressBar",
				Name = "PowerBar",
				AnchorPoints = { 0, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				AutoSetText = false,
				UseValues = true,
				SetTextToProgress = false,
				ProgressFull = "sUI:ProgressBar",
				IgnoreMouse = "true",
				UserData = {
					Element = "PowerBar",
				},
			},
		},
	});
end
