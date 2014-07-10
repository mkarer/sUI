--[[

	s:UI Unit Frame Element: Auras

	Dependencies: Sezz:Auras, Sezz:UnitFrameElement:Auras

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:Auras-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController, Auras, AuraControl;

-- Lua API
local sort, tinsert, tremove = table.sort, table.insert, table.remove;

-----------------------------------------------------------------------------
-- Sorting
-----------------------------------------------------------------------------

local fnSortAurasTimeAdded = function(a, b)
	return (a.nAdded < b.nAdded);
end

local fnSortAurasTimeAddedDebuffsFirst = function(a, b)
	return (a.bIsDebuff == b.bIsDebuff and (a.nAdded < b.nAdded) or (a.bIsDebuff and not b.bIsDebuff));
end

function Element:OrderAuras()
	local tAuras = self.tChildren;
	sort(tAuras, fnSortAurasTimeAddedDebuffsFirst);

	for i = 1, #tAuras do
		local wndAura = tAuras[i].tControl.wndMain;

		if (self.nAuraSize == 0) then
			self.nAuraSize = wndAura:GetWidth();
		end

		local nPosX = (i - 1) * (self.nAuraSize + self.nAuraPadding);
		local _, nPosT, _, nPosB = wndAura:GetAnchorOffsets();

		if (self.bAnchorLeft) then
			-- LTR
			wndAura:SetAnchorPoints(0, 0, 0, 0);
			wndAura:SetAnchorOffsets(nPosX, nPosT, nPosX + self.nAuraSize, nPosB);
		else
			-- RTL
			wndAura:SetAnchorPoints(1, 0, 1, 0);
			wndAura:SetAnchorOffsets(-nPosX - self.nAuraSize, nPosT, -nPosX, nPosB);
		end
	end
end

-----------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------

function Element:GetAura(nId)
	for i, tAuraData in ipairs(self.tChildren) do
		if (tAuraData.idBuff == nId) then
			return tAuraData, i;
		end
	end

	return false;
end

function Element:OnAuraUpdated(tAura)
	if (not self.bEnabled) then return; end

	local tAuraData, nIndex = self:GetAura(tAura.idBuff);
	if (tAuraData and nIndex) then
		tAuraData.tControl:UpdateDuration(tAura.fTimeRemaining);
		tAuraData.tControl:UpdateCount(tAura.nCount);
	end
end

function Element:OnAuraAdded(tAura)
	if (not self.bEnabled) then return; end

	if (not self:GetAura(tAura.idBuff)) then
		tAura.tControl = AuraControl:New(self.tUnitFrame.wndAuras, tAura, (tAura.bIsDebuff and self.tUnitFrame.tAttributes.AuraPrototypeDebuff or self.tUnitFrame.tAttributes.AuraPrototypeBuff)):Enable();
		tAura.nAdded = GameLib.GetTickCount();
		tinsert(self.tChildren, tAura);
		self:OrderAuras();
	end
end

function Element:OnAuraRemoved(tAura)
	if (not self.bEnabled) then return; end

	local tAuraData, nIndex = self:GetAura(tAura.idBuff);
	if (tAuraData and nIndex) then
		tAuraData.tControl:Destroy()
		tremove(self.tChildren, nIndex);
		self:OrderAuras();
	end
end

-----------------------------------------------------------------------------

function Element:Enable()
	self.bEnabled = true;
	self.tAuras:SetUnit(self.tUnitFrame.unit);
	self.tUnitFrame.wndAuras:Show(true, true);
end

function Element:Disable(bForce)
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
	self.tAuras:Disable();
	self.tUnitFrame.wndAuras:Show(false, true);

	for i = 1, #self.tChildren do
		tremove(self.tChildren).tControl:Destroy();
	end
end

local IsSupported = function(tUnitFrame)
	local bSupported = (Auras ~= nil and AuraControl ~= nil and tUnitFrame.wndAuras ~= nil);
	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	local self = setmetatable({}, { __index = Element });

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;
	self.bAnchorLeft = false;
	self.nAuraPadding = 4;
	self.tChildren = {};
	self.nAuraSize = 0;

	-- Reference Unit Frame
	self.tUnitFrame = tUnitFrame;

	-- Auras Library
	self.tAuras = Auras:New():SetUnit(self.tUnitFrame.unit, true);
	self.tAuras:RegisterCallback("OnAuraAdded", "OnAuraAdded", self);
	self.tAuras:RegisterCallback("OnAuraRemoved", "OnAuraRemoved", self);
	self.tAuras:RegisterCallback("OnAuraUpdated", "OnAuraUpdated", self);

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

	Auras = Apollo.GetPackage("Sezz:Auras-0.1").tPackage;
	AuraControl = Apollo.GetPackage("Sezz:Controls:Aura-0.1").tPackage;
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
