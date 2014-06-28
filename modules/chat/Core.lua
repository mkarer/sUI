--[[

	s:UI Chat Core

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "ChatSystemLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("ChatCore", "Gemini:Event-1.0", "Gemini:Hook-1.0");
M:SetDefaultModuleState(false);
local log;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	self.tChatLog = Apollo.GetAddon("ChatLog");
	if (not self.tChatLog) then
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self:RegisterAddonLoadedCallback("ChatLog", "UpdateChat");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:UpdateChat()
	-- Enable Submodules
	self:EnableSubmodules();

	-- Disable Profanity Filter
	self.tChatLog.bProfanityFilter = false;
	for _, channel in ipairs(ChatSystemLib.GetChannels()) do
		channel:SetProfanity(false);
	end
end
