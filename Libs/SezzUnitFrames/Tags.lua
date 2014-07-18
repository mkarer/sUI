--[[

	s:UI Unit Frame Tags

	Based on oUF Tags [*]
	Credits: Haste, Vika, Cladhaire, Tekkub

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	-----------------------------------------------------------------------------

	[*] oUF License:

	Copyright (c) 2006-2014 Trond A Ekseth <troeks@gmail.com>

	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.

--]]

local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
if (UnitFrameController.Tags) then return; end

local GeminiEvent = Apollo.GetPackage("Gemini:Event-1.0").tPackage;

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------

local knMaxLevel = 50;
local ktDifficultyColors = {
	{-4, "ff7d7d7d"}, -- Trivial
	{-3, "ff01ff07"}, -- Inferior
	{-2, "ff01fcff"}, -- Minor
	{-1, "ff597cff"}, -- Easy
	{ 0, "ffffffff"}, -- Average
	{ 1, "ffffff00"}, -- Moderate
	{ 2, "ffff8000"}, -- Tough
	{ 3, "ffff0000"}, -- Hard
	{ 4, "ffff00ff"} -- Impossible
};

-----------------------------------------------------------------------------
-- Window Metatable Wrapper
-----------------------------------------------------------------------------

local tUserDataWrapper = {};
local tUserDataMetatable = {};

function tUserDataMetatable:__index(strKey)
	local proto = rawget(self, "__proto__");
	local field = proto and proto[strKey];

	if (type(field) ~= "function") then
		return field;
	else
		return function(obj, ...)
			if (obj == self) then
				return field(proto, ...);
			else
				return field(obj, ...);
			end
		end
	end
end

function tUserDataWrapper:New(o)
	return setmetatable({__proto__ = o}, tUserDataMetatable);
end

local function WrapControl(wndControl)
	return tUserDataWrapper:New(wndControl);
end

-----------------------------------------------------------------------------
-- Tagging System
-----------------------------------------------------------------------------

local _PATTERN = '%[..-%]+';

local _ENV = {
	ColorArrayToHex = function(arColor)
		local r = math.floor(255 * arColor[1] + 0.5);
		local g = math.floor(255 * arColor[2] + 0.5);
		local b = math.floor(255 * arColor[3] + 0.5);
		local a = arColor[4] and math.floor(255 * arColor[4] + 0.5) or 255;

		return string.format("%02x%02x%02x%02x", a, r, g, b);
	end,
	RGBColorToHex = function(r, g, b, a)
		local r = math.floor(255 * r + 0.5);
		local g = math.floor(255 * g + 0.5);
		local b = math.floor(255 * b + 0.5);
		local a = a and math.floor(255 * a + 0.5) or 255;

		return string.format("%02x%02x%02x%02x", a, r, g, b);
	end,
	UnitIsObject = function(unit)
		local nCurrentHealth = unit:GetHealth();
		local nMaxHealth = unit:GetMaxHealth();

		return (unit:IsOnline() and not unit:IsDisconnected() and (not nCurrentHealth or not nMaxHealth or (nCurrentHealth == 0 and nMaxHealth == 0)));
	end,
	WrapAML = function(strTag, strText, strColor, strAlign)
		return format('<%s Font="CRB_Pixel_O" Align="%s" TextColor="%s">%s</%s>', strTag, strAlign or "Left", strColor or "ffffffff", strText, strTag);
	end,
	GetDifficultyColor = function(unit)
		local nUnitCon = (GameLib.GetPlayerUnit():GetLevelDifferential(unit.__proto__ or unit) or 0) + unit:GetGroupValue();
		local nCon = 1; --default setting

		if (nUnitCon <= ktDifficultyColors[1][1]) then -- lower bound
			nCon = 1;
		elseif (nUnitCon >= ktDifficultyColors[#ktDifficultyColors][1]) then -- upper bound
			nCon = #ktDifficultyColors;
		else
			for idx = 2, (#ktDifficultyColors-1) do -- everything in between
				if (nUnitCon == ktDifficultyColors[idx][1]) then
					nCon = idx;
				end
			end
		end

		return ktDifficultyColors[nCon][2];
	end,
};

local _PROXY = setmetatable(_ENV, { __index = _G });

local tagStrings = {
	["TClose"] = [[function()
		return '</T>';
	end]],

	["Level"] = [[function(unit)
		local l = unit:GetLevel();

		if (l and l > 0) then
			return l;
		else
			return '??';
		end
	end]],

	["Classification"] = [[function(unit)
		local strRank = "";

		-- Scale Indicator
		if (unit:IsMentoring()) then
			strRank = strRank.."~";
		end

		-- Elite Indicator
		if (unit:GetRank() == Unit.CodeEnumRank.Elite) then
			strRank = strRank.."+";
		end

		return strRank;
	end]],

	["Name"] = [[function(unit)
		return unit:GetName();
	end]],

	["Role"] = [[function(unit)
		local strRole = unit:GetRole();

		if (strRole == "TANK") then
			return "Tank";
		elseif (strRole == "HEALER") then
			return "Healer";
		end
	end]],

	["TClassColor"] = [[function(unit)
		return '<T Font="CRB_Pixel_O" TextColor="'..ColorArrayToHex(_COLORS.Class[UnitIsObject(unit) and "Object" or unit:GetClassId()])..'">';
	end]],

	["TDifficultyColor"] = [[function(unit)
		return '<T Font="CRB_Pixel_O" TextColor="'..GetDifficultyColor(unit)..'">';
	end]],

};

local tags = setmetatable(
	{},
	{
		__index = function(self, key)
			local tagFunc = tagStrings[key];
			if (tagFunc) then
				local func, err = loadstring('return ' .. tagFunc);
				if (func) then
					func = func();

					-- Want to trigger __newindex, so no rawset.
					self[key] = func;
					tagStrings[key] = nil;

					return func;
				else
					error(err, 3);
				end
			end
		end,
		__newindex = function(self, key, val)
			if (type(val) == 'string') then
				tagStrings[key] = val;
			elseif(type(val) == 'function') then
				-- So we don't clash with any custom envs.
				if (getfenv(val) == _G) then
					setfenv(val, _PROXY);
				end

				rawset(self, key, val);
			end
		end,
	}
);

_ENV._TAGS = tags;

local tagEvents = {
	["Name"]				= "UnitNameChanged",
	["Level"]				= "UnitLevelChanged Sezz_GroupUnitLevelChanged",
	["TDifficultyColor"]	= "UnitLevelChanged Sezz_GroupUnitLevelChanged PlayerLevelChange",
};

local unitlessEvents = {
	PlayerLevelChange = true,
};

local events = {};
local frame = GeminiEvent:Embed({});
frame.OnEvent = function(self, event, unit)
	local strings = events[event];

	if (type(unit) == "number") then
		-- Group_* Events
		unit = UnitFrameController:GetUnit((GroupLib.InRaid() and "Raid" or "Party"), unit);
	end

	if (strings and unit) then
		for k, fontstring in next, strings do
			if (fontstring:IsVisible() and (unitlessEvents[event] or fontstring.parent.unit:GetId() == unit:GetId())) then
				fontstring:UpdateTag();
			end
		end
	end
end

local OnUpdates = {};
local eventlessUnits = {};

local createOnUpdate = function(timer)
	local OnUpdate = OnUpdates[timer];

	if (not OnUpdate) then
		local ticks = GameLib.GetTickCount();
		local updated = ticks - timer;
		local frame = {};
		local strings = eventlessUnits[timer];

		frame.OnUpdate = function(self)
			ticks = GameLib.GetTickCount();

			if (ticks - updated >= timer) then
				for k, fs in next, strings do
					if (fs.parent.bEnabled and fs.parent.unit and fs.parent.unit:IsValid()) then
						fs:UpdateTag();
					end
				end

				updated = ticks;
			end
		end

		Apollo.RegisterEventHandler("NextFrame", "OnUpdate", frame);

		OnUpdates[timer] = frame;
	end
end

local getTagName = function(tag)
	local s = (tag:match('>+()') or 2);
	local e = tag:match('.*()<+');
	e = (e and e - 1) or -2;

	return tag:sub(s, e), s, e;
end

local RegisterEvent = function(fontstr, event)
	if (not events[event]) then events[event] = {}; end

	frame:RegisterEvent(event, "OnEvent");
	table.insert(events[event], fontstr);
end

local RegisterEvents = function(fontstr, tagstr)
	for tag in tagstr:gmatch(_PATTERN) do
		tag = getTagName(tag);
		local tagevents = tagEvents[tag];
		if (tagevents) then
			for event in tagevents:gmatch'%S+' do
				RegisterEvent(fontstr, event);
			end
		end
	end
end

local UnregisterEvents = function(fontstr)
	for event, data in pairs(events) do
		for k, tagfsstr in pairs(data) do
			if(tagfsstr == fontstr) then
				if(#data == 1) then
					frame:UnregisterEvent(event);
				end

				table.remove(data, k);
			end
		end
	end
end

local tagPool = {};
local funcPool = {};
local tmp = {};

local Tag = function(self, fs, tTag)
	if (not fs or not tTag) then return end
	if (type(fs) == "userdata") then
		fs = WrapControl(fs);
	end

	fs.strFont = tTag.Font;
	fs.strAlign = tTag.Align;

	local tagstr = tTag.Tags;

	if (not self.tTagControls) then
		self.tTagControls = {};
	else
		-- Since people ignore everything that's good practice - unregister the tag
		-- if it already exists.
		for _, tag in pairs(self.tTagControls) do
			if (fs == tag) then
				-- We don't need to remove it from the tTagControls table as Untag handles
				-- that for us.
				self:Untag(fs);
			end
		end
	end

	fs.parent = self;

	local func = tagPool[tagstr];
	if (not func) then
		local format, numTags = tagstr:gsub('%%', '%%%%'):gsub(_PATTERN, '%%s');
		local args = {};

		for bracket in tagstr:gmatch(_PATTERN) do
			local tagFunc = funcPool[bracket] or tags[bracket:sub(2, -2)];
			if (not tagFunc) then
				local tagName, s, e = getTagName(bracket);

				local tag = tags[tagName];
				if (tag) then
					s = s - 2;
					e = e + 2;

					if (s ~= 0 and e ~= 0) then
						local pre = bracket:sub(2, s);
						local ap = bracket:sub(e, -2);

						tagFunc = function(u, r)
							local str = tag(u, r);
							if (str) then
								return pre..str..ap;
							end
						end
					elseif (s ~= 0) then
						local pre = bracket:sub(2, s);

						tagFunc = function(u, r)
							local str = tag(u, r);
							if (str) then
								return pre..str;
							end
						end
					elseif (e ~= 0) then
						local ap = bracket:sub(e, -2);

						tagFunc = function(u, r)
							local str = tag(u, r);
							if (str) then
								return str..ap;
							end
						end
					end

					funcPool[bracket] = tagFunc;
				end
			end

			if (tagFunc) then
				table.insert(args, tagFunc);
			else
				return error(('Attempted to use invalid tag %s.'):format(bracket), 3);
			end
		end

		if (numTags == 1) then
			func = function(self)
				local parent = self.parent;
				local realUnit;
				if (self.overrideUnit) then
					realUnit = parent.realUnit;
				end

				_ENV._COLORS = parent.tColors;
				return self:SetText(string.format(
					format,
					args[1](parent.unit, realUnit) or ''
				));
			end
		elseif (numTags == 2) then
			func = function(self)
				local parent = self.parent;
				local unit = parent.unit;
				local realUnit;
				if (self.overrideUnit) then
					realUnit = parent.realUnit;
				end

				_ENV._COLORS = parent.tColors;
				return self:SetText(string.format(
					format,
					args[1](unit, realUnit) or '',
					args[2](unit, realUnit) or ''
				));
			end
		elseif (numTags == 3) then
			func = function(self)
				local parent = self.parent;
				local unit = parent.unit;
				local realUnit;
				if (self.overrideUnit) then
					realUnit = parent.realUnit;
				end

				_ENV._COLORS = parent.tColors;
				return self:SetText(string.format(
					format,
					args[1](unit, realUnit) or '',
					args[2](unit, realUnit) or '',
					args[3](unit, realUnit) or ''
				));
			end
		else
			func = function(self)
				local parent = self.parent;
				local unit = parent.unit;
				local realUnit;
				if (self.overrideUnit) then
					realUnit = parent.realUnit;
				end

				_ENV._COLORS = parent.tColors;
				for i, func in next, args do
					tmp[i] = func(unit, realUnit) or '';
				end

				-- We do 1, numTags because tmp can hold several unneeded variables.
				return self:SetText(string.format(format, unpack(tmp, 1, numTags)));
			end
		end

		tagPool[tagstr] = func;
	end
	fs.UpdateTag = func;

	local strUnit = self.strUnit;
	if ((strUnit and strUnit:match'Target') or tTag.Interval) then
		local timer;
		if (type(tTag.Interval) == 'number') then
			timer = tTag.Interval;
		else
			timer = 500;
		end

		if (not eventlessUnits[timer]) then eventlessUnits[timer] = {}; end
		table.insert(eventlessUnits[timer], fs);

		createOnUpdate(timer);
	else
		RegisterEvents(fs, tagstr);
	end

	table.insert(self.tTagControls, fs);
end

local Untag = function(self, fs)
	if (not fs) then return; end

	UnregisterEvents(fs);
	for _, timers in next, eventlessUnits do
		for k, fontstr in next, timers do
			if (fs == fontstr) then
				table.remove(timers, k);
			end
		end
	end

	for k, fontstr in next, self.tTagControls do
		if (fontstr == fs) then
			table.remove(self.tTagControls, k);
		end
	end

	fs.UpdateTag = nil;
end

UnitFrameController.Tags = {
	Methods = tags,
	Events = tagEvents,
	SharedEvents = unitlessEvents,
};

UnitFrameController.Tag = Tag;
UnitFrameController.Untag = Untag;
