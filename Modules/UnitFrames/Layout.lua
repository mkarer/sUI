--[[

	s:UI Unit Frame Layout Generation

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesCore = S:GetModule("UnitFramesCore");
local M = UnitFramesCore:CreateSubmodule("Layout");
local XmlDocument = Apollo.GetPackage("Drafto:Lib:XmlDocument-1.0").tPackage;
local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
local log;
local floor = math.floor;

-----------------------------------------------------------------------------

M.tSettings = {}; -- Unit specific Settings
M.strLayoutName = "SezzUnitFrames";

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:CreateUnitFrame(strUnit, tSettings)
	self:InitializeUnitFrameXML(strUnit, tSettings);
	self:CreateHealthBarElement(strUnit, tSettings);
	self:CreateShieldBarElement(strUnit, tSettings);
	self:CreateCastBarElement(strUnit, tSettings);
	self:CreateExperienceBarElement(strUnit, tSettings);
	self:CreateAurasElement(strUnit, tSettings);
	self:CreateThreatBarElement(strUnit, tSettings);

	self.tUnitFrameController:CreateUnitFrame(self.strLayoutName, strUnit, tSettings.tXmlData, tSettings.tAttributes);
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Create Unit Frame Controller
	self.tUnitFrameController = UnitFrameController:New();
	self.tUnitFrameController:SetColors(self.tColors);
	self.xmlDoc = self.tUnitFrameController.xmlDoc;

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

--	strDirection = "TOPBOTTOM",
--	nUnitsPerColumn = 5,
--	strDirectionColumn = "LEFTRIGHT",

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
	self.tUnitFrameController:LoadForm();
	self.tUnitFrameController:Enable();
end

function M:GetUnitFramePrefix(strUnit)
	return self.strLayoutName..strUnit;
end

function M:InitializeUnitFrameXML(strUnit, tSettings)
	-- Create Root Element
	tSettings.tXmlData = {
		["Root"] = self.xmlDoc:NewFormNode(self:GetUnitFramePrefix(strUnit), {
			AnchorPoints = tSettings.tAnchorPoints,
			AnchorOffsets = tSettings.tAnchorOffsets,
			Picture = true,
			Sprite = "WhiteFill",
			BGColor = "ffffffff",
			Moveable = true,
			TooltipType = "OnCursor",
		}),
	};
end

function M:SetUnitFrameAttribute(strUnit, strAttribute, vValue)
	local tSettings = self.tSettings[strUnit];

	if (not tSettings["tAttributes"]) then
		tSettings["tAttributes"] = {};
	end

	tSettings["tAttributes"][strAttribute] = vValue;
end
