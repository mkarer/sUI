--[[

	s:UI Chat Core

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "ChatSystemLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("ChatCore", "Gemini:Hook-1.0");
M:SetDefaultModuleState(false);
local log;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self.ChatLog = Apollo.GetAddon("ChatLog");
	self.ChatLog.bProfanityFilter = false;
	if (self.ChatLog.arChatColor) then
		-- Enable Submodules
		self:EnableSubmodules();

		-- Disable Profanity Filter
		for _, channel in ipairs(ChatSystemLib.GetChannels()) do
			channel:SetProfanity(false);
		end
	else
		self:PostHook(self.ChatLog, "OnWindowManagementReady", "EnableSubmodules");
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
