--[[

	s:UI Utility Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-- Lua API
local mod, format, floor, format, strlen = math.mod, string.format, math.floor, string.format, string.len;

-----------------------------------------------------------------------------
-- Table Utilities
-----------------------------------------------------------------------------

function S:Clone(t)
	if (type(t) ~= "table") then
		return t;
	end

	local mt = getmetatable(t);
	local res = {};

	for k, v in pairs(t) do
		if (type(v) == "table") then
			v = self:Clone(v);
		end

		res[k] = v;
	end

	setmetatable(res, mt);
	return res;
end

function S:Combine(t1, t2)
	if (not t1 or type(t1) ~= "table") then t1 = {}; end
	if (not t2 or type(t2) ~= "table") then t2 = {}; end

	for k, v in pairs(t2) do
		t1[k] = v;
	end

	return t1;
end

function S:InitializeTable(t)
	if (not t or type(t) ~= "table") then
		t = {};
	end

	return t;
end

-- Table Comparing
-- Credits: http://snippets.luacode.org/snippets/Deep_Comparison_of_Two_Values_3
function S:Compare(t1, t2, ignore_mt)
	local ty1 = type(t1);
	local ty2 = type(t2);
	if (ty1 ~= ty2) then
		return false;
	end

	-- non-table types can be directly compared
	if (ty1 ~= 'table' and ty2 ~= 'table') then return (t1 == t2); end

	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1);
	if (not ignore_mt and mt and mt.__eq) then
		return (t1 == t2);
	end

	for k1, v1 in pairs(t1) do
		local v2 = t2[k1];
		if (v2 == nil or not self:Compare(v1, v2)) then
			return false;
		end
	end

	for k2, v2 in pairs(t2) do
		local v1 = t1[k2];
		if (v1 == nil or not self:Compare(v1,v2)) then
			return false;
		end
	end

	return true;
end

-----------------------------------------------------------------------------
-- AML Tags
-----------------------------------------------------------------------------

function S:WrapAML(strTag, strText, strColor, strAlign)
	return format('<%s Font="CRB_Pixel_O" Align="%s" TextColor="%s">%s</%s>', strTag, strAlign or "Left", strColor or "ffffffff", strText, strTag);
end

-----------------------------------------------------------------------------
-- Money
-----------------------------------------------------------------------------

function S:GetMoneySplitted(nAmount)
	return floor(nAmount / 1000000), floor(mod(nAmount / 10000, 100)), floor(mod(nAmount / 100, 100)), mod(nAmount, 100);
end

local strColorCopper	= "ffeda55f";
local strColorSilver	= "ffc7c7cf";
local strColorGold		= "ffffd700";
local strColorPlatin	= "ffffffff";

function S:GetMoneyAML(nAmount, strFont)
	local nPlatin, nGold, nSilver, nCopper = self:GetMoneySplitted(nAmount);

	local strAML = "";
	local strNumberFormat = "%d";

	-- Platin
	if (nPlatin > 0) then
		strAML = format(strNumberFormat .. '<T TextColor="%s">p</T>', nPlatin, strColorPlatin);
	end

	-- Gold
	if (nPlatin > 0 or nGold > 0) then
		if (strlen(strAML) > 0) then
			strAML = strAML.." ";
			strNumberFormat = "%02d";
		end

		strAML = strAML..format(strNumberFormat .. '<T TextColor="%s">g</T>', nGold, strColorGold);
	end

	-- Silver
	if (nPlatin > 0 or nGold > 0 or nSilver > 0) then
		if (strlen(strAML) > 0) then
			strAML = strAML.." ";
			strNumberFormat = "%02d";
		end

		strAML = strAML..format(strNumberFormat .. '<T TextColor="%s">s</T>', nSilver, strColorSilver);
	end

	-- Copper
	if (strlen(strAML) > 0) then
		strAML = strAML.." ";
		strNumberFormat = "%02d";
	end

	strAML = strAML..format(strNumberFormat .. '<T TextColor="%s">c</T>', nCopper, strColorCopper);

	return '<P Font="' .. (strFont or "CRB_Pixel") .. '" Align="Right" TextColor="ffffffff">'..strAML..'</P>';
end

-----------------------------------------------------------------------------
-- Chat Output
-- Only supports Carbine's ChatLog
-----------------------------------------------------------------------------

local kcrAddonChannel = ApolloColor.new("magenta");

function S:ChatOutput(arMessageSegments)
	-- arMessageSegments is an array of:
	--   strType = Text or Image
	--   strContent = The actual text or the image sprite
	--   nImageWidth (Optional, default is 18)
	--   nImageHeight (Optional, default is 18)
	--   crSemgment = ApolloColor Name (like "white")
	local tChatLog = Apollo.GetAddon("ChatLog");
	local strFontOption = tChatLog.strFontOption;
	local bShowTimestamp = tChatLog.bShowTimestamp;

	local xml = XmlDoc.new()

	-- Timestamp + Channel
	local tmNow = GameLib.GetLocalTime();
	local strTime = (bShowTimestamp and format("%d:%02d ", tmNow.nHour, tmNow.nMinute or ""));

	xml:AddLine(strTime .. "[s:UI] ", kcrAddonChannel, strFontOption, "Left");

	-- Content
	for i, tSegment in ipairs(arMessageSegments) do
		if (tSegment.strType ~= "Image") then
			local crSegment = ApolloColor.new(tSegment.crSegment or "white");
			local strContent = tSegment.strContent..(tSegment.bNoSpace and "" or " ");

			xml:AppendText(strContent, crSegment, strFontOption);
		else
			xml:AppendImage(tSegment.strContent, tSegment.nImageWidth or 18, tSegment.nImageHeight or 18);
		end
	end

	-- Queue Message
	tChatLog.bQueuedMessages = true;
	tChatLog.tChatWindows[1]:GetData().tMessageQueue:Push({ xml = xml });
end

-----------------------------------------------------------------------------
-- Misc
-----------------------------------------------------------------------------

function S:Round(nValue)
	return floor(nValue + 0.5);
end
