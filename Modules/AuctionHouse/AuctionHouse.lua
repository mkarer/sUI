--[[

	s:UI Auction House

	Icons by [Font Awesome](http://fortawesome.github.io) License: [SIL OFL 1.1](http://scripts.sil.org/OFL)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "MarketplaceLib";

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AuctionHouse");
M:SetDefaultModuleState(false);

local log;
local AccountItemLib, MarketplaceLib, Apollo = AccountItemLib, MarketplaceLib, Apollo;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:EnableProfile();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self.MarketplaceAuction = Apollo.GetAddon("MarketplaceAuction");
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

	Apollo.RegisterSlashCommand("ah", "Open", self);
	Apollo.LoadSprites(Apollo.GetAssetFolder().."\\Modules\\AuctionHouse\\Media\\Icons.xml");

	self.ItemPreviewImproved = Apollo.GetAddon("ItemPreviewImproved");
	self.GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
	self.SearchLib = Apollo.GetPackage("Sezz:AuctionHouse:Search-0.1").tPackage;
	self.ContextMenu = Apollo.GetPackage("Sezz:Controls:ContextMenu-0.1").tPackage;
	self.TreeView = Apollo.GetPackage("Sezz:Controls:TreeView-0.1").tPackage;
	self.TabWindow = Apollo.GetPackage("Sezz:Controls:TabWindow-0.1").tPackage;

	-- Temporary AuctionStats Support
	self.AuctionStats = Apollo.GetAddon("AuctionStats");
	if (self.AuctionStats) then
		self.AuctionStats.ma = self;

		self.AuctionStats._ScanNextFamily = self.AuctionStats.ScanNextFamily;
		self.AuctionStats.ScanNextFamily = function(self)
			self:_ScanNextFamily();

			if (not self.tFamilies[self.nCurrFamilyId + 1]) then
				self.ma.wndMain:FindChild("BtnSearch"):SetText(Apollo.GetString("CRB_Search")); -- TODO: i18n Table
				self.ma:SetSearchState(false);
				self.ma.P.LastAuctionStatsScan = os.time();
			end
		end
	end

--	self:RegisterEvent("ToggleAuctionWindow", "Open");
	self:RegisterEvent("AuctionWindowClose", "Close");
end

function M:OnDisable()
	self:DisableSubmodules();
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
		self:EnableSubmodules();
		self:RegisterEvent("ItemAuctionBidResult", "OnItemAuctionResult");
		self:RegisterEvent("PostItemAuctionResult", "OnItemAuctionResult");
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
	self:DisableSubmodules();
	self:UnregisterEvent("ItemAuctionBidResult");
	self:UnregisterEvent("PostItemAuctionResult");
	self:UnregisterEvent("ItemAuctionWon");
	self:UnregisterEvent("VarChange_FrameCount");
	self:UnregisterEvent("Sezz_AuctionHouse_SearchCompleted");

	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	if (self.twndMain and self.twndMain:IsValid()) then
		self.twndMain:Destroy();
	end

	self.tSearch = nil;
	self.twndMain = nil;
	self.wndMain = nil;
	self.wndSearch = nil;
	self.wndFilters = nil;
	self.wndResults = nil;
	self.wndResultsGrid = nil;
	self.wndCurrentItem = nil;
	self.wndSelectedItem = nil;
	self.wndTreeView = nil;
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

local ktAuctionResultStrings = {
--	[MarketplaceLib.AuctionPostResult.Ok] = 0,
	[MarketplaceLib.AuctionPostResult.NotEnoughToFillQuantity] 	= Apollo.GetString("GenericError_Vendor_NotEnoughToFillQuantity"),
	[MarketplaceLib.AuctionPostResult.NotEnoughCash] 			= Apollo.GetString("GenericError_Vendor_NotEnoughCash"),
	[MarketplaceLib.AuctionPostResult.NotReady] 				= Apollo.GetString("MarketplaceAuction_TechnicalDifficulties"), -- Correct error?
	[MarketplaceLib.AuctionPostResult.CannotFillOrder] 			= Apollo.GetString("MarketplaceAuction_TechnicalDifficulties"),
	[MarketplaceLib.AuctionPostResult.TooManyOrders] 			= Apollo.GetString("MarketplaceAuction_MaxOrders"),
	[MarketplaceLib.AuctionPostResult.OrderTooBig] 				= Apollo.GetString("MarketplaceAuction_OrderTooBig"),
	[MarketplaceLib.AuctionPostResult.NotFound] 				= Apollo.GetString("MarketplaceAuction_NotFound"),
	[MarketplaceLib.AuctionPostResult.BidTooLow] 				= Apollo.GetString("MarketplaceAuction_BidTooLow"),
	[MarketplaceLib.AuctionPostResult.BidTooHigh] 				= Apollo.GetString("MarketplaceAuction_BidTooHigh"),
	[MarketplaceLib.AuctionPostResult.OwnItem] 					= Apollo.GetString("MarketplaceAuction_AlreadyBid"), -- Correct error?
	[MarketplaceLib.AuctionPostResult.AlreadyHasBid] 			= Apollo.GetString("MarketplaceAuction_AlreadyBid"),
	[MarketplaceLib.AuctionPostResult.ItemAuctionDisabled] 		= Apollo.GetString("MarketplaceAuction_AuctionDisabled"),
	[MarketplaceLib.AuctionPostResult.CommodityDisabled] 		= Apollo.GetString("MarketplaceAuction_CommodityDisabled"),
	[MarketplaceLib.AuctionPostResult.DbFailure] 				= Apollo.GetString("MarketplaceAuction_TechnicalDifficulties"),
};

function M:OnItemAuctionResult(strEvent, eResult, aucCurr)
	local bResultOk = (eResult == MarketplaceLib.AuctionPostResult.Ok);
	local strMessage;

	if (eResult == MarketplaceLib.AuctionPostResult.Ok) then
		if (strEvent == "ItemAuctionBidResult") then
			strMessage = String_GetWeaselString(Apollo.GetString("MarketplaceAuction_BidAccepted"), aucCurr:GetItem():GetName());
		elseif (strEvent == "PostItemAuctionResult") then
			strMessage = String_GetWeaselString(Apollo.GetString("MarketplaceAuction_PostAccepted"), aucCurr:GetItem():GetName());
		else
			strMessage = "Invalid Auction Result Event: "..strEvent;
		end
	else
		strMessage = (ktAuctionResultStrings[eResult] and ktAuctionResultStrings[eResult] or "MarketplaceLib.AuctionPostResult: "..eResult);
	end

	S:Print(strMessage);

	if (strEvent == "ItemAuctionBidResult" and (eResult == MarketplaceLib.AuctionPostResult.Ok or eResult == MarketplaceLib.AuctionPostResult.NotFound)) then
		if ((self.wndSelectedItem and self.wndSelectedItem:GetData() and self.wndSelectedItem:GetData() == aucCurr) or self:IsAuctionVisible(aucCurr)) then
			self:ClearSelection();
			self:UpdateAuction(aucCurr, bResultOk);
--			self:RefreshResults();
		end
	elseif (strEvent == "PostItemAuctionResult" and eResult == MarketplaceLib.AuctionPostResult.Ok) then
		S:Print("OK");
	end
end
