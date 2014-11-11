--[[

	s:UI Unit Frames Core

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("UnitFramesCore");
M:SetDefaultModuleState(false);
local log;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Enable Submodules
	self:EnableSubmodules();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
