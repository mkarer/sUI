--[[

	s:UI Temp File

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Temp", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	if (S.bCharacterLoaded) then
--		self:EventHandler();
	else
--		self:RegisterEvent("Sezz_CharacterLoaded", "EventHandler");
	end
end

function M:EventHandler(event, ...)
	local x = AbilityBook.GetAbilitiesList();
	for _, spl in pairs(x) do
		if (spl.strName == "Impale") then
			log:debug(spl.nId);
			log:debug(spl.tTiers[1].splObject:GetIcon());
		end
	end
end
