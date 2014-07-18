--[[

	s:UI Unit Frame Controller

	Should handle most of the updating, because in WildStar we have to use
	OnUpdate (aka VarChange_FrameCount) for nearly everything (PLEASE GIVE US MORE EVENTS).

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameController-0.2", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrameController = APkg and APkg.tPackage or {};
local UnitFrame, GeminiLogging, log;

-- Lua APIs
local format, floor, modf = string.format, math.floor, math.modf;

-- Constants
local knMaxGroupSize = 50; -- Not sure - they said battlegrounds for 50 people are coming, so I assume 50 for now.

-----------------------------------------------------------------------------
-- Child Libraries + Settings
-----------------------------------------------------------------------------

local tRegisteredElements = {};

-- Default Colors
local tColors = {
	Power = setmetatable({
		Default			= { 1, 1, 0.3 },
		SpellPower		= { 1, 1, 0.3 },
		Focus			= { 0.3, 1, 1 },
		SuitPower		= { 1, 1, 0.3 },
		KineticEnergy	= { 1, 0.25, 0.05 },
		Volatility		= { 1, 1, 0.3 },
	}, { __index = function(t, k) return rawget(t, k) or rawget(t, "Default"); end }),
	Reaction = {
		[2] = { 1, 0, 0 }, -- Aggressive
		[4] = { 1, 1, 0 }, -- Neutral
		[5] = { 0, 1, 0 }, -- Friendly
	},
	Threat = {
		[1] = { 1, 1, 1, 0.69 },
		[2] = { 1, 1, 0.47 },
		[3] = { 1, 0.6, 0 },
		[4] = { 1, 0, 0 },
	},
	Shield = { 1, 1, 1, 0.47 },
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
--		Warning = { 1, 0, 0 },
	},
	Class = setmetatable({
		["Default"]								= { 1, 1, 1 },
		["Object"]								= { 0, 1, 0 },
		[GameLib.CodeEnumClass.Engineer]		= { 164/255,  26/255,  49/255 },
		[GameLib.CodeEnumClass.Esper]			= { 116/255, 221/255, 255/255 },
		[GameLib.CodeEnumClass.Medic]			= { 255/255, 255/255, 255/255 },
		[GameLib.CodeEnumClass.Stalker]			= { 221/255, 212/255,  95/255 },
		[GameLib.CodeEnumClass.Spellslinger]	= { 130/255, 111/255, 172/255 },
		[GameLib.CodeEnumClass.Warrior]			= { 171/255, 133/255,  94/255 },
	}, { __index = function(t, k) return rawget(t, k) or rawget(t, "Default"); end }),
};

-----------------------------------------------------------------------------
-- Frame Creation
-----------------------------------------------------------------------------

function UnitFrameController:CreateUnitFrame(strUnit, tWindowDefinition)
--	log:debug("Creating Unit Frame for: %s", strUnit)
	self.tUnitFrames[strUnit] = UnitFrame:New(self, strUnit, tWindowDefinition);
	return self.tUnitFrames[strUnit];
end

function UnitFrameController:SpawnUnits()
	for _, tUnitFrame in pairs(self.tUnitFrames) do
--		log:debug("Loading Unit Frame: %s", tUnitFrame.strUnit);
		tUnitFrame:Spawn();

		-- Add Elements
		for _, tElement in pairs(tRegisteredElements) do
			tUnitFrame:RegisterElement(tElement);
		end
	end
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

function UnitFrameController:UpdateUnit(strUnit, unit)
	if (self.tUnitFrames[strUnit]) then
		self.tUnitFrames[strUnit]:SetUnit(unit);
		return self.tUnitFrames[strUnit]:Update();
	end

	return false;
end

function UnitFrameController:UpdateDefaultUnit(strUnit)
	self:UpdateUnit(strUnit, self:GetUnit(strUnit));
end

function UnitFrameController:OnAlternateTargetUnitChanged()
	self:UpdateDefaultUnit("Focus");
	self:UpdateDefaultUnit("FocusTarget");
	self:UpdateDefaultUnit("FocusTargetOfTarget");
end

function UnitFrameController:OnTargetUnitChanged()
	self:UpdateDefaultUnit("Target");
	self:UpdateDefaultUnit("TargetOfTarget");
	self:UpdateDefaultUnit("TargetOfTargetOfTarget");
end

function UnitFrameController:OnPlayerChanged()
	self:UpdateDefaultUnit("Player");
end

function UnitFrameController:UpdateGroups()
	local bInRaid, bInGroup, nGroupSize = GroupLib.InRaid(), GroupLib.InGroup(), GroupLib.GetMemberCount();

	-- Raid Frames
	for i = 1, knMaxGroupSize do
		self:UpdateUnit("Party"..i, i <= nGroupSize and bInGroup and not bInRaid and self:GetUnit("Party", i));
		self:UpdateUnit("Raid"..i, i <= nGroupSize and bInRaid and self:GetUnit("Raid", i));
	end
end

function UnitFrameController:OnGroupMemberFlagsChanged(nIndex)
	local bInRaid, bInGroup, nGroupSize = GroupLib.InRaid(), GroupLib.InGroup(), GroupLib.GetMemberCount();

	self:UpdateUnit("Party"..nIndex, nIndex <= nGroupSize and bInGroup and not bInRaid and self:GetUnit("Party", nIndex));
	self:UpdateUnit("Raid"..nIndex, nIndex <= nGroupSize and bInRaid and self:GetUnit("Raid", nIndex));
end

function UnitFrameController:UpdateUnits()
	-- Reduce Updates/Second
	local nTicks = GameLib.GetTickCount();

	if (self.nUpdated and nTicks - self.nUpdated < 50) then return; end
	self.nUpdated = nTicks;

	-- Check Character
	if (GameLib.IsCharacterLoaded()) then
		local unitPlayer = GameLib.GetPlayerUnit();

		if (unitPlayer and unitPlayer:IsValid()) then
			-- Update Unit Frames
			self.bCharacterLoaded = true;

			-- Main Unit Frames
			-- I don't think there are events for "TargetChanged" or "TargetOfTargetChanged" for non-players, so we'll update all.
			self:OnPlayerChanged();
			self:OnTargetUnitChanged();
			self:OnAlternateTargetUnitChanged();

			-- Party / Raid Frames
			self:UpdateGroups();
		end
	end

	if (not self.bCharacterLoaded) then
		-- Delay
		ApolloTimer.Create(0.1, false, "UpdateUnits", self);
	end
end

-----------------------------------------------------------------------------

function UnitFrameController:Enable()
	if (GameLib and GameLib.IsCharacterLoaded()) then
		self:UpdateUnits();
	end

	Apollo.RegisterEventHandler("CharacterCreated", "UpdateUnits", self);
	Apollo.RegisterEventHandler("PlayerChanged", "OnPlayerChanged", self);
	Apollo.RegisterEventHandler("TargetUnitChanged", "OnTargetUnitChanged", self);
	Apollo.RegisterEventHandler("AlternateTargetUnitChanged", "OnAlternateTargetUnitChanged", self);
	Apollo.RegisterEventHandler("VarChange_FrameCount", "UpdateUnits", self);
--	Apollo.RegisterEventHandler("Group_Updated", "OnGroupUpdated", self);
	Apollo.RegisterEventHandler("Group_MemberFlagsChanged", "OnGroupMemberFlagsChanged", self);
end

-----------------------------------------------------------------------------
-- Elements
-----------------------------------------------------------------------------

function UnitFrameController:RegisterElement(strPackageName)
	local strElementName = string.match(strPackageName, ":(%a+)\-");
	if (type(strElementName) == "string" and string.len(strElementName) > 0) then
--		log:debug("Registered Element: %s (Package: %s)", strElementName, strPackageName);
		tRegisteredElements[strPackageName] = false;
	end
end

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------

function UnitFrameController:Round(nValue)
	return floor(nValue + 0.5);
end

function UnitFrameController:ColorArrayToHex(arColor)
	-- We only use indexed arrays here!
	return format("%02x%02x%02x%02x", self:Round(255 * (arColor[4] or 1)), self:Round(255 * arColor[1]), self:Round(255 * arColor[2]), self:Round(255 * arColor[3]));
end

function UnitFrameController:RGBColorToHex(r, g, b)
	return format("%02x%02x%02x%02x", 255, self:Round(255 * r), self:Round(255 * g), self:Round(255 * b));
end

function UnitFrameController:SetColors(tCustomColors)
	self.tColors = setmetatable(tCustomColors, { __index = tColors });
end

-----------------------------------------------------------------------------
-- Color Gradient
-- http://www.wowwiki.com/ColorGradient
-----------------------------------------------------------------------------

local ColorsAndPercent = function(a, b, ...)
	if (a <= 0 or b == 0) then
		return nil, ...;
	elseif (a >= b) then
		return nil, select(select('#', ...) - 2, ...);
	end

	local num = select('#', ...) / 3;
	local segment, relperc = modf((a / b) * (num - 1));
	return relperc, select((segment * 3) + 1, ...);
end

function UnitFrameController:RGBColorGradient(...)
	local relperc, r1, g1, b1, r2, g2, b2 = ColorsAndPercent(...);
	if (relperc) then
		return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc;
	else
		return r1, g1, b1;
	end
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function UnitFrameController:New(tCustomColors)
	self = setmetatable({}, { __index = UnitFrameController });

	-- Properties
	self.tUnitFrames = {};
	self.tColors = (tCustomColors and setmetatable(tCustomColors, { __index = tColors }) or tColors);
	self.bCharacterLoaded = false;

	-- Load Element Packages
	for strPackageName, tElement in pairs(tRegisteredElements) do
		if (type(tElement) ~= "table") then
			tRegisteredElements[strPackageName] = Apollo.GetPackage(strPackageName).tPackage;
		end
	end

	-- Done
	return self;
end

function UnitFrameController:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	UnitFrame = Apollo.GetPackage("Sezz:UnitFrame-0.2").tPackage;
end

function UnitFrameController:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(UnitFrameController, MAJOR, MINOR, { "Sezz:UnitFrame-0.2", "Gemini:Logging-1.2", "Gemini:Event-1.0" });
