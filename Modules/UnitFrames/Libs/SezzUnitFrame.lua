--[[

	s:UI Unit Frame

	TODO:

		Interrupt Armor
		Shield Bar
		Power Bar
		Experience Bar

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

local Round = function(nValue)
	return floor(nValue + 0.5);
end

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
		if (not nCurrentHealth or not nMaxHealth) then return; end

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

local ColorArrayToHex = function(arColor)
	-- We only use indexed arrays here!
	return format("%02x%02x%02x%02x", 255, Round(255 * arColor[1]), Round(255 * arColor[2]), Round(255 * arColor[3]))
end

local RGBColorToHex = function(r, g, b)
	-- We only use indexed arrays here!
	return format("%02x%02x%02x%02x", 255, Round(255 * r), Round(255 * g), Round(255 * b))
end

-----------------------------------------------------------------------------
-- Color Gradient
-- http://www.wowwiki.com/ColorGradient
-----------------------------------------------------------------------------

local ColorsAndPercent = function(a, b, ...)
	if (a <= 0 or b == 0) then
		return nil, ...;
	elseif (a >= b) then
		return nil, select(select('#', ...) - 2, ...);
	end

	local num = select('#', ...) / 3;
	local segment, relperc = modf((a / b) * (num - 1));
	return relperc, select((segment * 3) + 1, ...);
end

local RGBColorGradient = function(...)
	local relperc, r1, g1, b1, r2, g2, b2 = ColorsAndPercent(...);
	if (relperc) then
		return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc;
	else
		return r1, g1, b1;
	end
end

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
		BarColor = ColorArrayToHex(self.tColors.Health),
	});

	self.tXmlData["HealthBarBackground"]:AddChild(self.tXmlData["HealthBar"]);
end

-- Left Text Element (Optional)
local AddTextLeft = function(self)
--	self.tXmlData["TextLeft"] = self.xmlDoc:NewControlNode("TextLeft", "Window", {
--		AnchorPoints = { 0, 0, 0.5, 1 },
--		AnchorOffsets = { 4, 0, 0, 0 },
--		TextColor = "white",
--		DT_VCENTER = true,
--		Text = "Elke",
--		IgnoreMouse = "true",
--		Font = "CRB_Pixel_O",
--	});

	-- MLWindow allows colors, but it doesn't care about DT_VCENTER/DT_RIGHT/Font
	self.tXmlData["TextLeft"] = self.xmlDoc:NewControlNode("TextLeft", "MLWindow", {
		AnchorPoints = { 0, 0.5, 0.5, 0.5 },
		AnchorOffsets = { 4, -7, 0, 7 },
		TextColor = "white",
		Text = "{Unit}",
		IgnoreMouse = "true",
		Font = "CRB_Pixel_O",
	});

	self.tXmlData["HealthBar"]:AddChild(self.tXmlData["TextLeft"]);
end

-- Right Text Element (Optional)
local AddTextRight = function(self)
--	self.tXmlData["TextRight"] = self.xmlDoc:NewControlNode("TextRight", "MLWindow", {
--		AnchorPoints = { 0.5, 0, 1, 1 },
--		AnchorOffsets = { 0, 0, -4, 0 },
--		TextColor = "white",
--		DT_VCENTER = true,
--		DT_RIGHT = true,
--		Text = "28.6k",
--		IgnoreMouse = "true",
--		Font = "CRB_Pixel_O",
--	});

	-- MLWindow allows colors, but it doesn't care about DT_VCENTER/DT_RIGHT/Font
	self.tXmlData["TextRight"] = self.xmlDoc:NewControlNode("TextRight", "MLWindow", {
		AnchorPoints = { 0.5, 0.5, 1, 0.5 },
		AnchorOffsets = { 0, -7, -4, 7 },
		TextColor = "white",
		Text = "{Right}",
		IgnoreMouse = "true",
		Font = "CRB_Pixel_O",
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
-- Health
-----------------------------------------------------------------------------

local SetHealth = function(self, nCurrent, nMax)
	self.wndHealth:SetMax(nMax);
	self.wndHealth:SetProgress(nCurrent);

	if (self.tColors.Smooth) then
		self.wndHealth:SetBarColor(RGBColorToHex(RGBColorGradient(nCurrent, nMax, unpack(self.tColors.Smooth))));
	end
end

local SetHealthText = function(self, nCurrent, nMax)
	-- TODO: Tags
	if (self.wndTextRight) then
		self.wndTextRight:SetText(tTags["sezz:hp"](self.unit));
	end
end

local UpdateHealth = function(self)
	-- Objects and some NPCs don't have any health
	local nCurrent = self.unit:GetHealth() or 1;
	local nMax = self.unit:GetMaxHealth() or nCurrent;

--	log:debug({nCurrent, nMax})
	SetHealth(self, nCurrent, nMax);
	SetHealthText(self, nCurrent, nMax);
end

------------------------------------------------------------------------------
-- Text
-- TODO: Tags
-----------------------------------------------------------------------------

local UpdateName = function(self)
	if (self.wndTextLeft) then
		self.wndTextLeft:SetText(WrapAML("P", self.unit:GetName(), ColorArrayToHex(self.tColors.Class[self.unit:GetClassId()]), "Left"));
	end
end

----------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------

local Update = function(self)
	if (self.bEnabled) then
		UpdateHealth(self);
		UpdateName(self);
	end
end

local Disable = function(self)
	self.bEnabled = false;
	self.unit = nil;
	self:Hide();
end

local Enable = function(self)
	self.bEnabled = true;
	self:Update();
	self:Show();
end

local SetUnit = function(self, unit)
	if (not unit or (unit and not unit:IsValid())) then
		-- Disable
		log:debug("[%s] Unit Invalid!", self.strUnit);
		self:Disable();
		return false;
	end

	-- Base Unit
	if (not self.unit or (self.unit and self.unit:GetId() ~= unit:GetId())) then
		log:debug("[%s] Updated Unit: %s", self.strUnit, unit:GetName());
		self.unit = unit;
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
	self.xmlDoc:GetRoot():AddChild(self.tXmlData["Background"]);

	-- Load Form
	self.wndMain = self.xmlDoc:LoadForm(self.strName, nil, self);
	self.wndMain:Show(false, true);

	-- Enable Mouseover Highlight
	self.wndMain:AddEventHandler("MouseEnter", "OnMouseEnter", self);
	self.wndMain:AddEventHandler("MouseExit", "OnMouseExit", self);
	self.wndMain:SetBGOpacity(0.2, 5e+20);

	-- Enable Target
	self.wndMain:AddEventHandler("MouseButtonDown", "OnMouseClick", self);

	-- Add Properties for our Elements
	self.wndHealth = self.wndMain:FindChild("HealthBar");
	self.wndTextLeft = self.wndMain:FindChild("TextLeft");
	self.wndTextRight = self.wndMain:FindChild("TextRight");

	-- Expose more Methods
	self.SetHealth = SetHealth;

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

local CreateUnitFrame = function(self)
	-- Initialize Unit Frame Table
	self.strName = "SezzUnitFrames_"..self.strUnit;
	self.bEnabled = false;

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
	self.OnMouseClick = OnMouseClick;
	self.Show = Show;
	self.Hide = Hide;
	self.ShowDelayed = ShowDelayed;
	self.SetUnit = SetUnit;
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;

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

	-- Reference Unit Frame Controller
	self.xmlDoc = tUnitFrameController.xmlDoc;
	self.tColors = setmetatable(self.tColors or {}, { __index = tUnitFrameController.tColors })

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
