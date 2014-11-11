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

local function EnableModule(self)
	local bEnabled = self:__Enable();
	if (not bEnabled and self.OverrideGeminiAddonStatus and self.EnabledState and self.OnEnable) then
		bEnabled = self:OnEnable();
	end

	return bEnabled;
end

-----------------------------------------------------------------------------
-- User Settings/Profile
-----------------------------------------------------------------------------

local function InitializeProfile(self)
	local strModuleName = self:GetName();
	local eLevel = GameLib.CodeEnumAddonSaveLevel.Character;

	-- initialize settings table
	if (not S.DB.Modules[strModuleName]) then
		S.Log:debug("There are no default settings for %s, you should consider adding some to avoid errors.", strModuleName);
		S.DB.Modules[strModuleName] = {};
	end

	if (S.bVariablesLoaded) then
		-- user settings available, apply them
		if (not S.Profile[eLevel][strModuleName]) then
			-- user settings table doesn't exit
			S.Profile[eLevel][strModuleName] = {};
		end

		-- replace module DB
		self.DB = S.Profile[eLevel][strModuleName];

		-- apply metatable so we can get default values for nonexisting keys
		setmetatable(self.DB, {
			__index = function(t, k) 
				return rawget(t, k) or S.DB.Modules[strModuleName][k];
			end
		});
	else
		-- settings not available yet, use defaults
		-- modules should take care of not replacing any of them
		self.DB = S.DB.Modules[strModuleName];
	end

	-- disable module if it can be enabled/disabled by the user and load it when settings are availabe
	if (S.DB.Modules[strModuleName].bEnabled ~= nil) then
		if (S.bVariablesLoaded) then
			-- enable/disable according to user setting
			self:SetEnabledState(self.DB.bEnabled);
		else
			-- disable, wait until settings are available to decide
			self:SetEnabledState(false);
		end
	end
end

local function OnVariablesLoaded(self, event, eLevel)
	if (eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then
		-- I ONLY use a limited amount of character based settings!
		-- Everything else is hardcoded or can be configured by chaning the Defaults.lua
		self:InitializeProfile();

		-- Callback
		if (self.RestoreProfile) then
			self:RestoreProfile();
		end
	end
end

local function EnableProfile(self)
	if (self.Parent and self.Parent ~= S) then
		-- only root modules have settings
		S.Log:debug("Sorry, cannot enable user profile for %s, submodules don't have settings.", self:GetName());
		return;
	end

	self:InitializeProfile();

	if (not S.bVariablesLoaded) then
		self:RegisterEvent("Sezz_VariablesLoaded", "OnVariablesLoaded");
	end
end

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
	InitializeProfile = InitializeProfile,
	EnableProfile = EnableProfile,
	OnVariablesLoaded = OnVariablesLoaded,
	-- Submodules
	EnableSubmodules = function(self)
		S.Log:debug("Enabling %s submodules...", self:GetName());

		for name, module in self:IterateModules() do
			S.Log:debug("Enabling %s submodule: %s", self:GetName(), name);
			module:Enable();
		end
	end,
	DisableSubmodules = function(self)
		S.Log:debug("Disabling %s submodules...", self:GetName());

		for name, module in self:IterateModules() do
			S.Log:debug("Disabling %s submodule: %s", self:GetName(), name);
			module:Disable();
		end
	end,
	CreateSubmodule = function(self, name, ...)
		local module = self:NewModule(name, "Gemini:Event-1.0", ...);
		module.InitializeForms = self.InitializeForms;
		module.EnableSubmodules = self.EnableSubmodules;
		module.DisableSubmodules = self.DisableSubmodules;
		module.__Enable = module.Enable;
		module.Enable = EnableModule;

		return module;
	end,
};

function S:CreateSubmodule(name, ...)
	-- SetDefaultModulePrototype doesn't work as expected or I'm doing it wrong.
	local module = self:NewModule(name, S:Clone(tModulePrototype), "Gemini:Event-1.0", ...);
	return module;
end
