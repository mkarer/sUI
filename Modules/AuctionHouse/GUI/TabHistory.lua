--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-----------------------------------------------------------------------------
-- History Tab
-----------------------------------------------------------------------------

local function CreateTab(self, wndParent)
	Print("Creating History Tab");
end

M:RegisterTab("history", "History", "FAHistory", CreateTab, 3);
