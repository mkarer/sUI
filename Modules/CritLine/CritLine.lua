--[[

	s:UI CritLine Module

	TODO:
		Switch to Spell IDs (but i don't know yet how proccs are handled, can't test without any items/runes that procc damage)
		Pet Support

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("CritLine", "Gemini:Timer-1.0");
local log;

-----------------------------------------------------------------------------

local eCombatResultHit, eCombatResultCrit;
local kstrNewRecord = "New %s record!";
local knTypeDamage = 1;
local knTypeHeal = 2;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:EnableProfile();
	self:InitializeForms();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	eCombatResultHit = GameLib.CodeEnumCombatResult.Hit;
	eCombatResultCrit = GameLib.CodeEnumCombatResult.Critical;

	-- Window
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "CritLineSplash", nil, self);

	-- Register Combatlog Events
	if (S.bCharacterLoaded) then
		self:OnCharacterLoaded();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "OnCharacterLoaded");
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());

	self:UnregisterEvent("CombatLogDamage");
	self:UnregisterEvent("CombatLogHeal");
	self:UnregisterEvent("CombatLogPet");
end

function M:OnCharacterLoaded()
	self:RegisterEvent("CombatLogDamage", "OnCombatLog");
	self:RegisterEvent("CombatLogHeal", "OnCombatLog");
	self:RegisterEvent("CombatLogPet", "OnCombatLog");
end

function M:RestoreProfile()
	-- OnRestore > RestoreProfile > OnEnable
	if (not self.P[knTypeDamage]) then
		self.P[knTypeDamage] = {};
	end

	if (not self.P[knTypeHeal]) then
		self.P[knTypeHeal] = {};
	end
end

-----------------------------------------------------------------------------
-- Splash
-----------------------------------------------------------------------------

local tmrFadeout;

function M:ShowSplash(strSpell, nAmount, bCritical)
	self.wndMain:FindChild("Crit"):Show(bCritical, true);
	self.wndMain:FindChild("NewRecord"):SetText(string.format(kstrNewRecord, strSpell));
	self.wndMain:FindChild("Amount"):SetText(nAmount);
	self.wndMain:Show(true, true);
	
	if (tmrFadeout) then
		self:CancelTimer(tmrFadeout);
	end

	tmrFadeout = self:ScheduleTimer("HideSplash", 3);
end

function M:HideSplash()
	tmrFadeout = nil;
	self.wndMain:Show(false);
end

-----------------------------------------------------------------------------
-- Combat Log Handling
-----------------------------------------------------------------------------

function M:HandleCombatData(eCombatResult, strSpell, nType, nAmount)
	if (strSpell and nAmount > 0) then
		local bNewRecord = true;
		if (self.P[nType][strSpell] and self.P[nType][strSpell][eCombatResult]) then
			-- New record?
			bNewRecord = (self.P[nType][strSpell][eCombatResult] < nAmount);
		end

		if (bNewRecord) then
			if (not self.P[nType][strSpell]) then
				self.P[nType][strSpell] = {};
			end
			
			self.P[nType][strSpell][eCombatResult] = nAmount;
			self:ShowSplash(strSpell, nAmount, eCombatResult == eCombatResultCrit);

			log:debug("NEW RECORD!! %s %d", strSpell, nAmount);
		end
	end
end

function M:OnCombatLog(event, tEventArgs)
	if (tEventArgs and tEventArgs.splCallingSpell and tEventArgs.unitCaster and (tEventArgs.unitCaster == S.myCharacter or tEventArgs.unitCaster:GetUnitOwner() == S.myCharacter)) then
		if (tEventArgs.eCombatResult == eCombatResultHit or tEventArgs.eCombatResult == eCombatResultCrit) then
			self:HandleCombatData(tEventArgs.eCombatResult, tEventArgs.splCallingSpell:GetName(), knTypeDamage, tEventArgs.nDamageAmount or 0);
			self:HandleCombatData(tEventArgs.eCombatResult, tEventArgs.splCallingSpell:GetName(), knTypeHeal, tEventArgs.nHealAmount or 0);
		else
			log:debug("Unsupported Combat Result: %d", tEventArgs.eCombatResult);
		end
	end
end
