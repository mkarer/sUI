--[[

	s:UI Sticky Whisper Channel

	Credits to Adelea
	http://www.curse.com/ws-addons/wildstar/221531-adeleauifixes

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "ChatSystemLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local ChatCore = S:GetModule("ChatCore");
local M = ChatCore:CreateSubmodule("StickyWhisper", "Gemini:Hook-1.0");
local log, chatPrefixes, chatChannels;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	chatPrefixes = {
		["/w"] = true,
		["/whisper"] = true,
		["/t"] = true,
		["/tell"] = true,
		["/aw"] = true,
	};

	chatChannels = {
		[ChatSystemLib.ChatChannel_AccountWhisper] = "/aw",
		[ChatSystemLib.ChatChannel_Whisper] = "/w"
	}

	self:RawHook(ChatCore.tChatLog, "OnChatInputReturn");
end

function M:OnChatInputReturn(luaCaller, wndHandler, wndControl, strText)
	local r = {};
	for token in string.gmatch(strText, "[^%s]+") do
		table.insert(r, token);
	end

	local tChatData = wndControl:GetParent():GetData();
	local chanCurrent = tChatData.channelCurrent:GetType();
	
	if (chatPrefixes[r[1]] and r[2]) then
		self.tChatPrefix = r[1];
		self.tLastWhisperer = r[2];
	end

	if (chatChannels[chanCurrent] and self.tLastWhisperer) then
		if (string.sub(strText, 1, 1) ~= "/") then
			strText = self.tChatPrefix.." "..self.tLastWhisperer.." "..strText;
		end
	end

	self.hooks[ChatCore.tChatLog].OnChatInputReturn(luaCaller, wndHandler, wndControl, strText);
end
