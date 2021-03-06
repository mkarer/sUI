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
	if (self.Profile[eLevel]) then
		return self.Profile[eLevel];
	end
end

function S:OnRestore(eLevel, tSavedData)
	if (self.Profile[eLevel]) then
		self.Profile[eLevel] = tSavedData or {};
		self.bVariablesLoaded = true;
		self:RaiseEvent("Sezz_VariablesLoaded", eLevel);
	end
end
