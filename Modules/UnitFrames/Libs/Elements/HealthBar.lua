--[[

	s:UI Unit Frame Element: Health Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:HealthBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log;

-- Lua API
local format, floor, modf = string.format, math.floor, math.modf;

-----------------------------------------------------------------------------
-- Color Conversion
-----------------------------------------------------------------------------

local Round = function(nValue)
	return floor(nValue + 0.5);
end

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

local Update = function(self)
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local tColors = self.tUnitFrame.tColors;
	local wndHealth = self.tUnitFrame.wndHealth;

	local nCurrent = unit:GetHealth();
	local nMax = unit:GetMaxHealth();

	if (not nCurrent or not nMax or (nCurrent == 0 and nMax == 0)) then
		nCurrent = 1;
		nMax = 1;
	end

	wndHealth:SetMax(nMax);
	wndHealth:SetProgress(nCurrent);

	local nVulnerabilityTime = unit:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability);

	if (self.tUnitFrame.strUnit ~= "Player" and (unit:IsTagged() and not unit:IsTaggedByMe() and not unit:IsSoftKill())) then
		-- Tagged
		wndHealth:SetBarColor(ColorArrayToHex(tColors.Tagged));
	elseif (nVulnerabilityTime and nVulnerabilityTime > 0) then
		-- Vulnerable
		if (tColors.VulnerabilitySmooth) then
			wndHealth:SetBarColor(RGBColorToHex(RGBColorGradient(nCurrent, nMax, unpack(tColors.VulnerabilitySmooth))));
		else
			wndHealth:SetBarColor(ColorArrayToHex(tColors.Vulnerability));
		end
	else
		-- Default
		if (tColors.HealthSmooth) then
			wndHealth:SetBarColor(RGBColorToHex(RGBColorGradient(nCurrent, nMax, unpack(tColors.HealthSmooth))));
		else
			wndHealth:SetBarColor(ColorArrayToHex(tColors.Health));
		end
	end
end

local Enable = function(self)
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
	Apollo.RegisterEventHandler("NextFrame", "Update", self);
end

local Disable = function(self, bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
	Apollo.RemoveEventHandler("NextFrame", self);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.wndHealth ~= nil);
	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	self = setmetatable({}, self);
	self.__index = self;

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;

	-- Reference Unit Frame
	self.tUnitFrame = tUnitFrame;

	-- Expose Methods
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;

	-- Done
	self:Disable(true);

	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Element:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage:RegisterElement(MAJOR);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
