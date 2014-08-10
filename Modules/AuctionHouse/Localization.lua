--[[

	s:UI Auction House: Localization

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "MarketplaceLib";
require "ItemAuction";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AuctionHouse = S:GetModule("AuctionHouse");

-----------------------------------------------------------------------------

-- Lua API
local format = string.format;

-----------------------------------------------------------------------------

AuctionHouse.L = {
	Search = Apollo.GetString("CRB_Search"),
	PostItem = Apollo.GetString("MarketAuctionHouse_ListItem"),
	BidAccepted = Apollo.GetString("MarketplaceAuction_BidAccepted"),
	PostAccepted = Apollo.GetString("MarketplaceAuction_PostAccepted"),
	AuctionWon = Apollo.GetString("MarketplaceAuction_WonMessage"),
	ErrorGuestAccount = Apollo.GetString("CRB_FeatureDisabledForGuests"),
	Bid = Apollo.GetString("MarketplaceAuction_BidBtn"),
	Buyout = Apollo.GetString("MarketplaceAuction_BuyoutHeader"),
	NoResults = Apollo.GetString("Tradeskills_NoResults"),
	Searching = Apollo.GetString("MarketplaceAuction_FetchingResults").."...",
	ErrorTryClearingFilters = Apollo.GetString("MarketplaceAuction_TryClearingFilter"),
	AuctionableItems = "Auctionable Items",
	AuctionResultStrings = {
--		[MarketplaceLib.AuctionPostResult.Ok] = 0,
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
	},
	DurationStrings = {
		[ItemAuction.CodeEnumAuctionRemaining.Expiring]				= Apollo.GetString("MarketplaceAuction_Expiring"),
		[ItemAuction.CodeEnumAuctionRemaining.LessThanHour]			= Apollo.GetString("MarketplaceAuction_LessThanHour"),
		[ItemAuction.CodeEnumAuctionRemaining.Short]				= Apollo.GetString("MarketplaceAuction_Short"),
		[ItemAuction.CodeEnumAuctionRemaining.Long]					= Apollo.GetString("MarketplaceAuction_Long"),
		[ItemAuction.CodeEnumAuctionRemaining.Very_Long]			= format("<%dh", MarketplaceLib.kItemAuctionListTimeDays * 24),
	},
};
