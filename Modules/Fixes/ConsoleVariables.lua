--[[

	s:UI Custom Console Variables

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("ConsoleVariables");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("Updating Console Variables...", self:GetName());

	-- Update Console Variables
	Apollo.SetConsoleVariable("camera.FovY", 60);			-- http://www.rjdown.co.uk/projects/bfbc2/fovcalculator.php
	Apollo.SetConsoleVariable("chat.filter", false);		-- Disable Profanity Filter
	Apollo.SetConsoleVariable("hud.healthTextDisplay", 2);	-- Show Health Text
	Apollo.SetConsoleVariable("hud.timeDisplay", 1); 		-- Show Clock
	Apollo.SetConsoleVariable("ui.TooltipDelay", 0);		-- Disable Tooltip Delay
end
