--[[

	s:UI Unit Frame Controller

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameController-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrameController = APkg and APkg.tPackage or {};
local XmlDocument, UnitFrame, GeminiLogging, log;

-----------------------------------------------------------------------------

local CreateUnitFrame = function(self, tSettings)
	log:debug("Creating Unit Frame for: %s", tSettings.strUnit)
	local tUnitFrame = UnitFrame:New(nil, self, tSettings);

	self.tUnitFrames[tUnitFrame.strUnit] = tUnitFrame;
	return tUnitFrame;
end

local LoadForm = function(self)
	-- Add all Unit Frames' XML Data as Root Element
	for _, tUnitFrame in pairs(self.tUnitFrames) do
		log:debug("Loading Unit Frame: %s", tUnitFrame.strUnit);
		tUnitFrame:LoadForm();
	end
end

-----------------------------------------------------------------------------

function UnitFrameController:New(o)
	self = setmetatable(o or {}, self);
	self.__index = self;

	-- Properties
	self.tUnitFrames = {};

	-- Create a new XML Document
	self.xmlDoc = XmlDocument.NewForm();
	
	-- Expose Methods
	self.CreateUnitFrame = CreateUnitFrame;
	self.LoadForm = LoadForm;

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
