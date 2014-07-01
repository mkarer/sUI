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

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

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

	-- Create Target Of Target
	local tSettings = {
		strUnit = "TargetOfTarget",
		nWidth = 146,
		nHeight = 22,
		tAnchorPoints = { 0.75, 1, 0.75, 1 },
		tAnchorOffsets = { 54, -190, 54, -190 },
	};

	local tUnitFrameTargetOfTarget = tUnitFrameController:CreateUnitFrame(tSettings);

	-- Create Target Of Target Of Target
	local tSettings = {
		strUnit = "TargetOfTargetOfTarget",
		nWidth = 102,
		nHeight = 22,
		tAnchorPoints = { 0.75, 1, 0.75, 1 },
		tAnchorOffsets = { -76, -190, -74, -190 },
	};

	local tUnitFrameTargetOfTargetOfTarget = tUnitFrameController:CreateUnitFrame(tSettings);

	-- Enable Unit Frames
	tUnitFrameController:LoadForm();
	tUnitFrameController:Enable();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
