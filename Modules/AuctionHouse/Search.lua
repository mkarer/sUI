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

local kstrNoResults = Apollo.GetString("Tradeskills_NoResults");
local kstrTryClearingFilter = Apollo.GetString("MarketplaceAuction_TryClearingFilter");

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
	S.Log:debug("Searching...");

	if (self.bFilterChanged == false) then
		-- Don't forget to call BuildFilter() before searching!
		S.Log:debug("Filters didn't change!")
		self:DisplaySearchResults();
		return;
	end

	if (not nPage or nPage == 0) then
		self:ClearSelection();
		self.tAuctions = {};
		self.wndResultsGrid:SetVScrollPos(0);
		self.wndResultsGrid:DestroyChildren();
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

	S.Log:debug("Total: "..nTotalResults.." Processed: "..nListedResults);
	if (nListedResults < nTotalResults) then
		-- Process next Page
		self:Search(nPage + 1);
	else
		-- Done
		self:DisplaySearchResults();
	end
end

function M:DisplaySearchResults()
	local nTotalResults = #self.tAuctions;

	self:ClearSelection();
	self.wndResultsGrid:SetVScrollPos(0);
	self.wndResultsGrid:DestroyChildren();

	for _, aucCurr in ipairs(self.tAuctions) do
		if (not self:IsFiltered(aucCurr)) then
			self:CreateListItem(aucCurr);
		end
	end

	local nResultsFiltered = nTotalResults - #self.wndResultsGrid:GetChildren();
	self:SetSearchState(false);
	self:SortResults();

	if (nTotalResults == 0) then
		self:SetStatusMessage(kstrNoResults, true);
	elseif (nResultsFiltered == nTotalResults) then
		self:SetStatusMessage(kstrNoResults .. " " .. nResultsFiltered .. " result"..(nResultsFiltered ~= 1 and "s" or "").." filtered." .. "\n" .. kstrTryClearingFilter, true);
	end
end

-----------------------------------------------------------------------------
-- Sorting
-- Credits: Bam
-- http://forums.curseforge.com/showpost.php?p=165200&postcount=6
-----------------------------------------------------------------------------

local lexsort
do
 local join, sort, select, format = string.join, table.sort, select, string.format
 local function lexcmp(...)
  local code = {"local lhs, rhs = ..."}
  for i = 1, select('#', ...) - 1 do
   local k = select(i, ...)
   code[#code+1] = format("local lv, rv = lhs[%q], rhs[%q]", k, k)
   code[#code+1] = "if lv < rv then return true end"
   code[#code+1] = "if lv > rv then return false end"
  end
  local k = select(-1, ...)
  code[#code+1] = format("return lhs[%q] < rhs[%q]", k, k)
  return assert(loadstring(table.concat(code, "\n")))
 end
 local lexcmps = {}
 lexsort = function(t, ...)
  if select('#', ...) == 0 then
   sort(t)
  else
   local key = join("\0", ...)
   local cmp = lexcmps[key]
   if not cmp then
    cmp = lexcmp(...)
    lexcmps[key] = cmp
   end
   sort(t, cmp)
  end
  return t
 end
end

function M:SetSortOrder(strHeader, strDirection)
	self.strSortHeader = strHeader;
	self.strSortDirection = strDirection;
end

function M:SortResults()
	if (not self.bIsSearching) then
		local fnSortResults;

		if (self.strSortDirection ~= "DESC") then
			fnSortResults = function(wndAucA, wndAucB)
				return (wndAucA:FindChild(self.strSortHeader):GetData() < wndAucB:FindChild(self.strSortHeader):GetData()); 
			end
		else
			fnSortResults = function(wndAucA, wndAucB)
				return (wndAucA:FindChild(self.strSortHeader):GetData() >= wndAucB:FindChild(self.strSortHeader):GetData()); 
			end
		end

		self.wndResultsGrid:ArrangeChildrenVert(0, fnSortResults);
	end
end
