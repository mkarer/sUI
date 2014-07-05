--[[

	s:UI Temp File

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

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

--	self:RegisterEvent("ObscuredAddonVisible", "EventHandler");
	self:RegisterEvent("CombatLogPet", "EventHandler");
--	Apollo.RegisterEventHandler("ObscuredAddonVisible", "EventHandler", self);

end

local pets = {};

function M:EventHandler(event, ...)
	log:debug(event);
	log:debug({...});

	if (true) then return; end

	if (event == "InterfaceMenuList_AlertAddOn") then
		local strAddon, tAlertInfo = ...;

		if (strAddon == Apollo.GetString("InterfaceMenu_Mail")) then
			log:debug("[InterfaceMenuList_AlertAddOn] Show Mail Alert: "..(tAlertInfo[1] and "YES" or "NO"));
		end
	end


--	ChallengeRewardPanel:OnWindowCloseDelay();

--[[
	-- Apollo.LoadForm Hook
	-- Why is everything in ToolTips.lua hardcoded?!
	Apollo._LoadForm = Apollo.LoadForm;
	Apollo.LoadForm = function(strFile, ...)
		if (type(strFile) == "string" and (strFile == "TooltipsForms.xml" or strFile == "ui\\Tooltips\\TooltipsForms.xml")) then
			strFile = tTooltips.xmlDoc;
		end

		return Apollo._LoadForm(strFile, ...);
	end
]]
end
