--[[

	s:UI Bag Opener

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AutomationCore = S:GetModule("AutomationCore");
local M = AutomationCore:CreateSubmodule("vendor");
local log;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self:RegisterEvent("InvokeVendorWindow", "OpenBags");
	self:RegisterEvent("ShowBank", "OpenBags");
	self:RegisterEvent("GuildBankerOpen", "OpenBags");
	self:RegisterEvent("CloseVendorWindow", "CloseBags");
	self:RegisterEvent("HideBank", "CloseBags");
	self:RegisterEvent("GuildBankerClose", "CloseBags");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());

	self:UnregisterEvent("InvokeVendorWindow");
	self:UnregisterEvent("ShowBank");
	self:UnregisterEvent("GuildBankerOpen");
	self:UnregisterEvent("CloseVendorWindow");
	self:UnregisterEvent("HideBank");
	self:UnregisterEvent("GuildBankerClose");
end

function M:OpenBags()
	local wndBags = Apollo.FindWindowByName("InventoryBag") or Apollo.FindWindowByName("SpaceStashInventoryForm");
	if (wndBags and not wndBags:IsShown()) then
		Event_FireGenericEvent("ToggleInventory");
	end
end

function M:CloseBags()
	local wndBags = Apollo.FindWindowByName("InventoryBag") or Apollo.FindWindowByName("SpaceStashInventoryForm");
	if (wndBags and wndBags:IsShown()) then
		Event_FireGenericEvent("ToggleInventory");
	end
end
