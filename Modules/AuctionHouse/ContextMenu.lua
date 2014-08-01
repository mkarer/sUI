--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-----------------------------------------------------------------------------

local itemCurr;

local function SendItemToRover(self)
	local tRover = Apollo.GetAddon("Rover");

	if (tRover and itemCurr) then
		SendVarToRover(itemCurr:GetName(), itemCurr);
		tRover.wndMain:Show(true, true);
	end
end

function M:ShowCurrentAuctionStats()
	if (itemCurr) then
		self.AuctionStats:DrawPlot(itemCurr:GetItemId());
	end
end

function M:ShowContextMenu(strId, ...)
	local tMenu = self.ContextMenu:GetRootMenu();
	tMenu:Initialize();

	if (strId == "ListItemBuy") then
		local aucCurr = ...;
		if (not aucCurr) then return; end
		itemCurr = aucCurr:GetItem();
		if (not itemCurr) then return; end

		tMenu:AddHeader(itemCurr:GetName());
		tMenu:AddItems({
			{
				Name = "Rover",
				Text = "Send to Rover",
				OnClick = SendItemToRover,
				CloseMenuOnClick = true,
				Enabled = function() return (Apollo.GetAddon("Rover") ~= nil) end,
			},
			{
				Name = "Stats",
				Text = "Show Price History",
				OnClick = { "ShowCurrentAuctionStats", self },
				CloseMenuOnClick = true,
				Enabled = function() return (self.AuctionStats ~= nil) end,
			},
		});

		tMenu:Show();
	end

end
