--[[

	s:UI Crafting Unmounting

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("UnmountToCraft");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
--	log:debug("%s enabled.", self:GetName());
	Apollo.RegisterEventHandler("InvokeCraftingWindow", "Unmount", self);
end

function M:OnDisable()
--	log:debug("%s disabled.", self:GetName());
	Apollo.RemoveEventHandler("InvokeCraftingWindow", self);
end

function M:Unmount()
	GameLib:Disembark();
end
