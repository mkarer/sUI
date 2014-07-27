--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local strlen, strfind, gmatch, tinsert = string.len, string.find, string.gmatch, table.insert;
local Apollo, MarketplaceLib = Apollo, MarketplaceLib;

-----------------------------------------------------------------------------
-- Search
-----------------------------------------------------------------------------

local strNoResults = Apollo.GetString("Tradeskills_NoResults");
local strTryClearingFilter = Apollo.GetString("MarketplaceAuction_TryClearingFilter");

function M:SetSearchState(bSearching)
	self.bIsSearching = bSearching;
	self.wndSearch:FindChild("BtnSearch"):Enable(not bSearching);
	if (bSearching) then
		self:SetStatusMessage("Searching...");
	else
		self:SetStatusMessage();
	end
end

function M:Search(nPage)
	Print("Searching...");

	if (not nPage or nPage == 0) then
		self.tAuctions = {};
		self.wndResults:SetVScrollPos(0);
		self.wndResults:DestroyChildren();
	end

	-- Initiate new Search
	local nPage = nPage or 0; -- nPage is zero-based
	local eAuctionSort = MarketplaceLib.AuctionSort.TimeLeft;
	local bReverseSort = false;
	local nPropertySort = false;

	if (self.tFilter.strSearchQuery) then
		-- Exit early if too many items in the search
		local tPackagedData = {};
		for _, tData in pairs(MarketplaceLib.SearchAuctionableItems(self.tFilter.strSearchQuery, self.tFilter.nFamilyId, self.tFilter.nCategoryId, self.tFilter.nTypeId)) do
			if (#tPackagedData > MarketplaceLib.kAuctionSearchMaxIds) then
				break;
			else
				tinsert(tPackagedData, tData.nId or 0);
			end
		end

		if (#tPackagedData > MarketplaceLib.kAuctionSearchMaxIds) then
			-- Too many results for MarketplaceLib, filter manually
			self.tFilter.strSearchQuery = nil;
			tinsert(self.tFilter.tCustomFilter, "Name");
			self:Search(nPage);
		elseif (#tPackagedData > 0) then
			MarketplaceLib.RequestItemAuctionsByItems(tPackagedData, nPage, eAuctionSort, bReverseSort, self.tFilter.tFilter, nil, nil, nPropertySort);
		else
			self:SetSearchState(false);
			self:SetStatusMessage(Apollo.GetString("MarketplaceAuction_SearchNotPossible"), true);
		end
	elseif (self.tFilter.nFamilyId > 0) then
		MarketplaceLib.RequestItemAuctionsByFamily(self.tFilter.nFamilyId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	elseif (self.tFilter.nCategoryId > 0) then
		MarketplaceLib.RequestItemAuctionsByCategory(self.tFilter.nCategoryId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	elseif (self.tFilter.nTypeId > 0) then
		MarketplaceLib.RequestItemAuctionsByType(self.tFilter.nTypeId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	else
		self:SetSearchState(false);
	end
end

function M:OnItemAuctionSearchResults(event, nPage, nTotalResults, tAuctions)
	if (not self.wndMain or not self.tAuctions) then return; end
	if (not self.bIsSearching) then return; end

	local nResults = #tAuctions;
	local nListedResults = nPage * MarketplaceLib.kAuctionSearchPageSize + nResults; -- nPage is zero-based

	for _, aucCurr in ipairs(tAuctions) do
		tinsert(self.tAuctions, aucCurr);
	end

	Print("Total: "..nTotalResults.." Processed: "..nListedResults);
	if (nListedResults < nTotalResults) then
		-- Process next Page
		self:Search(nPage + 1);
	else
		-- Done
		for _, aucCurr in ipairs(self.tAuctions) do
			if (not self:IsFiltered(aucCurr)) then
				self:CreateListItem(aucCurr);
			end
		end

		local nResultsFiltered = nTotalResults - #self.wndResults:GetChildren();
		self.wndResults:ArrangeChildrenVert(0);
		self:SetSearchState(false);

		if (#self.tAuctions == 0) then
			self:SetStatusMessage(strNoResults, true);
		elseif (nResultsFiltered == nTotalResults) then
			self:SetStatusMessage(strNoResults .. " " .. nResultsFiltered .. " result"..(nResultsFiltered ~= 1 and "s" or "").." filtered." .. "\n" .. strTryClearingFilter, true);
		end
	end
end
