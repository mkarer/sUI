--[[

	s:UI Salvage Items based on name
	Usage: /salvage Item Name

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "GameLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("SlashSalvage");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
--	log:debug("%s enabled.", self:GetName());
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:SalvageByName(strName)
	if (not strName) then
		Print("Please specify an item!");
		Print("Usage: /salvage Full Item Name");
		return;
	end

	strName = string.lower(strName);
	local invItems = GameLib.GetPlayerUnit():GetInventoryItems();

	for _, v in ipairs(invItems) do
		if (string.lower(v.itemInBag:GetName()) == strName) then
			-- Salvage Item
		end

		if self:IsSellable(v.itemInBag) then
			table.insert(sellItems, v.itemInBag)
			itemCount = itemCount + 1
		end
	end
	
	return sellItems, itemCount
end
