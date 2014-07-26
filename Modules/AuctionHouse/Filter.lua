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
-- Filters
-----------------------------------------------------------------------------

local strSearchLocalized = Apollo.GetString("CRB_Search");

local tCustomFilter = {
	KnownSchematics = function(aucCurrent)
		local itemCurr = aucCurrent:GetItem();
		return (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown);
	end,
	
};

function M:BuildFilter()
	local nFamilyId, nCategoryId, nTypeId, strSearchQuery, tFilter, tCustomFilter = self:GetCurrentFilter();

	self.tFilter = {
		nFamilyId = nFamilyId,
		nCategoryId = nCategoryId,
		nTypeId = nTypeId,
		strSearchQuery = strSearchQuery,
		tFilter = tFilter,
		tCustomFilter = tCustomFilter,
	};
end

function M:GetCurrentFilter()
	local tFilter = {};
	local tCustomFilter = {};

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

	return nFamilyId, nCategoryId, nTypeId, strSearchQuery, tFilter, tCustomFilter;
end

function M:IsFiltered(aucCurrent)
	for _, strFilter in ipairs(self.tFilter.tCustomFilter) do
		if (tCustomFilter[strFilter] and tCustomFilter[strFilter](aucCurrent)) then
			return true;
		end
	end

	return false;
end
