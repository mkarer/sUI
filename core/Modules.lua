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
		if (not strModulePath) then
			local debugInfo = debug.getinfo(2);
			local caller = string.gsub(debugInfo.short_src, "\\", "/");
			local pathRootIndex = caller:find("Addons/sUI/") + 11;
			local dir, file, ext = string.match(caller:sub(pathRootIndex), "(.-)([^/]-([^%.]+))$");
			strModulePath = dir:sub(1, -2);
		end

		self.xmlDoc = XmlDoc.CreateFromFile(strModulePath.."/"..self:GetName()..".xml");
	end,
};

S:SetDefaultModulePrototype(modulePrototype);
