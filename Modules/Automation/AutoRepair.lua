--[[

	s:UI Auto-Repair

	TODO: Guildbank Repair

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AutomationCore = S:GetModule("AutomationCore");
local M = AutomationCore:CreateSubmodule("AutoRepair");
local log, tVendor;

local tCurrencySprites = { "CRB_CurrencySprites:sprCashPlatinum", "CRB_CurrencySprites:sprCashGold", "CRB_CurrencySprites:sprCashSilver", "CRB_CurrencySprites:sprCashCopper" };

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	tVendor = Apollo.GetAddon("Vendor");
	if (not tVendor) then
		self:SetEnabledState(false);
	else
		self:RegisterEvent("InvokeVendorWindow", "RepairAllItems");
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());

	self:UnregisterEvent("InvokeVendorWindow");
end

-----------------------------------------------------------------------------

function M:RepairAllItems(event, unitVendor)
	local tRepairableItems = unitVendor:GetRepairableItems() or {};

	if (#tRepairableItems > 0) then
		-- Output Repair Costs in Chat
		local nPrice = GameLib.GetRepairAllCost();
		local tChatOutput = {
			{ strType = "Text", strContent = "Repair costs:" },
		};

		local tPrice = { S:GetMoneySplitted(nPrice) };

		for i = 1, 4 do
			if (tPrice[i] > 0) then
				table.insert(tChatOutput, { strType = "Text", strContent = tPrice[i], bNoSpace = true });
				table.insert(tChatOutput, { strType = "Image", strContent = tCurrencySprites[i] });
			end
		end

		S:ChatOutput(tChatOutput);

		-- Repair
		RepairAllItemsVendor();
		tVendor:RefreshRepairTab();
	end
end
