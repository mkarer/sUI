--[[

	s:UI Class Power Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("PowerBar", "Gemini:Hook-1.0", "Gemini:Event-1.0");
local log, cfg;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
	self.PowerButtons = {};
	self.DB = {
		["alwaysVisible"] = false,
		["buttonSize"] = 36,
		["buttonPadding"] = 4,
		["barHeight"] = 6,
	};
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Create Anchor
	self.wndAnchor = Apollo.LoadForm(self.xmlDoc, "PowerBarAnchor", nil, self);
	self.wndAnchor:Show(false);

	-- Load Class Configuration
	if (S.bCharacterLoaded) then
		self:ReloadConfiguration();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "ReloadConfiguration");
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:ReloadConfiguration()
	log:debug("ReloadConfiguration");

	-- Class Configuration (TEMP)
	self.DB.classConfiguration = {
		[GameLib.CodeEnumClass.Spellslinger] = {
			["numButtons"] = 4,
			["buttonEmpowerFunc"] = GameLib.IsSpellSurgeActive,
			["buttonPowerFunc"] = self.GetPowerSpell,
			["barEnabled"] = true,
			["barPowerFunc"] = self.GetPowerMana,
		},
		[GameLib.CodeEnumClass.Esper] = {
			["numButtons"] = 5,
			["buttonEmpowerFunc"] = GameLib.IsCurrentInnateAbilityActive,
			["buttonPowerFunc"] = self.GetPowerActuators,
			["barEnabled"] = true,
			["barPowerFunc"] = self.GetPowerMana,
		},
		[GameLib.CodeEnumClass.Medic] = {
			["numButtons"] = 4,
			["buttonEmpowerFunc"] = GameLib.IsCurrentInnateAbilityActive,
			["buttonPowerFunc"] = self.GetPowerActuators,
			["barEnabled"] = true,
			["barPowerFunc"] = self.GetPowerMana,
		},
		[GameLib.CodeEnumClass.Engineer] = {
			["numButtons"] = 0,
			["barEnabled"] = true,
			["barPowerFunc"] = self.GetPowerVolatility,
		},
		[GameLib.CodeEnumClass.Stalker] = {
			["numButtons"] = 0,
			["barEnabled"] = true,
			["barPowerFunc"] = self.GetPowerSuit,
		},
		[GameLib.CodeEnumClass.Warrior] = {
			["numButtons"] = 4,
			["buttonEmpowerFunc"] = GameLib.IsOverdriveActive,
			["buttonPowerFunc"] = self.GetPowerKineticEnergy,
			["barEnabled"] = false,
		},
	};

	cfg = self.DB.classConfiguration[S.myClassId];

	-- Resize Anchor
	local nBarWidth = cfg.numButtons > 0 and (cfg.numButtons * self.DB.buttonSize + (cfg.numButtons - 1) * self.DB.buttonPadding) or 156;
	self.wndAnchor:SetAnchorOffsets(-nBarWidth / 2, 100, nBarWidth / 2, 200);

	-- Create Buttons
	if (cfg.numButtons > 0) then
		for i = 1, cfg.numButtons do
			local button = Apollo.LoadForm(self.xmlDoc, "PowerButton", self.wndAnchor, self);
			button:SetName("PowerButton"..i);

			if (i > 1) then
				local nAnchorOffsetLeft = (i - 1) * (self.DB.buttonSize + self.DB.buttonPadding);
				button:SetAnchorOffsets(nAnchorOffsetLeft, 0, nAnchorOffsetLeft + self.DB.buttonSize, self.DB.buttonSize);
			end

			self.PowerButtons[i] = button;
		end
	end

	-- Create Bar
	if (cfg.barEnabled) then
		local bar = Apollo.LoadForm(self.xmlDoc, "PowerBar", self.wndAnchor, self);
		bar:SetName("PowerBar1");

		local nAnchorOffsetTop = self.DB.buttonSize + self.DB.buttonPadding;
		bar:SetAnchorOffsets(0, nAnchorOffsetTop, 0, nAnchorOffsetTop + self.DB.barHeight);

		self.PowerBar = bar;
	end

	-- Add Events
	-- Carbine uses OnUpdate, I'll use that too (although this propably sucks)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "UpdatePower", self);

	-- Show/Hide
	if (not self.DB.alwaysVisible) then
		self:RegisterEvent("Sezz_PlayerRegenDisabled", "ChangeVisibility");
		self:RegisterEvent("Sezz_PlayerRegenEnabled", "ChangeVisibility");
		self:ChangeVisibility();
	else
		self.wndAnchor:Show(true);
	end

	-- Done
	log:debug("%s ready!", self:GetName());
end

-----------------------------------------------------------------------------
-- Bar/Button Updates
-----------------------------------------------------------------------------

function M:UpdatePower()
	if (not S.inCombat and not self.DB.alwaysVisible) then return; end
	log:debug("UpdatePower");

	-- Buttons
	if (cfg.numButtons > 0) then
		local powerCurrent, powerMax = cfg.buttonPowerFunc();
		log:debug("Power Buttons: %d/%d", powerCurrent, powerMax);
		local bEmpowered = cfg.buttonEmpowerFunc and cfg.buttonEmpowerFunc() or false;

		for i = 1, cfg.numButtons do
			if (powerCurrent >= i) then
				self.PowerButtons[i]:FindChild("Icon"):SetSprite("PowerBarButton"..(bEmpowered and "Surged" or "Filled"));
			else
				self.PowerButtons[i]:FindChild("Icon"):SetSprite("PowerBarButtonEmpty");
			end
		end
	end

	-- Bar
	if (cfg.barEnabled) then
		local powerCurrent, powerMax = cfg.barPowerFunc();
		log:debug("Power Bar: %d/%d", powerCurrent, powerMax);
		self.PowerBar:FindChild("Progress"):SetMax(powerMax);
		self.PowerBar:FindChild("Progress"):SetProgress(powerCurrent);
	end

	log:debug("UpdatePower Done");
end

function M:ChangeVisibility()
	log:debug("ChangeVisibility: %s", S.inCombat and "TRUE" or "FALSE")
	self.wndAnchor:Show(S.inCombat, false, S.inCombat and 0.2 or 0.5);
end

-----------------------------------------------------------------------------
-- Power Functions
-----------------------------------------------------------------------------

function M:GetPowerMana()
	return math.floor(S.myCharacter:GetMana()), math.floor(S.myCharacter:GetMaxMana());
end

function M:GetPowerSpell()
	local powerMax = S.myCharacter:GetMaxResource(4);
	local powerCurrent = S.myCharacter:GetResource(4);
	local powerDivider = powerMax / cfg.numButtons;

	return math.floor(powerCurrent / powerDivider), math.floor(powerMax / powerDivider);
end

function M:GetPowerSuit()
	return S.myCharacter:GetResource(3), S.myCharacter:GetMaxResource(3);
end

function M:GetPowerActuators()
	return S.myCharacter:GetResource(1), S.myCharacter:GetMaxResource(1);
end

function M:GetPowerVolatility()
	local powerMax = S.myCharacter:GetMaxResource(1);
	local powerCurrent = S.myCharacter:GetResource(1);
	local powerPercent = powerCurrent / powerMax * 100;

	return powerPercent, powerMax;
end

function M:GetPowerKineticEnergy()
	local powerMax = S.myCharacter:GetMaxResource(1);
	local powerCurrent = S.myCharacter:GetResource(1);
	local powerDivider = powerMax / cfg.numButtons;

	return math.floor(powerCurrent / powerDivider), math.floor(powerMax / powerDivider);
end
