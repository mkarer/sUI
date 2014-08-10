--[[

	s:UI Auction House: Sell Module

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "MarketplaceLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AuctionHouse = S:GetModule("AuctionHouse");
local M = AuctionHouse:CreateSubmodule("Sell");
M.OverrideGeminiAddonStatus = true;

-- Lua API
local ipairs = ipairs;

-----------------------------------------------------------------------------

function M:OnInitialize()
	self:InitializeWindowDefinitions();
end

function M:OnEnable()
	self:RegisterEvent("PostItemAuctionResult", "OnPostItemAuctionResult");
end

function M:OnDisable()
	self:UnregisterEvent("PostItemAuctionResult");
end

-----------------------------------------------------------------------------

function M:OnPostItemAuctionResult(strEvent, eResult, aucCurr)
	if (strEvent == "PostItemAuctionResult" and eResult == MarketplaceLib.AuctionPostResult.Ok) then
		AuctionHouse.DB.ItemPrices[aucCurr:GetItem():GetItemId()] = {
			aucCurr:GetMinBid():GetAmount(),
			aucCurr:GetBuyoutPrice():GetAmount(),
		};
	end
end

-----------------------------------------------------------------------------
-- Sell Tab
-----------------------------------------------------------------------------

local tvwSellableItems, wndContent;
local tTabEventsHandler = {};

function tTabEventsHandler:OnChangeBidAmount()
	local wndForm = wndContent:FindChild("ListItemForm");
	local wndListItemButton = wndForm:FindChild("BtnListItem");
	local itemCurr = wndForm:GetData();

	local bValid = false;
	local monBid, monBuyout;

	if (itemCurr and itemCurr:IsAuctionable() and itemCurr:isInstance()) then
		monBid = wndForm:FindChild("Bid"):GetCurrency();
		monBuyout = wndForm:FindChild("Buyout"):GetCurrency();

		local nVendorPrice = itemCurr:GetSellPrice() and itemCurr:GetSellPrice():GetAmount() or 0;
		local nBid = monBid:GetAmount();
		local nBuyout = monBuyout:GetAmount();

		bValid = (nBid > 0 and (nBuyout == 0 or nBuyout >= nVendorPrice) and (nBuyout == 0 or nBid < nBuyout));
	end

	wndListItemButton:Enable(bValid);
	if (bValid) then
		wndListItemButton:SetActionData(GameLib.CodeEnumConfirmButtonType.MarketplaceAuctionSellSubmit, itemCurr, monBid, monBuyout);
	end
end

function tTabEventsHandler:SetItem(itemCurr)
	local wndForm = wndContent:FindChild("ListItemForm");
	wndForm:SetData(itemCurr);
	wndForm:FindChild("BtnListItem"):SetData(itemCurr);

	if (not itemCurr or not itemCurr:isInstance() or not itemCurr:IsAuctionable()) then
		-- Root Node/Invalid Item
	else
		local nVendorPrice = itemCurr:GetSellPrice() and itemCurr:GetSellPrice():GetAmount() or 0;
		local nItemId = itemCurr:GetItemId();

		local nBid = AuctionHouse.DB.ItemPrices[nItemId] and AuctionHouse.DB.ItemPrices[nItemId][1] or nVendorPrice;
		local nBuyout = AuctionHouse.DB.ItemPrices[nItemId] and AuctionHouse.DB.ItemPrices[nItemId][2] or nVendorPrice + 1;

		if (nBid < nVendorPrice) then
			nBid = nVendorPrice;
		end

		if (nBuyout ~= 0 and nBuyout <= nBid) then
			nBuyout = nBid + 1;
		end

		wndForm:FindChild("ItemName"):SetText(itemCurr:GetName());
		wndForm:FindChild("ItemName"):SetTextColor(AuctionHouse.GUI.Colors.Quality[itemCurr:GetItemQuality()] or AuctionHouse.GUI.Colors.Quality[Item.CodeEnumItemQuality.Inferior]);
		wndForm:FindChild("ItemFamily"):SetText(itemCurr:GetItemTypeName());
		wndForm:FindChild("IconContainer"):SetBGColor(AuctionHouse.GUI.Colors.Quality[itemCurr:GetItemQuality()] or AuctionHouse.GUI.Colors.Quality[Item.CodeEnumItemQuality.Inferior]);
		wndForm:FindChild("Icon"):SetSprite(itemCurr:GetIcon());
		wndForm:FindChild("Vendor"):SetAmount(nVendorPrice);
		wndForm:FindChild("Bid"):SetAmount(nBid);
		wndForm:FindChild("Buyout"):SetAmount(nBuyout);

--		local nPage = 0
--		local bReverseSort = true
--		MarketplaceLib.RequestItemAuctionsByItems({ itemCurr:GetItemId() }, nPage, MarketplaceLib.AuctionSort.Buyout, bReverseSort, nil, nil, nil, nil)
	end

	self:OnChangeBidAmount();
end

function tTabEventsHandler:OnAuctionableItemSelected(strNode)
	self:SetItem(tvwSellableItems:GetNodeData(strNode));
end

-----------------------------------------------------------------------------

local function CreateTab(self, wndParent)
	wndContent = self.GeminiGUI:Create(M.tWindowDefinitions):GetInstance(tTabEventsHandler, wndParent);

	-- Initialize Tree
	tvwSellableItems = self.TreeView:New(wndContent:FindChild("TreeView"));
	local strNodeSellableItems = tvwSellableItems:AddNode("Sellable Items");

	for _, itemCurr in ipairs(S.myCharacter:GetAuctionableItems()) do
		if (itemCurr and itemCurr:IsAuctionable()) then
			tvwSellableItems:AddChildNode(strNodeSellableItems, itemCurr:GetName(), itemCurr:GetIcon(), itemCurr);
		end
	end

	tvwSellableItems:RegisterCallback("NodeSelected", "OnAuctionableItemSelected", tTabEventsHandler);
	tvwSellableItems:Render();
end

AuctionHouse:RegisterTab("sell", "Sell", "FAGavel", CreateTab, 1);
