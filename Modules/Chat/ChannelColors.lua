--[[

	s:UI Chat Modifications

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "ChatSystemLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local ChatCore = S:GetModule("ChatCore");
local M = ChatCore:CreateSubmodule("ChannelColors");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Configuration
	local colWhite = { a = 1, r = 1, g = 1, b = 1 };
	local colYellow = { a = 1, r = 1, g = 1, b = 0 };
	local colRed = { a = 1, r = 1, g = 0, b = 0 };
	local colInstance = { a = 1, r = 1, g = 0.5, b = 0 };
	local colChannel = { a = 1, r = 1, g = 0.74, b = 0.71 };
	local colEmote = { a = 1, r = 1, g = 0.5, b = 0.25 };
	local colNpcSay = { a = 1, r = 1, g = 1, b = 0.63 };
	local colCombat = { a = 1, r = 1, g = 0.74, b = 0.71 };

	local arChatColorsBlizzard = { 
		[ChatSystemLib.ChatChannel_Zone] = colChannel, 
		[ChatSystemLib.ChatChannel_Command] = colWhite, 
		[ChatSystemLib.ChatChannel_System] = colYellow,
		[ChatSystemLib.ChatChannel_Debug] = colWhite,
		[ChatSystemLib.ChatChannel_Say] = colWhite,
		[ChatSystemLib.ChatChannel_Yell] = colRed,
		[ChatSystemLib.ChatChannel_Whisper] = { a = 1, r = 1, g = 0.40, b = 1 },
		[ChatSystemLib.ChatChannel_Party] = { a = 1, r = 0.59, g = 0.6, b = 1 },
		[ChatSystemLib.ChatChannel_AnimatedEmote] = colEmote,
		[ChatSystemLib.ChatChannel_ZonePvP] = colInstance,
		[ChatSystemLib.ChatChannel_Trade] = colChannel,
		[ChatSystemLib.ChatChannel_GuildOfficer] = { a = 1, r = 0.25, g = 0.53, b = 0.25 },
		[ChatSystemLib.ChatChannel_NPCSay] = colNpcSay,
		[ChatSystemLib.ChatChannel_NPCYell] = { a = 1, r = 1, g = 0.25, b = 0.25 },
		[ChatSystemLib.ChatChannel_NPCWhisper] = { a = 1, r = 1, g = 0.55, b = 0.43 },
		[ChatSystemLib.ChatChannel_Loot] = { a = 1, r = 0, g = 0.59, b = 0 },
		[ChatSystemLib.ChatChannel_Emote] = colEmote,
		[ChatSystemLib.ChatChannel_Instance] = colInstance,
		[ChatSystemLib.ChatChannel_WarParty] = colInstance,
		[ChatSystemLib.ChatChannel_WarPartyOfficer] = colInstance,
		[ChatSystemLib.ChatChannel_Advice] = colChannel,
		[ChatSystemLib.ChatChannel_AccountWhisper] = { a = 1, r = 0, g = 0.98, b = 0.96 },
		[ChatSystemLib.ChatChannel_Datachron] = colNpcSay,
		[ChatSystemLib.ChatChannel_PlayerPath] = colCombat,
		[ChatSystemLib.ChatChannel_Guild] = { a = 1, r = 0.25, g = 1, b = 0.25 }, 
		[ChatSystemLib.ChatChannel_Society] = { a = 1, r = 0.71, g = 1, b = 0.24 },
		[ChatSystemLib.ChatChannel_Realm] = colYellow,
		[ChatSystemLib.ChatChannel_Combat] = colCombat,
	 };

	-- Set Colors
	log:debug("Updating Chat Channel Colors...");
	for k, v in pairs(arChatColorsBlizzard) do
		ChatCore.tChatLog.arChatColor[k] = v;
	end
end
