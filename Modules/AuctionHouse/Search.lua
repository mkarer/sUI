--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local strlen, strfind, gmatch, tinsert, tremove = string.len, string.find, string.gmatch, table.insert, table.remove;
local Apollo, MarketplaceLib = Apollo, MarketplaceLib;

-----------------------------------------------------------------------------
-- Search
-----------------------------------------------------------------------------

local kstrNoResults = Apollo.GetString("Tradeskills_NoResults");
local kstrSearching = Apollo.GetString("MarketplaceAuction_FetchingResults").."...";
local kstrTryClearingFilter = Apollo.GetString("MarketplaceAuction_TryClearingFilter");

function M:RefreshResults()
	if (not self.bIsSearching and self.tAuctions and self.tFilter) then
		self:SetSearchState(true);
		self:Search(true);
	end
end

function M:UpdateAuction(aucCurr, bIsTopBidder)
	local wndAuction = self.wndResultsGrid:FindChildByUserData(aucCurr);
	if (wndAuction) then
		self:UpdateListItem(wndAuction, aucCurr);
	end
end

function M:SetSearchState(bSearching)
	self.bIsSearching = bSearching;
	self.wndSearch:FindChild("BtnSearch"):Enable(not bSearching);
	if (bSearching) then
		self:SetStatusMessage(kstrSearching);
	else
		self:SetStatusMessage();
	end
end

function M:Search(bForceRefresh)
	self.tSearch:SetFilter(self.tFilter);

	if (not bForceRefresh and not self.tSearch:IsCompleted()) then
		self:ClearSelection();
		self.tAuctions = {};
		self.wndResultsGrid:SetVScrollPos(0);
		self.wndResultsGrid:DestroyChildren();
	end

	self.tSearch:Search(bForceRefresh);
end

function M:OnSearchCompleted(event, tSearch)
	if (self.tSearch ~= tSearch) then return; end

	self.tAuctions = self.tSearch:GetFilteredResults();
	self:DisplaySearchResults();
end

function M:RemoveAuction(aucCurr)
	if (self.bIsSearching or not self.tAuctions) then return; end

	for i, aucCached in ipairs(self.tAuctions) do
		if (aucCached == aucCurr) then
			tremove(self.tAuctions, i);
			break;
		end
	end

	local wndAuction = self.wndResultsGrid:FindChildByUserData(aucCurr);
	if (wndAuction) then
		wndAuction:Destroy();
		self:ClearSelection();
		self:SortResults();
	end
end

function M:IsAuctionVisible(aucCurr)
	if (not self.tAuctions) then return false; end

	local wndAuction = self.wndResultsGrid:FindChildByUserData(aucCurr);
	return (wndAuction ~= nil);
end

function M:DisplaySearchResults()
	local nTotalResults = #self.tSearch:GetResults();
	local nResultsFiltered = nTotalResults - #self.tAuctions;

	self:ClearSelection();
	self.wndResultsGrid:SetVScrollPos(0);
	self.wndResultsGrid:DestroyChildren();

	for _, aucCurr in ipairs(self.tAuctions) do
		self:CreateListItem(aucCurr);
	end

	self:SetSearchState(false);
	self:SortResults();

	if (nTotalResults == 0) then
		self:SetStatusMessage(kstrNoResults, true);
	elseif (nResultsFiltered == nTotalResults) then
		self:SetStatusMessage(kstrNoResults .. " " .. nResultsFiltered .. " result"..(nResultsFiltered ~= 1 and "s" or "").." filtered." .. "\n" .. kstrTryClearingFilter, true);
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
		self:GridVisibleItemsCheckForced();
	end
end
