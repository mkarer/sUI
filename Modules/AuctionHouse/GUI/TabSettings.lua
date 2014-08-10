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
	wndParent:SetSprite("BasicSprites:WhiteFill");
	wndParent:SetBGColor("110000ff");
	wndParent:SetStyle("Picture", true);
end

M:RegisterTab("settings", "Settings", "FACog", CreateTab, 3);
