--[[

	s:UI Unit Wrapper

	Adds needed methods to GroupLib.GetGroupMember tables and also emulates this data for real units.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
if (UnitFrameController.GetUnit) then return; end

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------

local fnNil = function() return nil; end
local fnZero = function() return 0; end
local fnTrue = function() return true; end
local fnFalse = function() return false; end

local fnUnitRole = function(self)
	return (self.bHealer == true and "HEALER") or (self.bTank == true and "TANK") or "DAMAGER";
end

-----------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------

local UnitClassWrapper = {};
local UnitClassMetatable = {};

function UnitClassMetatable:__index(strKey)
	local proto = rawget(self, "__proto__");
	local field = proto and proto[strKey];

	if (type(field) ~= "function") then
		return field;
	else
		return function(obj, ...)
			if (obj == self) then
				return field(proto, ...);
			else
				return field(obj, ...);
			end
		end
	end
end

function UnitClassWrapper:New(unit, nIndex)
	local tUnit = nIndex and GroupLib.GetGroupMember(nIndex) or {};
	tUnit.__proto__ = unit;

	local self = setmetatable(tUnit, UnitClassMetatable);

	self.IsOnline = fnTrue;
	self.IsDisconnected = fnFalse;
	self.GetRole = fnUnitRole;
	self.IsRealUnit = fnTrue;

	if (unit:IsInYourGroup()) then
	end

	return self;
end

local WrapRealUnit = function(unit, nIndex)
	if (not unit) then return; end

	return UnitClassWrapper:New(unit, nIndex);
end

-----------------------------------------------------------------------------
-- GroupLib
-----------------------------------------------------------------------------

local GroupLibUnit = {
	GetGroupValue = fnZero,
	IsACharacter = fnTrue,
	GetTarget = fnNil,
	Inspect = fnNil,
	ShowHintArrow = fnNil,
	IsInYourGroup = fnTrue,
	IsValid = fnTrue,
	GetTargetMarker = fnNil,
	SetTargetMarker = fnNil,
	ClearTargetMarker = fnNil,
	IsTagged = fnFalse,
	IsTaggedByMe = fnTrue,
	IsSoftKill = fnTrue,
	GetCCStateTimeRemaining = fnZero,
	IsCasting = fnFalse,
	GetInterruptArmorValue = fnZero,
	GetId = fnZero,
	GetRole = fnUnitRole;
	IsRealUnit = fnFalse;
};

function GroupLibUnit:GetName()
	return self.strCharacterName;
end

function GroupLibUnit:IsOnline()
	return self.bIsOnline;
end

function GroupLibUnit:IsDisconnected()
	return self.bDisconnected;
end

function GroupLibUnit:GetHealth()
	return self.nHealth;
end

function GroupLibUnit:GetMaxHealth()
	return self.nHealthMax;
end

function GroupLibUnit:GetDispositionTo()
	return Unit.CodeEnumDisposition.Friendly;
end

function GroupLibUnit:GetClassId()
	return self.eClassId;
end

function GroupLibUnit:GetLevel()
	return self.nLevel;
end

function GroupLibUnit:GetRank()
	return Unit.CodeEnumRank.Minion;
end

function GroupLibUnit:GetBasicStats()
	return {
		nEffectiveLevel	= self.nEffectiveLevel,
		nHealth			= self.nHealth,
		nMaxHealth		= self.nHealthMax,
		nLevel			= self.nLevel,
		strName			= self.strCharacterName,
	};
end

function GroupLibUnit:GetBuffs()
	return {
		arBeneficial = {},
		arHarmful = {},
	};
end

function GroupLibUnit:IsDead()
	return self.bIsOnline and self.nHealth == 0;
end

function GroupLibUnit:GetShieldCapacity()
	return self.nShield;
end

function GroupLibUnit:GetShieldCapacityMax()
	return self.nShieldMax;
end

function GroupLibUnit:GetType()
	return "Player";
end

function GroupLibUnit:GetFaction()
	return GameLib.GetPlayerUnit():GetFaction();
end

local WrapGroupUnit = function(unit)
	if (not unit) then return; end

	return setmetatable(unit, { __index = GroupLibUnit });
end

-----------------------------------------------------------------------------
-- GetUnit
-----------------------------------------------------------------------------

function UnitFrameController:GetUnit(strUnit, nIndex)
	local unitPlayer = GameLib.GetPlayerUnit();

	if (unitPlayer and unitPlayer:IsValid()) then
		if (nIndex == nil) then
			-- Non-Party/Non-Raid
			if (strUnit == "Player") then
				return WrapRealUnit(unitPlayer);
			elseif (strUnit == "Target") then
				return WrapRealUnit(unitPlayer:GetTarget());
			elseif (strUnit == "TargetOfTarget") then
				return WrapRealUnit(unitPlayer:GetTargetOfTarget());
			elseif (strUnit == "TargetOfTargetOfTarget") then
				return WrapRealUnit(unitPlayer:GetTargetOfTarget() and unitPlayer:GetTargetOfTarget():GetTarget() or nil);
			elseif (strUnit == "Focus") then
				return WrapRealUnit(unitPlayer:GetAlternateTarget());
			elseif (strUnit == "FocusTarget") then
				return WrapRealUnit(unitPlayer:GetAlternateTarget() and unitPlayer:GetAlternateTarget():GetTarget() or nil);
			elseif (strUnit == "FocusTargetOfTarget") then
				return WrapRealUnit(unitPlayer:GetAlternateTarget() and unitPlayer:GetAlternateTarget():GetTargetOfTarget() or nil);
			end
		elseif (nIndex > 0) then
			-- Party/Raid
			local strUnit = strUnit..nIndex;
			return WrapRealUnit(GroupLib.GetUnitForGroupMember(nIndex), nIndex) or WrapGroupUnit(GroupLib.GetGroupMember(nIndex));
		end
	end
end
