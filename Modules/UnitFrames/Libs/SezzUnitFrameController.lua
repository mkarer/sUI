--[[

	s:UI Unit Frame Controller

	Should handle most of the updating, because in WildStar we have to use
	OnUpdate (aka VarChange_FrameCount) for nearly everything (PLEASE GIVE US MORE EVENTS).

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameController-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrameController = APkg and APkg.tPackage or {};
local XmlDocument, UnitFrame, GeminiLogging, log;

-- Lua APIs
local format, floor, modf = string.format, math.floor, math.modf;

-----------------------------------------------------------------------------
-- Child Libraries + Settings
-----------------------------------------------------------------------------

local tRegisteredElements = {};

-- Default Colors
local tColors = {
	Power = {
--		["MANA"]					= { 45/255, 82/255, 137/255 },
--		["RAGE"]					= { 226/255, 45/255, 75/255 },
--		["FOCUS"]					= { 1, 210/255, 0 },
--		["ENERGY"]					= { 1, 220/255, 25/255 },
--		["RUNIC_POWER"]				= { 1, 210/255, 0 },
--		["POWER_TYPE_STEAM"]		= { 0.55, 0.57, 0.61 },
--		["POWER_TYPE_PYRITE"]		= { 0.60, 0.09, 0.17 },
--		["POWER_TYPE_FEL_ENERGY"]	= { 1, 1, 0.3 },
--		["AMMOSLOT"]				= { 0.8, 0.6, 0 },
	},
	Reaction = {
		[2] = { 1, 0, 0 }, -- Aggressive
		[4] = { 1, 1, 0 }, -- Neutral
		[5] = { 0, 1, 0 }, -- Friendly
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

-----------------------------------------------------------------------------
-- Frame Creation
-----------------------------------------------------------------------------

local CreateUnitFrame = function(self, strLayoutName, strUnit, tXmlData)
	log:debug("Creating Unit Frame for: %s", strUnit)
	local tUnitFrame = UnitFrame:New(self, strLayoutName, strUnit, tXmlData);

	self.tUnitFrames[strUnit] = tUnitFrame;
	return tUnitFrame;
end

local LoadForm = function(self)
	-- Add all Unit Frames' XML and load them with Apollo
	for _, tUnitFrame in pairs(self.tUnitFrames) do
		log:debug("Loading Unit Frame: %s", tUnitFrame.strUnit);
		tUnitFrame:LoadForm();

		-- Add Elements
		for _, tElement in pairs(tRegisteredElements) do
			tUnitFrame:RegisterElement(tElement);
		end
	end
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

local UpdateUnit = function(self, strUnit, unit)
	if (self.tUnitFrames[strUnit]) then
		self.tUnitFrames[strUnit]:SetUnit(unit);
		self.tUnitFrames[strUnit]:Update();
		return true;
	end

	return false;
end

local UpdateUnits = function(self)
	local bCharacterLoaded = false;

	-- Reduce Updates/Second
	local nTicks = GameLib.GetTickCount();
	if (nTicks - self.nUpdated < 50) then return; end
	self.nUpdated = nTicks;

	-- Check Character
	if (GameLib and GameLib.IsCharacterLoaded()) then
		local unitPlayer = GameLib.GetPlayerUnit();

		if (unitPlayer and unitPlayer:IsValid()) then
			-- Update Unit Frames
--			log:debug("Updating Units...");
			bCharacterLoaded = true;
			UpdateUnit(self, "Player", unitPlayer);
			UpdateUnit(self, "Target", unitPlayer:GetTarget());
			UpdateUnit(self, "TargetOfTarget", unitPlayer:GetTargetOfTarget());
			UpdateUnit(self, "TargetOfTargetOfTarget", unitPlayer:GetTargetOfTarget() and unitPlayer:GetTargetOfTarget():GetTarget() or nil);
			UpdateUnit(self, "Focus", unitPlayer:GetAlternateTarget());
			UpdateUnit(self, "FocusTarget", unitPlayer:GetAlternateTarget() and unitPlayer:GetAlternateTarget():GetTarget() or nil);
			UpdateUnit(self, "FocusTargetOfTarget", unitPlayer:GetAlternateTarget() and unitPlayer:GetAlternateTarget():GetTargetOfTarget() or nil);
		end
	end

	if (not bCharacterLoaded) then
		-- Delay
		log:debug("Delaying OnCharacterCreated")
		ApolloTimer.Create(0.1, false, "OnCharacterCreated", self);
	end
end

-----------------------------------------------------------------------------

local Enable = function(self)
	self.UpdateUnits = UpdateUnits;

	if (GameLib and GameLib.IsCharacterLoaded()) then
		self:UpdateUnits();
	end

	Apollo.RegisterEventHandler("CharacterCreated", "UpdateUnits", self);
	Apollo.RegisterEventHandler("PlayerChanged", "UpdateUnits", self);
	Apollo.RegisterEventHandler("TargetUnitChanged", "UpdateUnits", self);
	Apollo.RegisterEventHandler("AlternateTargetUnitChanged", "UpdateUnits", self);
	Apollo.RegisterEventHandler("VarChange_FrameCount", "UpdateUnits", self);
end

-----------------------------------------------------------------------------
-- Elements
-----------------------------------------------------------------------------

function UnitFrameController:RegisterElement(strPackageName)
	local strElementName = string.match(strPackageName, ":(%a+)\-");
	if (type(strElementName) == "string" and string.len(strElementName) > 0) then
		log:debug("Registered Element: %s (Package: %s)", strElementName, strPackageName);
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

function UnitFrameController:New(xmlDoc, tCustomColors)
	self = setmetatable({}, { __index = UnitFrameController });

	-- Properties
	self.tUnitFrames = {};
	self.nUpdated = 0;
	self.tColors = (tCustomColors and setmetatable(tCustomColors, { __index = tColors }) or tColors);

	-- Create a new XML Document
	self.xmlDoc = xmlDoc or XmlDocument.NewForm();

	-- Load Element Packages
	for strPackageName, tElement in pairs(tRegisteredElements) do
		if (type(tElement) ~= "table") then
			tRegisteredElements[strPackageName] = Apollo.GetPackage(strPackageName).tPackage;
		end
	end

	-- Expose Methods
	self.CreateUnitFrame = CreateUnitFrame;
	self.LoadForm = LoadForm;
	self.Enable = Enable;

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

	XmlDocument = Apollo.GetPackage("Drafto:Lib:XmlDocument-1.0").tPackage;
	UnitFrame = Apollo.GetPackage("Sezz:UnitFrame-0.1").tPackage;
end

function UnitFrameController:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(UnitFrameController, MAJOR, MINOR, { "Drafto:Lib:XmlDocument-1.0", "Sezz:UnitFrame-0.1", "Gemini:Logging-1.2" });
