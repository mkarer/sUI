--[[

	s:UI Core Events & Messages

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:RaiseEvent(event, ...)
	local strArguments = "";
	local tArguments = {...};
	if (#tArguments > 0) then
		for _, arg in pairs(tArguments) do
			strArguments = strArguments.." "..tostring(arg);
		end
	end

	S.Log:debug("[Event] %s%s", event, strArguments);
	Event_FireGenericEvent(event, ...);
end

-----------------------------------------------------------------------------
-- External Addon Load Event
-----------------------------------------------------------------------------

local tAddonLoadingInformation = {
	InterfaceMenuList = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "tMenuAlerts", "tMenuData", "tPinnedAddons" },
	},
	XPBar = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "wndXPLevel", "bOnRedrawCooldown" },
	},
	MiniMap = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "arResourceNodes", "tMinimapMarkerInfo" },
	},
	ChatLog = {
		window = "wndChatOptions",
		hook = "OnWindowManagementReady",
		properties = { "arChatColor", "tChatWindows" },
	},
	Datachron = {
		window = "wndMinimized",
		hook = "OnDocumentReady",
		properties = { "tListOfDeniedCalls", "ProcessDatachronState" },
	},
	Inventory = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "tBagCounts", "OnBGBottomCashBtnToggle" },
	},
	QuestTracker = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "bQuestTrackerByDistance", "tQuestsQueuedForDestroy" },
	},
	FloatTextPanel = {
		window = "wndHintArrowDistance",
		hook = "OnHintArrowDistanceUpdate", -- Can't use OnDocumentReady because of LibApolloFixes
		properties = { "OnHintArrowDistanceUpdate", "OnAdvanceErrorTimer" },
	},
	SprintMeter = {
		window = "wndMain",
		hook = "OnDocumentReady",
		properties = { "OnSprintMeterGracePeriod" },
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
			-- Uknown Addon
--			tAddonLoadingInformation[name] = nil;
		else
			-- Unhook
			self:Unhook(addon, config.hook);

			-- Addon available
			if (addon[config.window]) then
				-- Main window exists, addon is initialized + enabled!
				self:RaiseEvent("Sezz_AddonAvailable", name, addon);
			else
				-- Main window doesn't exist yet, hook creation
				self:PostHook(addon, config.hook, "CheckExternalAddon");
			end
		end
	end
end

function S:CheckExternalAddons()
	Apollo.RegisterEventHandler("ObscuredAddonVisible", "CheckExternalAddon", self);

	for name in pairs(tAddonLoadingInformation) do
		self:CheckExternalAddon(name);
	end
end

function S:IsAddOnLoaded(name)
	local config = tAddonLoadingInformation[name];
	if (config) then
		local addon = Apollo.GetAddon(name);
		return (addon and addon[config.window]) and true or false;
	else
		S.Log:warn("Addon %s is not supported by IsAddOnLoaded()", name);
		return Apollo.GetAddon(name) and true or false;
	end
end
