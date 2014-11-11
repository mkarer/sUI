--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local floor, tinsert, mod, format, tostring = math.floor, table.insert, math.mod, string.format, tostring;
local Apollo = Apollo;

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Cash Pixie
-----------------------------------------------------------------------------

local strColorAmount	= "ffffffff";
local strColorCopper	= "ffeda55f";
local strColorSilver	= "ffc7c7cf";
local strColorGold		= "ffffd700";
local strColorPlatin	= "ffffffff";

local strColorDarkAmount	= "ff828282";
local strColorDarkCopper	= "ff795532";
local strColorDarkSilver	= "ff66666a";
local strColorDarkGold		= "ff826e03";
local strColorDarkPlatin	= "ff828282";

-- When using CRB_Pixel they all share the same width, will leave the calculcations here, they shouldn't be too much impact on performance.
local nWidthCopper, nWidthSilver, nWidthGold, nWidthPlatin, nWidthSpace, nWidthNumbers, nPosSilver, nPosGold, nPosPlatin;

function M:CreateCashPixie(nAmount, bDarken)
	local nPlatin, nGold, nSilver, nCopper = floor(nAmount / 1000000), floor(mod(nAmount / 10000, 100)), floor(mod(nAmount / 100, 100)), mod(nAmount, 100);
	local tPixies = {};

	-- Calculate Font Width
	if (not nWidthCopper) then
		nWidthCopper	= Apollo.GetTextWidth(self.DB.strFont, "c");
		nWidthSilver	= Apollo.GetTextWidth(self.DB.strFont, "s");
		nWidthGold		= Apollo.GetTextWidth(self.DB.strFont, "g");
		nWidthPlatin	= Apollo.GetTextWidth(self.DB.strFont, "p");
		nWidthSpace		= Apollo.GetTextWidth(self.DB.strFont, " ");
		nWidthNumbers	= Apollo.GetTextWidth(self.DB.strFont, "88");
		nPosSilver		= nWidthNumbers + nWidthSpace + nWidthCopper;
		nPosGold		= nPosSilver + nWidthSilver + nWidthNumbers + nWidthSpace;
		nPosPlatin		= nPosGold + nWidthGold + nWidthNumbers + nWidthSpace;
	end

	-- Platin
	if (nPlatin > 0) then
		tinsert(tPixies, {
			loc = {
				fPoints = { 0, 0, 1, 1 },
				nOffsets = { 0, 0, -nPosPlatin - nWidthPlatin, 0 },
			},
			strText = tostring(nPlatin),
			crText = bDarken and strColorDarkAmount or strColorAmount,
			strFont = self.DB.strFont,
			flagsText = {
				DT_RIGHT = true,
				DT_VCENTER = true,
			},
		});

		tinsert(tPixies, {
			loc = {
				fPoints = { 1, 0, 1, 1 },
				nOffsets = { -nPosPlatin - nWidthPlatin, 0, -nPosPlatin, 0 },
			},
			strText = "p",
			crText = bDarken and strColorDarkPlatin or strColorPlatin,
			strFont = self.DB.strFont,
			flagsText = {
				DT_RIGHT = true,
				DT_VCENTER = true,
			},
		});
	end

	-- Gold
	if (nPlatin > 0 or nGold > 0) then
		tinsert(tPixies, {
			loc = {
				fPoints = { 1, 0, 1, 1 },
				nOffsets = { -nWidthNumbers - nPosGold - nWidthGold, 0, -nPosGold - nWidthGold, 0 },
			},
			strText = tostring(#tPixies > 0 and format("%02d", nGold) or nGold),
			crText = bDarken and strColorDarkAmount or strColorAmount,
			strFont = self.DB.strFont,
			flagsText = {
				DT_RIGHT = true,
				DT_VCENTER = true,
			},
		});

		tinsert(tPixies, {
			loc = {
				fPoints = { 1, 0, 1, 1 },
				nOffsets = { -nPosGold - nWidthGold, 0, -nPosGold, 0 },
			},
			strText = "g",
			crText = bDarken and strColorDarkGold or strColorGold,
			strFont = self.DB.strFont,
			flagsText = {
				DT_RIGHT = true,
				DT_VCENTER = true,
			},
		});
	end

	-- Silver
	if (nPlatin > 0 or nGold > 0 or nSilver > 0) then
		tinsert(tPixies, {
			loc = {
				fPoints = { 1, 0, 1, 1 },
				nOffsets = { -nWidthNumbers - nPosSilver - nWidthSilver, 0, -nPosSilver - nWidthSilver, 0 },
			},
			strText = tostring(#tPixies > 0 and format("%02d", nSilver) or nSilver),
			crText = bDarken and strColorDarkAmount or strColorAmount,
			strFont = self.DB.strFont,
			flagsText = {
				DT_RIGHT = true,
				DT_VCENTER = true,
			},
		});

		tinsert(tPixies, {
			loc = {
				fPoints = { 1, 0, 1, 1 },
				nOffsets = { -nPosSilver - nWidthSilver, 0, -nPosSilver, 0 },
			},
			strText = "s",
			crText = bDarken and strColorDarkSilver or strColorSilver,
			strFont = self.DB.strFont,
			flagsText = {
				DT_RIGHT = true,
				DT_VCENTER = true,
			},
		});
	end

	-- Copper
	tinsert(tPixies, {
		loc = {
			fPoints = { 1, 0, 1, 1 },
			nOffsets = { -nWidthNumbers - nWidthCopper, 0, -nWidthCopper, 0 },
		},
		strText = tostring(#tPixies > 0 and format("%02d", nCopper) or nCopper),
		crText = bDarken and strColorDarkAmount or strColorAmount,
		strFont = self.DB.strFont,
		flagsText = {
			DT_RIGHT = true,
			DT_VCENTER = true,
		},
	});

	tinsert(tPixies, {
		loc = {
			fPoints = { 1, 0, 1, 1 },
			nOffsets = { -nWidthCopper, 0, 0, 0 },
		},
		strText = "c",
		crText = bDarken and strColorDarkCopper or strColorCopper,
		strFont = self.DB.strFont,
		flagsText = {
			DT_RIGHT = true,
			DT_VCENTER = true,
		},
	});

	return tPixies;
end