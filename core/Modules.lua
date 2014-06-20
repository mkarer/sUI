--[[

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	Module Defaults

--]]

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

local modulePrototype = {
	InitializeForms = function(self, strModulePath)
		self.xmlDoc = XmlDoc.CreateFromFile(strModulePath.."/"..self:GetName()..".xml");
	end,
};

S:SetDefaultModulePrototype(modulePrototype);
