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
local pairs, ipairs, tinsert, tremove = pairs, ipairs, table.insert, table.remove;

-----------------------------------------------------------------------------

function M:OnInitialize()
	self:InitializeWindowDefinitions();
end

function M:OnEnable()
	self:RegisterEvent("PostItemAuctionResult", "OnPostItemAuctionResult");
	self:RegisterEvent("UpdateInventory", "OnUpdateInventory");
end

function M:OnDisable()
	self:UnregisterEvent("UpdateInventory");
	self:UnregisterEvent("PostItemAuctionResult");

	self.tvwAuctionableItems = nil;
	self.wndContent = nil;
	self.itemSelected = nil;
end

function M:CreateTab(wndParent)
	self.wndContent = AuctionHouse.GeminiGUI:Create(self.tWindowDefinitions):GetInstance(self, wndParent);

	-- Initialize Tree
	self.tvwAuctionableItems = AuctionHouse.TreeView:New(self.wndContent:FindChild("TreeView"));
	self.strNodeAuctionableItems = self.tvwAuctionableItems:AddNode(AuctionHouse.L.AuctionableItems);

	for _, itemCurr in ipairs(S.myCharacter:GetAuctionableItems()) do
		if (itemCurr and itemCurr:IsAuctionable()) then
			self.tvwAuctionableItems:AddChildNode(self.strNodeAuctionableItems, itemCurr:GetName(), itemCurr:GetIcon(), itemCurr);
		end
	end

	self.tvwAuctionableItems:RegisterCallback("NodeSelected", "OnAuctionableItemSelected", self);
	self.tvwAuctionableItems:Render();
	self:DisableForm();
end

function M:DisableForm()
	self.wndContent:FindChild("ListItemForm:BtnListItem"):Enable(false);
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

function M:OnPostItemAuctionResult(strEvent, eResult, aucCurr)
	-- Remember Price
	if (strEvent == "PostItemAuctionResult" and eResult == MarketplaceLib.AuctionPostResult.Ok) then
		AuctionHouse.DB.ItemPrices[aucCurr:GetItem():GetItemId()] = {
			aucCurr:GetMinBid():GetAmount(),
			aucCurr:GetBuyoutPrice():GetAmount(),
		};
	end
end

function M:OnChangeBidAmount()
	local wndForm = self.wndContent:FindChild("ListItemForm");
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

function M:OnUpdateInventory()
	local tItemsRemoved = {};
Print("Get Auctionable Items")
	local tItemsNew = S.myCharacter:GetAuctionableItems() or {};

	for _, tNode in self.tvwAuctionableItems:IterateNodes(self.strNodeAuctionableItems) do
		local itemCurr = tNode.tData;

		if (itemCurr) then
			local bFound = false;
Print("Compare Items")
			for i, itemAuctionable in ipairs(tItemsNew) do
Print("Compare Item")
				if (itemAuctionable == itemCurr) then
					tremove(tItemsNew, i);
					bFound = true;
					break;
				end
			end

			if (not bFound) then
				tinsert(tItemsRemoved, itemCurr);
Print("Remove Node")
				self.tvwAuctionableItems:RemoveNode(tNode.strName, true);
				if (self.itemSelected == itemCurr) then
					self:DisableForm();
					self.itemSelected = nil;
				end
			end
		end
	end

	for _, itemNew in ipairs(tItemsNew) do
Print("Add Node")
		self.tvwAuctionableItems:AddChildNode(self.strNodeAuctionableItems, itemNew:GetName(), itemNew:GetIcon(), itemNew);
	end

	if (#tItemsNew > 0 or #tItemsRemoved > 0) then
Print("Render")
		self.tvwAuctionableItems:Render();
	end
end

-----------------------------------------------------------------------------

function M:SetItem(itemCurr)
	local wndForm = self.wndContent:FindChild("ListItemForm");
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

	self.itemSelected = itemCurr;
	self:OnChangeBidAmount();
end

function M:OnAuctionableItemSelected(strNode)
	self:SetItem(self.tvwAuctionableItems:GetNodeData(strNode));
end

-----------------------------------------------------------------------------

local function CreateTab(self, wndParent)
	return M:CreateTab(wndParent);
end

AuctionHouse:RegisterTab("sell", "Sell", "FAGavel", CreateTab, 1);
