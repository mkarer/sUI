--[[

	s:UI Data Text

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("DataText");
local log;
local strformat, tostring = string.format, tostring;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self.tFontSmall = S:CreatePixelFont("04b_11", 8);
	self.tFontLarge = S:CreatePixelFont("04b_11", 24);
	self.tColorClock = CColor.new(1, 1, 1, 0.2);

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "DataText", nil, self);
	self.wndMain:Show(true, true);

	-- Start Clock Timer + Update Time
	self.timerClock = ApolloTimer.Create(2, true, "UpdateText", self);
	self.timerMemory = ApolloTimer.Create(1, true, "UpdateAddondMemory", self);
	self.timerStats = ApolloTimer.Create(3, true, "UpdateLatency", self);

	-- Update Memory/Stats
	self:UpdateAddondMemory();
	self:UpdateLatency();

	-- Update Durability
	self:RegisterEvent("ItemDurabilityUpdate", "UpdateDurability");
	self:RegisterEvent("Sezz_CharacterLoaded", "UpdateDurability");
	self:UpdateDurability();

	-- Show Text
	self:UpdateText();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Clock
-----------------------------------------------------------------------------

function M:UpdateText(a)
	-- Get Time
	local tTime = GameLib.GetLocalTime();
	local strTime = strformat("%02d:%02d", tostring(tTime.nHour), tostring(tTime.nMinute));

	-- Update Text
	local strStats = strformat("%dFPS %.1fMB %dMS %d%%", self.nFPS, self.nAddonMemory, self.nLatency, self.nDurability);

	self.tFontLarge:Draw(self.wndMain:FindChild("Clock"), strTime, true, self.tColorClock);
	self.tFontSmall:Draw(self.wndMain:FindChild("Stats"), strStats, true);
end


-----------------------------------------------------------------------------
-- Latency / FPS
-----------------------------------------------------------------------------

function M:UpdateLatency()
	self.nLatency = GameLib.GetLatency();
	self.nFPS = GameLib.GetFrameRate();
end

-----------------------------------------------------------------------------
-- Durability
-----------------------------------------------------------------------------

function M:UpdateDurability()
	local nDurabilityLowest = 100;

	if (S.bCharacterLoaded) then
		local tItems = S.myCharacter:GetEquippedItems();

		for _, tItem in ipairs(tItems) do
			local nDurabilityMax = tItem:GetMaxDurability();
			local nDurabilityCurrent = tItem:GetDurability();

			if (nDurabilityMax > 0) then
				local nDurabilityPercent = math.floor(nDurabilityCurrent / (nDurabilityMax / 100));

				if (nDurabilityPercent < nDurabilityLowest) then
					nDurabilityLowest = nDurabilityPercent;
				end
			end
		end
	end

	self.nDurability = nDurabilityLowest;
end

-----------------------------------------------------------------------------
-- Addon Memory
-----------------------------------------------------------------------------

local tAddonMemory = {};
local tAddonList;
local iCurrentAddon = 1;
local nTotalAddons = 0;

local UpdateAddonMemory = function(strAddon)
	local tAddon = Apollo.GetAddonInfo(strAddon);
	if (tAddon and tAddon.nMemoryUsage) then
		tAddonMemory[strAddon] = tonumber(tAddon.nMemoryUsage);
	else
		tAddonMemory[strAddon] = 0;
	end
end

function M:UpdateAddondMemory()
	if (S.inCombat) then return; end
	local bInitialRun = false;

	-- Initial Run
	if (not tAddonList) then
		bInitialRun = true;
		tAddonList = Apollo.GetAddons();
		for _, strAddon in ipairs(tAddonList) do
			UpdateAddonMemory(strAddon);
		end

		nTotalAddons = #tAddonList;
	end

	-- Update only one addon every tick
	if (not bInitialRun) then
		if (iCurrentAddon > nTotalAddons or not tAddonList[iCurrentAddon]) then
			iCurrentAddon = 1;
		end

		if (tAddonList[iCurrentAddon]) then
			local nNow = GameLib.GetTickCount();
			UpdateAddonMemory(tAddonList[iCurrentAddon]);
			local nUpdateTime = GameLib.GetTickCount() - nNow;
			if (nUpdateTime > 0) then
				log:debug(" +++ Updated: %s (%sms)", tAddonList[iCurrentAddon], nUpdateTime);
			end

			iCurrentAddon = iCurrentAddon + 1;
		end
	end

	-- Calculate total used memory
	local nAddonMemory = 0;

	for i = 1, nTotalAddons do
		nAddonMemory = nAddonMemory + tAddonMemory[tAddonList[i]];
	end

	self.nAddonMemory = nAddonMemory / 1024 / 1024;
--	log:debug(self.nAddonMemory);

--[[
	local nAddonMemory = 0;
	local tAddons = Apollo:GetAddons();

	for _, strName in pairs(tAddons) do
		if (not tAddonsCarbine[strName]) then
			local tAddon = Apollo.GetAddonInfo(strName);
			if (tAddon and tAddon.nMemoryUsage) then
				nAddonMemory = nAddonMemory + tAddon.nMemoryUsage;
			end
		end
	end

	self.nAddonMemory = nAddonMemory / 1024 / 1024;
]]
end
