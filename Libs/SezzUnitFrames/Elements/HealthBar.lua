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
local log, UnitFrameController;

-----------------------------------------------------------------------------

function Element:Update()
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local tColors = self.tUnitFrame.tColors;
	local wndHealth = self.tUnitFrame.tControls.HealthBar;

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
		wndHealth:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Tagged));
	elseif (nVulnerabilityTime and nVulnerabilityTime > 0) then
		-- Vulnerable
		if (tColors.VulnerabilitySmooth) then
			wndHealth:SetBarColor(UnitFrameController:RGBColorToHex(UnitFrameController:RGBColorGradient(nCurrent, nMax, unpack(tColors.VulnerabilitySmooth))));
		else
			wndHealth:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Vulnerability));
		end
	else
		-- Default
		if (tColors.HealthSmooth) then
			wndHealth:SetBarColor(UnitFrameController:RGBColorToHex(UnitFrameController:RGBColorGradient(nCurrent, nMax, unpack(tColors.HealthSmooth))));
		else
			wndHealth:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Health));
		end
	end
end

function Element:Enable()
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
	Apollo.RegisterEventHandler("NextFrame", "Update", self);
end

function Element:Disable(bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
	Apollo.RemoveEventHandler("NextFrame", self);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.tControls.HealthBar ~= nil);
--	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	local self = setmetatable({ tUnitFrame = tUnitFrame }, { __index = Element });

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;

	-- Done
	self:Disable(true);

	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Element:OnLoad()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2") and Apollo.GetAddon("GeminiConsole") and Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	if (GeminiLogging) then
		log = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender ="GeminiConsole"
		});
	else
		log = setmetatable({}, { __index = function() return function(self, ...) local args = #{...}; if (args > 1) then Print(string.format(...)); elseif (args == 1) then Print(tostring(...)); end; end; end });
	end

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
	UnitFrameController:RegisterElement(MAJOR);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.2" });
