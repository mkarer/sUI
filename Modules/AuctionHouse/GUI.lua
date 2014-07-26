--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local strlen, strfind, gmatch = string.len, string.find, string.gmatch;
local Apollo, MarketplaceLib = Apollo, MarketplaceLib;

-----------------------------------------------------------------------------
-- GUI
-----------------------------------------------------------------------------

local ktQualityColors = {
	[Item.CodeEnumItemQuality.Inferior] 		= "ItemQuality_Inferior",
	[Item.CodeEnumItemQuality.Average] 			= "ItemQuality_Average",
	[Item.CodeEnumItemQuality.Good] 			= "ItemQuality_Good",
	[Item.CodeEnumItemQuality.Excellent] 		= "ItemQuality_Excellent",
	[Item.CodeEnumItemQuality.Superb] 			= "ItemQuality_Superb",
	[Item.CodeEnumItemQuality.Legendary] 		= "ItemQuality_Legendary",
	[Item.CodeEnumItemQuality.Artifact]		 	= "ItemQuality_Artifact",
};

local strSearchLocalized = Apollo.GetString("CRB_Search");
local nPadding = 2;

function M:ToggleWindow()
	self:CreateWindow();
	self.wndMain:Show(not self.wndMain:IsVisible());
end

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

function M:CreateWindow()
	if (not self.wndMain) then
		local nWidthCategories = 250;
		local nWidthSearchButton = 100;
		local nPaddingSearchControl = 4;
		local nHeightSearch = 40;
		local nHeightFilters = 200;

		self.wndMain = self.GeminiGUI:Create({
			Name = "SezzAuctionHouse",
			Moveable = true,
			Escapable = true,
			Overlapped = true,
			AnchorCenter = { 1000, 800 },
			Picture = true,
			Border = true,
			Sprite = "BK3:UI_BK3_Holo_Snippet",
			BGColor = "black",
			Sizable = true,
			Visible = false,
			Children = {
				{
					Name = "Title",
					AnchorPoints = { 0, 0, 1, 0 },
					AnchorOffsets = { 10, 10, -12, 39 },
					Font = "CRB_Header10_O",
					Text = Apollo.GetString("MarketplaceAuction_AuctionHouse"),
					DT_VCENTER = true,
					DT_CENTER = true,
				},
				{
					Name = "Framing",
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 5, 5, -5, -5 },
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
									BGColor = "aa000000",
									Name = "Search",
									Border = false,
									Picture = true,
									Sprite = "ClientSprites:WhiteFill",
									AnchorPoints = { 0, 0, 1, 0, },
									AnchorOffsets = { nWidthCategories + nPadding, 0, 0, nHeightSearch },
									Children = {
										-- Textbox
										{
											Class = "EditBox",
											Name = "Text",
											AnchorPoints = { 0, 0, 1, 1 },
											AnchorOffsets = { nPaddingSearchControl, nPaddingSearchControl, 2 * (-nPaddingSearchControl - nWidthSearchButton) - nPaddingSearchControl, -nPaddingSearchControl },
											Picture = true,
											Sprite = "ClientSprites:WhiteFill",
											BGColor = "11ffffff",
											Text = "Search",
											DT_VCENTER = true,
										},
										-- Button: Search
										{
											Class = "Button",
											Name = "BtnSearch",
											AnchorPoints = { 1, 0, 1, 1 },
											AnchorOffsets = { 2 * (-nPaddingSearchControl - nWidthSearchButton), nPaddingSearchControl, 2 * -nPaddingSearchControl - nWidthSearchButton, -nPaddingSearchControl },
											Picture = true,
											Sprite = "ClientSprites:WhiteFill",
											BGColor = "11ffffff",
											Text = strSearchLocalized,
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
											Picture = true,
											Sprite = "ClientSprites:WhiteFill",
											BGColor = "11ffffff",
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
									BGColor = "aa000000",
									Name = "Results",
									Border = false,
									Picture = true,
									Sprite = "ClientSprites:WhiteFill",
									AnchorPoints = { 0, 0, 1, 1, },
									AnchorOffsets = { nWidthCategories + nPadding, nHeightSearch + nPadding, 0, 0 },
									VScroll = true,
									AutoHideScroll = true,
									Template = "Holo_ScrollList",
								},
								-- Search Filter
								{
									BGColor = "aa000000",
									Name = "Filters",
									Border = false,
									Picture = true,
									Sprite = "ClientSprites:WhiteFill",
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
					AnchorOffsets = { 5, 5, -5, -5 },
					Picture = true,
					Border = true,
					Sprite = "ClientSprites:WhiteFill",
					BGColor = "77000000",
					Children = {},
				},
			},
		}):GetInstance(self);

		self.wndSearch = self.wndMain:FindChild("Search");
		self.wndFilters = self.wndMain:FindChild("Filters");
		self.wndResults = self.wndMain:FindChild("Results");
	end
end

-----------------------------------------------------------------------------
-- Items
-----------------------------------------------------------------------------

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
	local aucCurr = wndHandler == wndControl and wndHandler:GetParent() and wndHandler:GetParent():GetData() or nil;
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

function M:CreateListItem(aucCurr)
	local nItemSize = 30;
	local nIconBorder = 1;

	local itemCurr = aucCurr:GetItem();
	local bIsKnownSchematic = (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
	local strCount = aucCurr:GetCount() ~= 1 and aucCurr:GetCount() or "";

	-- Bids
	local tBidMinimum = aucCurr:GetMinBid();
	local tBidCurrent = aucCurr:GetCurrentBid();
	local bHasBids, strBid = tBidCurrent:GetAmount() > 0, "";

	if (bHasBids) then
		strBid = tBidCurrent:GetMoneyString();
	else
		strBid = tBidMinimum:GetMoneyString();
	end

	-- Create Control
	local wndItem = self.GeminiGUI:Create({
		BGColor = bIsKnownSchematic and "1eff0000" or "11ffffff",
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
						Name = "Count",
						AnchorPoints = { 0, 0, 1, 1 },
						AnchorOffsets = { 0, 0, -1, -1 },
						Text = strCount,
						DT_RIGHT = true,
						Font = "CRB_Interface9_O",
					},
					{
						Name = "Icon",
						AnchorPoints = { 0, 0, 1, 1 },
						AnchorOffsets = { nIconBorder, nIconBorder, -nIconBorder, -nIconBorder },
						Picture = true,
						BGColor = "white",
						Sprite = itemCurr:GetIcon(),
					},
					{
						Name = "IconBackground",
						AnchorPoints = { 0, 0, 1, 1 },
						AnchorOffsets = { nIconBorder, nIconBorder, -nIconBorder, -nIconBorder },
						Picture = true,
						BGColor = "black",
						Sprite = "ClientSprites:WhiteFill",
					},
				},
			},
			-- Name
			{
				AnchorPoints = { 0, 0, 0.5, 1 },
				AnchorOffsets = { nItemSize + 4, 0, 0, 0 },
				Text = "["..(#self.wndResults:GetChildren() + 1).."] "..itemCurr:GetName(),
				TextColor = ktQualityColors[itemCurr:GetItemQuality()] or ktQualityColors[Item.CodeEnumItemQuality.Inferior],
				DT_VCENTER = true,
			},
			-- Bid
			{
				AnchorPoints = { 0.5, 0, 0.7, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = strBid,
				TextColor = bHasBids and "white" or "darkgray",
				DT_VCENTER = true,
				DT_RIGHT = true,
			},
			-- Buyout
			{
				AnchorPoints = { 0.7, 0, 0.9, 1 },
				AnchorOffsets = { 0, 0, 0, 0 },
				Text = aucCurr:GetBuyoutPrice():GetMoneyString(),
				DT_VCENTER = true,
				DT_RIGHT = true,
			},
		},
		UserData = aucCurr,
	}):GetInstance(self, self.wndResults);

	SendVarToRover("AHCurrentAuction", aucCurr);

	return wndItem;
end
