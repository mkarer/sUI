--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AuctionHouse", "Gemini:Hook-1.0");
local log, GeminiGUI, MarketplaceAuction;
local strlen, strfind, gmatch = string.len, string.find, string.gmatch;
local Apollo, MarketplaceLib = Apollo, MarketplaceLib;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	MarketplaceAuction = Apollo.GetAddon("MarketplaceAuction");
	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;

	if (not MarketplaceAuction) then
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	if (not MarketplaceAuction._OnToggleAuctionWindow) then
		MarketplaceAuction._OnToggleAuctionWindow = MarketplaceAuction.OnToggleAuctionWindow;
		MarketplaceAuction.OnToggleAuctionWindow = function(tMarketplaceAuction)
			tMarketplaceAuction:_OnToggleAuctionWindow();
			self:ToggleWindow();
		end
	end

	self:ToggleWindow();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- GUI
-----------------------------------------------------------------------------

function M:ToggleWindow()
	self:CreateWindow();
	self.wndMain:Show(not self.wndMain:IsVisible());
end

local function InitializeTreeCategories(self, wndHandler, wndControl)
	local nNodeIdRoot = wndControl:AddNode(0, "Auctions");

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

					wndControl:AddNode(nNodeIdCategory, strName, nil, { Type = "Type", Id = tDataType.nId });
				end
			end

			wndControl:CollapseNode(nNodeIdRootCategory);
--		end
	end

	SendVarToRover("AHCategories", wndControl);
end

function M:CreateWindow()
	if (not self.wndMain) then
		self.wndMain = GeminiGUI:Create({
			Name = "SezzAuctionHouse",
			Moveable = true,
			Escapable = true,
			Overlapped = true,
			AnchorCenter = { 1000, 800 },
			Picture = true,
			Sprite = "ClientSprites:WhiteFill",
			BGColor = "66000000",
			Sizable = true,
			Visible = false,
			Children = {

				{ -- Categories
					Class = "TreeControl",
					BGColor = "aa000000",
					Picture = true,
					Sprite = "ClientSprites:WhiteFill",
					AnchorPoints = { 0, 0, 0, 1 },
					AnchorOffsets = { 0, 0, 300, 0 },
					VScroll = true,
					AutoHideScroll = true,
					Events = {
						WindowLoad = InitializeTreeCategories,
						TreeSelectionChanged = function(self, wndHandler, wndControl, hSelected, hPrevSelected)
							log:debug(hSelected);
							log:debug(wndControl:GetNodeData(hSelected));
						end,
					},
				},

			},
		}):GetInstance(self);
	end
end
