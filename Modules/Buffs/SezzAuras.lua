--[[

	s:UI Auras Library

	Contains all buffs and debuffs of a specified unit.
	Callbacks are used to react on buff gain/change/lose.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Auras-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Auras = APkg and APkg.tPackage or {};
local log;

-- Lua API
local tinsert = table.insert;

-----------------------------------------------------------------------------

--[[
local tXml = {
	__XmlNode = "Forms",
	{
		__XmlNode="Form", Class="BuffContainerWindow",
		LAnchorPoint="0", LAnchorOffset="0",
		TAnchorPoint="0", TAnchorOffset="0",
		RAnchorPoint="0", RAnchorOffset="300",
		BAnchorPoint="0", BAnchorOffset="30",
		RelativeToClient="1", Template="Default",
		Font="Default", Text="", TooltipType="OnCursor",
		BGColor="00000000", TextColor="UI_WindowTextDefault",
		Border="1", Picture="1", SwallowMouseClicks="1", Moveable="1", Escapable="0", IgnoreMouse="1",
		Overlapped="1", TooltipColor="", Sprite="BasicSprites:WhiteFill", Tooltip="",
		BeneficialBuffs="1", HarmfulBuffs="1", Name="SezzAurasContainer",
	},
};
--]]

-----------------------------------------------------------------------------

function Auras:Enable()
	if (self.bEnabled) then return; end
--[[
	-- Create Buff Window
	if (not self.wndBuffContainer) then
		self.wndBuffContainer = Apollo.LoadForm(XmlDoc.CreateFromTable(tXml), "SezzAurasContainer", nil, self);
		self.wndBuffContainer:SetUnit(self.unit);
		self.wndBuffContainer:AddEventHandler("GenerateTooltip", "OnGenerateBuffTooltip", self);
	end
--]]

	-- Update
	if (self.unit and self.unit:IsValid()) then
		log:debug("Enable");
		self.bEnabled = true;
		Apollo.RegisterEventHandler("VarChange_FrameCount", "Update", self);
		self:Update();
	else
		self:Disable();
	end
end

function Auras:Disable()
	if (not self.bEnabled) then return; end

	log:debug("Disable");
	self.bEnabled = false;
	Apollo.RemoveEventHandler("VarChange_FrameCount", self);
	self:Reset();
end

function Auras:RegisterCallback(strEvent, strFunction, tEventHandler)
	if (not self.tCallbacks[strEvent]) then
		self.tCallbacks[strEvent] = {};
	end

	tinsert(self.tCallbacks[strEvent], { strFunction, tEventHandler });
end

function Auras:UpdateUnit(bNoAutoEnable)
	log:debug("Unit Update")
	self.fnUpdateUnit(self);

	if (not bNoAutoEnable) then
		self:Enable();
	end
end

function Auras:SetUnit(unit, bClearBuffs)
	self.unit = unit;

--[[
	if (self.wndBuffContainer) then
		self.wndBuffContainer:SetUnit(self.unit);
	end
--]]

	if (bClearBuffs) then
		self:Reset();
	end
end

function Auras:Reset()
	log:debug("Reset");

	for _, tAura in pairs(self.tDebuffs) do
		self.tBuffs[tAura.idBuff] = nil;
		self:Call("OnAuraRemoved", tAura);
	end

	for _, tAura in pairs(self.tBuffs) do
		self.tBuffs[tAura.idBuff] = nil;
		self:Call("OnAuraRemoved", tAura);
	end
end

function Auras:Call(strEvent, ...)
	if (self.tCallbacks[strEvent]) then
		for _, tCallback in ipairs(self.tCallbacks[strEvent]) do
			local strFunction = tCallback[1];
			local tEventHandler = tCallback[2];

			tEventHandler[strFunction](tEventHandler, ...);
		end
	end
end

function Auras:ScanAuras(arAuras, tCache, bIsDebuff)
	-- Mark all auras as expired
	for _, tAura in pairs(tCache) do
		tAura.bExpired = true;
	end

	-- Add/Update Auras
	for _, tAura in ipairs(arAuras) do
		tAura.bIsDebuff = bIsDebuff;

		if (not tCache[tAura.idBuff]) then
			-- New Aura
--			log:debug("Added Aura: %s", tAura.splEffect:GetName());
			tCache[tAura.idBuff] = tAura;
			self:Call("OnAuraAdded", tAura);
		else
			-- Update Existing Aura
			local bAuraUpdated = (tAura.fTimeRemaining > tCache[tAura.idBuff].fTimeRemaining);
			tCache[tAura.idBuff].fTimeRemaining = tAura.fTimeRemaining; -- fTimeRemaining doesn't get updated when a buff is refreshed!

			if (tCache[tAura.idBuff].nCount ~= tAura.nCount) then
				tCache[tAura.idBuff].nCount = tAura.nCount;
				bAuraUpdated = true;
			end

			if (bAuraUpdated) then
				log:debug("Updated Aura: %s", tAura.splEffect:GetName());
				self:Call("OnAuraUpdated", tAura);
			end
		end

		-- Remove IsExpired
		tCache[tAura.idBuff].bExpired = false;
	end

	-- Remove expired
	for _, tAura in pairs(tCache) do
		if (tAura.bExpired) then
			-- Remove Aura
			tCache[tAura.idBuff] = nil;
--			log:debug("Removed Aura: %s", tAura.splEffect:GetName());
			self:Call("OnAuraRemoved", tAura);
		end
	end
end

function Auras:Update()
--	log:debug("Update");

	if (self.unit and self.unit:IsValid()) then
		local tAuras = self.unit:GetBuffs();

		self:ScanAuras(tAuras.arBeneficial, self.tBuffs, false);
		self:ScanAuras(tAuras.arHarmful, self.tDebuffs, true);
	else
		-- Invalid Unit
		log:debug("Unit Invalid!")
		self:Disable();
	end
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Auras:New(fnUpdateUnit)
	self = setmetatable({}, { __index = Auras });

	self.bEnabled = false;
	self.tBuffs = {};
	self.tDebuffs = {};
	self.tCallbacks = {};

	self.fnUpdateUnit = fnUpdateUnit;
	self.fnUpdateUnit(self);

	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Auras:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});
end

function Auras:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Auras, MAJOR, MINOR, { "Gemini:Logging-1.2" });
