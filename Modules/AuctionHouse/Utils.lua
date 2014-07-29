--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

local floor, tinsert, mod, format = math.floor, table.insert, math.mod, string.format;
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
			AnchorPoints = { 0, 0, 1, 1 },
			AnchorOffsets = { 0, 0, -nPosPlatin - nWidthPlatin, 0 },
			Text = nPlatin,
			TextColor = bDarken and strColorDarkAmount or strColorAmount,
			Font = kstrFont,
			DT_RIGHT = true,
			DT_VCENTER = true,
		});

		tinsert(tPixies, {
			AnchorPoints = { 1, 0, 1, 1 },
			AnchorOffsets = { -nPosPlatin - nWidthPlatin, 0, -nPosPlatin, 0 },
			Text = "p",
			TextColor = bDarken and strColorDarkPlatin or strColorPlatin,
			Font = kstrFont,
			DT_RIGHT = true,
			DT_VCENTER = true,
		});
	end

	-- Gold
	if (nPlatin > 0 or nGold > 0) then
		tinsert(tPixies, {
			AnchorPoints = { 1, 0, 1, 1 },
			AnchorOffsets = { -nWidthNumbers - nPosGold - nWidthGold, 0, -nPosGold - nWidthGold, 0 },
			Text = #tPixies > 0 and format("%02d", nGold) or nGold,
			TextColor = bDarken and strColorDarkAmount or strColorAmount,
			Font = kstrFont,
			DT_RIGHT = true,
			DT_VCENTER = true,
		});

		tinsert(tPixies, {
			AnchorPoints = { 1, 0, 1, 1 },
			AnchorOffsets = { -nPosGold - nWidthGold, 0, -nPosGold, 0 },
			Text = "g",
			TextColor = bDarken and strColorDarkGold or strColorGold,
			Font = kstrFont,
			DT_RIGHT = true,
			DT_VCENTER = true,
		});
	end

	-- Silver
	if (nPlatin > 0 or nGold > 0 or nSilver > 0) then
		tinsert(tPixies, {
			AnchorPoints = { 1, 0, 1, 1 },
			AnchorOffsets = { -nWidthNumbers - nPosSilver - nWidthSilver, 0, -nPosSilver - nWidthSilver, 0 },
			Text = #tPixies > 0 and format("%02d", nSilver) or nSilver,
			TextColor = bDarken and strColorDarkAmount or strColorAmount,
			Font = kstrFont,
			DT_RIGHT = true,
			DT_VCENTER = true,
		});

		tinsert(tPixies, {
			AnchorPoints = { 1, 0, 1, 1 },
			AnchorOffsets = { -nPosSilver - nWidthSilver, 0, -nPosSilver, 0 },
			Text = "s",
			TextColor = bDarken and strColorDarkSilver or strColorSilver,
			Font = kstrFont,
			DT_RIGHT = true,
			DT_VCENTER = true,
		});
	end

	-- Copper
	tinsert(tPixies, {
		AnchorPoints = { 1, 0, 1, 1 },
		AnchorOffsets = { -nWidthNumbers - nWidthCopper, 0, -nWidthCopper, 0 },
		Text = #tPixies > 0 and format("%02d", nCopper) or nCopper,
		TextColor = bDarken and strColorDarkAmount or strColorAmount,
		Font = kstrFont,
		DT_RIGHT = true,
		DT_VCENTER = true,
	});

	tinsert(tPixies, {
		AnchorPoints = { 1, 0, 1, 1 },
		AnchorOffsets = { -nWidthCopper, 0, 0, 0 },
		Text = "c",
		TextColor = bDarken and strColorDarkCopper or strColorCopper;
		Font = kstrFont,
		DT_RIGHT = true,
		DT_VCENTER = true,
	});

	return tPixies;
end