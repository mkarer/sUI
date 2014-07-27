--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local strlen, strfind, tinsert, gsub, strlower = string.len, string.find, table.insert, string.gsub, string.lower;
local Apollo, MarketplaceLib = Apollo, MarketplaceLib;

-----------------------------------------------------------------------------
-- Filters
-----------------------------------------------------------------------------

local strSearchLocalized = Apollo.GetString("CRB_Search");

local EscapePattern
do
	local matches = {
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

	EscapePattern = function(s)
		return (gsub(s, ".", matches));
	end
end

local tCustomFilter = {
	-- fnFilter returns true when the auction is filtered and false when it should be displayed.
	KnownSchematics = {
		fnFilter = function(self, aucCurrent)
			local itemCurr = aucCurrent:GetItem();
			return (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
		end,
	},
	Name = {
		fnFilter = function(self, aucCurrent)
			local itemCurr = aucCurrent:GetItem();
			return (strfind(strlower(itemCurr:GetName()), self.tFilter.strSearchQueryEscaped) == nil);
		end,
	},
	RuneSlots = {
		fnFilter = function(self, aucCurrent, nAmount)
			local itemCurr = aucCurrent:GetItem();
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
};

function M:BuildFilter()
	local nFamilyId, nCategoryId, nTypeId, strSearchQuery, tFilter, tCustomFilter, tCustomFilterValues = self:GetCurrentFilter();

	self.bFilterChanged = (not self.tFilter or self.tFilter.nFamilyId ~= nFamilyId or self.tFilter.nCategoryId ~= nCategoryId or self.tFilter.nTypeId ~= nTypeId or self.tFilter.strSearchQuery ~= strSearchQuery or not S:Compare(self.tFilter.tFilter, tFilter));
	self.tFilter = {
		nFamilyId = nFamilyId,
		nCategoryId = nCategoryId,
		nTypeId = nTypeId,
		strSearchQuery = strSearchQuery,
		strSearchQueryEscaped = strSearchQuery and EscapePattern(strlower(strSearchQuery)) or "",
		tFilter = tFilter,
		tCustomFilter = tCustomFilter,
		tCustomFilterValues = tCustomFilterValues,
	};
end

function M:GetCurrentFilter()
	local tFilter = {};
	local tCustomFilter = {};
	local tCustomFilterValues = {};

	-- Search String
	local strSearchQuery = self.wndMain:FindChild("Search"):FindChild("Text"):GetText();
	if (strlen(strSearchQuery) == 0 or strSearchQuery == strSearchLocalized) then
		strSearchQuery = nil;
	end

	-- Category
	local nFamilyId, nCategoryId, nTypeId = 0, 0, 0;
	if (self.tSelectedCategory) then
		if (self.tSelectedCategory.Type == "Family") then
			nFamilyId = self.tSelectedCategory.Id;
		elseif (self.tSelectedCategory.Type == "Category") then
			nCategoryId = self.tSelectedCategory.Id;
		elseif (self.tSelectedCategory.Type == "Type") then
			nTypeId = self.tSelectedCategory.Id;
		end
	end

	-- Custom Filters
	if (self.wndFilters:FindChild("KnownSchematics"):IsChecked()) then
		tinsert(tCustomFilter, "KnownSchematics");
	end
	if (self.wndFilters:FindChild("RuneSlots"):IsChecked()) then
		tinsert(tCustomFilter, "RuneSlots");
		tCustomFilterValues["RuneSlots"] = tonumber(self.wndFilters:FindChild("RuneSlotsAmount"):GetText());
		if (type(tCustomFilterValues["RuneSlots"]) ~= "number" or tCustomFilterValues["RuneSlots"] < 0) then
			tCustomFilterValues["RuneSlots"] = 0;
		end
	end

	return nFamilyId, nCategoryId, nTypeId, strSearchQuery, tFilter, tCustomFilter, tCustomFilterValues;
end

function M:IsFiltered(aucCurrent)
	for _, strFilter in ipairs(self.tFilter.tCustomFilter) do
		if (tCustomFilter[strFilter] and tCustomFilter[strFilter].fnFilter(self, aucCurrent, self.tFilter.tCustomFilterValues[strFilter])) then
			return true;
		end
	end

	return false;
end
