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

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Create Unit Frame Controller
	self.tUnitFrameController = UnitFrameController:New();
	self.xmlDoc = self.tUnitFrameController.xmlDoc;

	-- Create XML Forms for our Unit Frames
	for strUnit, tSettings in pairs(self.tSettings) do
		self:InitializeUnitFrameXML(strUnit);
		self:CreateHealthBarElement(strUnit);
		self:CreateCastBarElement(strUnit);
		self:CreateExperienceBarElement(strUnit);
		self:CreateAurasElement(strUnit);

		self.tUnitFrameController:CreateUnitFrame(self.strLayoutName, strUnit, tSettings.tXmlData);
	end


	-- Enable Unit Frames
	self.tUnitFrameController:LoadForm();
	self.tUnitFrameController:Enable();
end

function M:GetUnitFramePrefix(strUnit)
	return self.strLayoutName..strUnit;
end

function M:InitializeUnitFrameXML(strUnit)
	local tSettings = self.tSettings[strUnit];

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
