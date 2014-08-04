--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-----------------------------------------------------------------------------
-- Settings Tab
-----------------------------------------------------------------------------

local function CreateTab(self, wndParent)
	Print("Creating Settings Tab");
end

M:RegisterTab("settings", "Settings", "FACog", CreateTab, 4);
