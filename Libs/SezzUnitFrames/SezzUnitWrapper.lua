--[[

	s:UI Unit Wrapper

	Adds needed methods to GroupLib.GetGroupMember tables and also emulates this data for real units.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
if (UnitFrameController.GetUnit) then return; end

local fmod, byte, len = math.fmod, string.byte, string.len;
local tCache = {};

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

local function StringHash(strText)
	-- http://www.wowwiki.com/USERAPI_StringHash
	local nCounter = 1;
	local nLength = len(strText);

	for i = 1, nLength, 3 do 
		nCounter = fmod(nCounter * 8161, 4294967279) +  -- 2^32 - 17: Prime!
			(byte(strText, i) * 16776193) +
			((byte(strText, i + 1) or (nLength - i + 256)) * 8372226) +
			((byte(strText, i + 2) or (nLength - i + 256)) * 3932164);
	end

	return -fmod(nCounter, 4294967291); -- 2^32 - 5: Prime (and different from the prime in the loop)
end

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
	GetRole = fnUnitRole,
	IsRealUnit = fnFalse,
};

function GroupLibUnit:GetId()
	return self.nId;
end

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

function GroupLibUnit:IsMentoring()
	return self.bIsMentoring;
end

function GroupLibUnit:GetRaceId()
	return self.eRaceId;
end

function GroupLibUnit:GetPlayerPathType()
	return self.ePathType;
end

local WrapGroupUnit = function(unit)
	if (not unit) then return; end

	local tGroupUnit = setmetatable(unit, { __index = GroupLibUnit });
	tGroupUnit.nId = StringHash(tGroupUnit.strCharacterName);

	return tGroupUnit;
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
			local unit = GroupLib.GetUnitForGroupMember(nIndex) or GroupLib.GetGroupMember(nIndex) or nil;

			if (unit) then
				if (type(unit) == "table") then
					-- GetGroupMember
					if (tCache[strUnit] and not tCache[strUnit]:IsRealUnit()) then
						-- Update cached data
						tCache[strUnit].bUpdated = false;

						for k, v in pairs(unit) do
							if (type(v) ~= "table" and tCache[strUnit][k] ~= v) then
								-- ignore tMentoredBy...
--								S.Log:debug("%s - Updated %s from %s to %s", unit.strCharacterName, k, tostring(tCache[strUnit][k]), tostring(v));
								tCache[strUnit].bUpdated = true;
								tCache[strUnit][k] = v;

								if (k == "nLevel") then
									Event_FireGenericEvent("Sezz_GroupUnitLevelChanged", nIndex);
								end
							end
						end

						if (tCache[strUnit].bUpdated) then
--							S.Log:debug("Updated cached group unit data for "..unit.strCharacterName)
							Event_FireGenericEvent("Sezz_GroupUnitUpdated", nIndex);
						end
					else
						-- Unit changed (not cached or was a real unit)
--						S.Log:debug("New cached group unit "..unit.strCharacterName)
						tCache[strUnit] = WrapGroupUnit(unit);
					end

					return tCache[strUnit];
				else
					-- GetUnitForGroupMember
					if (not tCache[strUnit] or (tCache[strUnit] and tCache[strUnit]:GetId() ~= unit:GetId())) then
--						S.Log:debug("New cached real unit "..unit:GetName())
						tCache[strUnit] = WrapRealUnit(unit, nIndex);
					end

					tCache[strUnit].nMemberIdx = nIndex;
				end

				-- Return cached unit
				return tCache[strUnit];
			else
				-- Invalid unit
				tCache[strUnit] = nil;
			end
		end
	end
end
