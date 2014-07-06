--[[

	s:UI Buffs/Debuffs

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Buffs", "Gemini:Hook-1.0");
local log, GeminiGUI;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	if (S.bCharacterLoaded) then
		self:Auras_Init();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "Auras_Init");
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

local Auras = {};

function Auras:New(fnUpdateUnit)
	self = setmetatable({}, { __index = Auras });

	self.tBuffs = {};
	self.tDebuffs = {};
	self.fnUpdateUnit = fnUpdateUnit;
	self.fnUpdateUnit(self);
	self:Update();

	return self;
end

function Auras:UpdateUnit()
	self.fnUpdateUnit(self);
end

function Auras:SetUnit(unit, bClearBuffs)
	self.unit = unit;

	if (bClearBuffs) then
		self:Reset();
	end
end

function Auras:Reset()
	self.tBuffs = {};
	self.tDebuffs = {};
end

function Auras:Update()
	if (self.unit and self.unit:IsValid()) then
		-- mark all auras as expired
		for _, tAura in pairs(self.tBuffs) do
			tAura.bExpired = true;
		end

		-- add/update auras
		for _, tAura in ipairs(self.unit:GetBuffs().arBeneficial) do
			if (not self.tBuffs[tAura.idBuff]) then
				-- new aura
				log:debug("XXXXXXXXXXXX new aura: %s", tAura.splEffect:GetName());
				self.tBuffs[tAura.idBuff] = tAura;
				-- attach window
			else
				-- update existing
				local bAuraChanged = false;

				if (self.tBuffs[tAura.idBuff].fTimeRemaining ~= tAura.fTimeRemaining) then
					self.tBuffs[tAura.idBuff].fTimeRemaining = tAura.fTimeRemaining;
--					bAuraChanged = true;
				end

				if (self.tBuffs[tAura.idBuff].nCount ~= tAura.nCount) then
					self.tBuffs[tAura.idBuff].nCount = tAura.nCount;
					bAuraChanged = true;
				end

				if (bAuraChanged) then
					log:debug("XXXXXXXXXXXX changed aura: %s", tAura.splEffect:GetName());
				end
			end

			-- remove expired mark
			self.tBuffs[tAura.idBuff].bExpired = false;
		end

		-- remove expired
		for nId, tAura in pairs(self.tBuffs) do
			if (tAura.bExpired) then
				-- free window
				-- remove aura
				self.tBuffs[nId] = nil;
				log:debug("XXXXXXXXXXXX removed aura: %s", tAura.splEffect:GetName());
			end
		end
	else
		log:debug("XXXXXXXXXXXX invalid unit - reset");
		self:Reset();
	end
end

-----------------------------------------------------------------------------

local tPlayerAuras;

function M:Auras_Init()
	local fnUpdatePlayerUnit = function(self)
		if (not self.unit or S.myCharacter ~= self.unit) then
			log:debug("XXXXXXXXXXXX update unit")
			self:SetUnit(S.myCharacter);
		end
	end

	tPlayerAuras = Auras:New(fnUpdatePlayerUnit);

	Apollo.RegisterEventHandler("VarChange_FrameCount", "Update", tPlayerAuras);
	Apollo.RegisterEventHandler("PlayerChanged", "UpdateUnit", tPlayerAuras);
end

-----------------------------------------------------------------------------

function M:SetupBuffs()
	local tBuffProto = {
		WidgetType = "Window",
		WhiteFillMe = true,
		Anchor = "TOPLEFT",
		AnchorOffsets = { 0, 0, 200, 20 },
	};

	-- Retrieve the GeminiGUI library from Apollo's package system
	local GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

	-- Setup the table definition for the window
	local tWindowDefinition = {
		Name          = "MyExampleWindow",
		Template      = "CRB_TooltipSimple",
		UseTemplateBG = true,
		Picture       = true,
		Moveable      = true,
		Border        = true,
		AnchorCenter  = { 500, 300 },
		Children = {
		{
			WidgetType     = "PushButton",
			Base           = "CRB_UIKitSprites:btn_square_LARGE_Red",
			Text           = "Close Parent",
			TextThemeColor = "ffffffff", -- sets normal, flyby, pressed, pressedflyby, disabled to a color
			AnchorCenter   = { 150, 40 },
			Events = {
			ButtonSignal = function(self, wndHandler, wndControl)
				wndControl:GetParent():Close()
			end
			},
		},
		},
	}

	-- Aura Container
	local tContainer = GeminiGUI:Create(tWindowDefinition)
	local wndContainer = tContainer:GetInstance()

	-- Add Auras
	local tBuff = GeminiGUI:Create(tBuffProto):GetInstance(self, wndContainer);

end
