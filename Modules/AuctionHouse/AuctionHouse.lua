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
			self:ToggleWindow();
		end
	end

	self:RegisterEvent("ItemAuctionSearchResults", "OnItemAuctionSearchResults");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
