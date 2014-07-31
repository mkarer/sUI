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

local kstrFont = "CRB_Pixel"; -- TODO, also defined in GUI.lua

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
local nWidthCopper		= Apollo.GetTextWidth(kstrFont, "c");
local nWidthSilver		= Apollo.GetTextWidth(kstrFont, "s");
local nWidthGold		= Apollo.GetTextWidth(kstrFont, "g");
local nWidthPlatin		= Apollo.GetTextWidth(kstrFont, "p");
local nWidthSpace		= Apollo.GetTextWidth(kstrFont, " ");
local nWidthNumbers		= Apollo.GetTextWidth(kstrFont, "88");

local nPosSilver		= nWidthNumbers + nWidthSpace + nWidthCopper;
local nPosGold			= nPosSilver + nWidthSilver + nWidthNumbers + nWidthSpace;
local nPosPlatin		= nPosGold + nWidthGold + nWidthNumbers + nWidthSpace;

function M:CreateCashPixie(nAmount, bDarken)
	local nPlatin, nGold, nSilver, nCopper = floor(nAmount / 1000000), floor(mod(nAmount / 10000, 100)), floor(mod(nAmount / 100, 100)), mod(nAmount, 100);
	local tPixies = {};

	-- Platin
	if (nPlatin > 0) then
		tinsert(tPixies, {
			loc = {
				fPoints = { 0, 0, 1, 1 },
				nOffsets = { 0, 0, -nPosPlatin - nWidthPlatin, 0 },
			},
			strText = tostring(nPlatin),
			crText = bDarken and strColorDarkAmount or strColorAmount,
			strFont = kstrFont,
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
			strFont = kstrFont,
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
			strFont = kstrFont,
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
			strFont = kstrFont,
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
			strFont = kstrFont,
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
			strFont = kstrFont,
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
		strFont = kstrFont,
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
		strFont = kstrFont,
		flagsText = {
			DT_RIGHT = true,
			DT_VCENTER = true,
		},
	});

SendVarToRover("bla", tPixies);

	return tPixies;
end