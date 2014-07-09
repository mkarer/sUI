--[[

	s:UI Unit Frame Element: Auras

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:Auras-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController, Auras;

-----------------------------------------------------------------------------

local OnAuraUpdated = function(self, tAura)
	if (not self.bEnabled) then return; end

	log:debug("AuraUpdated %s", tAura.splEffect:GetName());
end

local OnAuraAdded = function(self, tAura)
	if (not self.bEnabled) then return; end

	log:debug("AuraAdded %s", tAura.splEffect:GetName());
end

local OnAuraRemoved = function(self, tAura)
	if (not self.bEnabled) then return; end

	log:debug("AuraRemoved %s", tAura.splEffect:GetName());
end

-----------------------------------------------------------------------------

local Enable = function(self)
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
	self.tAuras:SetUnit(self.tUnitFrame.unit);
end

local Disable = function(self, bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.tAuras:Disable(); -- Disable Auras first, so we get OnAuraRemoved
	self.bEnabled = false;
end

local IsSupported = function(tUnitFrame)
	local bSupported = (Auras ~= nil and tUnitFrame.wndAuras ~= nil);
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
	self.OnAuraAdded = OnAuraAdded;
	self.OnAuraRemoved = OnAuraRemoved;
	self.OnAuraUpdated = OnAuraUpdated;

	-- Auras
	self.tAuras = Auras:New():SetUnit(self.tUnitFrame.unit, true);
	self.tAuras:RegisterCallback("OnAuraAdded", "OnAuraAdded", self);
	self.tAuras:RegisterCallback("OnAuraRemoved", "OnAuraRemoved", self);
	self.tAuras:RegisterCallback("OnAuraUpdated", "OnAuraUpdated", self);

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

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
	UnitFrameController:RegisterElement(MAJOR);

	Auras = Apollo.GetPackage("Sezz:Auras-0.1").tPackage;
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
