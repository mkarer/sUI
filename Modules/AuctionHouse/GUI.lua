--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local strlen, strfind, gmatch, format = string.len, string.find, string.gmatch, string.format;
local Apollo, MarketplaceLib, GameLib = Apollo, MarketplaceLib, GameLib;

-----------------------------------------------------------------------------
-- GUI
-----------------------------------------------------------------------------

local ktColumnsEquippable = { "Level", "Item Level", "Rune Slots" };
local ktAdditionalColumns = {
	[1] = ktColumnsEquippable, -- Armor
	[16] = ktColumnsEquippable, -- Gear
	[2] = { "Level", "Item Level", "Rune Slots", "Assault Power", "Support Power" }, -- Weapon
	[5] = { "Slots" }, -- Bag
};

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

	if (nNodeIdSelected) then
		wndControl:ExpandNode(nNodeIdSelectedCategory);
		wndControl:SelectNode(nNodeIdSelected);
		self.tSelectedCategory = wndControl:GetNodeData(nNodeIdSelected);
	end

	SendVarToRover("AHCategories", wndControl);
end

local function OnTreeSelectionChanged(self, wndHandler, wndControl, hSelected, hPrevSelected)
	self.tSelectedCategory = wndControl:GetNodeData(hSelected);

	local nParentId = wndControl:GetParentNode(hSelected);
	while (wndControl:GetParentNode(nParentId) and wndControl:GetParentNode(nParentId) > 1) do
		nParentId = wndControl:GetParentNode(nParentId);
	end

	self.nSelectedFamily = wndControl:GetNodeData(nParentId).Id;
end

local function OnShowFilters(self, wndHandler, wndControl)
	Print("Show Filters")
	wndControl:SetText("Filters [-]");
	self.wndFilters:Show(true, true);

	local nL, nT, nR, nB = self.wndResults:GetAnchorOffsets();
	nT = self.wndSearch:GetHeight() + self.wndFilters:GetHeight() + 2 * nPadding;
	self.wndResults:SetAnchorOffsets(nL, nT, nR, nB);
end

local function OnHideFilters(self, wndHandler, wndControl)
	Print("Hide Filters")
	wndControl:SetText("Filters [+]");
	self.wndFilters:Show(false, true);

	local nL, nT, nR, nB = self.wndResults:GetAnchorOffsets();
	nT = self.wndSearch:GetHeight() + nPadding;
	self.wndResults:SetAnchorOffsets(nL, nT, nR, nB);
end

local function OnSearch(self)
	self:SetSearchState(true);
	self:BuildFilter();
	self:Search();
end

local function OnSearchLostFocus(self, wndHandler, wndControl)
	if (strlen(wndControl:GetText()) == 0) then
		wndControl:SetText(kstrSearch);
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
		local nWidthCategories = 250;
		local nWidthSearchButton = 100;
		local nPaddingSearchControl = 4;
		local nHeightSearch = 40;
		local nHeightFilters = 200;
		local nHeightHeader = 40;

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
									Font = "CRB_Interface9_BO",
									AnchorPoints = { 0, 0, 0, 1 },
									AnchorOffsets = { 0, 0, nWidthCategories, 0 },
									VScroll = true,
									AutoHideScroll = false,
									Template = "Holo_ScrollListSmall",
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
											AnchorOffsets = { nPaddingSearchControl, nPaddingSearchControl, 2 * (-nPaddingSearchControl - nWidthSearchButton) - nPaddingSearchControl, -nPaddingSearchControl },
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
											AnchorOffsets = { 2 * (-nPaddingSearchControl - nWidthSearchButton), nPaddingSearchControl, 2 * -nPaddingSearchControl - nWidthSearchButton, -nPaddingSearchControl },
											Base = "BK3:btnHolo_ListView_Mid",
											Text = kstrSearch,
											DT_VCENTER = true,
											DT_CENTER = true,
											Events = {
												ButtonSignal = OnSearch,
											},
										},
										-- Button: Filters
										{
											Class = "Button",
											AnchorPoints = { 1, 0, 1, 1 },
											AnchorOffsets = { -nPaddingSearchControl - nWidthSearchButton, nPaddingSearchControl, -nPaddingSearchControl, -nPaddingSearchControl },
											Base = "BK3:btnHolo_ListView_Mid",
											Text = "Filters [+]",
											ButtonType = "Check",
											DT_VCENTER = true,
											DT_CENTER = true,
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
									Font = "Nameplates",
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
											Children = {
												{
													Class = "Button",
													ButtonType = "Check",
													RadioGroup = "ResultSorting",
													Text = "Item",
													Name = "Name",
													Base = "BK3:btnHolo_ListView_Mid",
													DT_VCENTER = true,
													DT_CENTER = true,
													AnchorPoints = { 0, 0, 0.5, 1 },
													AnchorOffsets = { 0, 0, 0, 0 },
													Events = { ButtonCheck = OnHeaderClick, ButtonUncheck = OnHeaderClick },
												},
												{
													Class = "Button",
													ButtonType = "Check",
													RadioGroup = "ResultSorting",
													Text = "Bid",
													Name = "Bid",
													Base = "BK3:btnHolo_ListView_Mid",
													DT_VCENTER = true,
													DT_CENTER = true,
													AnchorPoints = { 0.5, 0, 0.7, 1 },
													AnchorOffsets = { 0, 0, 0, 0 },
													Events = { ButtonCheck = OnHeaderClick, ButtonUncheck = OnHeaderClick },
												},
												{
													Class = "Button",
													ButtonType = "Check",
													RadioGroup = "ResultSorting",
													Text = "Buyout",
													Name = "Buyout",
													Base = "BK3:btnHolo_ListView_Mid",
													DT_VCENTER = true,
													DT_CENTER = true,
													AnchorPoints = { 0.7, 0, 0.9, 1 },
													AnchorOffsets = { 0, 0, 0, 0 },
													Events = { ButtonCheck = OnHeaderClick, ButtonUncheck = OnHeaderClick },
												},
												{
													Class = "Button",
													ButtonType = "Check",
													RadioGroup = "ResultSorting",
													Text = "Time\nLeft",
													Name = "TimeRemaining",
													Base = "BK3:btnHolo_ListView_Mid",
													DT_VCENTER = true,
													DT_CENTER = true,
													AnchorPoints = { 0.9, 0, 1, 1 },
													AnchorOffsets = { 0, 0, 0, 0 },
													Events = { ButtonCheck = OnHeaderClick, ButtonUncheck = OnHeaderClick },
												},
											},
										},
										-- Items
										{
--											BGColor = "aa000000",
											Name = "Grid",
--											Border = false,
--											Picture = true,
--											Sprite = "ClientSprites:WhiteFill",
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
											AnchorOffsets = { 4, 8, 210, 30 },
											Text = "Filter known Schematics",
											Base = "HologramSprites:HoloCheckBoxBtn",
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

local function ShowItemTooltip(self, wndHandler, wndControl) -- Build on mouse enter and not every hit to save computation time
	local aucCurr = wndHandler == wndControl and wndHandler:GetParent() and wndHandler:GetParent():GetData() or nil;

	if (aucCurr) then
		local itemCurr = aucCurr:GetItem();
		Tooltip.GetItemTooltipForm(self, wndHandler, itemCurr, { bPrimary = true, bSelling = false, itemModData = nil, itemCompare = itemCurr:GetEquippedItemForItemType() });
	end
end

local function HideItemTooltip(self, wndHandler, wndControl)
	if (wndHandler ~= wndControl) then return; end
	wndHandler:SetTooltipDoc(nil);
end

local function ShowItemPreview(self, wndHandler, wndControl, eMouseButton)
	if (wndHandler ~= wndControl) then return; end
	local aucCurr = wndHandler:GetParent():GetData();
	if (not aucCurr) then return; end

	local itemCurr = aucCurr:GetItem();
	if (not itemCurr) then return; end

	if (Apollo.IsControlKeyDown() and eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		if (itemCurr:GetHousingDecorInfoId() ~= nil and itemCurr:GetHousingDecorInfoId() ~= 0) then
			Event_FireGenericEvent("DecorPreviewOpen", itemCurr:GetHousingDecorInfoId());
		else
			self.ItemPreviewImproved:OnShowItemInDressingRoom(itemCurr);
		end
	end
end

function M:CreateListItem(aucCurr)
	local nItemSize = 30;
	local nIconBorder = 1;

	local itemCurr = aucCurr:GetItem();
	local bIsKnownSchematic = (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
	local strCount = aucCurr:GetCount() ~= 1 and aucCurr:GetCount() or "";

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
	local wndItem = self.GeminiGUI:Create({
		BGColor = bIsKnownSchematic and "aa381010" or "aa000000",
		Border = false,
		Picture = true,
		Sprite = "ClientSprites:WhiteFill",
		AnchorPoints = { 0, 0, 1, 0, },
		AnchorOffsets = { 0, 0, 0, nItemSize },
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
								Name = "Count",
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { 0, 0, -2, -1 },
								Text = strCount,
								DT_RIGHT = true,
								DT_BOTTOM = true,
								Font = "CRB_Interface9_O",
							},
							{
								Name = "Icon",
								AnchorPoints = { 0, 0, 1, 1 },
								AnchorOffsets = { 0, 0, 0, 0 },
								Picture = true,
								BGColor = "white",
								Sprite = itemCurr:GetIcon(),
							},
						},
					},
				},
			},
			-- Name
			{
				AnchorPoints = { 0, 0, 0.5, 1 },
				AnchorOffsets = { nItemSize + 4, 0, 0, 0 },
				Text = itemCurr:GetName(),
				TextColor = ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior],
				DT_VCENTER = true,
				Font = "Nameplates",
			},
			-- Bid
			{
				Class = "MLWindow",
				Name = "Bid",
				AnchorPoints = { 0.5, 0, 0.7, 1 },
				AnchorOffsets = { 0, 8, 0, 0 },
				TextColor = bHasBids and "white" or "darkgray",
				Events = {
					WindowShow = not bHasBids and OnWindowShow or nil,
				},
				Visible = false,
			},
			-- Buyout
			{
				Class = "MLWindow",
				Name = "Buyout",
				AnchorPoints = { 0.7, 0, 0.9, 1 },
				AnchorOffsets = { 0, 8, 0, 0 },
			},
			-- Remaining Time
			{
				AnchorPoints = { 0.9, 0, 1, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = ktDurationStrings[aucCurr:GetTimeRemainingEnum()],
				TextColor = ktDurationColors[aucCurr:GetTimeRemainingEnum()];
				Font = "Nameplates",
				DT_CENTER = true,
				DT_VCENTER = true,
			},
		},
		UserData = aucCurr,
		Visible = false,
	}):GetInstance(self, self.wndResultsGrid);

	wndItem:FindChild("Bid"):SetText(S:GetMoneyAML(nBidAmount));
	wndItem:FindChild("Buyout"):SetText(S:GetMoneyAML(aucCurr:GetBuyoutPrice():GetAmount()));

	if (not bHasBids) then
		wndItem:FindChild("Bid"):SetOpacity(0.5, 5e+20);
	end

	SendVarToRover("AHCurrentAuction", aucCurr);

	wndItem:Show(true, true);
	wndItem:FindChild("Bid"):Show(true, true);

	return wndItem;
end
