--[[

	s:UI Utility Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-- Lua API
local mod, format, floor = math.mod, string.format, math.floor;

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
