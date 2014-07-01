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

-----------------------------------------------------------------------------
-- Child Libraries
-----------------------------------------------------------------------------

local tRegisteredElements = {};

-----------------------------------------------------------------------------
-- Frame Creation
-----------------------------------------------------------------------------

local CreateUnitFrame = function(self, tSettings)
	log:debug("Creating Unit Frame for: %s", tSettings.strUnit)
	local tUnitFrame = UnitFrame:New(nil, self, tSettings);

	self.tUnitFrames[tUnitFrame.strUnit] = tUnitFrame;
	return tUnitFrame;
end

local LoadForm = function(self)
	-- Add all Unit Frames' XML and load them with Apollo
	for _, tUnitFrame in pairs(self.tUnitFrames) do
		log:debug("Loading Unit Frame: %s", tUnitFrame.strUnit);
		tUnitFrame:LoadForm();
	end
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

local UpdateUnit = function(self, strName, unit)
	if (self.tUnitFrames[strName]) then
		self.tUnitFrames[strName]:SetUnit(unit);
		self.tUnitFrames[strName]:Update();
		return true;
	end

	return false;
end

local UpdateUnits = function(self)
	local bCharacterLoaded = false;

	-- Reduce Updates/Second
	local nTicks = GameLib.GetTickCount();
	if (nTicks - self.nUpdated < 100) then return; end

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
	local strElementName = string.match("Sezz:UnitFrameElement:CastBar-0.1", ":(%a+)\-");
	if (type(strElementName) == "string" and string.len(strElementName) > 0) then
		log:debug("Registered Element: %s (Package: %s)", strElementName, strPackageName);
		tRegisteredElements[strName] = strPackageName;
	end
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function UnitFrameController:New(o)
	self = setmetatable(o or {}, self);
	self.__index = self;

	-- Properties
	self.tUnitFrames = {};
	self.nUpdated = 0;

	-- Default Colors
	-- Copied from my World of Warcraft Unit Frames
	self.tColors = {
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
		Vulnerable = { 127/255, 38/255, 127/255 },
		VulnerableSmooth = { 255/255, 38/255, 255/255, 255/255, 38/255, 255/255, 38/255, 38/255, 38/255 },
		Tagged = { 153/255, 153/255, 153/255 },
		Experience = {
			Normal = { 45/255 - 0.1, 85/255 + 0.2, 137/255 },
			Rested = { 45/255 + 0.2, 85/255 - 0.1, 137/255 - 0.1 },
		},
		Castbar = {
			Normal = { 0.43, 0.75, 0.44 },
			Uninterruptable = { 1.00, 0.75, 0.44 },
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

	-- Create a new XML Document
	self.xmlDoc = XmlDocument.NewForm();

	-- Expose Methods
	self.CreateUnitFrame = CreateUnitFrame;
	self.LoadForm = LoadForm;
	self.Enable = Enable;

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

Apollo.RegisterPackage(UnitFrameController, MAJOR, MINOR, { "Drafto:Lib:XmlDocument-1.0", "Sezz:UnitFrame-0.1" });
