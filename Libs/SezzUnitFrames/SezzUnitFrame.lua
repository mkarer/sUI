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

local MAJOR, MINOR = "Sezz:UnitFrame-0.2", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrame = APkg and APkg.tPackage or {};
local log, ToolTips, GeminiGUI;

-----------------------------------------------------------------------------
-- Tags
-----------------------------------------------------------------------------

local EnableTags = function(self)
	if (#self.tTagControls == 0 and self.tControls.Text) then
		for _, wndControl in ipairs(self.tControls.Text) do
			self:Tag(wndControl, { Tags = wndControl:GetData().Tags, Interval = 50 });
		end
	end
end

local UpdateTags = function(self)
	for _, tControl in ipairs(self.tTagControls) do
		tControl:UpdateTag();
	end
end

local DisableTags = function(self)
	for _, tControl in ipairs(self.tTagControls) do
		self:Untag(tControl);
	end
end

-----------------------------------------------------------------------------
-- Handle Mouse Clicks
-----------------------------------------------------------------------------

local OnMouseClick = function(self, wndHandler, wndControl, eMouseButton, x, y)
	if (wndHandler ~= wndControl) then return; end

	if (eMouseButton == GameLib.CodeEnumInputMouse.Left) then
		if (self.unit.__proto__) then
			GameLib.SetTargetUnit(self.unit.__proto__);
		end
		return false;
	elseif (eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, self.unit:GetName(), self.unit.__proto__ and self.unit.__proto__ or self.unit);
		return true;
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

local UpdateElements = function(self)
	if (not self.bEnabled) then return; end

	for _, tElement in ipairs(self.tElements) do
		if (tElement.bUpdateOnUnitFrameFrameCount) then
			tElement:Update();
		end
	end
end

local EnableElements = function(self)
	for _, tElement in ipairs(self.tElements) do
		tElement:Enable();
	end
end

local DisableElements = function(self)
	for _, tElement in ipairs(self.tElements) do
		tElement:Disable();
	end
end

----------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------

local Update = function(self)
	UpdateElements(self);
end

local Disable = function(self)
	self:Hide();
	DisableElements(self);
	DisableTags(self);
	self.unit = nil;
	self.bEnabled = false;
end

local Enable = function(self)
	self.bEnabled = true;
	EnableElements(self);
	EnableTags(self);
	UpdateTags(self);
	Update(self);
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

local FindElementControls;
FindElementControls = function(wndControl, tControls)
	local tData = wndControl:GetData();
	if (tData and type(tData) == "table" and tData.Element) then
		if (tData.Element == "Text" and not tControls.Text) then
			tControls.Text = {};
		end

		if (tControls[tData.Element]) then
			assert(tData.Element == "Text", string.format("Adding multiple elements of type %s is not supported!", tData.Element));
			table.insert(tControls[tData.Element], wndControl);
		else
			tControls[tData.Element] = wndControl;
		end
	end

	for _, wndChild in ipairs(wndControl:GetChildren()) do
		tControls = FindElementControls(wndChild, tControls);
	end

	return tControls;
end

local SpawnUnit = function(self)
	-- Spawn Window
	self.wndMain = self.tPrototype:GetInstance(self);
	self.tControls = FindElementControls(self.wndMain, {});
	self.wndMain:Show(false, true);

	-- Enable OnClick Handler (Targetting)
	self.wndMain:AddEventHandler("MouseButtonDown", "OnMouseClick", self);

	-- Enable Unit Tooltips
	if (ToolTips) then
		self.wndMain:AddEventHandler("GenerateTooltip", "OnGenerateTooltip", self);
	end

	-- Return
	return self.wndMain;
end

local Show = function(self)
	self.wndMain:Show(true, true);
end

local Hide = function(self)
	self.wndMain:Show(false, true);
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function UnitFrame:New(tUnitFrameController, strUnit, tWindowDefinition)
	self = setmetatable({}, { __index = UnitFrame });

	-- Properties
	self.tPrototype = GeminiGUI:Create(tWindowDefinition);
	self.strUnit = strUnit;
	self.bEnabled = false;
	self.tElements = {};
	self.tColors = setmetatable(self.tColors or {}, { __index = tUnitFrameController.tColors });

	-- Tags
	self.tTagControls = {};
	self.Tag = tUnitFrameController.Tag;
	self.Untag = tUnitFrameController.Untag;

	-- Expose Methods
	self.SpawnUnit = SpawnUnit;
	self.OnMouseClick = OnMouseClick;
	self.Show = Show;
	self.Hide = Hide;
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
	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
end

function UnitFrame:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(UnitFrame, MAJOR, MINOR, { "Gemini:GUI-1.0" });
