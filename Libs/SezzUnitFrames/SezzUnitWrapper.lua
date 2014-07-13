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

local GroupLibUnit = {};

GroupLibUnit.GetName = function(self)
	return self.strCharacterName;
end

function GroupLibUnit:IsOnline()
	return self.bIsOnline;
end

function GroupLibUnit:IsDisconnected()
	return self.bDisconnected;
end

GroupLibUnit.GetHealth = function(self)
	return self.nHealth;
end

GroupLibUnit.GetTarget = fnNil;
GroupLibUnit.Inspect = fnNil;
GroupLibUnit.ShowHintArrow = fnNil;
GroupLibUnit.IsInYourGroup = fnTrue;

GroupLibUnit.GetMaxHealth = function(self)
	return self.nHealthMax;
end

GroupLibUnit.GetDispositionTo = function(self)
	return Unit.CodeEnumDisposition.Friendly;
end

GroupLibUnit.GetGroupValue = fnZero;
GroupLibUnit.IsACharacter = fnTrue;

GroupLibUnit.GetClassId = function(self)
	return self.eClassId;
end

GroupLibUnit.GetLevel = function(self)
	return self.nLevel;
end

GroupLibUnit.GetRank = function(self)
	return Unit.CodeEnumRank.Minion;
end

GroupLibUnit.GetBasicStats = function(self)
	return {
		nEffectiveLevel	= self.nEffectiveLevel,
		nHealth			= self.nHealth,
		nMaxHealth		= self.nHealthMax,
		nLevel			= self.nLevel,
		strName			= self.strCharacterName,
	};
end

GroupLibUnit.IsValid = fnTrue;

GroupLibUnit.GetBuffs = function(self)
	return {
		arBeneficial = {},
		arHarmful = {},
	};
end

GroupLibUnit.IsDead = function(self)
	return self.bIsOnline and self.nHealth > 0;
end

GroupLibUnit.GetShieldCapacity = function(self)
	return self.nShield;
end

GroupLibUnit.GetShieldCapacityMax = function(self)
	return self.nShieldMax;
end

GroupLibUnit.GetType = function(self)
	return "Player";
end

GroupLibUnit.GetTargetMarker = fnNil;
GroupLibUnit.SetTargetMarker = fnNil;
GroupLibUnit.ClearTargetMarker = fnNil;

GroupLibUnit.GetFaction = function()
	return GameLib.GetPlayerUnit():GetFaction();
end

GroupLibUnit.GetId = fnZero;

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
