--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-- Lua API
local tinsert, pairs, ipairs = table.insert, pairs, ipairs;

-----------------------------------------------------------------------------
-- Tabs
-----------------------------------------------------------------------------

local tTabs;
local tTabOrder;

function M:RegisterTab(strKey, strTitle, strIcon, fnCreate, nOrder)
	if (not tTabs) then
		tTabs = {};
	end

	if (not tTabOrder) then
		tTabOrder = {};
	end

	if (not nOrder or nOrder < 1 or nOrder > #tTabOrder) then
		nOrder = #tTabOrder + 1;
	end

	tTabs[strKey] = {
		strTitle = strTitle,
		strIcon = strIcon,
		fnCreate = fnCreate,
		nOrder = nOrder,
	};

	tinsert(tTabOrder, nOrder, strKey);
end

function M:InitializeTabs()
	if (tTabs and tTabOrder) then
		for _, strKey in ipairs(tTabOrder) do
			self.twndMain:AddTab(tTabs[strKey].strTitle, tTabs[strKey].strIcon, strKey);
		end
	end
end

function M:CreateTabs()
	if (tTabs and tTabOrder) then
		for _, strKey in ipairs(tTabOrder) do
			if (tTabs[strKey].fnCreate) then
				tTabs[strKey].fnCreate(self, self.twndMain:GetTabContainer(strKey));
			end
		end
	end
end
