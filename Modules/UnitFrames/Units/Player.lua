--[[

	s:UI Player Unit Frame

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesCore = S:GetModule("UnitFramesCore");
local M = UnitFramesCore:CreateSubmodule("Player");
local XmlDocument = Apollo.GetPackage("Drafto:Lib:XmlDocument-1.0").tPackage;
local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
local log;

-----------------------------------------------------------------------------
-- Unit Frame Creation
-- Requires Drafto:Lib:XmlDocument-1.0
-----------------------------------------------------------------------------

local CreateUnitFrame;
do
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

	-----------------------------------------------------------------------------
	-- Constructor
	-----------------------------------------------------------------------------

	CreateUnitFrame = function(tSettings)
		-- Initialize Unit Frame Table
		local tUnitFrame = setmetatable({}, { __index = tSettings });
		tUnitFrame.strName = "SezzUnitFrames_"..tUnitFrame.strUnit;

		-- Calculate Anchor Offets
		-- Currently only supports CENTERED unit frames
		tUnitFrame.tAnchorOffsets[1] = tUnitFrame.tAnchorOffsets[1] - math.floor(tUnitFrame.nWidth / 2);
		tUnitFrame.tAnchorOffsets[3] = tUnitFrame.tAnchorOffsets[3] + math.floor(tUnitFrame.nWidth / 2);
		tUnitFrame.tAnchorOffsets[4] = tUnitFrame.tAnchorOffsets[4] + tUnitFrame.nHeight;

		-- Initialize XML Data
		tUnitFrame.xmlDoc = XmlDocument.NewForm();
		tUnitFrame.tXmlData = {};

		-- Add Elements to XML Data
		AddBackground(tUnitFrame);
		AddHealthBar(tUnitFrame);
		AddTextLeft(tUnitFrame);
		AddTextRight(tUnitFrame);

		-- Expose Methods
		tUnitFrame.LoadForm = LoadForm;
		tUnitFrame.OnMouseEnter = OnMouseEnter;
		tUnitFrame.OnMouseExit = OnMouseExit;
		tUnitFrame.Show = Show;
		tUnitFrame.ShowDelayed = ShowDelayed;

		-- Return Unit Frame Object
		return tUnitFrame;
	end
end

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Player = GameLib.GetPlayerUnit()
	-- Target = GameLib.GetPlayerUnit():GetTarget()
	-- Focus = GameLib.GetPlayerUnit():GetAlternateTarget()
--	Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterLoaded", self)
--	Apollo.RegisterEventHandler("TargetUnitChanged", "OnTargetUnitChanged", self)
--	Apollo.RegisterEventHandler("AlternateTargetUnitChanged", "OnAlternateTargetUnitChanged", self)
--		self:RegisterEvent("PlayerChanged", "OnPlayerChanged");
--[[
	-- Settings
	local tSettings = {
		strUnit = "Player",
		nWidth = 254,
		nHeight = 34,
		nPositionY = -126,
		tAnchorPoints = { 0.75, 1, 0.75, 1 },
		tAnchorOffsets = { 0, -126, 0, -126 },
	};

	local tPlayer = CreateUnitFrame(tSettings);
	tPlayer:LoadForm();
	tPlayer:Show();

	-- Set Progress Bar Values
	tPlayer.wndMain:FindChild("HealthBar"):SetMax(100);
	tPlayer.wndMain:FindChild("HealthBar"):SetProgress(100);
--]]

	-- Initialize Controller
	local tUnitFrameController = UnitFrameController:New();


	-- Create Player
	local tSettings = {
		strUnit = "Player",
		nWidth = 254,
		nHeight = 34,
		tAnchorPoints = { 0.75, 1, 0.75, 1 },
		tAnchorOffsets = { 0, -126, 0, -126 },
	};

	local tUnitFramePlayer = tUnitFrameController:CreateUnitFrame(tSettings);

	-- Create Target
	local tSettings = {
		strUnit = "Target",
		nWidth = 254,
		nHeight = 34,
		tAnchorPoints = { 0.75, 1, 0.75, 1 },
		tAnchorOffsets = { 0, -164, 0, -164 },
	};

	local tUnitFrameTarget = tUnitFrameController:CreateUnitFrame(tSettings);

	-- Enable Unit Frames
	tUnitFrameController:LoadForm();

	tUnitFramePlayer:Show();
	tUnitFramePlayer:SetHealth(70, 100);

	tUnitFrameTarget:Show();
	tUnitFrameTarget:SetHealth(100, 100);
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
