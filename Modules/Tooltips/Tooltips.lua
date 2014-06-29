--[[

	s:UI Tooltips

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Tooltips", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	local tTooltips = Apollo.GetAddon("ToolTips");
	if (tTooltips) then
		self:PostHook(tTooltips, "OnDocumentReady", "UpdateWorldTooltipContainer");
	else
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:UpdateWorldTooltipContainer()
	GameLib.GetWorldTooltipContainer():SetTooltipType(0);
end
