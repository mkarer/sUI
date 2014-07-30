--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "MarketplaceLib";

-----------------------------------------------------------------------------

local MAJOR, MINOR = "Sezz:AuctionHouse:Search-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local Search = APkg and APkg.tPackage or {};
local MarketplaceLib, TableUtil, Apollo = MarketplaceLib, TableUtil, Apollo;
local tinsert, pairs, gsub, strfind, strlower, ipairs, tremove, floor = table.insert, pairs, string.gsub, string.find, string.lower, ipairs, table.remove, math.floor;
local log;

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------

-- Table Comparing
-- Credits: http://snippets.luacode.org/snippets/Deep_Comparison_of_Two_Values_3
local function Compare(t1, t2, ignore_mt)
	local ty1 = type(t1);
	local ty2 = type(t2);
	if (ty1 ~= ty2) then
		return false;
	end

	-- non-table types can be directly compared
	if (ty1 ~= 'table' and ty2 ~= 'table') then return (t1 == t2); end

	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1);
	if (not ignore_mt and mt and mt.__eq) then
		return (t1 == t2);
	end

	for k1, v1 in pairs(t1) do
		local v2 = t2[k1];
		if (v2 == nil or not Compare(v1, v2)) then
			return false;
		end
	end

	for k2, v2 in pairs(t2) do
		local v1 = t1[k2];
		if (v1 == nil or not Compare(v1,v2)) then
			return false;
		end
	end

	return true;
end

-- local tSpecials = {};
local function ItemHasSpecial(itemCurr, nSpecialSpellId)
	local tInfo = itemCurr:GetDetailedInfo();

	for _, tData in pairs(tInfo) do
		if (tData.arSpells) then
			for _, tSpell in ipairs(tData.arSpells) do
-- if (tSpell.splData) then tSpecials[tSpell.splData:GetId()]= tSpell.strName.." ("..tSpell.strFlavor..")";end
				if (tSpell.splData and tSpell.splData:GetId() == nSpecialSpellId) then
					return true;
				end
			end
		end
	end

	return false;
end

-----------------------------------------------------------------------------
-- Filters Definitions
-----------------------------------------------------------------------------

local EscapePattern
do
	local tMatches = {
		["^"] = "%^",
		["$"] = "%$",
		["("] = "%(",
		[")"] = "%)",
		["%"] = "%%",
		["."] = "%.",
		["["] = "%[",
		["]"] = "%]",
		["*"] = "%*",
		["+"] = "%+",
		["-"] = "%-",
		["?"] = "%?",
		["\0"] = "%z",
	};

	EscapePattern = function(strPattern)
		return gsub(strPattern, ".", tMatches);
	end
end

local tCustomFilter = {
	-- fnFilter returns true when the auction is filtered and false when it should be displayed.
	KnownSchematics = {
		fnFilter = function(aucCurr)
			local itemCurr = aucCurr:GetItem();
			return (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
		end,
	},
	Name = {
		fnFilter = function(aucCurr, strPattern)
			local itemCurr = aucCurr:GetItem();
			return (strfind(strlower(itemCurr:GetName()), strPattern) == nil);
		end,
	},
	RuneSlots = {
		fnFilter = function(aucCurr, nAmount)
			local itemCurr = aucCurr:GetItem();
			local tInfo = itemCurr:GetDetailedInfo();
			local nRuneSlots = 0;
			for _, tData in pairs(tInfo) do
				if (tData.tSigils and tData.tSigils.arSigils) then
					nRuneSlots = nRuneSlots + #tData.tSigils.arSigils;
				end
			end

			return (nRuneSlots < nAmount);
		end,
	},
	MinLevel = {
		fnFilter = function(aucCurr, nLevel)
			return aucCurr:GetItem():GetRequiredLevel() < nLevel;
		end,
	},
	MaxPrice = {
		fnFilter = function(aucCurr, nAmount)
			local nPrice = aucCurr:GetBuyoutPrice():GetAmount();
			if (nPrice == 0) then
				nPrice = aucCurr:GetCurrentBid():GetAmount();
				if (nPrice == 0) then
					nPrice = aucCurr:GetMinBid():GetAmount();
				end
			end

			return nPrice > nAmount;
		end,
	},
	MinAssaultPower = {
		fnFilter = function(aucCurr, nPower)
			local tInfo = aucCurr:GetItem():GetDetailedInfo();

			for _, tData in pairs(tInfo) do
				if (tData.arInnateProperties) then
					for _, tInnateProperty in ipairs(tData.arInnateProperties) do
						if (tInnateProperty.eProperty == Unit.CodeEnumProperties.AssaultPower) then
							return floor(tInnateProperty.nValue + 0.05) < nPower;
						end
					end
				end
			end

			return true;
		end,
	},
	MinSupportPower = {
		fnFilter = function(aucCurr, nPower)
			local tInfo = aucCurr:GetItem():GetDetailedInfo();

			for _, tData in pairs(tInfo) do
				if (tData.arInnateProperties) then
					for _, tInnateProperty in ipairs(tData.arInnateProperties) do
						if (tInnateProperty.eProperty == Unit.CodeEnumProperties.SupportPower) then
							return floor(tInnateProperty.nValue + 0.05) < nPower;
						end
					end
				end
			end

			return true;
		end,
	},
	MinStats = {
		fnFilter = function(aucCurr, tStats)
			local tInfo = aucCurr:GetItem():GetDetailedInfo();
			local bStatsFound = false;
			local bHasMinimumStats = true;

			for _, tData in pairs(tInfo) do
				if (tData.arBudgetBasedProperties) then
					for _, tProperty in ipairs(tData.arBudgetBasedProperties) do
						if (tStats[tProperty.eProperty]) then
							bStatsFound = true;
							bHasMinimumStats = bHasMinimumStats and (tProperty.nValue >= tStats[tProperty.eProperty]);
							if (not bHasMinimumStats) then
								return true;
							end
						end
					end
				end
			end

			return not (bStatsFound and bHasMinimumStats);
		end,
	},
	Special = {
		fnFilter = function(aucCurr, nSpecialSpellId)
			return not ItemHasSpecial(aucCurr:GetItem(), nSpecialSpellId);
		end,
	},
};

local function AuctionPassesFilters(aucCurr, tSearch)
	-- TODO: Carbine Filter Replacements

	-- Custom Filters
	if (#tSearch.tFilters == 0) then return true; end
	local bPassed = false;

	for _, tFilter in ipairs(tSearch.tFilters) do
		local bFilterPassed = true;

		if (tFilter.tCustomFilter) then
			for strFilter, oValue in pairs(tFilter.tCustomFilter) do

xpcall(function() return tCustomFilter[strFilter] and tCustomFilter[strFilter].fnFilter(aucCurr, oValue) end, Print)

				if (tCustomFilter[strFilter] and tCustomFilter[strFilter].fnFilter(aucCurr, oValue)) then
					bFilterPassed = false;
					break;
				end
			end
		end

		if (bFilterPassed) then
			return true; -- Passed on search filter
		end
	end

	return bPassed;
end

-----------------------------------------------------------------------------
-- Search
-----------------------------------------------------------------------------

function Search:Search(bForceRequest, bIsQueued, bReuseCurrentSearch)
	if (not self.bIsSearching or bIsQueued) then
		if (not bIsQueued and self.bSearchCompleted and not bForceRequest) then
			-- Use old results
			Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
		elseif ((bReuseCurrentSearch and self.tCurrentSearch) or (self.tQueue and #self.tQueue > 0)) then
			-- Request new results
--			log:debug("Queued Searches: %d", #self.tQueue);
			self:SetSearchState(true);

			if (not bReuseCurrentSearch) then
				self.tCurrentSearch = tremove(self.tQueue); -- Get next queued search
			end

--			log:debug("Requesting Results...");
			self:RequestAuctions(0, bForceRequest);
		else
			self:SetSearchState(false);
		end
	end
end

function Search:RequestAuctions(nPage, bForceRequest)
	if (not nPage or nPage == 0) then
		Event_FireGenericEvent("Sezz_AuctionHouse_SearchInitiated", self);
	end

	-- Initiate new Search
	local nPage = nPage or 0; -- nPage is zero-based
	local eAuctionSort = MarketplaceLib.AuctionSort.TimeLeft;
	local bReverseSort = false;
	local nPropertySort = false;
	local tSearchInfo;

	if (#self.tCurrentSearch.tFilters == 1) then
		tSearchInfo = self.tCurrentSearch.tFilters[1];
	else
		tSearchInfo = self.tCurrentSearch;
	end

	if (tSearchInfo.strSearchQuery) then
		-- Exit early if too many items in the search
		local tPackagedData = {};
		for _, tData in pairs(MarketplaceLib.SearchAuctionableItems(tSearchInfo.strSearchQuery, tSearchInfo.nFamilyId or 0, tSearchInfo.nCategoryId or 0, tSearchInfo.nTypeId or 0)) do
			if (#tPackagedData > MarketplaceLib.kAuctionSearchMaxIds) then
				break;
			else
				tinsert(tPackagedData, tData.nId or 0);
			end
		end

		if (#tPackagedData > MarketplaceLib.kAuctionSearchMaxIds) then
			-- Too many results for MarketplaceLib, filter manually
			if (not tSearchInfo.tCustomFilter) then
				tSearchInfo.tCustomFilter = {};
			end

			tSearchInfo.tCustomFilter["Name"] = strlower(EscapePattern(tSearchInfo.strSearchQuery));
			tSearchInfo.strSearchQuery = nil;
			self:RequestAuctions(nPage);
		elseif (#tPackagedData > 0) then
			MarketplaceLib.RequestItemAuctionsByItems(tPackagedData, nPage, eAuctionSort, bReverseSort, tSearchInfo.tFilter or {}, nil, nil, nPropertySort);
		else
			self:SetSearchState(false, false); -- Error
			Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
		end
	elseif (tSearchInfo.nFamilyId and tSearchInfo.nFamilyId > 0) then
		MarketplaceLib.RequestItemAuctionsByFamily(tSearchInfo.nFamilyId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	elseif (tSearchInfo.nCategoryId and tSearchInfo.nCategoryId > 0) then
		MarketplaceLib.RequestItemAuctionsByCategory(tSearchInfo.nCategoryId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	elseif (tSearchInfo.nTypeId and tSearchInfo.nTypeId > 0) then
		MarketplaceLib.RequestItemAuctionsByType(tSearchInfo.nTypeId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	else
		self:SetSearchState(false, false); -- Error
		Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
	end
end

function Search:OnItemAuctionSearchResults(nPage, nTotalResults, tAuctions)
	if (not self.bIsSearching) then return; end

	local nResults = #tAuctions;
	local nListedResults = nPage * MarketplaceLib.kAuctionSearchPageSize + nResults; -- nPage is zero-based

	for _, aucCurr in ipairs(tAuctions) do
		tinsert(self.tAuctions, aucCurr);

		if (AuctionPassesFilters(aucCurr, self.tCurrentSearch)) then
			tinsert(self.tAuctionsFiltered, aucCurr);
		end
	end

--	log:debug("Total: "..nTotalResults.." Processed: "..nListedResults);
	Event_FireGenericEvent("Sezz_AuctionHouse_SearchProgress", self, nListedResults, nTotalResults);

	if (nListedResults < nTotalResults) then
		-- Process next Page
		self:RequestAuctions(nPage + 1);
	else
		-- Done
		if (#self.tQueue == 0) then
			self:SetSearchState(false, true);
			Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
		else
			self:Search(false, true);
		end
	end
end

function Search:ResetData()
	self.bSearchCompleted = false;
	self.tAuctions = {};
	self.tAuctionsFiltered = {};
end

function Search:Update()
	-- Search again
	self:Search(true);
end

function Search:GetResults()
	if (self.bIsSearching) then return {}; end

	return self.tAuctions;
end

function Search:GetFilteredResults()
	if (self.bIsSearching) then return {}; end

	return self.tAuctionsFiltered;
end

function Search:IsSearching()
	return self.bIsSearching;
end

function Search:IsCompleted()
	return self.bSearchCompleted;
end

function Search:SetSearchState(bState, bSearchCompleted)
	if (self.bIsSearching ~= bState or self.bIsSearching == nil) then
		self.bIsSearching = bState;

		if (bState) then
			Apollo.RegisterEventHandler("ItemAuctionSearchResults", "OnItemAuctionSearchResults", self);
		else
			Apollo.RemoveEventHandler("ItemAuctionSearchResults", self);
		end

		log:debug("New State: "..(bState and "Enabled" or "Disabled"));
	end

	if (bSearchCompleted ~= nil) then
		self.bSearchCompleted = bSearchCompleted;
	end
end

-----------------------------------------------------------------------------
-- Single Filter Search
-----------------------------------------------------------------------------

function Search:SetFilter(tFilter, bKeepResults, bNoQueueOverride)
	if (self.bIsSearching) then return; end
	if (not tFilter) then tFilter = {}; end

	local tOldFilter;
	if (#self.tQueue == 1 and #self.tQueue[1].tFilters == 1) then
		tOldFilter = self.tQueue[1].tFilters[1];
	end

	local bFilterChanged = (not tOldFilter or tOldFilter.nFamilyId ~= (tFilter.nFamilyId or 0) or tOldFilter.nCategoryId ~= (tFilter.nCategoryId or 0) or tOldFilter.nTypeId ~= (tFilter.nTypeId or 0) or tOldFilter.strSearchQuery ~= tFilter.strSearchQuery or not Compare(tOldFilter.tFilter, tFilter.tFilter));
	log:debug("Filter changed: "..(bFilterChanged and "Yes" or "No"));

	if (bFilterChanged) then
		if (not bKeepResults) then
			self:ResetData();
		end

		self.tFilter = tFilter;

		if (not bNoQueueOverride) then
			local tSearch = {};
			tSearch.nFamilyId	= tFilter.nFamilyId;
			tSearch.nCategoryId	= tFilter.nCategoryId;
			tSearch.nTypeId		= tFilter.nTypeId;
			tSearch.tFilters	= { tFilter };

			self.tQueue = { tSearch };
		end
	end
end

function Search:EnableCustomFilter(strFilter, oValue)
	if (not tCustomFilter[strFilter]) then return; end
	if (not self.tFilter.tCustomFilter) then
		self.tFilter.tCustomFilter = {};
	end

	self.tFilter.tCustomFilter[strFilter] = oValue;
end

-----------------------------------------------------------------------------
-- Multiple Filters Search
-----------------------------------------------------------------------------

local tMarketplaceTree;
local tMarketplaceTreeFamilies;
local tMarketplaceTreeCategories;
local tMarketplaceTreeTypes;

local function MoveFilters(tSource, tDestination)
	if (tDestination.tParent and tDestination.tParent.nFilters > 0) then
		MoveFilters(tSource, tDestination.tParent);
		return;
	end

	for i = 1, #tSource.tFilters do
		-- Remove
		local tFilter = tremove(tSource.tFilters);

		-- Update Association
		tFilter.nCategoryId = nil;
		tFilter.nTypeId = nil;

		if (tDestination.nFamilyId) then
			tFilter.nFamilyId = tDestination.nFamilyId;
		elseif (tDestination.nCategoryId) then
			tFilter.nCategoryId = tDestination.nCategoryId;
		end

		-- Insert
		tinsert(tDestination.tFilters, tFilter);
		tSource.nFilters = tSource.nFilters - 1;
		tDestination.nFilters = tDestination.nFilters + 1;
	end

	for i = 1, #tSource do
		local tData = tremove(tSource);
		tinsert(tDestination, tData);
	end
end

local function AddFilter(tDestination, tFilter)
	tFilter.nFamilyId = tDestination.nFamilyId;
	tFilter.nCategoryId = tDestination.nCategoryId;
	tFilter.nTypeId = tDestination.nTypeId;

	tinsert(tDestination.tFilters, tFilter);
	tDestination.nFilters = tDestination.nFilters + 1;
end

local function QueueFilters(tQueue, tData)
	if (#tData.tFilters > 0) then
		local tSearch = {};
		tSearch.nFamilyId	= tData.nFamilyId;
		tSearch.nCategoryId	= tData.nCategoryId;
		tSearch.nTypeId		= tData.nTypeId;
		tSearch.tFilters	= tData.tFilters;

		if (#tSearch.tFilters > 1) then
			-- Replace Carbine Filters with custom ones
			for _, tFilter in ipairs(tSearch.tFilters) do
				-- Name
				if (tFilter.strSearchQuery) then
					if (not tFilter.tCustomFilter) then
						tFilter.tCustomFilter = {};
					end

					tFilter.tCustomFilter["Name"] = strlower(EscapePattern(tFilter.strSearchQuery));
					tFilter.strSearchQuery = nil;
				end
			end
		end

		tinsert(tQueue, tSearch);
	end

	for _, tChild in pairs(tData.tChildren) do
		QueueFilters(tQueue, tChild);
	end
end

function Search:SetMultipleFilters(tFilters, bKeepResults)
	if (self.bIsSearching) then return; end
	self.tFilter = nil;
	self.tQueue = {};

	if (not bKeepResults) then
		self:ResetData();
	end

	-- Get Families/Categories/Types
	if (not tMarketplaceTree) then
		tMarketplaceTree = {};
		tMarketplaceTreeFamilies = {};
		tMarketplaceTreeCategories = {};
		tMarketplaceTreeTypes = {};

		for _, tFamily in ipairs(MarketplaceLib.GetAuctionableFamilies()) do
			local tTreeFamily = { nFilters = 0, tChildren = {}, nFamilyId = tFamily.nId };
			tMarketplaceTree[tFamily.nId] = tTreeFamily;
			tMarketplaceTreeFamilies[tFamily.nId] = tTreeFamily;

			for _, tCategory in ipairs(MarketplaceLib.GetAuctionableCategories(tFamily.nId) or {}) do
				local tTreeCategory = { nFilters = 0, tChildren = {}, tParent = tTreeFamily, nCategoryId = tCategory.nId };
				tTreeFamily.tChildren[tCategory.nId] = tTreeCategory;
				tMarketplaceTreeCategories[tCategory.nId] = tTreeCategory;

				for _, tType in ipairs(MarketplaceLib.GetAuctionableTypes(tCategory.nId) or {}) do
					local tTreeType = { nFilters = 0, tChildren = {}, tParent = tTreeCategory, nTypeId = tType.nId };
					tTreeCategory.tChildren[tType.nId] = tTreeType;
					tMarketplaceTreeTypes[tType.nId] = tTreeType;
				end
			end
		end
	end

	-- Reset Filter Counter
	for _, tData in pairs(tMarketplaceTreeFamilies) do
		tData.nFilters = 0;
		tData.tFilters = {};
	end

	for _, tData in pairs(tMarketplaceTreeCategories) do
		tData.nFilters = 0;
		tData.tFilters = {};
	end

	for _, tData in pairs(tMarketplaceTreeTypes) do
		tData.nFilters = 0;
		tData.tFilters = {};
	end

	-- Arrange Filters
	-- This should reduce the number of searches (but may increase processing time, not sure yet, but when searching for weapons with a minimum
	-- number of runeslots and weapons with a specific name this should result in only one search).
	-- When there's a large amount of auctions it would propably be better to process every filter separately.
	-- Downside: When there's more than one search we cannot use the MarketplaceLib filters so I'll have to filter them myself.
	for _, tFilter in ipairs(tFilters) do
		-- Family Filter
		local tFilter = TableUtil:Copy(tFilter);

		if (tFilter.nFamilyId and tFilter.nFamilyId > 0 and tMarketplaceTreeFamilies[tFilter.nFamilyId]) then
			local tFamily = tMarketplaceTreeFamilies[tFilter.nFamilyId];
			AddFilter(tFamily, tFilter);

			-- Move all child category and type filters
			for _, tCategory in pairs(tFamily.tChildren) do
				MoveFilters(tCategory, tFamily);

				for _, tType in pairs(tCategory.tChildren) do
					MoveFilters(tType, tFamily);
				end
			end
		end

		-- Category Filter
		if (tFilter.nCategoryId and tFilter.nCategoryId > 0 and tMarketplaceTreeCategories[tFilter.nCategoryId]) then
			local tCategory = tMarketplaceTreeCategories[tFilter.nCategoryId];

			if (tCategory.tParent.nFilters > 0) then
				AddFilter(tCategory.tParent, tFilter);
			else
				AddFilter(tCategory, tFilter);

				-- Move all child type filters
				for _, tType in pairs(tCategory.tChildren) do
					MoveFilters(tType, tCategory);
				end
			end
		end

		-- Type Filter
		if (tFilter.nTypeId and tFilter.nTypeId > 0 and tMarketplaceTreeTypes[tFilter.nTypeId]) then
			local tType = tMarketplaceTreeTypes[tFilter.nTypeId];

			if (tType.tParent.tParent.nFilters > 0) then
				-- Add to Family
				AddFilter(tType.tParent.tParent, tFilter);
			elseif (tType.tParent.nFilters > 0) then
				-- Add to Category
				AddFilter(tType.tParent, tFilter);
			else
				-- Add to Type
				AddFilter(tType, tFilter);
			end
		end
	end

	-- Build Search Queue
	for nFamilyId, tFamily in pairs(tMarketplaceTreeFamilies) do
		QueueFilters(self.tQueue, tFamily);
	end
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Search:New(tFilter)
	local self = setmetatable({
		tQueue = {},
	}, { __index = Search });

	self:SetSearchState(false);
	self:SetFilter(tFilter);

	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Search:OnLoad()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2") and Apollo.GetAddon("GeminiConsole") and Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	if (GeminiLogging) then
		log = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender ="GeminiConsole"
		});
	else
		log = setmetatable({}, { __index = function() return function(self, ...) local args = #{...}; if (args > 1) then Print(string.format(...)); elseif (args == 1) then Print(tostring(...)); end; end; end });
	end
end

function Search:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Search, MAJOR, MINOR, {});
