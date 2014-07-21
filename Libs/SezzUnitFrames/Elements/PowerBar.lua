--[[

	s:UI Unit Frame Element: Power Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:PowerBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController;

-- Lua API
local format, min, max = string.format, math.min, math.max;

-----------------------------------------------------------------------------
-- Class-specific Power
-----------------------------------------------------------------------------

local GetMana = function(unit)
	local nCurrent = unit:GetMana();
	local nMax = unit:GetMaxMana(); -- Doesn't work for other units? Maybe it will work sometimes.

	if (nCurrent and nMax and nMax == 0) then
		nMax = 1000; -- Most characters I targeted have 1062, but I don't care.
	end

	return nCurrent, nMax;
end

local GetSpellPower = function(unit)
	return unit:GetResource(4), unit:GetMaxResource(4);
end

local GetSuitPower = function(unit)
	return unit:GetResource(3), unit:GetMaxResource(3);
end

local GetDefaultResource = function(unit)
	return unit:GetResource(1), unit:GetMaxResource(1);
end

local tClassPower = {
	[GameLib.CodeEnumClass.Engineer]		= GetDefaultResource,
	[GameLib.CodeEnumClass.Esper]			= GetMana,
	[GameLib.CodeEnumClass.Medic]			= GetMana,
	[GameLib.CodeEnumClass.Stalker]			= GetSuitPower,
	[GameLib.CodeEnumClass.Spellslinger]	= GetMana,
	[GameLib.CodeEnumClass.Warrior]			= GetDefaultResource,
};

local tClassPowerColorStrings = { -- There's no CodeEnum.Whatever defined?
	[GameLib.CodeEnumClass.Spellslinger]	= "Focus",
	[GameLib.CodeEnumClass.Stalker]			= "SuitPower",
	[GameLib.CodeEnumClass.Warrior]			= "KineticEnergy",
	[GameLib.CodeEnumClass.Esper]			= "Focus",
	[GameLib.CodeEnumClass.Engineer]		= "Volatility",
	[GameLib.CodeEnumClass.Medic]			= "Focus",
};

-----------------------------------------------------------------------------

function Element:Update()
	if (not self.bEnabled) then return; end

	local fPowerCurrent, fPowerMax = self.fnGetPower(self.tUnitFrame.unit);
	if (not fPowerCurrent or not fPowerMax) then
		fPowerCurrent = 0;
		fPowerMax = 0;
	end

	self.wndPowerBar:SetProgress(fPowerCurrent);
	self.wndPowerBar:SetMax(fPowerMax);
end

function Element:Enable()
	-- OnAbilityCheck
	if (self.tUnitFrame.strUnit == "Player" and not GameLib.GetPlayerUnit():IsValid()) then
		return;
	end

	-- NPCs
	-- I don't know if pets or NPCs have mana/whatever, I'll just ignore them.
	local unit = self.tUnitFrame.unit;
	if (not unit:IsACharacter()) then
		self:Disable();
	end

	-- Players
	self.nClassId = unit:GetClassId();

	if (unit:IsThePlayer() and self.nClassId == GameLib.CodeEnumClass.Spellslinger) then
		-- Spellslinger: Show spell power instead of mana in assault spec.
		local nAssaultAbilities = 0;
		local nSupportAbilities = 0;

		local tActionSet = {};
		for i, nAbilityId in ipairs(ActionSetLib.GetCurrentActionSet()) do
			if (i > 8) then break; end
			tActionSet[nAbilityId] = 0;
		end

		for _, tAbility in ipairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Support)) do
			if (tActionSet[tAbility.nId]) then
				nSupportAbilities = nSupportAbilities + 1;
			end
		end

		for _, tAbility in ipairs(AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Assault)) do
			if (tActionSet[tAbility.nId]) then
				nAssaultAbilities = nAssaultAbilities + 1;
			end
		end

		if (nAssaultAbilities >= nSupportAbilities) then
			-- Assault
			self.wndPowerBar:SetBarColor(UnitFrameController:ColorArrayToHex(self.tUnitFrame.tColors.Power.SpellPower));
			self.fnGetPower = GetSpellPower;
		else
			-- Support
			self.wndPowerBar:SetBarColor(UnitFrameController:ColorArrayToHex(self.tUnitFrame.tColors.Power.Focus));
			self.fnGetPower = GetMana;
		end

		if (not self.bEnabled) then
			Apollo.RegisterEventHandler("AbilityBookChange", "Enable", self);
		end
	else
		-- Other Classes
		self.wndPowerBar:SetBarColor(UnitFrameController:ColorArrayToHex(self.tUnitFrame.tColors.Power[tClassPowerColorStrings[self.nClassId] or "SuitPower"]));
		self.fnGetPower = tClassPower[self.nClassId];
	end

	if (self.fnGetPower) then
		self.bEnabled = true;
		if (not self.wndPowerBarContainer:IsShown()) then
			-- WindowShow Event Fix
			self.wndPowerBarContainer:Show(true, true);
		end
		self:Update();
	else
		self:Disable();
	end
end

function Element:Disable(bForce)
	if (not self.bEnabled and not bForce) then return; end

	Apollo.RemoveEventHandler("AbilityBookChange", self);
	self.bEnabled = false;
	self.wndPowerBarContainer:Show(false, true);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.tControls.PowerBar ~= nil);

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	local self = setmetatable({ tUnitFrame = tUnitFrame }, { __index = Element });

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = true;
	self.wndPowerBar = self.tUnitFrame.tControls.PowerBar;
	self.wndPowerBarContainer = self.tUnitFrame.tControls.PowerBarContainer or self.wndPowerBar;

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
