--[[

	s:UI Unit Frame

	TODO:

		Interrupt Armor
		Shield Bar
		Power Bar
		Experience Bar
		Remove the layout code
		
		Events:

			UnitNameChanged(unitUpdated, strNewName)
			TargetUnitChanged(unitOwner)
			UnitLevelChanged(unitUpdating)
			local tRewardUpdateEvents = {
				"QuestObjectiveUpdated", "QuestStateChanged", "ChallengeAbandon", "ChallengeLeftArea",
				"ChallengeFailTime", "ChallengeFailArea", "ChallengeActivate", "ChallengeCompleted",
				"ChallengeFailGeneric", "PublicEventObjectiveUpdate", "PublicEventUnitUpdate",
				"PlayerPathMissionUpdate", "FriendshipAdd", "FriendshipPostRemove", "FriendshipUpdate" 
			}
		local nVulnerabilityTime = unitOwner:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrame-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local UnitFrame = APkg and APkg.tPackage or {};
local log;

-- Lua APIs
local format, modf, select, floor, upper, gsub, ceil = string.format, math.modf, select, math.floor, string.upper, string.gsub, math.ceil;

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------

local ShortNumber = function(nValue)
	if (nValue >= 1e6) then
		return (gsub(format("%.2fm", nValue / 1e6), "%.?0+([km])$", "%1"));
	elseif (nValue >= 1e4) then
		return (gsub(format("%.1fk", nValue / 1e3), "%.?0+([km])$", "%1"));
	else
		return nValue;
	end
end

local UnitIsFriend = function(unit)
	return (unit:IsThePlayer() or unit:GetDispositionTo(GameLib.GetPlayerUnit()) == Unit.CodeEnumDisposition.Friendly);
end

local WrapAML = function(strTag, strText, strColor, strAlign)
	return format('<%s Font="CRB_Pixel_O" Align="%s" TextColor="%s">%s</%s>', strTag, strAlign or "Left", strColor or "ffffffff", strText, strTag);
end

-----------------------------------------------------------------------------
-- Tags
-- But not now...
-- MLWindow is so fucked up, I want to test performance first.
-----------------------------------------------------------------------------

local tTags = {};

local UnitStatus = function(unit)
--	if (UnitIsUnconscious(unit)) then
--		return "|cffff7f7fUnconscious|r";
	if (unit:IsDead()) then
		return WrapAML("P", "DEAD", "ffff7f7f", "Right");
--	elseif (UnitIsGhost(unit)) then
--		return "Ghost";
--	elseif (not UnitIsConnected(unit)) then
--			Offline only works in groups
--		Unit:IsInYourGroup()
-- 		GroupLib.GetGroupMember(i).bDisconnected
--		return "Offline";
	end
	
	return nil;
end

tTags["sezz:hp"] = function(unit)
	-- Default HP
	local strStatus = UnitStatus(unit);
	if (strStatus) then
		return strStatus;
	else
		local nCurrentHealth, nMaxHealth = unit:GetHealth(), unit:GetMaxHealth();
		if (not nCurrentHealth or not nMaxHealth or (nCurrentHealth == 0 and nMaxHealth == 0)) then return; end

		-- ? UnitCanAttack//not UnitIsFriend
		if (UnitIsFriend(unit) and unit:IsACharacter(unit)) then
			-- Unit is friendly and a Player
			-- HP Style: [CURHP]-[LOSTHP]
			if (nCurrentHealth ~= nMaxHealth) then
				return WrapAML("P", ShortNumber(nCurrentHealth)..WrapAML("T", "-"..ShortNumber(nMaxHealth - nCurrentHealth), "ffff7f7f", "Right"), "ffffffff", "Right");
			else
				return WrapAML("P", ShortNumber(nMaxHealth), nil, "Right");
			end
		else
			-- Unit is no player or an enemy
			-- HP Style: [CURHP]/[MAXHP] [HP%]
			if (nCurrentHealth ~= nMaxHealth) then
				return WrapAML("P", WrapAML("T", ShortNumber(nCurrentHealth), "ffff9000", "Right").."/"..ShortNumber(nMaxHealth)..WrapAML("T", " "..ceil(nCurrentHealth / (nMaxHealth * 0.01)).."%", "ffff9000", "Right"), nil, "Right");
			else
				return WrapAML("P", ShortNumber(nCurrentHealth)..WrapAML("T", " "..ceil(nCurrentHealth / (nMaxHealth * 0.01)).."%", "ffff9000", "Right"), nil, "Right");
			end
		end
	end
end

-----------------------------------------------------------------------------
-- Colors
-----------------------------------------------------------------------------

local Round = function(nValue)
	return floor(nValue + 0.5);
end

local ColorArrayToHex = function(arColor)
	-- We only use indexed arrays here!
	return format("%02x%02x%02x%02x", 255, Round(255 * arColor[1]), Round(255 * arColor[2]), Round(255 * arColor[3]))
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
		GameLib.SetTargetUnit(self.unit);
		return false
	elseif (eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, self.unit:GetName(), self.unit);
		return true
	end

	return false;
end

-----------------------------------------------------------------------------
-- Tooltips
-----------------------------------------------------------------------------

-- local OnGenerateTooltip = function(self, wndControl, wndHandler, eType, arg1, arg2)
-- end

-----------------------------------------------------------------------------
-- Health
-----------------------------------------------------------------------------

local SetHealthText = function(self, nCurrent, nMax)
	-- TODO: Tags
	if (self.wndTextRight) then
		self.wndTextRight:SetText(tTags["sezz:hp"](self.unit));
	end
end

local UpdateHealth = function(self)
	-- Objects and some NPCs don't have any health
	local nCurrent = self.unit:GetHealth();
	local nMax = self.unit:GetMaxHealth();

	if (not nCurrent or not nMax or (nCurrent == 0 and nMax == 0)) then
		nCurrent = 1;
		nMax = 1;
	end

	SetHealthText(self, nCurrent, nMax);
end

------------------------------------------------------------------------------
-- Text
-- TODO: Tags
-----------------------------------------------------------------------------

local UpdateName = function(self)
	self.wndMain:SetTooltip(self.unit:GetName()); -- Current Workaround
	if (self.wndTextLeft) then
		self.wndTextLeft:SetText(WrapAML("P", self.unit:GetName(), ColorArrayToHex(self.tColors.Class[self.bIsObject and "Object" or self.unit:GetClassId()]), "Left"));
	end
end

-----------------------------------------------------------------------------
-- Elements
-----------------------------------------------------------------------------

local RegisterElement = function(self, tElement)
	local tElement = tElement:New(self);
	if (tElement) then
		table.insert(self.tElements, tElement);
	end
end

----------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------

local UnitIsObject = function(unit)
	local nCurrent = unit:GetHealth();
	local nMax = unit:GetMaxHealth();

	return (not nCurrent or not nMax or (nCurrent == 0 and nMax == 0));
end

local Update = function(self)
	if (self.bEnabled) then
		UpdateHealth(self);
		UpdateName(self);

		for _, tElement in ipairs(self.tElements) do
			if (tElement.bUpdateOnUnitFrameFrameCount) then
				tElement:Update();
			end
		end
	end
end

local Disable = function(self)
	self.bEnabled = false;
	for _, tElement in ipairs(self.tElements) do
		tElement:Disable();
	end

	self.unit = nil;
	self:Hide();
end

local Enable = function(self)
	self.bEnabled = true;
	for _, tElement in ipairs(self.tElements) do
		tElement:Enable();
	end

	self:Update();
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
		self.bIsObject = UnitIsObject(unit);
		self:Enable();
	end
end

-----------------------------------------------------------------------------
-- Forms
-----------------------------------------------------------------------------

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

	-- Enable Targetting
	self.wndMain:AddEventHandler("MouseButtonDown", "OnMouseClick", self);

--	-- Enable Tooltips
--	self.wndMain:AddEventHandler("GenerateTooltip", "OnGenerateTooltip", self);

	-- Add Properties for our Elements
	self.wndCastBar = self.xmlDoc:LoadForm(self.strLayoutName..self.strUnit.."CastBar", nil, self) or self.wndMain:FindChild("CastBar");
	self.wndExperience = self.xmlDoc:LoadForm(self.strLayoutName..self.strUnit.."Experience", nil, self) or self.wndMain:FindChild("Experience");
	self.wndHealth = self.wndMain:FindChild("Health:Progress");
	self.wndTextLeft = self.wndMain:FindChild("TextLeft");
	self.wndTextRight = self.wndMain:FindChild("TextRight");

	-- Expose more Methods
	self.SetHealth = SetHealth;

	-- Enable Elements
	self.RegisterElement = RegisterElement;
	self.tElements = {};

	-- Return
	return self.wndMain;
end

local Show = function(self)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "ShowDelayed", self); -- We need this because SetBGOpacity apparently needs 1 frame....
end

local ShowDelayed = function(self)
	Apollo.RemoveEventHandler("VarChange_FrameCount", self);
	self.wndMain:Show(true, true);
end

local Hide = function(self)
	self.wndMain:Show(false, true);
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function UnitFrame:New(o, tUnitFrameController, strLayoutName, strUnit, tXmlData)
	self = setmetatable(o or {}, self);
	self.__index = self;

	-- Properties
	self.tXmlData = tXmlData;
	self.strUnit = strUnit;
	self.strLayoutName = strLayoutName;
	self.bEnabled = false;

	-- Reference Unit Frame Controller
	self.xmlDoc = tUnitFrameController.xmlDoc;
	self.tColors = setmetatable(self.tColors or {}, { __index = tUnitFrameController.tColors })

	-- Expose Methods
	self.LoadForm = LoadForm;
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
end

function UnitFrame:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(UnitFrame, MAJOR, MINOR, {});
