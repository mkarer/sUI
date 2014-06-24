--[[

	s:UI Experience Bars

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("Experience", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
	self:MoveExperienceBars();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:MoveExperienceBars()
	local tXPBar = Apollo.GetAddon("XPBar");
	if (not tXPBar) then return; end
	self:Unhook(tXPBar, "OnDocumentReady");

	if (tXPBar.wndMain ) then
		log:debug("Skinning Experience Bars", self:GetName());

		tXPBar.wndMain:SetAnchorOffsets(156, -239, -472, -187);
	else
		self:PostHook(tXPBar, "OnDocumentReady", "MoveExperienceBars");
	end
end
