--[[

	s:UI Unit Frame

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrame-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrame = APkg and APkg.tPackage or {};
local log;

-----------------------------------------------------------------------------
-- XML Elements
-----------------------------------------------------------------------------

-- Add Background (Required)
-- Acts as root element
local AddBackground = function(self)
	self.tXmlData["Background"] = self.xmlDoc:NewFormNode(self.strName, {
		AnchorPoints = self.tAnchorPoints,
		AnchorOffsets = self.tAnchorOffsets,
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ffffffff",
		Moveable = true,
	});
end

-- Add Health Bar (Required)
local AddHealthBar = function(self)
	-- Health Bar Background
	-- We should calculate the required height before creating this (Power/XP/Reputation Bar + Padding)
	self.tXmlData["HealthBarBackground"] = self.xmlDoc:NewControlNode("HealthBarBackground", "Window", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 2, 2, -2, -2 },
		Picture = true,
		Sprite = "WhiteFill",
		BGColor = "ff000000",
		IgnoreMouse = "true",
	});

	self.tXmlData["Background"]:AddChild(self.tXmlData["HealthBarBackground"]);

	-- Health Bar
	self.tXmlData["HealthBar"] = self.xmlDoc:NewControlNode("HealthBar", "ProgressBar", {
		AnchorPoints = { 0, 0, 1, 1 },
		AnchorOffsets = { 0, 0, 0, 0 },
		AutoSetText = false,
		UseValues = true,
		SetTextToProgress = false,
		ProgressFull = "sUI:ProgressBar",
		IgnoreMouse = "true",
		BarColor = "ff262626",
	});

	self.tXmlData["HealthBarBackground"]:AddChild(self.tXmlData["HealthBar"]);
end

-- Left Text Element (Optional)
local AddTextLeft = function(self)
	self.tXmlData["TextLeft"] = self.xmlDoc:NewControlNode("TextLeft", "Window", {
		AnchorPoints = { 0, 0, 0.5, 1 },
		AnchorOffsets = { 4, 0, 0, 0 },
		TextColor = "white",
		DT_VCENTER = true,
		Text = "Elke",
		IgnoreMouse = "true",
		Font = "CRB_Header9_O",
	});

	self.tXmlData["HealthBar"]:AddChild(self.tXmlData["TextLeft"]);
end

-- Right Text Element (Optional)
local AddTextRight = function(self)
	self.tXmlData["TextRight"] = self.xmlDoc:NewControlNode("TextRight", "Window", {
		AnchorPoints = { 0.5, 0, 1, 1 },
		AnchorOffsets = { 0, 0, -4, 0 },
		TextColor = "white",
		DT_VCENTER = true,
		DT_RIGHT = true,
		Text = "28.6k",
		IgnoreMouse = "true",
		Font = "CRB_Header9_O",
	});

	self.tXmlData["HealthBar"]:AddChild(self.tXmlData["TextRight"]);
end

-----------------------------------------------------------------------------
-- Highlight on Mouseover
-----------------------------------------------------------------------------

local OnMouseEnter = function(self, wndHandler)
	if (self.wndMain:ContainsMouse()) then
		self.wndMain:SetBGOpacity(0.4);
	end
end

local OnMouseExit = function(self, wndHandler)
	if (not self.wndMain:ContainsMouse()) then
		self.wndMain:SetBGOpacity(0.2);
	end
end

-----------------------------------------------------------------------------
-- Forms
-----------------------------------------------------------------------------

-- Load Form
-- Adds the Unit Frame to the UI
local LoadForm = function(self)
	-- Add XML Data as Root Element
	self.xmlDoc:GetRoot():AddChild(self.tXmlData["Background"]);

	-- Load Form
	self.wndMain = self.xmlDoc:LoadForm(self.strName, nil, self);
	self.wndMain:Show(false, true);

	-- Enable Mouseover Highlight
	self.wndMain:AddEventHandler("MouseEnter", "OnMouseEnter", self);
	self.wndMain:AddEventHandler("MouseExit", "OnMouseExit", self);
	self.wndMain:SetBGOpacity(0.2, 5e+20);

	-- Return
	return self.wndMain;
end

local Show = function(self)
	ApolloTimer.Create(0, false, "ShowDelayed", self);
end

local ShowDelayed = function(self)
	self.wndMain:Show(true, true);
end

local Hide = function(self)
	self.wndMain:Hide(true, true);
end

CreateUnitFrame = function(self)
	-- Initialize Unit Frame Table
	self.strName = "SezzUnitFrames_"..self.strUnit;

	-- Calculate Anchor Offets
	-- Currently only supports CENTERED unit frames
	self.tAnchorOffsets[1] = self.tAnchorOffsets[1] - math.floor(self.nWidth / 2);
	self.tAnchorOffsets[3] = self.tAnchorOffsets[3] + math.floor(self.nWidth / 2);
	self.tAnchorOffsets[4] = self.tAnchorOffsets[4] + self.nHeight;

	-- Initialize XML Data
	self.tXmlData = {};

	-- Add Elements to XML Data
	AddBackground(self);
	AddHealthBar(self);
	AddTextLeft(self);
	AddTextRight(self);

	-- Expose Methods
	self.LoadForm = LoadForm;
	self.OnMouseEnter = OnMouseEnter;
	self.OnMouseExit = OnMouseExit;
	self.Show = Show;
	self.ShowDelayed = ShowDelayed;

	-- Return Unit Frame Object
	return self;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function UnitFrame:New(o, tUnitFrameController, tSettings)
	self = setmetatable(o or {}, self);
	self.__index = self;

	if (tSettings) then
		for k, v in pairs(tSettings) do
			self[k] = v;
		end
	end

	self.xmlDoc = tUnitFrameController.xmlDoc;
	
	-- Expose Methods
	self.LoadForm = LoadForm;

	-- Create and return Unit Frame
	return CreateUnitFrame(self);
end

-----------------------------------------------------------------------------

function UnitFrame:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});
end

function UnitFrame:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(UnitFrame, MAJOR, MINOR, {});
