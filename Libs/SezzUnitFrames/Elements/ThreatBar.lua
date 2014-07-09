--[[

	s:UI Unit Frame Element: Threat Bar

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


local UpdateThreat = function(self, ...)
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	if (unit:IsDead()) then self:Disable(); return; end -- Mobs don't get resurrected, right?

	local nUnitPlayerId = GameLib.GetPlayerUnit():GetId();
	local wndThreat = self.tUnitFrame.wndThreat;
	local tColors = self.tUnitFrame.tColors;

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

		wndThreat:Show(true, true);
		wndThreat:SetProgress(nThreadPercent);

		local bIsPlayerTargetted = UnitTargetsPlayer(unit);

		if (nThreadPercent == 100 and bIsPlayerTargetted) then
			-- Aggro
			wndThreat:SetBarColor(UnitFrameController:ColorArrayToHex(tColors.Threat[4]));
		elseif (nThreadPercent > 80 or bIsPlayerTargetted) then
			-- High Aggro or Taunted by another player
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

local Update = function(self)
	local unit = self.tUnitFrame.unit;

	if (UnitIsFriend(unit) or unit:IsDead()) then
		self.tUnitFrame.wndThreat:Show(false, true);
	elseif (UnitTargetsPlayer(unit)) then
		self:UpdateThreat(GameLib.GetPlayerUnit(), 1);
	end
end

local TargetedByUnit = function(self, unit)
	if (unit == self.tUnitFrame.unit) then
		self:Update();
	end
end

local Enable = function(self)
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;

	self.tThreat = {};
	Apollo.RegisterEventHandler("TargetThreatListUpdated", "UpdateThreat", self);
	Apollo.RegisterEventHandler("TargetedByUnit", "TargetedByUnit", self);

	self:Update();
end

local Disable = function(self, bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;

	self.tThreat = {};
	Apollo.RemoveEventHandler("TargetThreatListUpdated", self);
	Apollo.RemoveEventHandler("TargetedByUnit", self);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.wndThreat ~= nil);
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
	self.tUnitFrame.wndThreat:SetMax(100);

	-- Expose Methods
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;
	self.UpdateThreat = UpdateThreat;
	self.TargetedByUnit = TargetedByUnit;

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

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
	UnitFrameController:RegisterElement(MAJOR);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
