--[[

	s:UI Data Text

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("DataText", "Gemini:Hook-1.0");
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
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

