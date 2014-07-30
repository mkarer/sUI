--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AuctionHouse", "Gemini:Hook-1.0");
local log;
local AccountItemLib = AccountItemLib;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:EnableProfile();

	self.MarketplaceAuction = Apollo.GetAddon("MarketplaceAuction");
	self.ItemPreviewImproved = Apollo.GetAddon("ItemPreviewImproved");
	self.GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;

	if (not self.MarketplaceAuction) then
		self:SetEnabledState(false);
		return;
	end

	if (self.MarketplaceAuction and not self.MarketplaceAuction._OnToggleAuctionWindow) then
		self.MarketplaceAuction._OnToggleAuctionWindow = self.MarketplaceAuction.OnToggleAuctionWindow;
		self.MarketplaceAuction.OnToggleAuctionWindow = function(tMarketplaceAuction)
			tMarketplaceAuction:_OnToggleAuctionWindow();
			self:Open();
		end
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self.SearchLib = Apollo.GetPackage("Sezz:AuctionHouse:Search-0.1").tPackage;
	self.ContextMenu = Apollo.GetPackage("Sezz:Controls:ContextMenu-0.1").tPackage;

--	self:RegisterEvent("ToggleAuctionWindow", "Open");
	self:RegisterEvent("AuctionWindowClose", "Close");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------

function M:Open()
	if (AccountItemLib.CodeEnumEntitlement.EconomyParticipation and AccountItemLib.GetEntitlementCount(AccountItemLib.CodeEnumEntitlement.EconomyParticipation) == 0) then
		Event_FireGenericEvent("GenericEvent_SystemChannelMessage", Apollo.GetString("CRB_FeatureDisabledForGuests"));
		return;
	end

	if (not self.wndMain or not self.wndMain:IsValid()) then
		self.tSearch = self.SearchLib:New();
		self:SetSortOrder("Name", "ASC");
		self:CreateWindow();
		self:RegisterEvent("ItemAuctionBidResult", "OnItemAuctionBidResult");
		self:RegisterEvent("ItemAuctionWon", "OnItemAuctionWon");
		self:RegisterEvent("VarChange_FrameCount", "GridVisibleItemsCheck");
		self:RegisterEvent("Sezz_AuctionHouse_SearchCompleted", "OnSearchCompleted");
		self.wndMain:Show(true);

		-- Hide Carbine AH
		self.MarketplaceAuction.wndMain:Show(false, true);
		Apollo.RemoveEventHandler("ItemAuctionWon", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("ItemAuctionOutbid", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("ItemAuctionExpired", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("ItemAuctionSearchResults", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("PostItemAuctionResult", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("ItemAuctionBidResult", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("ItemCancelResult", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("UpdateInventory", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("PlayerCurrencyChanged", self.MarketplaceAuction);
		Apollo.RemoveEventHandler("OwnedItemAuctions", self.MarketplaceAuction);
	end
end

function M:Close()
	Event_CancelAuctionhouse();
	self:UnregisterEvent("ItemAuctionBidResult");
	self:UnregisterEvent("ItemAuctionWon");
	self:UnregisterEvent("VarChange_FrameCount");
	self:UnregisterEvent("Sezz_AuctionHouse_SearchCompleted");

	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	self.tSearch = nil;
	self.wndMain = nil;
	self.wndSearch = nil;
	self.wndFilters = nil;
	self.wndResults = nil;
	self.wndResultsGrid = nil;
	self.wndCurrentItem = nil;
	self.wndSelectedItem = nil;
	self.tFilter = nil;
	self.tSelectedCategory = nil;
	self.nSelectedFamily = nil;
	self.tAuctions = nil;
	self.bIsSearching = false;
	self.strSortHeader = nil;
	self.strSortDirection = nil;
	self.bFilterChanged = nil;
	self.tHeaders = nil;
	self.strSelectedShoppingList = nil;
end

-----------------------------------------------------------------------------

function M:OnItemAuctionWon(event, aucCurr)
	local bValidItem = aucCurr and aucCurr:GetItem();
	local strItemName = bValidItem and aucCurr:GetItem():GetName() or "";
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", String_GetWeaselString(Apollo.GetString("MarketplaceAuction_WonMessage"), strItemName));

	if ((self.wndSelectedItem and self.wndSelectedItem:GetData() and self.wndSelectedItem:GetData() == aucCurr) or self:IsAuctionVisible(aucCurr)) then
		self:RemoveAuction(aucCurr);
	end
end

function M:OnItemAuctionBidResult(event, eAuctionBidResult, aucCurr)
	local bResultOk = (eAuctionBidResult == MarketplaceLib.AuctionPostResult.Ok);
	local strMessage = bResultOk and String_GetWeaselString(Apollo.GetString("MarketplaceAuction_BidAccepted"), aucCurr:GetItem():GetName()) or "Error MarketplaceLib.AuctionPostResult: "..eAuctionBidResult;
	Print(strMessage);

	if (bResultOk or eAuctionBidResult == MarketplaceLib.AuctionPostResult.NotFound) then
		if ((self.wndSelectedItem and self.wndSelectedItem:GetData() and self.wndSelectedItem:GetData() == aucCurr) or self:IsAuctionVisible(aucCurr)) then
			self:ClearSelection();
			self:UpdateAuction(aucCurr, bResultOk);
--			self:RefreshResults();
		end
	end
end
