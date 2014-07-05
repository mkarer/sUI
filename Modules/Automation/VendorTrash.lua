--[[

	s:UI Junk Seller

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AutomationCore = S:GetModule("AutomationCore");
local M = AutomationCore:CreateSubmodule("VendorTrash");
local log;

local format = string.format;
local tCurrencySprites = { "CRB_CurrencySprites:sprCashPlatinum", "CRB_CurrencySprites:sprCashGold", "CRB_CurrencySprites:sprCashSilver", "CRB_CurrencySprites:sprCashCopper" };

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self:RegisterEvent("InvokeVendorWindow", "SellJunk");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());

	self:UnregisterEvent("InvokeVendorWindow");
end

-----------------------------------------------------------------------------

function M:SellJunk()
	log:debug("sell")

	local tItemsJunk = S:GetInventoryByCategory(94, true);
	if (#tItemsJunk > 0) then
		local nItemsSold = 0;
		local nProfit = 0;

		for _, itemJunk in ipairs(tItemsJunk) do
			if (itemJunk.itemInBag and itemJunk.itemInBag:GetSellPrice()) then
				-- Sell
				nProfit = nProfit + itemJunk.itemInBag:GetStackCount() * (itemJunk.itemInBag:GetSellPrice():GetMoneyType() == Money.CodeEnumCurrencyType.Credits and itemJunk.itemInBag:GetSellPrice():GetAmount() or 0);
				nItemsSold = nItemsSold + itemJunk.itemInBag:GetStackCount();

				SellItemToVendorById(itemJunk.itemInBag:GetInventoryId(), itemJunk.itemInBag:GetStackCount());
			end
		end

		if (nItemsSold > 0) then
			-- Output Profit in Chat
			local tProfit = { S:GetMoneySplitted(nProfit) };
			local tChatOutput = {
				{ strType = "Text", strContent = format("Sold %d trash item%s for", nItemsSold, nItemsSold > 1 and "s" or "") },
			};

			for i = 1, 4 do
				if (tProfit[i] > 0) then
					table.insert(tChatOutput, { strType = "Text", strContent = tProfit[i], bNoSpace = true });
					table.insert(tChatOutput, { strType = "Image", strContent = tCurrencySprites[i] });
				end
			end

			S:ChatOutput(tChatOutput);
		end
	end
end
