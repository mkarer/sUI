--[[

	s:UI Unit Frame Element: Shield Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:ShieldBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController;

-----------------------------------------------------------------------------

local Update = function(self)
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local wndShield = self.tUnitFrame.wndShield;

	local nCurrent = unit:GetShieldCapacity();
	local nMax = unit:GetShieldCapacityMax();

	if (not nCurrent or not nMax or (nCurrent == 0 and nMax == 0)) then
		wndShield:SetMax(0);
		wndShield:SetProgress(0);
	else
		wndShield:SetMax(nMax);
		wndShield:SetProgress(nCurrent);
	end
end

local Enable = function(self)
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
end

local Disable = function(self, bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.wndShield ~= nil);
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
	self.bUpdateOnUnitFrameFrameCount = true;

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

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
	UnitFrameController:RegisterElement(MAJOR);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
