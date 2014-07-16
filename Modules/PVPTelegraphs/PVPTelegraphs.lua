--[[

	s:UI Enemy Telegraph Toggler (PVE Servers)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("PVPTelegraphs", "Gemini:Hook-1.0");
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

	if (S.bCharacterLoaded) then
		self:UpdateTelegraphDisplay();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "UpdateTelegraphDisplay");
	end

	self:RegisterEvent("UnitPvpFlagsChanged", "OnUnitPvpFlagsChanged");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:UpdateTelegraphDisplay()
	Apollo.SetConsoleVariable("spell.enemyPlayerTelegraphDisplay", GameLib.IsPvpFlagged());
end

function M:OnUnitPvpFlagsChanged(event, unit)
	if (unit == S.myCharacter) then
		self:UpdateTelegraphDisplay();
	end
end
