--[[

	s:UI Module Defaults

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------
-- Main Modules
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
		if (self.OnDocumentReady) then
			self.xmlDoc:RegisterCallback("OnDocumentReady", self);
		end
	end,
	-- Callback when external addon is fully loaded
	-- Supports only one function at the moment
	tAddonLoadedCallbacks = {},
	RegisterAddonLoadedCallback = function(self, name, callback)
		if (S:IsAddOnLoaded(name)) then
			self[callback](self);
		else
			self.tAddonLoadedCallbacks[name] = callback;
			self:RegisterEvent("Sezz_AddonAvailable", "CheckAddonLoadedCallback");
		end
	end,
	DoAddonLoadedCallback = function(self, name)
		if (self.tAddonLoadedCallbacks[name]) then
			self[self.tAddonLoadedCallbacks[name]](self);
			self.tAddonLoadedCallbacks[name] = nil;
		end
	end,
	CheckAddonLoadedCallback = function(self, event, name)
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
		self:RegisterEvent("Sezz_VariablesLoaded", "OnVariablesLoaded");
	end,
	OnVariablesLoaded = function(self, event, eLevel)
		if (eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then
			-- I ONLY use a limited amount of character based settings!
			-- Everything else is hardcoded or can be configured by chaning the Default.lua
			-- TODO: Intelligent metatable like in s:UI in World of Warcraft
			self:InitializeProfile();

			-- Callback
			if (self.RestoreProfile) then
				self:RestoreProfile();
			end

			-- TODO: Submodules Callback
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
	CreateSubmodule = function(self, name, ...)
		local module = self:NewModule(name, "Gemini:Event-1.0", ...);
		module.InitializeForms = self.InitializeForms;
		module.EnableSubmodules = self.EnableSubmodules;

		return module;
	end,
};

function S:CreateSubmodule(name, ...)
	-- SetDefaultModulePrototype doesn't work as expected or I'm doing it wrong.
	local module = self:NewModule(name, S:Clone(tModulePrototype), "Gemini:Event-1.0", ...);
	return module;
end
