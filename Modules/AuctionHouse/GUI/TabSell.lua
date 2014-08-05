--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-- Lua API
local ipairs = ipairs;

-----------------------------------------------------------------------------
-- Sell Tab
-----------------------------------------------------------------------------

local kstrFont = "CRB_Pixel"; 
local knWidthPanelLeft = 220;

local function CreateTab(self, wndParent)
	local wndContent = self.GeminiGUI:Create({
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 4, 4, -4, -4 },
		IgnoreMouse = 1,
		Children = {
			-- Sellable Items Tree
			{
				Name = "TreeView",
				Class = "Window",
				Font = kstrFont,
				AnchorPoints = { 0, 0, 0, 1 },
				AnchorOffsets = { 0, 0, knWidthPanelLeft, 0 },
				VScroll = true,
				AutoHideScroll = false,
				Template = "Holo_ScrollListSmall",
				Border = true,
				Sprite = "ClientSprites:WhiteFill",
				BGColor = "ff121314",
				Picture = true,
				UseTemplateBG = false,
				IgnoreMouse = 0,
			},
		},
	}):GetInstance(self, wndParent);

	-- Auction Stats Graph

	-- Post Item Form

	-- Similar Items

	-- Initialize Tree
	local tvwSellableItems = self.TreeView:New(wndContent:FindChild("TreeView"), self);
	local strNodeSellableItems = tvwSellableItems:AddNode("Sellable Items");

	for _, itemCurr in ipairs(S.myCharacter:GetAuctionableItems()) do
		if (itemCurr and itemCurr:IsAuctionable()) then
			tvwSellableItems:AddChildNode(strNodeSellableItems, itemCurr:GetName(), itemCurr:GetIcon(), itemCurr);
		end
	end

	tvwSellableItems:Render();
end

M:RegisterTab("sell", "Sell", "FAGavel", CreateTab, 2);
