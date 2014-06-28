--[[

	s:UI Temp File

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("Temp", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
--	self:Hook(Apollo, "LoadForm", "OnLoadForm");
end

function M:OnEnable()
--	Apollo.RegisterEventHandler("ToggleTradeskills", "OnToggleTradeskills", self); 
end

function M:OnLoadForm(strFile, strForm, wndParent, tLuaEventHandler)
	if (strForm and strForm == "TradeskillContainerForm") then
		self:Hook(tLuaEventHandler, "OnClose", "OnCloseTradeskillContainer");
		self:Unhook(Apollo, "LoadForm");
	end
end

function M:OnToggleTradeskills()
	log:debug("ToggleTradeskills");
	log:debug("Tradeskills window is %s", Apollo.FindWindowByName("TradeskillContainerForm"):IsShown() and "visible" or "hidden");
end

function M:OnCloseTradeskillContainer()
	log:debug("CloseTradeskillContainer");
end
