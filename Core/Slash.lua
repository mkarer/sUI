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

-- Command Shortcuts
local tCommandShortcuts = {
	ty = "thanks",
	thx = "thanks",
	lol = "laugh",
	hi = "welcome",
	inv = "invite",
};

function M:ExecuteCommand(strCommand, strArguments)
	if (strCommand and tCommandShortcuts[strCommand]) then
		ChatSystemLib.Command("/"..tCommandShortcuts[strCommand].. " "..strArguments);
	end
end

for strCommand in pairs(tCommandShortcuts) do
	Apollo.RegisterSlashCommand(strCommand, "ExecuteCommand", M);
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

-- Ready Check
function M:ReadyCheck()
	GroupLib.ReadyCheck("Are you ready?");
end

Apollo.RegisterSlashCommand("rc", "ReadyCheck", M);
Apollo.RegisterSlashCommand("rch", "ReadyCheck", M);
Apollo.RegisterSlashCommand("readycheck", "ReadyCheck", M);
