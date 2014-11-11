--[[

	s:UI Unit Frame Layout Generation: Role Element

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

function UnitFramesLayout:CreateRoleElement(strUnit)
	local tSettings = self.tSettings[strUnit];
	if (not tSettings.bRoleEnabled) then return; end

	-- Create Container
	local tRole = {
		Name = "Role",
		AnchorPoints = tSettings.tRoleAnchorPoints,
		AnchorOffsets = tSettings.tRoleAnchorOffsets,
		IgnoreMouse = true,
		Picture = true,
		BGColor = "ffffffff",
		NoClip = true,
		UserData = {
			Element = "Role",
		},
	};

	tinsert(tSettings.tElements["HealthBar"].Children, tRole);
	tSettings.tElements["Role"] = tRole;
end
