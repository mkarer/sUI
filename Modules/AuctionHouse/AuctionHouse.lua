--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AuctionHouse", "Gemini:Hook-1.0");
local log, MarketplaceAuction;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	self.MarketplaceAuction = Apollo.GetAddon("MarketplaceAuction");
	self.ItemPreviewImproved = Apollo.GetAddon("ItemPreviewImproved");
	self.GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;

	if (not self.MarketplaceAuction) then
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	if (not self.MarketplaceAuction._OnToggleAuctionWindow) then
		self.MarketplaceAuction._OnToggleAuctionWindow = self.MarketplaceAuction.OnToggleAuctionWindow;
		self.MarketplaceAuction.OnToggleAuctionWindow = function(tMarketplaceAuction)
			tMarketplaceAuction:_OnToggleAuctionWindow();
			self:Open();
		end
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------

function M:Open()
	if (not self.wndMain or not self.wndMain:IsValid()) then
		self:CreateWindow();
		self:RegisterEvent("ItemAuctionSearchResults", "OnItemAuctionSearchResults");
		self.wndMain:Show(true);
		self:SetSortOrder("Name", "ASC");
	end
end

function M:Close()
	self:UnregisterEvent("ItemAuctionSearchResults");

	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	self.tFilter = nil;
	self.tSelectedCategory = nil;
	self.nSelectedFamily = nil;
	self.tAuctions = nil;
	self.bIsSearching = false;
	self.strSortHeader = nil;
	self.strSortDirection = nil;
	self.fnSortResults = nil;
	self.bFilterChanged = nil;
end
