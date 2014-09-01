--[[

	s:UI Unit Frame Layout Generation: Threat Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateThreatBarElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bThreatBarEnabled) then return; end

	local tColors = self.tUnitFrameController.tColors;

	-- Threat Bar
	local tThreatBar = {
		Class = "ProgressBar",
		Name = "ThreatBar",
		AnchorPoints = { 0, 0, 1, 0 },
		AnchorOffsets = { 0, 0, 0, tSettings.nThreatBarHeight },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		UserData = {
			Element = "ThreatBar",
		},
	};

	tinsert(tSettings.tElements["HealthBar"].Children, tThreatBar);
	tSettings.tElements["ThreatBar"] = tThreatBar;
end
