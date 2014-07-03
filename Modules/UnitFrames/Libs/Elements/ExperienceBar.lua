--[[

	s:UI Unit Frame Element: Experience (and Elder Points) Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:ExperienceBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log;

-- Lua API
local format, min, max = string.format, math.min, math.max;

-----------------------------------------------------------------------------

local knMaxLevel = 50;

local UpdateTooltip = function(self)
	-- Taken from XPBar.lua
	local wndExperience = self.tUnitFrame.wndExperience;
	local nLevel = self.tUnitFrame.unit:GetLevel() or 0;
	local strTooltip = "";

	local nRested = GetRestXp();
	local nRestedPool = GetRestXpKillCreaturePool();
	if (not nRested) then return; end

	if (nLevel < knMaxLevel) then
		-- Experience + Rested Experience (< Level 50)
		-- XPBar:ConfigureXPTooltip()
		local nCurrentXP = GetXp() - GetXpToCurrentLevel();
		local nNeededXP = GetXpToNextLevel();
		if (not nCurrentXP or not nNeededXP) then return; end

		strTooltip = string.format('<P Font="CRB_InterfaceSmall_O">%s</P>', String_GetWeaselString(Apollo.GetString("Base_XPValue"), nCurrentXP, nNeededXP, nCurrentXP / nNeededXP * 100));

		if (nRested > 0) then
			local strRestLineOne = String_GetWeaselString(Apollo.GetString("Base_XPRested"), nRested, nRested / nNeededXP * 100);
			strTooltip = string.format('%s<P Font="CRB_InterfaceSmall_O" TextColor="ffda69ff">%s</P>', strTooltip, strRestLineOne);

			if (nCurrentXP + nRestedPool > nNeededXP) then
				strTooltip = string.format('%s<P Font="CRB_InterfaceSmall_O" TextColor="ffda69ff">%s</P>', strTooltip, Apollo.GetString("Base_XPRestedEndsAfterLevelTooltip"));
			else
				local strRestLineTwo = String_GetWeaselString(Apollo.GetString("Base_XPRestedPoolTooltip"), nRestedPool, ((nRestedPool + nCurrentXP)  / nNeededXP) * 100);
				strTooltip = string.format('%s<P Font="CRB_InterfaceSmall_O" TextColor="ffda69ff">%s</P>', strTooltip, strRestLineTwo);
			end
		end
	else
		-- Elder Points + Rested Elder Points (Level 50)
		-- XPBar:ConfigureEPTooltip()
		local nCurrentEP = GetElderPoints();
		local nCurrentToDailyMax = GetPeriodicElderPoints();
		local nEPToAGem = GameLib.ElderPointsPerGem;
		local nEPDailyMax = GameLib.ElderPointsDailyMax;
		if (not nCurrentEP or not nEPToAGem or not nEPDailyMax) then return; end

		-- Top String
		strTooltip = String_GetWeaselString(Apollo.GetString("BaseBar_ElderPointsPercent"), nCurrentEP, nEPToAGem, min(99.9, nCurrentEP / nEPToAGem * 100));
		if (nCurrentEP == nEPDailyMax) then
			strTooltip = '<P Font="CRB_InterfaceSmall_O">' .. strTooltip .. '</P><P Font="CRB_InterfaceSmall_O">' .. Apollo.GetString("BaseBar_ElderPointsAtMax") .. "</P>";
		else
			local strDailyMax = String_GetWeaselString(Apollo.GetString("BaseBar_ElderPointsWeeklyMax"), nCurrentToDailyMax, nEPDailyMax, min(99.9, nCurrentToDailyMax / nEPDailyMax * 100));
			strTooltip = '<P Font="CRB_InterfaceSmall_O">' .. strTooltip .. '</P><P Font="CRB_InterfaceSmall_O">' .. strDailyMax .. "</P>"
		end

		-- Rested
		if (nRested > 0) then
			local strRestLineOne = String_GetWeaselString(Apollo.GetString("Base_EPRested"), nRested, nRested / nEPToAGem * 100);
			strTooltip = string.format('%s<P Font="CRB_InterfaceSmall_O" TextColor="ffda69ff">%s</P>', strTooltip, strRestLineOne);

			if (nCurrentEP + nRestedPool > nEPToAGem) then
				strTooltip = string.format('%s<P Font="CRB_InterfaceSmall_O" TextColor="ffda69ff">%s</P>', strTooltip, Apollo.GetString("Base_EPRestedEndsAfterLevelTooltip"));
			else
				local strRestLineTwo = String_GetWeaselString(Apollo.GetString("Base_EPRestedPoolTooltip"), nRestedPool, ((nRestedPool + nCurrentEP)  / nEPToAGem) * 100);
				strTooltip = string.format('%s<P Font="CRB_InterfaceSmall_O" TextColor="ffda69ff">%s</P>', strTooltip, strRestLineTwo);
			end
		end
	end

	-- Add Current Level Text
	strTooltip = string.format('<P Font="CRB_InterfaceSmall_O">%s%s</P>%s', Apollo.GetString("CRB_Level_"), nLevel, strTooltip);

	-- Update Tooltip
	wndExperience:SetTooltip(strTooltip);
end

local Update = function(self)
	if (not self.bEnabled) then return; end

	local wndExperience = self.tUnitFrame.wndExperience;
	local wndProgress = self.tUnitFrame.wndExperience:FindChild("Progress");
	local wndProgressRested = self.tUnitFrame.wndExperience:FindChild("ProgressRested");

	-- Get Current Experience/Elder Points
	local nLevel = self.tUnitFrame.unit:GetLevel() or 0;
	local nCurrent, nNeeded;

	if (nLevel < knMaxLevel) then
		nCurrent = GetXp() - GetXpToCurrentLevel();
		nNeeded = GetXpToNextLevel();
	else
		nCurrent = GetPeriodicElderPoints();
		nNeeded = GameLib.ElderPointsDailyMax; -- Weekly EP Cap
	end

	if (not nCurrent or not nNeeded) then return; end

	-- Get Rested Experience (TODO: EP Daily CAP)
	local nRested = max(GetRestXp(), GetRestXpKillCreaturePool());

	-- Experience
	wndProgress:SetMax(nNeeded);
	wndProgress:SetProgress(nCurrent);

	-- Rested Experience
	wndProgressRested:Show(nRested and nRested > 0, true);
	wndProgressRested:SetMax(nNeeded);
	if (nRested and nRested > 0) then
		wndProgressRested:SetProgress(min(nNeeded, nCurrent + nRested));
	end

	-- Update Tooltip
	UpdateTooltip(self);
end

local Enable = function(self)
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;

	Apollo.RegisterEventHandler("Group_MentorRelationship", 	"Update", self);
	Apollo.RegisterEventHandler("CharacterCreated", 			"Update", self);
	Apollo.RegisterEventHandler("UnitPvpFlagsChanged", 			"Update", self);
	Apollo.RegisterEventHandler("UnitNameChanged", 				"Update", self);
	Apollo.RegisterEventHandler("PersonaUpdateCharacterStats", 	"Update", self);
	Apollo.RegisterEventHandler("PlayerLevelChange", 			"Update", self);
	Apollo.RegisterEventHandler("UI_XPChanged", 				"Update", self);
	Apollo.RegisterEventHandler("ElderPointsGained", 			"Update", self);
	Apollo.RegisterEventHandler("OptionsUpdated_HUDPreferences","Update", self);

	self:Update();
end

local Disable = function(self, bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;

	Apollo.RemoveEventHandler("Group_MentorRelationship", self);
	Apollo.RemoveEventHandler("CharacterCreated", self);
	Apollo.RemoveEventHandler("UnitPvpFlagsChanged", self);
	Apollo.RemoveEventHandler("UnitNameChanged", self);
	Apollo.RemoveEventHandler("PersonaUpdateCharacterStats", self);
	Apollo.RemoveEventHandler("PlayerLevelChange", self);
	Apollo.RemoveEventHandler("UI_XPChanged", self);
	Apollo.RemoveEventHandler("ElderPointsGained", self);
	Apollo.RemoveEventHandler("OptionsUpdated_HUDPreferences", self);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.strUnit == "Player" and tUnitFrame.wndExperience ~= nil and tUnitFrame.wndExperience:FindChild("Progress") and tUnitFrame.wndExperience:FindChild("ProgressRested") and true);
	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	self = setmetatable({}, self);
	self.__index = self;

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;

	-- Reference Unit Frame
	self.tUnitFrame = tUnitFrame;

	-- Expose Methods
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;

	-- Done
	self:Disable(true);

	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Element:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage:RegisterElement(MAJOR);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
