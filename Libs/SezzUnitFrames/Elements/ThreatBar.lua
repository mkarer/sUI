--[[

	s:UI Unit Frame Element: Threat Bar

	Only uses threat data available from the current target!
	When (If) Carbine implements a better API or someone creates a nifty library I'll add that.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:ThreatBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController;

-- Lua API
local floor = math.floor;

-----------------------------------------------------------------------------

local UnitIsFriend = function(unit)
	local unitPlayer = GameLib.GetPlayerUnit();
	return (unit == unitPlayer or unit:GetDispositionTo(unitPlayer) == Unit.CodeEnumDisposition.Friendly);
end

local UnitTargetsPlayer = function(unit)
	return (unit and unit:IsInCombat() and unit:GetTarget() and unit:GetTarget():IsThePlayer());
end

-----------------------------------------------------------------------------

function Element:UpdateThreat(...)
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local nUnitPlayerId = GameLib.GetPlayerUnit():GetId();
	local wndThreat = self.tUnitFrame.tControls.ThreatBar;
	local tColors = self.tUnitFrame.tColors;

	if (UnitIsFriend(unit) or unit:IsACharacter()) then
		return;
	end

	if (unit:IsDead()) then
		-- Mobs don't get resurrected, right?
		self:Disable();
	elseif (not self.bIsInCombat) then
		-- Clear player threat, should reset on Death/Void Slip
		self.tThreat[nUnitPlayerId] = nil;
	end

	-- Calculate Player Threat
	local nThreatMax = 0;
	local nThreatPlayer = 0;
	local nUnits = 0;

	for i = 1, select("#", ...), 2 do
		local unit, nThreat = select(i, ...);

		if (unit) then
			self.tThreat[unit:GetId()] = nThreat;
		end
	end

	for nUnitId, nThreat in pairs(self.tThreat) do
		if (nUnitId == nUnitPlayerId) then
			nThreatPlayer = nThreat;
		end

		if (nThreat > nThreatMax) then
			nThreatMax = nThreat;
		end
	end

	if (nThreatPlayer > 0) then
		-- TODO: Only show in group or solo when more than 1 unit on threat table
		local nThreadPercent = floor(nThreatPlayer / (nThreatMax / 100) + 0.01);

		wndThreat:SetProgress(nThreadPercent);
		wndThreat:Show(true, true);

		local bIsPlayerTargetted = UnitTargetsPlayer(unit);

		if (nThreadPercent == 100 and bIsPlayerTargetted) then
			-- Aggro
			wndThreat:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Threat[4]));
		elseif (nThreadPercent > 80 or bIsPlayerTargetted) then
			-- High Threat/Taunted by another player (Threat < 100, but we are still targetted)
			wndThreat:Threat(UnitFrameController:ColorArrayToHex(tColors.Threat[3]));
		elseif (nThreadPercent > 60) then
			-- Medium Threat
			wndThreat:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Threat[2]));
		else
			-- Low Threat
			wndThreat:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Threat[1]));
		end
	else
		wndThreat:Show(false, true);
	end
end

function Element:Update()
	-- Update() is only called when the element is enabled/target has changed
	local unit = self.tUnitFrame.unit;

	if (UnitIsFriend(unit) or unit:IsACharacter() or unit:IsDead()) then
		self.tUnitFrame.tControls.ThreatBar:Show(false, true);
		-- Not sure if friendly NPCs can turn into enemies, won't disable the element until someone can confirm.
		-- self:Disable();
	elseif (UnitTargetsPlayer(unit)) then
		self:UpdateThreat(GameLib.GetPlayerUnit(), 1);
	else
		self:UpdateThreat();
	end
end

function Element:OnTargetedByUnit(unit)
	if (unit == self.tUnitFrame.unit) then
		self:Update();
	end
end

function Element:OnUnitEnteredCombat(unit, bIsInCombat)
	if (unit and unit == self.tUnitFrame.unit and not bIsInCombat) then
		-- Reset Threat
		self.tThreat = {};
		self:Update();
	else
		local unitPlayer = GameLib.GetPlayerUnit();

		if (not unit or unit == unitPlayer) then
			self.bIsInCombat = bIsInCombat ~= nil and bIsInCombat or unitPlayer:IsInCombat();
			self:Update();
		end
	end
end

-----------------------------------------------------------------------------

function Element:Enable()
	if (not self.bEnabled) then
		-- Enable
		self.bEnabled = true;

		self.tThreat = {};
		Apollo.RegisterEventHandler("TargetThreatListUpdated", "UpdateThreat", self);
		Apollo.RegisterEventHandler("TargetedByUnit", "OnTargetedByUnit", self);
		Apollo.RegisterEventHandler("UnitEnteredCombat", "OnUnitEnteredCombat", self);
	elseif (not self.unit or self.unit ~= self.tUnitFrame.unit) then
		-- Unit changed, clear Threat Table
		self.unit = self.tUnitFrame.unit;
		self.tThreat = {};
	end

	self:Update();
end

function Element:Disable(bForce)
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;

	self.tThreat = {};
	Apollo.RemoveEventHandler("TargetThreatListUpdated", self);
	Apollo.RemoveEventHandler("TargetedByUnit", self);
	Apollo.RemoveEventHandler("UnitEnteredCombat", self);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.tControls.ThreatBar ~= nil);
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

	-- Initialize Threat Control
	self.tUnitFrame.tControls.ThreatBar:SetMax(100);

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
