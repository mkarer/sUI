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
		AuctionHouse.P.ItemPrices[aucCurr:GetItem():GetItemId()] = {
			aucCurr:GetMinBid():GetAmount(),
			aucCurr:GetBuyoutPrice():GetAmount(),
		};
	end
end

-----------------------------------------------------------------------------
-- Sell Tab
-----------------------------------------------------------------------------

local kstrFont = "CRB_Pixel"; 
local kstrFontLarge = "CRB_ButtonHeader"; 
local knWidthPanelLeft = 220;
local knControlPadding = 2;
local knIconBorderBig = 2;
local knIconSizeBig = 40;

local ktQualityColors = {
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
};

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

		local nBid = AuctionHouse.P.ItemPrices[nItemId] and AuctionHouse.P.ItemPrices[nItemId][1] or nVendorPrice;
		local nBuyout = AuctionHouse.P.ItemPrices[nItemId] and AuctionHouse.P.ItemPrices[nItemId][2] or nVendorPrice + 1;

		if (nBid < nVendorPrice) then
			nBid = nVendorPrice;
		end

		if (nBuyout ~= 0 and nBuyout <= nBid) then
			nBuyout = nBid + 1;
		end

		wndForm:FindChild("ItemName"):SetText(itemCurr:GetName());
		wndForm:FindChild("ItemName"):SetTextColor(ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior]);
		wndForm:FindChild("ItemFamily"):SetText(itemCurr:GetItemTypeName());
		wndForm:FindChild("IconContainer"):SetBGColor(ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior]);
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

local tWindowDefinitions = {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 4, 4, -4, -4 },
		IgnoreMouse = 1,
		Children = {
			-- Sellable Items Tree
			{
				Name = "TreeView",
				Class = "Window",
				Font = kstrFont,
				AnchorPoints = { 0, 0, 0, 1 },
				AnchorOffsets = { 0, 0, knWidthPanelLeft, 0 },
				VScroll = true,
				AutoHideScroll = false,
				Template = "Holo_ScrollListSmall",
				Border = true,
				Sprite = "ClientSprites:WhiteFill",
				BGColor = "ff121314",
				Picture = true,
				UseTemplateBG = false,
				IgnoreMouse = 0,
			},
			-- Post Item Form
			{
				Name = "ListItemForm",
				AnchorPoints = { 0, 0, 0, 0 },
				AnchorOffsets = { knWidthPanelLeft + knControlPadding, 0, knWidthPanelLeft + knControlPadding + 440, 168 },
				Border = true,
--				Picture = true,
--				Sprite = "BK3:UI_BK3_Holo_InsetDivider",
				Children = {
					-- Item Name
					{
						Name = "ItemName",
						Font = kstrFontLarge,
						Text = "PlaceHolder:ItemName",
						AnchorPoints = { 0, 0, 1, 0 },
						AnchorOffsets = { 80, 22, -knControlPadding, 22 + 20 },
						TextColor = ktQualityColors[Item.CodeEnumItemQuality.Good],
					},
					-- Item Family
					{
						Name = "ItemFamily",
						Font = kstrFont,
						Text = "PlaceHolder:ItemFamily",
						AnchorPoints = { 0, 0, 1, 0 },
						AnchorOffsets = { 80, 46, -knControlPadding, 46 + 20 },
					},
					-- Icon
					{
						Name = "IconContainer",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 20, 20, knIconSizeBig + 2 * knIconBorderBig + 20, knIconSizeBig + 2 * knIconBorderBig + 20 },
						Picture = true,
						BGColor = ktQualityColors[Item.CodeEnumItemQuality.Good],
						Sprite = "ClientSprites:WhiteFill",
--						Events = {
--							MouseEnter = ShowItemTooltip,
--							MouseExit = HideItemTooltip,
--							MouseButtonUp = self.ItemPreviewImproved and ShowItemPreview or nil,
--						},
						Children = {
							-- Icon
							{
								Name = "Icon",
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { knIconBorderBig, knIconBorderBig, -knIconBorderBig, -knIconBorderBig },
								BGColor = "white",
								Picture = true,
							},
						},
						Pixies = {
							-- Count
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { knIconBorderBig, knIconBorderBig, -knIconBorderBig -2, -knIconBorderBig -1 },
								Text = strCount,
								DT_RIGHT = true,
								DT_BOTTOM = true,
								Font = "CRB_Interface9_O",
							},
							-- Background
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { knIconBorderBig, knIconBorderBig, -knIconBorderBig, -knIconBorderBig },
								BGColor = "black",
								Sprite = "ClientSprites:WhiteFill",
							},
						},
					},
					-- Vendor
					{
						Class = "CashWindow",
						Name = "Vendor",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 80, 76, 280, 76 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
						Font = kstrFont,
						AllowEditing = false,
					},
					-- Bid
					{
						Class = "CashWindow",
						Name = "Bid",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 80, 102, 280, 102 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
						Font = kstrFont,
						AllowEditing = true,
						Events = { CashWindowAmountChanged = "OnChangeBidAmount" },
					},
					-- Buyout
					{
						Class = "CashWindow",
						Name = "Buyout",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 80, 128, 280, 128 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
						Font = kstrFont,
						AllowEditing = true,
						Events = { CashWindowAmountChanged = "OnChangeBidAmount" },
					},
					-- List Item Button
					{
						Class = "ActionConfirmButton",
						Name = "BtnListItem",
						AnchorPoints = { 0, 0, 1, 0 },
						AnchorOffsets = { 282 + knControlPadding, 102, 0, 152 },
						Base = "BK3:btnHolo_ListView_Mid",
						Text = Apollo.GetString("MarketAuctionHouse_ListItem"),
						DT_VCENTER = true,
						DT_CENTER = true,
						Font = kstrFont,
					},
				},
				Pixies = {
					-- Vendor Price
					{
						Font = kstrFont,
						Text = "Vendor:",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 0, 76, knIconSizeBig + 2 * knIconBorderBig + 20, 76 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
					},
					-- Bid
					{
						Font = kstrFont,
						Text = "Bid:",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 0, 102, knIconSizeBig + 2 * knIconBorderBig + 20, 102 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
					},
					{
						Sprite = "BK3:UI_BK3_Holo_InsetDivider",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 78, 100, 280, 100 + 20 + 4 },
					},
					-- Buyout
					{
						Font = kstrFont,
						Text = "Buyout:",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 0, 128, knIconSizeBig + 2 * knIconBorderBig + 20, 128 + 20 },
						DT_RIGHT = true,
						DT_VCENTER = true,
					},
					{
						Sprite = "BK3:UI_BK3_Holo_InsetDivider",
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 78, 126, 280, 126 + 20 + 4 },
					},
				},
			},
		},

};

-----------------------------------------------------------------------------

local function CreateTab(self, wndParent)
	wndContent = self.GeminiGUI:Create(tWindowDefinitions):GetInstance(tTabEventsHandler, wndParent);

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

AuctionHouse:RegisterTab("sell", "Sell", "FAGavel", CreateTab, 2);
