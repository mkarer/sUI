--[[

	s:UI Core Events & Messages

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------
-- External Addon Load Event
-----------------------------------------------------------------------------

local tAddonLoadingInformation = {
	InterfaceMenuList = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "tMenuAlerts", "tMenuData", "tPinnedAddons" },
	},
};

function S:CheckExternalAddon(name)
	if (type(name) == "table") then
		-- Try to identify the addon
		local caller = name;

		for id, config in pairs(tAddonLoadingInformation) do
			if (config.properties and #config.properties > 0) then
				local found = true;
				for _, property in pairs(config.properties) do
					found = found and caller[property] ~= nil;
				end

				if (found) then
					self:CheckExternalAddon(id);
					return;
				end
			end
		end

		return;
	end

	-- Check Addon
	local config = tAddonLoadingInformation[name];
	if (config) then
		local addon = Apollo.GetAddon(name);
		if (not addon) then
			-- Addon won't be loaded, remove from list
			tAddonLoadingInformation[name] = nil;
		else
			-- Unhook
			self:Unhook(addon, config.hook);

			-- Addon available
			if (addon[config.window]) then
				-- Main window exists, addon is initialized + enabled!
				tAddonLoadingInformation[name] = nil;
				S.Log:debug("ADDON_LOADED "..name);
				self:SendMessage("ADDON_LOADED", name);
			else
				-- Main window doesn't exist yet, hook creation
				self:PostHook(addon, config.hook, "CheckExternalAddon");
			end
		end
	end
end

function S:CheckExternalAddons()
	for name in pairs(tAddonLoadingInformation) do
		self:CheckExternalAddon(name);
	end
end

function S:IsAddOnLoaded(name)
	local config = tAddonLoadingInformation[name];
	if (config) then
		local addon = Apollo.GetAddon(name);
		return addon and addon[config.window];
	else
		S.Log:warn("Addon %s is not supported by IsAddOnLoaded()", name);
		return Apollo.GetAddon(name) and true;
	end
end
