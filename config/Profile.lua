--[[

  s:UI User Profile

  Martin Karer / Sezz, 2014
  http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

S.Profile = {
	[GameLib.CodeEnumAddonSaveLevel.Account] = {},
	[GameLib.CodeEnumAddonSaveLevel.Character] = {},
};

function S:OnSave(eLevel)
	if (S.Profile[eLevel]) then
		return S.Profile[eLevel];
	end
end

function S:OnRestore(eLevel, tSavedData)
	if (S.Profile[eLevel]) then
		S.Profile[eLevel] = tSavedData or {};

		S.Log:debug("VARIABLES_LOADED "..eLevel);
		self:SendMessage("VARIABLES_LOADED", eLevel);
	end
end
