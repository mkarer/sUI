--[[

	s:UI Module Defaults

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
		if (self.tAddonLoadedCallbacks[name] and self[self.tAddonLoadedCallbacks[name]]) then
			self[self.tAddonLoadedCallbacks[name]](self);
			self.tAddonLoadedCallbacks[name] = nil;
		end
	end,
	CheckAddonLoadedCallback = function(self, message, name)
		if (self.tAddonLoadedCallbacks[name]) then
			self:DoAddonLoadedCallback(name);
		end
	end,
	-- Settings
	InitializeProfile = function(self)
		local strModuleName = self:GetName();
		local eLevel = GameLib.CodeEnumAddonSaveLevel.Character;
		if (not S.Profile[eLevel][strModuleName]) then
			S.Profile[eLevel][strModuleName] = {};
		end

		self.P = S.Profile[eLevel][strModuleName];
	end,
	EnableProfile = function(self)
		self:InitializeProfile();
		self:RegisterMessage("VARIABLES_LOADED");
	end,
	VARIABLES_LOADED = function(self, message, eLevel)
		if (eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then
			-- I ONLY use a limited amount of character based settings!
			-- Everything else is hardcoded or can be configured by chaning the Default.lua
			-- TODO: Intelligent metatable like in s:UI in World of Warcraft
			self:InitializeProfile();

			-- Callback
			if (self.RestoreProfile) then
				self:RestoreProfile();
			end
		end
	end,
	-- Submodules
	EnableSubmodules = function(self)
		S.Log:debug("Enabling %s submodules...", self:GetName());

		for name, module in self:IterateModules() do
			S.Log:debug("Enabling %s submodule: %s", self:GetName(), name);
			module:Enable();
		end
	end,
};

S:SetDefaultModulePrototype(tModulePrototype);
