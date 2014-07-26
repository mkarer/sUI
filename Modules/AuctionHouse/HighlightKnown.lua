--[[

	s:UI Known Schematics Highlighter

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AuctionHouseHighlightKnown");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

local HighlightKnownSchematics = function(self, aucCurr, wndParent, bBuyTab)
	self:_BuildListItem(aucCurr, wndParent, bBuyTab);

	if (bBuyTab) then
		local itemCurr = aucCurr:GetItem();
		if (itemCurr:GetActivateSpell() and itemCurr:GetActivateSpell():GetTradeskillRequirements() and itemCurr:GetActivateSpell():GetTradeskillRequirements().bIsKnown) then
			local tAuctions = wndParent:GetChildren();
			local wndAuction = tAuctions[#tAuctions];
			wndAuction:SetSprite("BasicSprites:WhiteFill");
			wndAuction:SetBGColor("33ff0000");
			wndAuction:SetOpacity(0.6);
		else
			local tInfo = itemCurr:GetDetailedInfo();--.tPrimary.tSigils.arSigils
			local nRuneSlots = 0;
			for _, tData in pairs(tInfo) do
				if (tData.tSigils and tData.tSigils.arSigils) then
					nRuneSlots = nRuneSlots + #tData.tSigils.arSigils;
				end

				if (nRuneSlots > 0) then
--					log:debug("%s: %d Runeslot(s)", itemCurr:GetName(), nRuneSlots);

					if (nRuneSlots >= 3) then
						local tAuctions = wndParent:GetChildren();
						local wndAuction = tAuctions[#tAuctions];
						wndAuction:SetSprite("BasicSprites:WhiteFill");
						wndAuction:SetBGColor("3300aa00");

						if (nRuneSlots > 3) then
							wndAuction:SetBGColor("33F200FF");
						end
					end
				end
			end
		end
	end
end

function M:OnInitialize()
	local tMarketplaceAuction = Apollo.GetAddon("MarketplaceAuction");
	if (not tMarketplaceAuction) then return; end
	log = S.Log;

	-- Cannot hook BuildListItem now, so we'll hook it when Initialize() is called...
	tMarketplaceAuction._Initialize = tMarketplaceAuction.Initialize;
	tMarketplaceAuction.Initialize = function(self)
		self:_Initialize();

		if (self._BuildListItem) then return; end

		self._BuildListItem = self.BuildListItem;
		self.BuildListItem = HighlightKnownSchematics;
	end
end
