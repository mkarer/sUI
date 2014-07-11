--[[

	s:UI Proc-/Cooldown-/Aura-Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("ProcBar");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self.PowerButtons = {};
	self.DB = {
		["alwaysVisible"] = false,
		["buttonSize"] = 36,
		["buttonPadding"] = 4,
		["barHeight"] = 6,
	};
end

function M:OnEnable()
	if (true) then return; end
	log:debug("%s enabled.", self:GetName());

	self:CreateAnchor();

	-- Load Class Configuration
	if (S.bCharacterLoaded) then
		self:ReloadConfiguration();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "ReloadConfiguration");
	end

	self:RegisterEvent("Sezz_LimitedActionSetChanged", "ReloadConfiguration");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:ReloadConfiguration()
	log:debug("ReloadConfiguration");
end

-----------------------------------------------------------------------------
