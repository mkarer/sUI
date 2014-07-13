--[[

	s:UI Slash Commands

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "ChatSystemLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = {};

-----------------------------------------------------------------------------

-- Reload UI
Apollo.RegisterSlashCommand("rl", "RequestReloadUI");

-- Emotes
-- ChatSystemLib.GetEmotes()
local emoteShortcuts = {
	ty = "thanks",
	thx = "thanks",
	lol = "laugh",
	hi = "welcome",
};

function M:DoEmote(emote, target)
	if (emote and emoteShortcuts[emote]) then
		ChatSystemLib.Command("/"..emoteShortcuts[emote].. " "..target);
	end
end

for emote, v in pairs(emoteShortcuts) do
	Apollo.RegisterSlashCommand(emote, "DoEmote", M);
end

-- Window Wire Frames
function M:ToggleWindowWireFrames()
	Apollo.SetConsoleVariable("ui.WindowWireFrame", not Apollo.GetConsoleVariable("ui.WindowWireFrame"));
end

Apollo.RegisterSlashCommand("fstack", "ToggleWindowWireFrames", M);

-- Focus
function M:SetFocus()
	local unitPlayer = GameLib.GetPlayerUnit();
	unitPlayer:SetAlternateTarget(unitPlayer:GetTarget());
end

Apollo.RegisterSlashCommand("focus", "SetFocus", M);
