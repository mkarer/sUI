--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";
require "GameLib";
require "Item";
require "Unit";
require "MarketplaceLib";
require "ItemAuction";

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local strlen, strfind, gmatch, format, tinsert, floor, max, strmatch, sort = string.len, string.find, string.gmatch, string.format, table.insert, math.floor, math.max, string.match, table.sort;
local Apollo, MarketplaceLib, GameLib = Apollo, MarketplaceLib, GameLib;

-----------------------------------------------------------------------------
-- GUI
-----------------------------------------------------------------------------

local kstrFont = "CRB_Pixel"; -- Nameplates (update MLWindow top offset when changing font as it doesn't support DT_VCENTER)

local ktQualityColors = {
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
};

local ktDurationStrings = {
	[ItemAuction.CodeEnumAuctionRemaining.Expiring]		= Apollo.GetString("MarketplaceAuction_Expiring"),
	[ItemAuction.CodeEnumAuctionRemaining.LessThanHour]	= Apollo.GetString("MarketplaceAuction_LessThanHour"),
	[ItemAuction.CodeEnumAuctionRemaining.Short]		= Apollo.GetString("MarketplaceAuction_Short"),
	[ItemAuction.CodeEnumAuctionRemaining.Long]			= Apollo.GetString("MarketplaceAuction_Long"),
	[ItemAuction.CodeEnumAuctionRemaining.Very_Long]	= format("<%dh", MarketplaceLib.kItemAuctionListTimeDays * 24);
};

local ktDurationColors = {
	[ItemAuction.CodeEnumAuctionRemaining.Expiring]		= "ffff0000",
	[ItemAuction.CodeEnumAuctionRemaining.LessThanHour]	= "ffff9900",
	[ItemAuction.CodeEnumAuctionRemaining.Short]		= "ff99ff66",
	[ItemAuction.CodeEnumAuctionRemaining.Long]			= "ffffffff",
	[ItemAuction.CodeEnumAuctionRemaining.Very_Long]	= "ffffffff",
};

local kstrSearch = Apollo.GetString("CRB_Search");
local nPadding = 2;
local nItemSize = 30;
local nIconBorder = 1;
local tTree;

function M:OnNodeSelected(strNode)
	self.tSelectedCategory = tTree:GetNodeData(strNode);
	self.strSelectedShoppingList = nil;
	self.nSelectedFamily = nil;

	if (not self.tSelectedCategory) then return; end
	if (self.tSelectedCategory.Type == "Family" or self.tSelectedCategory.Type == "Category" or self.tSelectedCategory.Type == "Type") then
		if (self.tSelectedCategory.Type ~= "Family") then
			local nParentId = tTree:GetParentNode(strNode);
			while (tTree:GetParentNode(nParentId) and tTree:GetNodeData(nParentId).Type ~= "Family") do
				nParentId = tTree:GetParentNode(nParentId);
			end

			self.nSelectedFamily = tTree:GetNodeData(nParentId).Id;
		else
			self.nSelectedFamily = self.tSelectedCategory.Id;
		end
	elseif (self.tSelectedCategory.Type == "ShoppingList") then
		self.strSelectedShoppingList = self.tSelectedCategory.Name;
	end
end

local function OnTreeWindowLoad(self, wndHandler, wndControl)
	tTree = self.TreeView:New(wndControl, self);

	local nNodeIdRoot = tTree:AddNode("Auctions");
	local nNodeIdSelected, nNodeIdSelectedCategory;

	--[[
	-- Armor
	for _, tDataRootCategory in ipairs(MarketplaceLib.GetAuctionableCategories(1)) do
		local nNodeIdRootCategory = tTree:AddNode(nNodeIdRoot, tDataRootCategory.strName, nil, tDataRootCategory.nId);

		for _, tDataType in pairs(MarketplaceLib.GetAuctionableTypes(tDataRootCategory.nId) or {}) do
			if (strlen(tDataType.strName) > 0) then
				tTree:AddNode(nNodeIdRootCategory, tDataType.strName, nil, tDataType.nId);
			end
		end
	end
	]]

	-- Others
	for _, tDataRootCategory in ipairs(MarketplaceLib.GetAuctionableFamilies()) do
--		if (tDataRootCategory.nId > 1) then -- Ignore Armor
			local nNodeIdRootCategory = tTree:AddChildNode(nNodeIdRoot, tDataRootCategory.strName, nil, { Type = "Family", Id = tDataRootCategory.nId });
			tTree:CollapseNode(nNodeIdRootCategory);

			for _, tDataCategory in pairs(MarketplaceLib.GetAuctionableCategories(tDataRootCategory.nId) or {}) do
				local tTypes = MarketplaceLib.GetAuctionableTypes(tDataCategory.nId) or {};
				local nNodeIdCategory = nNodeIdRootCategory;

				if (tDataRootCategory.nId == 1 or (#tTypes == 0 and strlen(tDataCategory.strName) > 0)) then
					nNodeIdCategory = tTree:AddChildNode(nNodeIdRootCategory, tDataCategory.strName, nil, { Type = "Category", Id = tDataCategory.nId });
					tTree:CollapseNode(nNodeIdCategory);
				end

				for _, tDataType in pairs(tTypes) do
					local strName = tDataType.strName;
					if (strfind(strName, "-")) then
						strName = gmatch(strName, ".*-(.*)")();
					end

					local nNodeId = tTree:AddChildNode(nNodeIdCategory, strName, nil, { Type = "Type", Id = tDataType.nId });
					tTree:CollapseNode(nNodeId);
					if (strName == "Implant") then
						nNodeIdSelected = nNodeId; -- TEMP
						nNodeIdSelectedCategory = nNodeIdRootCategory;
					end
				end
			end
--		end
	end

	if (nNodeIdSelected) then -- TEMP
		tTree:SelectNode(nNodeIdSelected);
		self.tSelectedCategory = tTree:GetNodeData(nNodeIdSelected);
		self.nSelectedFamily = 15;
	end

	-- Shopping Lists
	local nNodeIdShoppingLists = tTree:AddNode("Shopping Lists");
	tTree:CollapseNode(nNodeIdShoppingLists);
	local tShoppingListsSorted = {};
	for i, tList in ipairs(self.P.ShoppingList) do
		tinsert(tShoppingListsSorted, { i, tList.Name });
		sort(tShoppingListsSorted, function(a, b) return a[2] < b[2]; end);
	end

	for i, tList in pairs(tShoppingListsSorted) do
		tTree:AddChildNode(nNodeIdShoppingLists, tList[2], nil, { Type = "ShoppingList", Name = tList[2] });
	end

	-- My Listings
	tTree:AddNode("My Listings");

	-- Events
	tTree:RegisterCallback("NodeSelected", "OnNodeSelected", self);
	tTree:RegisterCallback("NodeDoubleClick", "OnNodeDoubleClick", self);

	-- Done
	tTree:Render();
end

local function OnShowFilters(self, wndHandler, wndControl)
	wndControl:SetText("Filters [-]");
	self.wndFilters:Show(true, true);

	local nL, nT, nR, nB = self.wndResults:GetAnchorOffsets();
	nT = self.wndSearch:GetHeight() + self.wndFilters:GetHeight() + 2 * nPadding;
	self.wndResults:SetAnchorOffsets(nL, nT, nR, nB);

	local wndMessage = self.wndMain:FindChild("Message");
	local nL, nT, nR, nB = wndMessage:GetAnchorOffsets();
	nT = self.wndSearch:GetHeight() + self.wndFilters:GetHeight() + 2 * nPadding;
	wndMessage:SetAnchorOffsets(nL, nT, nR, nB);
end

local function OnHideFilters(self, wndHandler, wndControl)
	wndControl:SetText("Filters [+]");
	self.wndFilters:Show(false, true);

	local nL, nT, nR, nB = self.wndResults:GetAnchorOffsets();
	nT = self.wndSearch:GetHeight() + nPadding;
	self.wndResults:SetAnchorOffsets(nL, nT, nR, nB);

	local wndMessage = self.wndMain:FindChild("Message");
	local nL, nT, nR, nB = wndMessage:GetAnchorOffsets();
	nT = self.wndSearch:GetHeight() + nPadding;
	wndMessage:SetAnchorOffsets(nL, nT, nR, nB);
end

local function OnSearch(self)
	if (not self.tSelectedCategory) then return; end
	if (self.bIsSearching) then return; end

	if (not self.strSelectedShoppingList) then
		local strSearchQuery = self.wndSearch:FindChild("Text"):GetText();
		self.wndSearch:FindChild("Text"):SetText(strfind(strSearchQuery, "^%s*$") and "" or strmatch(strSearchQuery, "^%s*(.*%S)"))

		self:SetSearchState(true);
		self:BuildFilter();
		self:UpdateListHeaders();
		self:Search();
	elseif (self.strSelectedShoppingList) then
		local nShoppingListIndex;

		for i, tList in ipairs(self.P.ShoppingList) do
			if (tList.Name == self.strSelectedShoppingList) then
				nShoppingListIndex = i;
			end
		end

		if (not nShoppingListIndex) then return; end

		self:SetSearchState(true);
		self:UpdateListHeaders();
		self.tSearch:SetMultipleFilters(self.P.ShoppingList[nShoppingListIndex].Searches);
		self:ClearSelection();
		self.tAuctions = {};
		self.wndResultsGrid:SetVScrollPos(0);
		self.wndResultsGrid:DestroyChildren();
		self.tSearch:Search();
	end
end

function M:OnNodeDoubleClick(strNode, bTogglingNode)
	if (not bTogglingNode) then
		OnSearch(self);
	end
end

local function OnSearchButtonUp(self, wndHandler, wndControl, eMouseButton)
	if (not self.bIsSearching and eMouseButton == GameLib.CodeEnumInputMouse.Right and self.AuctionStats) then
		self:SetSearchState(true);
		self.AuctionStats:OnScanAuctionHouseButtonSignal(wndHandler, wndControl, eMouseButton);
	end
end

local function OnClickItem(self, wndHandler, wndControl, eMouseButton)
	if (wndHandler == wndControl and eMouseButton == GameLib.CodeEnumInputMouse.Right and not Apollo.IsControlKeyDown()) then
		self:ShowContextMenu(wndHandler:GetName(), wndHandler:GetData());
	end
end

local function OnChangeBidAmount(self, wndHandler, wndControl)
	local aucCurr = wndControl:GetParent():GetParent():GetData();
	local nPlayerCash = GameLib.GetPlayerCurrency(Money.CodeEnumCurrencyType.Credits):GetAmount();
	self.wndCurrentItem:FindChild("BtnBid"):SetActionData(GameLib.CodeEnumConfirmButtonType.MarketplaceAuctionBuySubmit, aucCurr, false, wndControl:GetCurrency());
	self.wndCurrentItem:FindChild("BtnBid"):Enable(wndControl:GetAmount() <= nPlayerCash);
end

local function OnSelectItem(self, wndHandler, wndControl)
	self.wndSelectedItem = wndHandler;

	-- Resize Results
	local nL, nT, nR, nB = self.wndResults:GetAnchorOffsets();
	nB = -self.wndCurrentItem:GetHeight() - nPadding;
	self.wndResults:SetAnchorOffsets(nL, nT, nR, nB);

	-- Icon/Name
	local aucCurr = wndHandler:GetData();
	local itemCurr = aucCurr:GetItem();
	self.wndCurrentItem:SetData(aucCurr);

	self.wndCurrentItem:FindChild("Name"):SetText(itemCurr:GetName());
	self.wndCurrentItem:FindChild("IconContainer"):SetBGColor(ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior]);
	self.wndCurrentItem:FindChild("Icon"):SetSprite(itemCurr:GetIcon());
	self.wndCurrentItem:FindChild("Name"):SetTextColor(ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior]);

	-- Bid/Buyout
	local nBuyoutPrice = aucCurr:GetBuyoutPrice():GetAmount();
	local bBidOnly = (nBuyoutPrice == 0);
	local nPlayerCash = GameLib.GetPlayerCurrency(Money.CodeEnumCurrencyType.Credits):GetAmount();
	local bCanBuyout = (not bBidOnly and not aucCurr:IsOwned() and nBuyoutPrice <= nPlayerCash);
	local nMinBidPrice = aucCurr:GetMinBid():GetAmount();
	local nCurrBidPrice = aucCurr:GetCurrentBid():GetAmount();
	local nDefaultBid = max(nMinBidPrice, nCurrBidPrice);
	local bBuyoutOnly = (not bBidOnly and nDefaultBid >= nBuyoutPrice);
	local bCanBid = (not bBuyoutOnly and not aucCurr:IsTopBidder() and not aucCurr:IsOwned());

	-- Bid
	self.wndCurrentItem:FindChild("Bid"):Enable(bCanBid);
	self.wndCurrentItem:FindChild("Bid"):SetAmount(nMinBidPrice);
	self.wndCurrentItem:FindChild("BtnBid"):SetActionData(GameLib.CodeEnumConfirmButtonType.MarketplaceAuctionBuySubmit, aucCurr, false, nMinBidPrice);
	self.wndCurrentItem:FindChild("BtnBid"):Enable(bCanBid and nMinBidPrice <= nPlayerCash);

	-- Buyout
	self.wndCurrentItem:FindChild("Price"):SetText(S:GetMoneyAML(nBuyoutPrice, kstrFont));
	self.wndCurrentItem:FindChild("BtnBuyout"):Enable(bCanBuyout);
	self.wndCurrentItem:FindChild("BtnBuyout"):SetActionData(GameLib.CodeEnumConfirmButtonType.MarketplaceAuctionBuySubmit, aucCurr, true);

	-- Display
	self.wndCurrentItem:Show(true, true);
end

local function OnDeselectItem(self, wndHandler, wndControl)
	self:ClearSelection();
end

function M:ClearSelection()
	if (self.wndSelectedItem) then
		self.wndSelectedItem:SetCheck(false);
	end

	self.wndSelectedItem = nil;

	local nL, nT, nR, nB = self.wndResults:GetAnchorOffsets();
	self.wndResults:SetAnchorOffsets(nL, nT, nR, 0);

	self.wndCurrentItem:Show(false, true);
end

local function OnSearchLostFocus(self, wndHandler, wndControl)
	if (strlen(wndControl:GetText()) == 0) then
		wndControl:SetText(kstrSearch);
	end
end

local function ShowItemTooltip(self, wndHandler, wndControl) -- Build on mouse enter and not every hit to save computation time
	if (wndHandler ~= wndControl) then return; end
	local aucCurr = wndHandler:GetParent():GetParent():GetData();

	if (not aucCurr) then return; end

	local itemCurr = aucCurr:GetItem();
	Tooltip.GetItemTooltipForm(self, wndHandler, itemCurr, { bPrimary = true, bSelling = false, itemModData = nil, itemCompare = itemCurr:GetEquippedItemForItemType() });
end

local function HideItemTooltip(self, wndHandler, wndControl)
	if (wndHandler ~= wndControl) then return; end
	wndHandler:SetTooltipDoc(nil);
end

local function ShowItemPreview(self, wndHandler, wndControl, eMouseButton)
	if (wndHandler ~= wndControl) then return; end

	local aucCurr = wndHandler:GetParent():GetParent():GetData();
	if (not aucCurr) then return; end

	local itemCurr = aucCurr:GetItem();

	if (Apollo.IsControlKeyDown() and eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		if (itemCurr:GetHousingDecorInfoId() ~= nil and itemCurr:GetHousingDecorInfoId() ~= 0) then
			Event_FireGenericEvent("DecorPreviewOpen", itemCurr:GetHousingDecorInfoId());
		else
			self.ItemPreviewImproved:OnShowItemInDressingRoom(itemCurr);
		end
	end
end

function M:SetStatusMessage(strMessage, bIsError)
	local wndMessage = self.wndMain:FindChild("Message");

	if (type(strMessage) == "string" and strlen(strMessage) > 0) then
		if (bIsError) then
			wndMessage:SetTextColor("red");
		else
			wndMessage:SetTextColor("UI_TextHoloTitle");
		end

		wndMessage:SetText(strMessage);
		wndMessage:Show(true);
	else
		wndMessage:Show(false);
	end
end

local function OnHeaderClick(self, wndHandler, wndControl)
	if (wndHandler ~= wndControl) then return; end
	self:SetSortOrder(wndControl:GetName(), wndControl:IsChecked() and "ASC" or "DESC");
	self:SortResults();
end

function M:CreateWindow()
	if (not self.twndMain or not self.twndMain:IsValid()) then
		local tAttributesAutionHouse = {
			Name = "SezzAuctionHouse",
			Moveable = 1,
			Escapable = 1,
			Overlapped = 1,
			LAnchorPoint = 0.225, TAnchorPoint = 0.10, RAnchorPoint = 0.775, BAnchorPoint = 0.75,
			LAnchorOffset = 0, TAnchorOffset = 0, RAnchorOffset = 0, BAnchorOffset = 0,
			Sizable = 1,
		};

		self.twndMain = self.TabWindow:New("Auction House", tAttributesAutionHouse);
		self.twndMain.bDestroyOnClose = true;

		self.twndMain:AddTab("Browse", "FAHome", "browse");
		self:InitializeTabs();

		self.twndMain:Show();
		self:CreateTabs();

		self.twndMain:RegisterCallback("WindowClosed", "Close", self);
	end
	
	if (not self.wndMain or not self.wndMain:IsValid()) then
		local nWidthCategories = 220;
		local nWidthSearchButton = 100;
		local nPaddingSearchControl = 4;
		local nHeightSearch = 40;
		local nHeightFilters = 140;
		local nHeightHeader = 40;
		local nHeightCurrentItem = 40;

		self.wndMain = self.GeminiGUI:Create({
			AnchorPoints = { 0, 0, 1, 1 },
			AnchorOffsets = { 4, 4, -4, -4 },
			Children = {
				-- CONTENT
				-- Categories
				{
					Name = "TreeView",
					Class = "Window",
					Font = kstrFont,
					AnchorPoints = { 0, 0, 0, 1 },
					AnchorOffsets = { 0, 0, nWidthCategories, 0 },
					VScroll = true,
					AutoHideScroll = false,
					Template = "Holo_ScrollListSmall",
					Border = true,
					Sprite = "ClientSprites:WhiteFill",
					BGColor = "ff121314",
					Picture = true,
					UseTemplateBG = false,
				},
				-- Search Box
				{
					Name = "Search",
					Border = false,
					AnchorPoints = { 0, 0, 1, 0, },
					AnchorOffsets = { nWidthCategories + nPadding, 0, 0, nHeightSearch },
					Children = {
						-- Textbox
						{
							AnchorPoints = { 0, 0, 1, 1 },
							AnchorOffsets = { nPadding, 0, 2 * (-nPadding - nWidthSearchButton) - nPadding, -nPadding },
							Sprite = "BK3:UI_BK3_Holo_InsetDivider",
							Picture = true,
							Children = {
								{
									Class = "EditBox",
									Name = "Text",
									AnchorPoints = { 0, 0, 1, 1 },
									AnchorOffsets = { 8, 0, -8, 0 },
									Text = "Search",
									DT_VCENTER = true,
									Font = kstrFont,
									Events = {
										EditBoxReturn = OnSearch,
										WindowLostFocus = OnSearchLostFocus,
									},
								},
							},
						},
						-- Button: Search
						{
							Class = "Button",
							Name = "BtnSearch",
							AnchorPoints = { 1, 0, 1, 1 },
							AnchorOffsets = { 2 * (-nPadding - nWidthSearchButton), 0, 2 * -nPadding - nWidthSearchButton, -nPadding },
							Base = "BK3:btnHolo_ListView_Mid",
							Text = kstrSearch,
							DT_VCENTER = true,
							DT_CENTER = true,
							Font = kstrFont,
							Events = {
								ButtonSignal = OnSearch,
								MouseButtonUp = OnSearchButtonUp,
							},
						},
						-- Button: Filters
						{
							Class = "Button",
							AnchorPoints = { 1, 0, 1, 1 },
							AnchorOffsets = { -nPadding - nWidthSearchButton, 0, -nPadding, -nPadding },
							Base = "BK3:btnHolo_ListView_Mid",
							Text = "Filters [+]",
							ButtonType = "Check",
							DT_VCENTER = true,
							DT_CENTER = true,
							Font = kstrFont,
							Events = {
								ButtonCheck = OnShowFilters,
								ButtonUncheck = OnHideFilters,
							},
						},
					},
				},
				-- Search Results
				{
					Name = "Message",
					AnchorPoints = { 0, 0, 1, 0.5, },
					AnchorOffsets = { nWidthCategories + nPadding, nHeightSearch + nPadding, 0, 0 },
					DT_VCENTER = true,
					DT_CENTER = true,
					Visible = false,
					Font = kstrFont,
				},
				{
					Name = "Results",
					AnchorPoints = { 0, 0, 1, 1, },
					AnchorOffsets = { nWidthCategories + nPadding, nHeightSearch + nPadding, 0, 0 },
					Children = {
						-- Header
						{
							Name = "Header",
							AnchorPoints = { 0, 0, 1, 0 },
							AnchorOffsets = { 0, 0, -20, nHeightHeader },
							Children = {}, -- Will be generated later.
						},
						-- Items
						{
							BGColor = "aa000000",
							Name = "Grid",
--											Border = false,
							Picture = true,
							Sprite = "ClientSprites:WhiteFill",
							AnchorPoints = { 0, 0, 1, 1, },
							AnchorOffsets = { 0, nHeightHeader + nPadding, 0, 0 },
							VScroll = true,
							AutoHideScroll = false,
							Template = "Holo_ScrollList",
						},
					},
				},
				-- Search Filter
				{
--									BGColor = "aa000000",
					Name = "Filters",
					Border = true,
					Picture = true,
					Sprite = "BK3:UI_BK3_Holo_InsetDivider",
					AnchorPoints = { 0, 0, 1, 0, },
					AnchorOffsets = { nWidthCategories + nPadding, nHeightSearch + nPadding, 0, nHeightFilters },
					Visible = false,
					Children = {
						-- Known Schematics
						{
							Name = "KnownSchematics",
							WidgetType = "CheckBox",
							AnchorOffsets = { 4, 8, 350, 30 },
							Text = "Filter known Schematics",
							Base = "HologramSprites:HoloCheckBoxBtn",
							Font = kstrFont,
						},
						-- Rune Slots
						{
							Name = "RuneSlots",
							WidgetType = "CheckBox",
							AnchorOffsets = { 4, 38, 180, 60 },
							Text = "Minimum Rune Slots",
							Base = "HologramSprites:HoloCheckBoxBtn",
							Font = kstrFont,
						},
						{
							Class = "EditBox",
							Name = "RuneSlotsAmount",
							AnchorOffsets = { 180, 38, 350, 54 },
							Text = "4",
							DT_VCENTER = true,
							DT_CENTER = true,
							Font = kstrFont,
						},
						-- Maximum Price
						{
							Name = "MaxPrice",
							WidgetType = "CheckBox",
							AnchorOffsets = { 4, 68, 180, 90 },
							Text = "Maximum Price",
							Base = "HologramSprites:HoloCheckBoxBtn",
							Font = kstrFont,
						},
						{
							Class = "CashWindow",
							Name = "MaxPriceAmount",
							AnchorOffsets = { 180, 68, 350, 86 },
							Amount = 10000,
							DT_VCENTER = true,
							DT_RIGHT = true,
							Font = kstrFont,
							AllowEditing = true,
						},
					},
				},
				-- Current Item (Buy/Bid)
				{
					Name = "CurrentItem",
					Border = true,
					Picture = true,
					Sprite = "BK3:UI_BK3_Holo_InsetDivider",
					AnchorPoints = { 0, 1, 1, 1, },
					AnchorOffsets = { nWidthCategories + nPadding, -nHeightCurrentItem, 0, 0 },
					Visible = false,
					Children = {
						{
							AnchorPoints = { 0, 0, 1, 1, },
							AnchorOffsets = { 0, 0, 0, 0 },
							Children = {
								-- Icon
								{
									Name = "IconContainer",
									AnchorPoints = { 0, 0, 0, 1 },
									AnchorOffsets = { 4, 4, nHeightCurrentItem - 8, -4 },
									Picture = true,
									Sprite = "ClientSprites:WhiteFill",
									Events = {
										MouseEnter = ShowItemTooltip,
										MouseExit = HideItemTooltip,
										MouseButtonUp = self.ItemPreviewImproved and ShowItemPreview or nil,
									},
									Children = {
										{
											Name = "IconBackground",
											AnchorPoints = { 0, 0, 1, 1 },
											AnchorOffsets = { nIconBorder, nIconBorder, -nIconBorder, -nIconBorder },
											Picture = true,
											BGColor = "black",
											Sprite = "ClientSprites:WhiteFill",
											Children = {
												{
													Name = "Icon",
													AnchorPoints = { 0, 0, 1, 1 },
													AnchorOffsets = { 0, 0, 0, 0 },
													Picture = true,
													BGColor = "white",
													Children = {
														{
															Name = "Count",
															AnchorPoints = { 0, 0, 1, 1 },
															AnchorOffsets = { 0, 0, -2, -1 },
															DT_RIGHT = true,
															DT_BOTTOM = true,
															Font = "CRB_Interface9_O",
														},
													},
												},
											},
										},
									},
								},
								-- Name
								{
									Name = "Name",
									AnchorPoints = { 0, 0, 1, 1 },
									AnchorOffsets = { nHeightCurrentItem - 2, 0, 0, 0 },
									DT_VCENTER = true,
									Font = kstrFont,
									AutoScaleTextOff = true,
								},
								-- Bid
								{
									Class = "CashWindow",
									Name = "Bid",
									AnchorPoints = { 1, 0, 1, 1 },
									AnchorOffsets = { -410, 0, -284, 0 },
									DT_RIGHT = true,
									DT_VCENTER = true,
									Font = kstrFont,
									AllowEditing = true,
									Events = { CashWindowAmountChanged = OnChangeBidAmount },
								},
								{
									Class = "ActionConfirmButton",
									Name = "BtnBid",
									AnchorPoints = { 1, 0, 1, 1 },
									AnchorOffsets = { -284, nPadding, -204, -nPadding },
									Base = "BK3:btnHolo_ListView_Mid",
									Text = Apollo.GetString("MarketplaceAuction_BidBtn"),
									DT_VCENTER = true,
									DT_CENTER = true,
									Font = kstrFont,
								},
								-- Buyout
								{
									Class = "MLWindow",
									Name = "Price",
									AnchorPoints = { 1, 0, 1, 1 },
									AnchorOffsets = { -200, 12, -84, 0 },
								},
								{
									Class = "ActionConfirmButton",
									Name = "BtnBuyout",
									AnchorPoints = { 1, 0, 1, 1 },
									AnchorOffsets = { -80, nPadding, -nPadding, -nPadding },
									Base = "BK3:btnHolo_ListView_Mid",
									Text = Apollo.GetString("MarketplaceAuction_BuyoutHeader"),
									DT_VCENTER = true,
									DT_CENTER = true,
									Font = kstrFont,
								},
							},
						},
					},
				},
			},
		}):GetInstance(self, self.twndMain:GetTabContainer("browse"));

self.wndTreeView = self.wndMain:FindChild("TreeView");
pcall(function() OnTreeWindowLoad(self, self.wndTreeView, self.wndTreeView); end, Print)

		self.wndSearch = self.wndMain:FindChild("Search");
		self.wndFilters = self.wndMain:FindChild("Filters");
		self.wndResults = self.wndMain:FindChild("Results");
		self.wndResultsGrid = self.wndResults:FindChild("Grid");
		self.wndCurrentItem = self.wndMain:FindChild("CurrentItem");

		self:UpdateListHeaders();
	end
end

-----------------------------------------------------------------------------
-- Items
-----------------------------------------------------------------------------

local ktAdditionalColumns = {
	[1] = { "Level", "ItemLevel", "RuneSlots" }, -- Armor
	[15] = { "Level", "ItemLevel", "RuneSlots" }, -- Gear
	[20] = { "Level" }, -- Housing
	[2] = { "Level", "ItemLevel", "RuneSlots", "AssaultPower", "SupportPower" }, -- Weapon
	[5] = { "BagSlots" }, -- Bag
	ShoppingList = { "Level", "ItemLevel", "RuneSlots" },
};

local ktListColumns = {
	-- Generic
	Name = {
		Text = "Item",
		-- Width will be calculated (takes all available space)
		-- Method is also hardcoded currently, because we also display the icon
	},
	Bid = {
		Text = "Current Bid",
		Width = 0.12,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local nBid = aucCurr:GetCurrentBid():GetAmount();
			local bHasBids = (nBid > 0);
			if (nBid == 0) then
				nBid = aucCurr:GetMinBid():GetAmount();
			end

			return {
				Class = "Window",
				Name = "Bid",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Pixies = self:CreateCashPixie(nBid, not bHasBids),
				UserData = nBid,
			};
		end,
	},
	Buyout = {
		Text = "Buyout Price",
		Width = 0.12,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local nBuyout = aucCurr:GetBuyoutPrice():GetAmount();

			return {
				Class = "Window",
				Name = "Buyout",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Pixies = self:CreateCashPixie(nBuyout),
				UserData = nBuyout,
			};
		end,
	},
	TimeRemaining = {
		Text = "Time\nLeft",
		Width = 0.08,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local eTimeRemaining = aucCurr:GetTimeRemainingEnum();

			return {
				Name = "TimeRemaining",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = ktDurationStrings[eTimeRemaining],
				TextColor = ktDurationColors[eTimeRemaining];
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				UserData = eTimeRemaining,
			};
		end,
	},
	-- Bags
	BagSlots = {
		Text = "Slots",
		Width = 0.07,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local nBagSlots = itemCurr:GetBagSlots();

			return {
				Name = "BagSlots",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = nBagSlots,
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				UserData = nBagSlots,
			};
		end,
	},
	-- Armor
	Level = {
		Text = "Level",
		Width = 0.07,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local nLevel = itemCurr:GetRequiredLevel();

			return {
				Name = "Level",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = nLevel,
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				UserData = nLevel,
			};
		end,
	},
	ItemLevel = {
--		Text = "Item\nLevel",
		Text = "Power",
		Width = 0.07,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local nItemPower = itemCurr:GetItemPower();

			return {
				Name = "ItemLevel",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = nItemPower,
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				UserData = nItemPower,
			};
		end,
	},
	RuneSlots = {
		Text = "Rune\nSlots",
		Width = 0.07,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local tInfo = itemCurr:GetDetailedInfo();
			local nRuneSlots = 0;
			for _, tData in pairs(tInfo) do
				if (tData.tSigils and tData.tSigils.arSigils) then
					nRuneSlots = nRuneSlots + #tData.tSigils.arSigils;
				end
			end

			return {
				Name = "RuneSlots",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = nRuneSlots,
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				TextColor = ktQualityColors[nRuneSlots + 1];
				UserData = nRuneSlots,
			};
		end,
	},
	-- Weapons
	AssaultPower = {
		Text = "AP",
		Description = "Assault Power",
		Width = 0.07,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local tInfo = itemCurr:GetDetailedInfo();
			local nAssaultPower = 0;
			for _, tData in pairs(tInfo) do
				if (tData.arInnateProperties) then
					for _, tInnateProperty in ipairs(tData.arInnateProperties) do
						if (tInnateProperty.eProperty == Unit.CodeEnumProperties.AssaultPower) then
							nAssaultPower = floor(tInnateProperty.nValue + 0.05);
							break;
						end
					end
				end
			end

			return {
				Name = "AssaultPower",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = nAssaultPower,
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				UserData = nAssaultPower,
			};
		end,
	},
	SupportPower = {
		Text = "SP",
		Description = "Support Power",
		Width = 0.08,
		GetWindowDefinitions = function(self, aucCurr, itemCurr, fPosition, fWidth)
			local tInfo = itemCurr:GetDetailedInfo();
			local nSupportPower = 0;
			for _, tData in pairs(tInfo) do
				if (tData.arInnateProperties) then
					for _, tInnateProperty in ipairs(tData.arInnateProperties) do
						if (tInnateProperty.eProperty == Unit.CodeEnumProperties.SupportPower) then
							nSupportPower = floor(tInnateProperty.nValue + 0.05);
							break;
						end
					end
				end
			end

			return {
				Name = "SupportPower",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = nSupportPower,
				Font = kstrFont,
				DT_CENTER = true,
				DT_VCENTER = true,
				AutoScaleTextOff = true,
				UserData = nSupportPower,
			};
		end,
	},
};

--for _, strColumn in ipairs( { "SupportPower", "AssaultPower", "RuneSlots", "ItemLevel", "Level", "BagSlots", "TimeRemaining" }) do
--	ktListColumns[strColumn].GetPixie = ktListColumns[strColumn].GetWindowDefinitions;
--end

local function CreateHeader(self, strName, strText, fPosition, fWidth)
	local wndHeader = self.wndResults:FindChild("Header");

	return self.GeminiGUI:Create({
		Class = "Button",
		ButtonType = "Check",
		RadioGroup = "SezzUI_AH_ResultSorting",
		Text = strText,
		Name = strName,
		Base = "BK3:btnHolo_ListView_Mid",
		Font = kstrFont,
		DT_VCENTER = true,
		DT_CENTER = true,
		AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		Events = { ButtonCheck = OnHeaderClick, ButtonUncheck = OnHeaderClick },
		AutoScaleTextOff = true,
		DT_WORDBREAK = true,
	}):GetInstance(self, wndHeader);
end

function M:UpdateListHeaders()
	local wndHeader = self.wndResults:FindChild("Header");

	local fWidthName = 1;
	local fPosition = 0;
	local tHeaders = { "Name", "Bid", "Buyout", "TimeRemaining" };
	local bSortHeaderValid = false;

	-- Add additional headers (as defined by current category/family)
	local tAdditionalColumns = (self.nSelectedFamily and ktAdditionalColumns[self.nSelectedFamily]) or (self.strSelectedShoppingList and ktAdditionalColumns.ShoppingList) or nil;
	if (tAdditionalColumns) then
		local nInsertPos = 2;
		for _, strName in ipairs(tAdditionalColumns) do
			tinsert(tHeaders, nInsertPos, strName);
			nInsertPos = nInsertPos + 1;
		end
	end

	-- Calculate "name" width
	for _, strName in ipairs(tHeaders) do
		if (self.strSortHeader == strName) then
			bSortHeaderValid = true;
		end

		if (strName ~= "Name") then
			fWidthName = fWidthName - ktListColumns[strName].Width;
		end
	end
	ktListColumns.Name.Width = fWidthName;

	if (not bSortHeaderValid) then
		self:SetSortOrder("Name", "ASC");
	end

	-- Add all headers
	wndHeader:DestroyChildren();
	for _, strName in ipairs(tHeaders) do
		local wndHeader = CreateHeader(self, strName, ktListColumns[strName].Text, fPosition, ktListColumns[strName].Width);

		if (self.strSortHeader and self.strSortHeader == strName and self.strSortDirection == "ASC") then
			wndHeader:SetCheck(true);
		end

		fPosition = fPosition + ktListColumns[strName].Width;
	end

	self.tHeaders = tHeaders;
end

local kstrItemBGColors = {
	Default = "aa000000",
	Owned = "aa002938",
	TopBidder = "aa102D00",
	KnownSchematic = "aa381010",
};

function M:CreateListItem(aucCurr)
	local fPosition = ktListColumns.Name.Width;

	local itemCurr = aucCurr:GetItem();
	local bIsKnownSchematic = (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
	local strCount = aucCurr:GetCount() ~= 1 and aucCurr:GetCount() or "";
	local strName = itemCurr:GetName();

	local strBGColor;
	if (aucCurr:IsOwned()) then
		strBGColor = kstrItemBGColors.Owned;
	elseif (aucCurr:IsTopBidder()) then
		strBGColor = kstrItemBGColors.TopBidder;
	elseif (bIsKnownSchematic) then
		strBGColor = kstrItemBGColors.KnownSchematic;
	else
		strBGColor = kstrItemBGColors.Default;
	end

	-- Bids
	local tBidMinimum = aucCurr:GetMinBid();
	local tBidCurrent = aucCurr:GetCurrentBid();
	local bHasBids, nBidAmount = tBidCurrent:GetAmount() > 0, 0;

	if (bHasBids) then
		nBidAmount = tBidCurrent:GetAmount();
	else
		nBidAmount = tBidMinimum:GetAmount();
	end

	-- Create Control
	local tWindowDefinitions = {
		BGColor = strBGColor,
		Border = false,
		Picture = true,
		Sprite = "ClientSprites:WhiteFill",
		AnchorPoints = { 0, 0, 1, 0, },
		AnchorOffsets = { -5, 0, 5, nItemSize + 1 },
		Name = "ListItemBuy",
		Children = {
			-- Icon + Name
			{
				AnchorPoints = { 0, 0, ktListColumns.Name.Width, 1 },
				AnchorOffsets = { 6, 0, 0, 0 },
				Name = "ButtonBorderFix",
				Children = {
					-- Icon
					{
						Name = "Name", -- TODO: It's actually the IconContainer, but I need the GetData() for sorting.
						UserData = strName,
						AnchorPoints = { 0, 0, 0, 0 },
						AnchorOffsets = { 1, 1, nItemSize - 2, nItemSize - 2 },
						Picture = true,
						BGColor = ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior],
						Sprite = "ClientSprites:WhiteFill",
						Events = {
							MouseEnter = ShowItemTooltip,
							MouseExit = HideItemTooltip,
							MouseButtonUp = self.ItemPreviewImproved and ShowItemPreview or nil,
						},
						Pixies = {
							-- Count
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { nIconBorder, nIconBorder, -nIconBorder -2, -nIconBorder -1 },
								Text = strCount,
								DT_RIGHT = true,
								DT_BOTTOM = true,
								Font = "CRB_Interface9_O",
							},
							-- Icon
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { nIconBorder, nIconBorder, -nIconBorder, -nIconBorder },
								BGColor = "white",
								Sprite = itemCurr:GetIcon(),
							},
							-- Background
							{
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { nIconBorder, nIconBorder, -nIconBorder, -nIconBorder },
								BGColor = "black",
								Sprite = "ClientSprites:WhiteFill",
							},
						},
					},
				},
			},
		},
		Pixies = {
			-- Name
			{
				AnchorPoints = { 0, 0, ktListColumns.Name.Width, 1 },
				AnchorOffsets = { nItemSize + 4 + 6, 0, 0, 0 },
				Text = strName,
				TextColor = ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior],
				DT_VCENTER = true,
				Font = kstrFont,
			},
		},
		UserData = aucCurr,
		Base = "sUI:SimpleButton",
		Class = "Button",
		ButtonType = "Check",
		RadioGroup = "SezzUI_AH_ResultItem",
		Border = false,
		Events = {
			ButtonCheck = OnSelectItem,
			ButtonUncheck = OnDeselectItem,
			MouseButtonUp = OnClickItem,
		},
	};

	for _, strName in ipairs(self.tHeaders) do
		if (strName ~= "Name") then
--			if (ktListColumns[strName].GetPixie) then
--				local tPixies = { ktListColumns[strName].GetPixie(self, aucCurr, itemCurr, fPosition, ktListColumns[strName].Width) }; -- TOOD
--
--				for _, tPixie in ipairs(tPixies) do
--					tinsert(tWindowDefinitions.Pixies, tPixie);
--				end
--
--				fPosition = fPosition + ktListColumns[strName].Width;
--			elseif (ktListColumns[strName].GetWindowDefinitions) then
			if (ktListColumns[strName].GetWindowDefinitions) then
				local tDefinitions = ktListColumns[strName].GetWindowDefinitions(self, aucCurr, itemCurr, fPosition, ktListColumns[strName].Width); -- TOOD

				tinsert(tWindowDefinitions.Children, tDefinitions);
				fPosition = fPosition + ktListColumns[strName].Width;
			end
		end
	end

	local wndItem = self.GeminiGUI:Create(tWindowDefinitions):GetInstance(self, self.wndResultsGrid);
	wndItem:Enable(false); -- GridVisibleItemsCheck enables it!

--	for _, wndChild in ipairs(wndItem:GetChildren()) do
--		wndChild:Enable(wndChild:GetName() == "ButtonBorderFix");
--	end

--	SendVarToRover("AHCurrentAuction", aucCurr);
--	SendVarToRover("AHCurrentAuctionWindow", wndItem);

	return wndItem;
end

function M:UpdateListItem(wndItem, aucCurr)
	-- Update a auction list item
	-- Properties that can change after creating it: bIsKnownSchematic, IsOwned(), IsTopBidder(), GetCurrentBid()
	-- Maybe also (needs testing): GetCount()
	wndItem:SetData(aucCurr);

	local itemCurr = aucCurr:GetItem();
	local bIsKnownSchematic = (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);

	-- Background Color
	local strBGColor;
	if (aucCurr:IsOwned()) then
		strBGColor = kstrItemBGColors.Owned;
	elseif (aucCurr:IsTopBidder()) then
		strBGColor = kstrItemBGColors.TopBidder;
	elseif (bIsKnownSchematic) then
		strBGColor = kstrItemBGColors.KnownSchematic;
	else
		strBGColor = kstrItemBGColors.Default;
	end

	wndItem:SetBGColor(strBGColor);

	-- Current Bid
	local tBidCurrent = aucCurr:GetCurrentBid();
	if (tBidCurrent:GetAmount() > 0) then
		local wndBid = wndItem:FindChild("Bid");
		local tPixies = self:CreateCashPixie(tBidCurrent:GetAmount(), false);

		wndBid:DestroyAllPixies();
S.Log:debug(tPixies);
		for _, tPixie in ipairs(tPixies) do
			wndBid:AddPixie(tPixie);
		end
	end
end

--[[
function M:Test()
	local aucCurr = {};
	local itemCurr = S:GetInventory()[1].itemInBag;

	local tBidMinimum = { GetAmount = function() return 123456; end };
	local tBidCurrent = { GetAmount = function() return 0; end };
	local tBuyoutPrice = { GetAmount = function() return 2345608; end };
	local eShort = ItemAuction.CodeEnumAuctionRemaining.Short;

	function aucCurr:GetItem() return itemCurr; end
	function aucCurr:IsOwned() return false; end
	function aucCurr:IsTopBidder() return false; end
	function aucCurr:GetCount() return 1; end

	function aucCurr:GetMinBid() return tBidMinimum; end
	function aucCurr:GetCurrentBid() return tBidCurrent; end
	function aucCurr:GetBuyoutPrice() return tBuyoutPrice; end
	function aucCurr:GetTimeRemainingEnum() return eShort; end

	for i = 1, 1000 do
		self:CreateListItem(aucCurr);
	end

	self.wndResultsGrid:ArrangeChildrenVert(0);

	self:OnFrameCount();
end
--]]

-----------------------------------------------------------------------------
-- FPS Fix
-----------------------------------------------------------------------------

local nPrevScrollPos;
local nPrevHeight;

function M:GridVisibleItemsCheck(strEvent, strVar, nFrameCount)
--	if (self.bIsSearching or not self.wndMain or not self.wndMain:IsValid() or not self.wndResultsGrid) then return; end
	if (self.bIsSearching or not self.tAuctions or #self.tAuctions == 0) then return; end

	local wndGrid = self.wndResultsGrid;
	local nScrollPos = wndGrid:GetVScrollPos();
	local nHeight = wndGrid:GetHeight();

	if (not nPrevScrollPos or not nPrevHeight or nPrevScrollPos ~= nScrollPos or nPrevHeight ~= nHeight) then
		nPrevScrollPos = nScrollPos;
		nPrevHeight = nHeight;

		for _, wndItem in ipairs(wndGrid:GetChildren()) do
			local _, nPosY = wndItem:GetPos();
			wndItem:Enable(nPosY < nHeight and nPosY + nItemSize > 0);
		end
	end
end

function M:GridVisibleItemsCheckForced()
	nPrevHeight = nil;
	nPrevScrollPos = nil;
	self:GridVisibleItemsCheck(0,0,0);
end
