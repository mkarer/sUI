--[[

	s:UI Unit Frame Element: Cast Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:CastBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local Element = APkg and APkg.tPackage or {};
local UnitFrameController, log;

-----------------------------------------------------------------------------

local Update = function(self)
	if (not self.bEnabled) then return false; end

	if (self.unit:IsCasting()) then
	end
end

local Enable = function(self)
	-- Register Events
	-- CastBar doesn't have any, we need to use OnUpdate
	if (self.tUnitFrame.wndCastBar) then
		self.bEnabled = true;
		return true;
	else
		return false;
	end
end

local Disable = function(self)
	-- Unregister Events
	-- CastBar doesn't have any, we need to use OnUpdate
	self.bEnabled = false;
	return true;
end

-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	self = setmetatable({}, self);
	self.__index = self;

	-- Properties
	self.bEnabled = false;

	-- Reference Unit Frame
	self.tUnitFrame = tUnitFrame;

	-- Expose Methods
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;

	-- Done
	return self;
end

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
