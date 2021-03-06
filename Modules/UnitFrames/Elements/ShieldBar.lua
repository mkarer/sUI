--[[

	s:UI Unit Frame Layout Generation: Shield Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateShieldBarElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bShieldBarEnabled) then return; end

	local tColors = self.tUnitFrameController.tColors;

	-- Shield Bar
	local tShieldBar = {
		Class = "ProgressBar",
		Name = "ShieldBar",
		AnchorPoints = { 0, 0, 1, 0 },
		AnchorOffsets = { 0, 0, 0, tSettings.nShieldBarHeight },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = self.tUnitFrameController:ColorArrayToHex(tColors.Shield),
		UserData = {
			Element = "ShieldBar",
		},
	};

	tinsert(tSettings.tElements["HealthBar"].Children, tShieldBar);
	tSettings.tElements["ShieldBar"] = tShieldBar;
end
