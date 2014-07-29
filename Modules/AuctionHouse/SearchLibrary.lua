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
local MarketplaceLib = MarketplaceLib;
local tinsert, pairs, gsub, strfind, strlower, ipairs = table.insert, pairs, string.gsub, string.find, string.lower, ipairs;
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

-----------------------------------------------------------------------------
-- Filters
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
		return (gsub(strPattern, ".", tMatches));
	end
end

local tCustomFilter = {
	-- fnFilter returns true when the auction is filtered and false when it should be displayed.
	KnownSchematics = {
		fnFilter = function(self, aucCurr)
			local itemCurr = aucCurr:GetItem();
			return (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
		end,
	},
	Name = {
		fnFilter = function(self, aucCurr)
			local itemCurr = aucCurr:GetItem();
			return (strfind(strlower(itemCurr:GetName()), self.tFilter.strSearchQueryEscaped) == nil);
		end,
	},
	RuneSlots = {
		fnFilter = function(self, aucCurr, nAmount)
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
	MaxPrice = {
		fnFilter = function(self, aucCurr, nAmount)
			return aucCurr:GetBuyoutPrice():GetAmount() > nAmount;
		end,
	},
};

function Search:EnableCustomFilter(strFilter, oValue)
	if (not tCustomFilter[strFilter]) then return; end
	if (not self.tFilter.tCustomFilter) then
		self.tFilter.tCustomFilter = {};
	end

	self.tFilter.tCustomFilter[strFilter] = oValue;
end

-----------------------------------------------------------------------------
-- Search
-----------------------------------------------------------------------------

function Search:Search(bForceRequest)
	if (not self.bIsSearching) then
		if (self.bSearchCompleted and not bForceRequest) then
			-- Use old results
			Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
		else
			-- Request new results
			self:SetSearchState(true);
			self:RequestAuctions(0, bForceRequest);
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
			self:EnableCustomFilter("Name", EscapePattern(self.tFilter.strSearchQuery));
			self.tFilter.strSearchQuery = nil;
			self:RequestAuctions(nPage);
		elseif (#tPackagedData > 0) then
			MarketplaceLib.RequestItemAuctionsByItems(tPackagedData, nPage, eAuctionSort, bReverseSort, self.tFilter.tFilter, nil, nil, nPropertySort);
		else
			self:SetSearchState(false, false); -- Error
			Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
		end
	elseif (self.tFilter.nFamilyId > 0) then
		MarketplaceLib.RequestItemAuctionsByFamily(self.tFilter.nFamilyId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	elseif (self.tFilter.nCategoryId > 0) then
		MarketplaceLib.RequestItemAuctionsByCategory(self.tFilter.nCategoryId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
	elseif (self.tFilter.nTypeId > 0) then
		MarketplaceLib.RequestItemAuctionsByType(self.tFilter.nTypeId, nPage, eAuctionSort, bReverseSort, arFilters, nil, nil, nPropertySort);
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
	end

	log:debug("Total: "..nTotalResults.." Processed: "..nListedResults);
	Event_FireGenericEvent("Sezz_AuctionHouse_SearchProgress", self, nListedResults, nTotalResults);

	if (nListedResults < nTotalResults) then
		-- Process next Page
		self:RequestAuctions(nPage + 1);
	else
		-- Done
		self:SetSearchState(false, true);
		Event_FireGenericEvent("Sezz_AuctionHouse_SearchCompleted", self);
	end
end

function Search:Update()
	-- Search again
end

function Search:GetResults()
	if (self.bIsSearching) then return {}; end

	return self.tAuctions;
end

function Search:IsSearching()
	return self.bIsSearching;
end

function Search:IsCompleted()
	return self.bSearchCompleted;
end

function Search:SetFilter(tFilter, bKeepResults)
	if (self.bIsSearching) then return; end
	if (not tFilter) then tFilter = {}; end

	local bFilterChanged = (not self.tFilter or self.tFilter.nFamilyId ~= (tFilter.nFamilyId or 0) or self.tFilter.nCategoryId ~= (tFilter.nCategoryId or 0) or self.tFilter.nTypeId ~= (tFilter.nTypeId or 0) or self.tFilter.strSearchQuery ~= tFilter.strSearchQuery or not Compare(self.tFilter.tFilter, tFilter.tFilter));
	log:debug("Filter changed: "..(bState and "Yes" or "No"));

	if (bFilterChanged) then
		self.tFilter = tFilter;

		if (not bKeepResults) then
			self.bSearchCompleted = false;
			self.tAuctions = {};
		end

		if (not self.tFilter.nFamilyId)	then self.tFilter.nFamilyId = 0; end
		if (not self.tFilter.nCategoryId) then self.tFilter.nCategoryId = 0; end
		if (not self.tFilter.nTypeId) then self.tFilter.nTypeId = 0; end
		if (not self.tFilter.tFilter) then self.tFilter.tFilter = {}; end
	end
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
-- Constructor
-----------------------------------------------------------------------------

function Search:New(tFilter)
	local self = setmetatable({}, { __index = Search });

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
