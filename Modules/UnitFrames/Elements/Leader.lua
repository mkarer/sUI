--[[

	s:UI Unit Frame Layout Generation: Leader/Assistant Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateLeaderElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bLeaderEnabled) then return; end

	-- Create Container
	local tRole = {
		Name = "Role",
		AnchorPoints = tSettings.tLeaderAnchorPoints,
		AnchorOffsets = tSettings.tLeaderAnchorOffsets,
		IgnoreMouse = true,
		Picture = true,
		BGColor = "ffffffff",
		NoClip = true,
		UserData = {
			Element = "Leader",
		},
	};

	tinsert(tSettings.tElements["HealthBar"].Children, tRole);
	tSettings.tElements["Leader"] = tRole;
end
