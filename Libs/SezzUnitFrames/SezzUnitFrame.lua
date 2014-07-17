--[[

	s:UI Unit Frame

	TODO:

		Interrupt Armor
		Power Bar
		Remove the layout code
		
		Events:

			local tRewardUpdateEvents = {
				"QuestObjectiveUpdated", "QuestStateChanged", "ChallengeAbandon", "ChallengeLeftArea",
				"ChallengeFailTime", "ChallengeFailArea", "ChallengeActivate", "ChallengeCompleted",
				"ChallengeFailGeneric", "PublicEventObjectiveUpdate", "PublicEventUnitUpdate",
				"PlayerPathMissionUpdate", "FriendshipAdd", "FriendshipPostRemove", "FriendshipUpdate" 
			}

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrame-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrame = APkg and APkg.tPackage or {};
local log, ToolTips;

-- Constants
local kbTestMode = false;

-----------------------------------------------------------------------------
-- Tags
-----------------------------------------------------------------------------

function UnitFrame:EnableTags()
	if (#self.tTagControls == 0 and self.tAttributes and self.tAttributes.Tags) then
		for strControl, tTag in pairs(self.tAttributes.Tags) do
			self:Tag(self.wndMain:FindChild(strControl), tTag);
		end
	end
end

function UnitFrame:UpdateTags()
	for _, tControl in ipairs(self.tTagControls) do
		tControl:UpdateTag();
	end
end

function UnitFrame:DisableTags()
	for _, tControl in ipairs(self.tTagControls) do
		self:Untag(tControl);
	end
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
-- Handle Mouse Clicks
-----------------------------------------------------------------------------

local OnMouseClick = function(self, wndHandler, wndControl, eMouseButton, x, y)
	if (eMouseButton == GameLib.CodeEnumInputMouse.Left) then
		if (self.unit.__proto__) then
			GameLib.SetTargetUnit(self.unit.__proto__);
		end
		return false
	elseif (eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, self.unit:GetName(), self.unit.__proto__ and self.unit.__proto__ or self.unit);
		return true
	end

	return false;
end

------------------------------------------------------------------------------
-- Unit Tooltips
-----------------------------------------------------------------------------

function UnitFrame:OnGenerateTooltip()
	ToolTips:UnitTooltipGen(self.wndMain, self.unit.__proto__ or self.unit, "");
end

-----------------------------------------------------------------------------
-- Elements
-----------------------------------------------------------------------------

function UnitFrame:RegisterElement(tElement)
	local tElement = tElement:New(self);
	if (tElement) then
		table.insert(self.tElements, tElement);
	end
end

function UnitFrame:UpdateElements()
	if (not self.bEnabled) then return; end

	for _, tElement in ipairs(self.tElements) do
		if (tElement.bUpdateOnUnitFrameFrameCount) then
			tElement:Update();
		end
	end
end

function UnitFrame:EnableElements()
	for _, tElement in ipairs(self.tElements) do
		tElement:Enable();
	end
end

function UnitFrame:DisableElements()
	for _, tElement in ipairs(self.tElements) do
		tElement:Disable();
	end
end

----------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------

local Update = function(self)
	self:UpdateElements();
end

local Disable = function(self)
	if (not kbTestMode) then
		self:Hide();
	else
		self:Show();
	end

	self:DisableElements();
	self:DisableTags();
	self.unit = nil;
	self.bEnabled = false;
end

local Enable = function(self)
	self.bEnabled = true;
	self:EnableElements();
	self:EnableTags();
	self:UpdateTags();
	self:Update();
	self.wndMain:SetTooltip("");
	self:Show();
end

local SetUnit = function(self, unit)
	-- Invalid Unit
	if (not unit or (unit and not unit:IsValid())) then
--		log:debug("[%s] Unit Invalid!", self.strUnit);
		self:Disable();
		return false;
	end

	-- Update Unit
	if (not self.unit or (self.unit and self.unit:GetId() ~= unit:GetId())) then
		log:debug("[%s] Updated Unit: %s", self.strUnit, unit:GetName());

		self.unit = unit;
		self:Enable();
	elseif (self.unit and not self.unit:IsRealUnit() and self.unit.bUpdated) then
		-- GroupLib Unit, Enable/Update
		if (not self.bEnabled) then
			self:Enable();
		else
			self:Update();
		end
	end
end

-----------------------------------------------------------------------------
-- Forms
-----------------------------------------------------------------------------

local FindRootOrChildWindow = function(self, strName)
	return self.xmlDoc:LoadForm(self.strLayoutName..self.strUnit..strName, nil, self) or self.wndMain:FindChild(strName);
end

-- Load Form
-- Adds the Unit Frame to the UI
local LoadForm = function(self)
	-- Add XML Data as Root Element
	self.xmlDoc:GetRoot():AddChild(self.tXmlData["Root"]);

	-- Load Form
	self.wndMain = self.xmlDoc:LoadForm(self.strLayoutName..self.strUnit, nil, self);
	self.wndMain:Show(false, true);

	-- Enable Mouseover Highlight
	self.wndMain:AddEventHandler("MouseEnter", "OnMouseEnter", self);
	self.wndMain:AddEventHandler("MouseExit", "OnMouseExit", self);
	self.wndMain:SetBGOpacity(0.2, 5e+20);

	-- Tooltips
	if (ToolTips) then
		self.wndMain:AddEventHandler("GenerateTooltip", "OnGenerateTooltip", self);
	end

	-- Enable Targetting
	self.wndMain:AddEventHandler("MouseButtonDown", "OnMouseClick", self);

	-- Add Properties for our Elements
	self.wndCastBar = self:FindRootOrChildWindow("CastBar");
	self.wndExperience = self:FindRootOrChildWindow("Experience");
	self.wndHealth = self.wndMain:FindChild("Health:Progress");
	self.wndShield = self.wndMain:FindChild("Shield");
	self.wndThreat = self.wndMain:FindChild("Threat");
	self.wndAuras = self:FindRootOrChildWindow("Auras");
	-- Temporary Elements
	self.wndTextLeft = self.wndMain:FindChild("TextLeft");
	self.wndTextRight = self.wndMain:FindChild("TextRight");

	-- Expose more Methods
	self.SetHealth = SetHealth;

	-- Return
	return self.wndMain;
end

local Show = function(self)
	Apollo.RegisterEventHandler("NextFrame", "ShowDelayed", self); -- We need this because SetBGOpacity apparently needs 1 frame....
end

local ShowDelayed = function(self)
	Apollo.RemoveEventHandler("NextFrame", self);
	self.wndMain:Show(true, true);
end

local Hide = function(self)
	self.wndMain:Show(false, true);
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function UnitFrame:New(tUnitFrameController, strLayoutName, strUnit, tXmlData, tAttributes)
	self = setmetatable({}, { __index = UnitFrame });

	-- Properties
	self.tXmlData = tXmlData;
	self.tAttributes = tAttributes or {};
	self.strUnit = strUnit;
	self.strLayoutName = strLayoutName;
	self.bEnabled = false;
	self.tElements = {};

	-- Reference Unit Frame Controller
	self.xmlDoc = tUnitFrameController.xmlDoc;
	self.tColors = setmetatable(self.tColors or {}, { __index = tUnitFrameController.tColors })

	-- Tags
	self.tTagControls = {};
	self.Tag = tUnitFrameController.Tag;
	self.Untag = tUnitFrameController.Untag;

	-- Expose Methods
	self.LoadForm = LoadForm;
	self.FindRootOrChildWindow = FindRootOrChildWindow;
	self.OnMouseEnter = OnMouseEnter;
	self.OnMouseExit = OnMouseExit;
	self.OnMouseClick = OnMouseClick;
	self.Show = Show;
	self.Hide = Hide;
	self.ShowDelayed = ShowDelayed;
	self.SetUnit = SetUnit;
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;

	-- Done
	return self;
end

-----------------------------------------------------------------------------

function UnitFrame:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	ToolTips = Apollo.GetAddon("ToolTips");
end

function UnitFrame:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(UnitFrame, MAJOR, MINOR, {});
