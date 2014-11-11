--[[

	s:UI Unit Frame Layout Generation

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesCore = S:GetModule("UnitFramesCore");
local M = UnitFramesCore:CreateSubmodule("Layout");
local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
local log;
local floor = math.floor;

-----------------------------------------------------------------------------

M.tSettings = {}; -- Unit specific Settings

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:CreateUnitFrame(strUnit, tSettings)
	self:InitializeUnitFrameXML(strUnit);
	self:CreateHealthBarElement(strUnit);
	self:CreateShieldBarElement(strUnit);
	self:CreateCastBarElement(strUnit);
	self:CreateExperienceBarElement(strUnit);
	self:CreateAurasElement(strUnit);
	self:CreateThreatBarElement(strUnit);
	self:CreatePowerBarElement(strUnit);
	self:CreateRoleElement(strUnit);
	self:CreateLeaderElement(strUnit);

	self.tUnitFrameController:CreateUnitFrame(strUnit, tSettings.tWindowDefinition);
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Create Unit Frame Controller
	self.tUnitFrameController = UnitFrameController:New(self.tColors);
	self:RegisterTags();

	-- Create Settings for Party
	if (self.tSettings["Party"]) then
		local strUnit = "Party";
		local tBaseSettings = self.tSettings[strUnit];
		local tBaseAnchorOffsets = tBaseSettings.tAnchorOffsets;

		local nFramePadding = 2;
		local nAnchorIncreaseL, nAnchorIncreaseT, nAnchorIncreaseR, nAnchorIncreaseB = 0, 0, 0, 0;
		if (tBaseSettings.strDirection and tBaseSettings.strDirection == "BOTTOMTOP") then
			-- Spawndirection: Bottom to Top
			nAnchorIncreaseT = -(tBaseAnchorOffsets[4] - tBaseAnchorOffsets[2]) - nFramePadding;
			nAnchorIncreaseB = -(tBaseAnchorOffsets[4] - tBaseAnchorOffsets[2]) - nFramePadding;
		end

		for i = 2, 5 do
			local tSettings = {};

			-- Update Anchors
			if (i  > 2) then
				tSettings.tAnchorOffsets = {
					tBaseSettings.tAnchorOffsets[1] + (i - 2) * nAnchorIncreaseL,
					tBaseSettings.tAnchorOffsets[2] + (i - 2) * nAnchorIncreaseT,
					tBaseSettings.tAnchorOffsets[3] + (i - 2) * nAnchorIncreaseR,
					tBaseSettings.tAnchorOffsets[4] + (i - 2) * nAnchorIncreaseB,
				};

				if (tBaseSettings.bAurasEnabled) then
					tSettings.tAurasAnchorOffsets = {
						tBaseSettings.tAurasAnchorOffsets[1] + (i - 2) * nAnchorIncreaseL,
						tBaseSettings.tAurasAnchorOffsets[2] + (i - 2) * nAnchorIncreaseT,
						tBaseSettings.tAurasAnchorOffsets[3] + (i - 2) * nAnchorIncreaseR,
						tBaseSettings.tAurasAnchorOffsets[4] + (i - 2) * nAnchorIncreaseB,
					};
				end
			end

			self.tSettings[strUnit..i] = setmetatable(tSettings, { __index = tBaseSettings });
		end
	end

	-- Create Settings for Raid
	if (self.tSettings["Raid"]) then
		local strUnit = "Raid";
		local tBaseSettings = self.tSettings[strUnit];
		local tBaseAnchorOffsets = tBaseSettings.tAnchorOffsets;
		local nColumn = 1;
		local nRow = 0;
		local nFramePadding = 2;
		local nAnchorIncreaseL, nAnchorIncreaseT, nAnchorIncreaseR, nAnchorIncreaseB = 0, 0, 0, 0;

		if (tBaseSettings.strDirection and tBaseSettings.strDirection == "TOPBOTTOM") then
			-- Spawndirection: Top to Bottom
			nAnchorIncreaseT = tBaseAnchorOffsets[4] - tBaseAnchorOffsets[2] + nFramePadding;
			nAnchorIncreaseB = tBaseAnchorOffsets[4] - tBaseAnchorOffsets[2] + nFramePadding;
		end

		if (tBaseSettings.strDirectionColumn and tBaseSettings.strDirectionColumn == "LEFTRIGHT") then
			-- Spawndirection: Top to Bottom
			nAnchorIncreaseL = tBaseAnchorOffsets[3] - tBaseAnchorOffsets[1] + nFramePadding;
			nAnchorIncreaseR = tBaseAnchorOffsets[3] - tBaseAnchorOffsets[1] + nFramePadding;
		end

		for i = 1, 40 do
			local tSettings = {};

			if (i - 1 > 0 and (i - 1) % tBaseSettings.nUnitsPerColumn == 0) then
				-- Next Column
				nColumn = nColumn + 1;
				nRow = 1;
			else
				nRow = nRow + 1;
			end

			-- Update Anchors
			tSettings.tAnchorOffsets = {
				tBaseSettings.tAnchorOffsets[1] + (nColumn - 1) * nAnchorIncreaseL,
				tBaseSettings.tAnchorOffsets[2] + (nRow - 1) * nAnchorIncreaseT,
				tBaseSettings.tAnchorOffsets[3] + (nColumn - 1) * nAnchorIncreaseR,
				tBaseSettings.tAnchorOffsets[4] + (nRow - 1) * nAnchorIncreaseB,
			};

			self.tSettings[strUnit..i] = setmetatable(tSettings, { __index = tBaseSettings });
		end
	end

	-- Create XML Forms for our Unit Frames
	for strUnit, tSettings in pairs(self.tSettings) do
		if (strUnit ~= "Party" and strUnit ~= "Raid") then
			self:CreateUnitFrame(strUnit, tSettings);
		end
	end

	-- Enable Unit Frames
	self.tUnitFrameController:SpawnUnits();
	self.tUnitFrameController:Enable();
end

-----------------------------------------------------------------------------
-- Root Element
-----------------------------------------------------------------------------

local function OnWindowShow(self, wndHandler, wndControl)
	-- Background Opacity Fix
	if (wndHandler:GetBGOpacity() == 1) then
		S:ShowDelayed(wndHandler);
	end
end

local function OnMouseEnter(self, wndHandler, wndControl, x, y)
	if (wndHandler:ContainsMouse()) then
		wndHandler:SetBGOpacity(0.4);
	end
end

local function OnMouseExit(self, wndHandler, wndControl, x, y)
	if (not wndHandler:ContainsMouse()) then
		wndHandler:SetBGOpacity(0.2);
	end
end

local function OnWindowHide(self, wndHandler, wndControl)
	wndHandler:SetBGOpacity(0.2, 5e+20);
end

function M:InitializeUnitFrameXML(strUnit)
	local tSettings = self.tSettings[strUnit];

	-- Create Root Element
	tSettings.tWindowDefinition = {
		AnchorPoints = tSettings.tAnchorPoints,
		AnchorOffsets = tSettings.tAnchorOffsets,
		Picture = true,
		BGColor = "ffffffff",
--		BGOpacity = 0.2,
		Sprite = "ClientSprites:WhiteFill",
		IgnoreMouse = false,
		Events = {
			MouseEnter = OnMouseEnter,		-- Background Fade In
			MouseExit = OnMouseExit,		-- Background Fade Out
			WindowHide = OnWindowHide,		-- Background Fade Out (Instantly)
			WindowShow = OnWindowShow,		-- Opacity Fix
		},
		Children = {},
		Visible = false,
		UserData = {
			Element = "Main",
		},
	};

	tSettings.tElements = {
		Main = tSettings.tWindowDefinition,
	};

	if (tSettings.fOutOfRangeOpacity) then
		tSettings.tWindowDefinition.UserData.OutOfRangeOpacity = tSettings.fOutOfRangeOpacity;
	end
end
