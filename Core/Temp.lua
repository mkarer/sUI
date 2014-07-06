--[[

	s:UI Temp File

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Temp", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------

local TestClass = {};

TestClass.strName = "Base";
TestClass.tNames = {};

local tColors = {
	Power = {
		["MANA"]					= { 45/255, 82/255, 137/255 },
		["RAGE"]					= { 226/255, 45/255, 75/255 },
		["FOCUS"]					= { 1, 210/255, 0 },
		["ENERGY"]					= { 1, 220/255, 25/255 },
		["RUNIC_POWER"]				= { 1, 210/255, 0 },
		["POWER_TYPE_STEAM"]		= { 0.55, 0.57, 0.61 },
		["POWER_TYPE_PYRITE"]		= { 0.60, 0.09, 0.17 },
		["POWER_TYPE_FEL_ENERGY"]	= { 1, 1, 0.3 },
		["AMMOSLOT"]				= { 0.8, 0.6, 0 },
	},
	Reaction = {
		[2] = { 1, 0, 0 },
		[4] = { 1, 1, 0 },
		[5] = { 0, 1, 0 },
	},
	Health = { 38/255, 38/255, 38/255 },
	HealthSmooth = { 255/255, 38/255, 38/255, 255/255, 38/255, 38/255, 38/255, 38/255, 38/255 },
	Vulnerability = { 127/255, 38/255, 127/255 },
	VulnerabilitySmooth = { 255/255, 38/255, 255/255, 255/255, 38/255, 255/255, 38/255, 38/255, 38/255 },
	Tagged = { 153/255, 153/255, 153/255 },
	Experience = {
		Normal = { 45/255 - 0.1, 85/255 + 0.2, 137/255 },
		Rested = { 45/255 + 0.2, 85/255 - 0.1, 137/255 - 0.1 },
	},
	CastBar = {
		Normal = { 0.43, 0.75, 0.44 },
		Uninterruptable = { 1.00, 0.75, 0.44 },
		Vulnerability = { 127/255, 38/255, 127/255 },
		Warning = { 1, 0, 0 },
	},
	Class = setmetatable({
		["Default"]								= { 255/255, 255/255, 255/255 },
		["Object"]								= { 0, 1, 0 },
		[GameLib.CodeEnumClass.Engineer]		= { 164/255,  26/255,  49/255 },
		[GameLib.CodeEnumClass.Esper]			= { 116/255, 221/255, 255/255 },
		[GameLib.CodeEnumClass.Medic]			= { 255/255, 255/255, 255/255 },
		[GameLib.CodeEnumClass.Stalker]			= { 221/255, 212/255,  95/255 },
		[GameLib.CodeEnumClass.Spellslinger]	= { 130/255, 111/255, 172/255 },
		[GameLib.CodeEnumClass.Warrior]			= { 171/255, 133/255,  94/255 },
	}, { __index = function(t, k) return rawget(t, k) or rawget(t, "Default"); end }),
};

function TestClass:Hi()
	log:debug(self.strName);
	for _, v in ipairs(self.tNames) do
		log:debug(v);
	end
end

function TestClass:New(strName, tCustomColors)
	self = setmetatable({}, { __index = TestClass });
--	self.__index = TestClass;
--	self.__newindex = self;

	self.strName = strName;
	self.tColors = (tCustomColors and setmetatable(tCustomColors, { __index = tColors }) or tColors);

	return self;
end

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

function S:Test()
	log:debug("--1");
	local t1 = TestClass:New("test1")
	t1:Hi();
	t1.gusti = "sex";
	log:debug(t1.gusti)
	log:debug(t1.tColors.CastBar.Normal)
	log:debug(t1.tColors.CastBar.Green)

	log:debug("--2");
local tc= {
	CastBar = {
		Normal = "red",
		Green = "grüüüün",
	},
}
	local t2 = TestClass:New("test2", tc)
	t2:Hi();
	log:debug(t2.gusti)
	log:debug(t2.tColors.CastBar.Normal)
	log:debug(t2.tColors.CastBar.Green)

	log:debug("--1");
	t1:Hi();
	log:debug(t1.gusti)
	log:debug(t1.tColors.CastBar.Normal)
	log:debug(t1.tColors.CastBar.Green)

	log:debug("--TestClass");
	TestClass:Hi();
	log:debug(TestClass.gusti)
	log:debug(TestClass.tColors)

	log:debug("------");
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
