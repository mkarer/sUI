--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

require "Window";
require "GameLib";
require "Item";
require "Unit";
require "MarketplaceLib";
require "ItemAuction";

local strlen, strfind, gmatch, format, tinsert, floor, max = string.len, string.find, string.gmatch, string.format, table.insert, math.floor, math.max;
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

local function OnTreeWindowLoad(self, wndHandler, wndControl)
	local nNodeIdRoot = wndControl:AddNode(0, "Auctions");
	local nNodeIdSelected, nNodeIdSelectedCategory;

	--[[
	-- Armor
	for _, tDataRootCategory in ipairs(MarketplaceLib.GetAuctionableCategories(1)) do
		local nNodeIdRootCategory = wndControl:AddNode(nNodeIdRoot, tDataRootCategory.strName, nil, tDataRootCategory.nId);

		for _, tDataType in pairs(MarketplaceLib.GetAuctionableTypes(tDataRootCategory.nId) or {}) do
			if (strlen(tDataType.strName) > 0) then
				wndControl:AddNode(nNodeIdRootCategory, tDataType.strName, nil, tDataType.nId);
			end
		end
	end
	]]

	-- Others
	for _, tDataRootCategory in ipairs(MarketplaceLib.GetAuctionableFamilies()) do
--		if (tDataRootCategory.nId > 1) then -- Ignore Armor
			local nNodeIdRootCategory = wndControl:AddNode(nNodeIdRoot, tDataRootCategory.strName, nil, { Type = "Family", Id = tDataRootCategory.nId });

			for _, tDataCategory in pairs(MarketplaceLib.GetAuctionableCategories(tDataRootCategory.nId) or {}) do
				local tTypes = MarketplaceLib.GetAuctionableTypes(tDataCategory.nId) or {};
				local nNodeIdCategory = nNodeIdRootCategory;

				if (tDataRootCategory.nId == 1 or (#tTypes == 0 and strlen(tDataCategory.strName) > 0)) then
					nNodeIdCategory = wndControl:AddNode(nNodeIdRootCategory, tDataCategory.strName, nil, { Type = "Category", Id = tDataCategory.nId });
				end

				for _, tDataType in pairs(tTypes) do
					local strName = tDataType.strName;
					if (strfind(strName, "-")) then
						strName = gmatch(strName, ".*-(.*)")();
					end

					local nNodeId = wndControl:AddNode(nNodeIdCategory, strName, nil, { Type = "Type", Id = tDataType.nId });
					if (strName == "Implant") then
						nNodeIdSelected = nNodeId; -- TEMP
						nNodeIdSelectedCategory = nNodeIdRootCategory;
					end
				end
			end

			wndControl:CollapseNode(nNodeIdRootCategory);
--		end
	end

	if (nNodeIdSelected) then -- TEMP
		wndControl:ExpandNode(nNodeIdSelectedCategory);
		wndControl:SelectNode(nNodeIdSelected);
		self.tSelectedCategory = wndControl:GetNodeData(nNodeIdSelected);
		self.nSelectedFamily = 15;
	end

	SendVarToRover("AHCategories", wndControl);
end

local function OnTreeSelectionChanged(self, wndHandler, wndControl, hSelected, hPrevSelected)
	self.tSelectedCategory = wndControl:GetNodeData(hSelected);

	local nParentId = wndControl:GetParentNode(hSelected);
	while (wndControl:GetParentNode(nParentId) and wndControl:GetParentNode(nParentId) > 1) do
		nParentId = wndControl:GetParentNode(nParentId);
	end

	if (nParentId <= 1 and self.tSelectedCategory.Type == "Family") then
		self.nSelectedFamily = self.tSelectedCategory.Id;
	else
		self.nSelectedFamily = wndControl:GetNodeData(nParentId).Id;
	end
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
	self:SetSearchState(true);
	self:BuildFilter();
	self:UpdateListHeaders();
	self:Search();
end

local function OnChangeBidAmount(self, wndHandler, wndControl)
	local aucCurr = wndControl:GetParent():GetParent():GetData();
	self.wndCurrentItem:FindChild("BtnBid"):SetActionData(GameLib.CodeEnumConfirmButtonType.MarketplaceAuctionBuySubmit, aucCurr, false, wndControl:GetCurrency());
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
	local nBidAmount = nCurrBidPrice == 0 and nMinBidPrice or nCurrBidPrice + 1;

	-- Bid
	self.wndCurrentItem:FindChild("Bid"):Enable(bCanBid);
	self.wndCurrentItem:FindChild("Bid"):SetAmount(nBidAmount);
	self.wndCurrentItem:FindChild("BtnBid"):SetActionData(GameLib.CodeEnumConfirmButtonType.MarketplaceAuctionBuySubmit, aucCurr, false, nBidAmount);

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
	if (not self.wndMain or not self.wndMain:IsValid()) then
		local nWidthCategories = 220;
		local nWidthSearchButton = 100;
		local nPaddingSearchControl = 4;
		local nHeightSearch = 40;
		local nHeightFilters = 200;
		local nHeightHeader = 40;
		local nHeightCurrentItem = 40;

		self.wndMain = self.GeminiGUI:Create({
			Name = "SezzAuctionHouse",
			Moveable = true,
			Escapable = true,
			Overlapped = true,
			AnchorCenter = { 1000, 800 },
			Picture = true,
			Border = true,
			Sprite = "BK3:UI_BK3_Holo_InsetHeader",
			BGColor = "xkcdBabyPink",
			Sizable = true,
			Visible = false,
			Events = {
				WindowClosed = self.Close,
				WindowKeyEscape = self.Close,
				WindowShow = self.Open,
			},
			Children = {
				{
					Name = "Title",
					AnchorPoints = { 0, 0, 1, 0 },
					AnchorOffsets = { 5, 5, -5, 34 },
					Font = "CRB_Header12_O",
					Text = Apollo.GetString("MarketplaceAuction_AuctionHouse"),
					DT_VCENTER = true,
					DT_CENTER = true,
				},
				{
					Name = "BtnClose",
					AnchorPoints = { 1, 0, 1, 0 },
					Class = "Button",
					Base = "CRB_ChallengeTrackerSprites:btnChallengeClose",
					AnchorOffsets = { -30, 8, -10, 30 },
					Events = { ButtonSignal = self.Close },
				},
				{
					Name = "Framing",
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 0, 0, 0, 0 },
					Picture = true,
					Border = false,
					Sprite = "BK3:UI_BK3_Holo_InsetHeader",
					BGColor = "white",
					Children = {
						{
							AnchorPoints = { 0, 0, 1, 1 },
							AnchorOffsets = { 14, 48, -14, -14 },
							Children = {
								-- CONTENT
								-- Categories
								{
									Class = "TreeControl",
									Font = kstrFont,
									AnchorPoints = { 0, 0, 0, 1 },
									AnchorOffsets = { 0, 0, nWidthCategories, 0 },
									VScroll = true,
									AutoHideScroll = false,
									Template = "Holo_ScrollListSmall",
									SelectedBG = "BK3:UI_BK3_Holo_InsetDivider",
									MinimumNodeHeight = 18,
									Events = {
										WindowLoad = OnTreeWindowLoad,
										TreeSelectionChanged = OnTreeSelectionChanged,
									},
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
											AnchorOffsets = { 4, 8, 300, 30 },
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
											AnchorOffsets = { 180, 38, 300, 54 },
											Text = "0",
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
											AnchorOffsets = { 180, 68, 300, 86 },
											Text = "0",
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
								-- CONTENT
							},
						},
					},
				},
				{
					Name = "Backdrop",
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 0, 0, 0, 0 },
					Picture = true,
					Border = false,
					Sprite = "sUI:HoloWindowBackdrop",
					BGColor = "cc222326",
					Children = {},
				},
			},
		}):GetInstance(self);

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

local function OnWindowShow(self, wndHandler, wndControl)
	-- Background Opacity Fix
	if (wndHandler:GetOpacity() == 1) then
		S:ShowDelayed(wndHandler); 
	end
end

local ktAdditionalColumns = {
	[1] = { "Level", "ItemLevel", "RuneSlots" }, -- Armor
	[15] = { "Level", "ItemLevel", "RuneSlots" }, -- Gear
	[20] = { "Level" }, -- Housing
	[2] = { "Level", "ItemLevel", "RuneSlots", "AssaultPower", "SupportPower" }, -- Weapon
	[5] = { "BagSlots" }, -- Bag
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
				Class = "MLWindow",
				Name = "Bid",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 9, 0, 0 },
				Text = S:GetMoneyAML(nBid, kstrFont),
				TextColor = bHasBids and "white" or "darkgray",
				Events = {
					WindowShow = not bHasBids and OnWindowShow or nil,
				},
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
				Class = "MLWindow",
				Name = "Buyout",
				AnchorPoints = { fPosition, 0, fPosition + fWidth, 1 },
				AnchorOffsets = { 0, 9, 0, 0 },
				Text = S:GetMoneyAML(nBuyout, kstrFont),
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
			local tInfo = itemCurr:GetDetailedInfo();
			-- TODO: Custom Calculations
			--[[
			local nItemPower = 1;
			for _, tData in pairs(tInfo) do
				if (tData.arInnateProperties) then
					for _, tInnateProperty in ipairs(tData.arInnateProperties) do
						nItemPower = nItemPower + tInnateProperty.nValue * 0.61;
					end
				end

				if (tData.arBudgetBasedProperties) then
					for _, tProperty in ipairs(tData.arBudgetBasedProperties) do
						if (tProperty.eProperty == Unit.CodeEnumProperties.BaseHealth) then
							nItemPower = nItemPower + tProperty.nValue / 27.595238;
						elseif (tProperty.eProperty == Unit.CodeEnumProperties.ShieldCapacityMax) then
							nItemPower = nItemPower + tProperty.nValue / 41.392857;
							Print(tProperty.nValue);
						elseif (tProperty.eProperty == Unit.CodeEnumProperties.Armor) then
							nItemPower = nItemPower + tProperty.nValue / 8;
						elseif (tProperty.eProperty ~= Unit.CodeEnumProperties.PvPDefensiveRating and tProperty.eProperty ~= Unit.CodeEnumProperties.PvPOffensiveRating) then
							nItemPower = nItemPower + tProperty.nValue;
						end 

						if tProperty.nValue > 100 then
							Print(tProperty.eProperty);
						end
					end
				end

				if (tData.tSigils and tData.tSigils.arSigils) then
					for _, tSigil in ipairs(tData.tSigils.arSigils) do
						nItemPower = nItemPower + 20 * tSigil.nPercent;
					end
				end
			end

			nItemPower = floor((nItemPower / 2) * (itemCurr:GetItemPower() / 800) / 36) + itemCurr:GetRequiredLevel();
			--]]

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
	if (self.nSelectedFamily and ktAdditionalColumns[self.nSelectedFamily]) then
		local nInsertPos = 2;
		for _, strName in ipairs(ktAdditionalColumns[self.nSelectedFamily]) do
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

function M:CreateListItem(aucCurr)
	local fPosition = ktListColumns.Name.Width;

	local itemCurr = aucCurr:GetItem();
	local bIsKnownSchematic = (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
	local strCount = aucCurr:GetCount() ~= 1 and aucCurr:GetCount() or "";
	local strName = itemCurr:GetName();

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
		BGColor = bIsKnownSchematic and "aa381010" or "aa000000",
		Border = false,
		Picture = true,
		Sprite = "ClientSprites:WhiteFill",
		AnchorPoints = { 0, 0, 1, 0, },
		AnchorOffsets = { -5, 0, 0, nItemSize + 1 },
		Name = "ListItem",
		Children = {
			-- Icon + Name
			{
				AnchorPoints = { 0, 0, ktListColumns.Name.Width, 1 },
				AnchorOffsets = { 6, 0, 0, 0 },
				Children = {
					-- Icon
					{
						Name = "IconContainer",
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
										Sprite = itemCurr:GetIcon(),
										Children = {
											{
												Name = "Count",
												AnchorPoints = { 0, 0, 1, 1 },
												AnchorOffsets = { 0, 0, -2, -1 },
												Text = strCount,
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
						AnchorOffsets = { nItemSize + 4, 0, 0, 0 },
						Text = strName,
						TextColor = ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior],
						DT_VCENTER = true,
						Font = kstrFont,
						AutoScaleTextOff = true,
						UserData = strName,
					},
				},
			},
		},
		UserData = aucCurr,
		Visible = false,
		Base = "sUI:SimpleButton",
		Class = "Button",
		ButtonType = "Check",
		RadioGroup = "SezzUI_AH_ResultItem",
		Border = false,
		Events = {
			ButtonCheck = OnSelectItem,
			ButtonUncheck = OnDeselectItem,
		},
	};

	for _, strName in ipairs(self.tHeaders) do
		if (strName ~= "Name" and ktListColumns[strName].GetWindowDefinitions) then
			local tDefinitions = ktListColumns[strName].GetWindowDefinitions(self, aucCurr, itemCurr, fPosition, ktListColumns[strName].Width); -- TOOD

			tinsert(tWindowDefinitions.Children, tDefinitions);
			fPosition = fPosition + ktListColumns[strName].Width;
		end
	end

	local wndItem = self.GeminiGUI:Create(tWindowDefinitions):GetInstance(self, self.wndResultsGrid);

	if (not bHasBids) then
		wndItem:FindChild("Bid"):SetOpacity(0.5, 5e+20);
	end

	wndItem:Show(true, true);
	wndItem:FindChild("Bid"):Show(true, true);

	SendVarToRover("AHCurrentAuction", aucCurr);

	return wndItem;
end
