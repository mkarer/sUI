--[[

	Module Defaults

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

local tModulePrototype = {
	-- Forms
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
	-- Callback when external addon is fully loaded
	-- Supports only one function at the moment
	tAddonLoadedCallbacks = {},
	RegisterAddonLoadedCallback = function(self, name, callback)
		if (S:IsAddOnLoaded(name)) then
			self[callback](self);
		else
			self.tAddonLoadedCallbacks[name] = callback;
			self:RegisterMessage("ADDON_LOADED", "CheckAddonLoadedCallback");
		end
	end,
	DoAddonLoadedCallback = function(self, name)
		if (self.tAddonLoadedCallbacks[name]) then
			self[self.tAddonLoadedCallbacks[name]](self);
			self.tAddonLoadedCallbacks[name] = nil;
		end
	end,
	CheckAddonLoadedCallback = function(self, message, name)
		if (self.tAddonLoadedCallbacks[name]) then
			self:DoAddonLoadedCallback(name);
		end
	end,
};

S:SetDefaultModulePrototype(tModulePrototype);
