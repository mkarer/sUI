--[[

	s:UI Unit Frame Tags

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesLayout = S:GetModule("UnitFramesCore"):GetModule("Layout");

-- Lua API
local format, modf, select, floor, upper, gsub, ceil, len = string.format, math.modf, select, math.floor, string.upper, string.gsub, math.ceil, string.len;

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------

local ShortNumber = function(nValue)
	if (nValue >= 1e6) then
		return (gsub(format("%.2fm", nValue / 1e6), "%.?0+([km])$", "%1"));
	elseif (nValue >= 1e4) then
		return (gsub(format("%.1fk", nValue / 1e3), "%.?0+([km])$", "%1"));
	else
		return nValue;
	end
end

local UnitIsFriend = function(unit)
	local unitPlayer = GameLib.GetPlayerUnit();
	return (unit == unitPlayer or unit:GetDispositionTo(unitPlayer) == Unit.CodeEnumDisposition.Friendly);
end

local WrapAML = function(strTag, strText, strColor, strAlign)
	return format('<%s Font="CRB_Pixel_O" Align="%s" TextColor="%s">%s</%s>', strTag, strAlign or "Left", strColor or "ffffffff", strText, strTag);
end

local UnitStatus = function(unit)
	if (unit:IsDead()) then
		return '<P Font="CRB_Pixel_O" Align="Right" TextColor="ffff7f7f">DEAD</P>';
	elseif (unit:IsDisconnected() or not unit:IsOnline()) then
		return '<P Font="CRB_Pixel_O" Align="Right" TextColor="ffff7f7f">OFFLINE</P>';
--	elseif (not unit:IsRealUnit()) then
--		return '<P Font="CRB_Pixel_O" Align="Right" TextColor="ffcccccc">OUT OF RANGE</P>';
	end
end

local function UTF8Sub(string, i, dots)
	if string then
	local bytes = string:len()
	if bytes <= i then
		return string
	else
		local len, pos = 0, 1
		while pos <= bytes do
			len = len + 1
			local c = string:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == i then break end
		end
		if len == i and pos <= bytes then
			return string:sub(1, pos - 1)..(dots and '..' or '')
		else
			return string
		end
	end
	end
end

-----------------------------------------------------------------------------
-- Custom Tags
-----------------------------------------------------------------------------

function UnitFramesLayout:RegisterTags()

	self.tUnitFrameController.Tags.Methods["Sezz:Role"] = function(unit)
		local strRole = unit:GetRole();

		if (strRole) then
			if (strRole == "TANK") then
				return '<T Font="CRB_Pixel_O" TextColor="ff900000"> T</T>';
			elseif (strRole == "HEALER") then
				return '<T Font="CRB_Pixel_O" TextColor="ff009000"> H</T>';
			end
		end
	end

	self.tUnitFrameController.Tags.Methods["Sezz:HP"] = function(unit)
		-- Default HP
		local strStatus = UnitStatus(unit);
		if (strStatus) then
			return strStatus;
		else
			local nCurrentHealth, nMaxHealth = unit:GetHealth(), unit:GetMaxHealth();
			if (not nCurrentHealth or not nMaxHealth or (nCurrentHealth == 0 and nMaxHealth == 0)) then return; end

			-- ? UnitCanAttack//not UnitIsFriend
			if (UnitIsFriend(unit) and unit:IsACharacter()) then
				-- Unit is friendly and a Player
				-- HP Style: [CURHP]-[LOSTHP]
				if (nCurrentHealth ~= nMaxHealth) then
					return WrapAML("P", ShortNumber(nCurrentHealth)..WrapAML("T", "-"..ShortNumber(nMaxHealth - nCurrentHealth), "ffff7f7f", "Right"), "ffffffff", "Right");
				else
					return WrapAML("P", ShortNumber(nMaxHealth), nil, "Right");
				end
			else
				-- Unit is no player or an enemy
				-- HP Style: [CURHP]/[MAXHP] [HP%]
				if (nCurrentHealth ~= nMaxHealth) then
					return WrapAML("P", WrapAML("T", ShortNumber(nCurrentHealth), "ffff9000", "Right").."/"..ShortNumber(nMaxHealth)..WrapAML("T", " "..ceil(nCurrentHealth / (nMaxHealth * 0.01)).."%", "ffff9000", "Right"), nil, "Right");
				else
					return WrapAML("P", ShortNumber(nCurrentHealth)..WrapAML("T", " "..ceil(nCurrentHealth / (nMaxHealth * 0.01)).."%", "ffff9000", "Right"), nil, "Right");
				end
			end
		end
	end

	self.tUnitFrameController.Tags.Methods["Sezz:HPMinimalParty"] = function(unit)
		-- Minimalistic HP (for Group/Pet) [CURHP]-[LOSTHP]
		local strStatus = UnitStatus(unit);
		if (strStatus) then
			return strStatus;
		else
			local nCurrentHealth, nMaxHealth = unit:GetHealth(), unit:GetMaxHealth();
			if (not nCurrentHealth or not nMaxHealth or (nCurrentHealth == 0 and nMaxHealth == 0)) then return; end

			if (nCurrentHealth ~= nMaxHealth) then
				return WrapAML("P", ShortNumber(nCurrentHealth)..WrapAML("T", "-"..ShortNumber(nMaxHealth - nCurrentHealth), "ffff7f7f", "Right"), "ffffffff", "Right");
			else
				return WrapAML("P", ShortNumber(nMaxHealth), nil, "Right");
			end

			return (nCurrentHealth ~= nMaxHealth and ShortNumber(nCurrentHealth).."|cffff7f7f-"..ShortNumber(nMaxHealth - nCurrentHealth).."|r") or ShortNumber(nMaxHealth);
		end
	end

	self.tUnitFrameController.Tags.Methods["Sezz:HPMinimal"] = function(unit)
		-- Minimalistic HP - Lost HP for Players, % for Non-Players
		local strStatus = UnitStatus(unit);
		if (strStatus) then
			return strStatus;
		else
			local nCurrentHealth, nMaxHealth = unit:GetHealth(), unit:GetMaxHealth();
			if (not nCurrentHealth or not nMaxHealth or (nCurrentHealth == 0 and nMaxHealth == 0)) then return; end

			if (nCurrentHealth ~= nMaxHealth) then
				if (UnitIsFriend(unit)) then
					return WrapAML("P", "-"..ShortNumber(nMaxHealth - nCurrentHealth), "ffff7f7f", "Right");
				else
					return WrapAML("P", ceil(nCurrentHealth / (nMaxHealth * 0.01)).."%", "ffff9000", "Right");
				end
			end
		end
	end

	self.tUnitFrameController.Tags.Events["Sezz:RaidName"] = self.tUnitFrameController.Tags.Events["Name"];
	self.tUnitFrameController.Tags.Methods["Sezz:RaidName"] = function(unit)
		return UTF8Sub(unit:GetName(), 4, false);
	end

	self.tUnitFrameController.Tags.Methods["Sezz:RaidHP"] = function(unit)
		local strStatus = UnitStatus(unit);
		if (strStatus) then
			return strStatus;
		else
			local nCurrentHealth, nMaxHealth, fHealthPercent = unit:GetHealth(), unit:GetMaxHealth(), 1;
			if (nCurrentHealth and nMaxHealth and nMaxHealth > 0 and nCurrentHealth ~= nMaxHealth) then
				fHealthPercent = nCurrentHealth / nMaxHealth;
			end

			if (fHealthPercent < .9) then
				return WrapAML("P", "-"..ShortNumber(nMaxHealth - nCurrentHealth), "ffff7f7f", "Right");
			else
				local strName = self.tUnitFrameController.Tags.Methods["TClassColor"](unit)..UTF8Sub(unit:GetName(), 4, false)..self.tUnitFrameController.Tags.Methods["TClose"](unit);
				return WrapAML("P", strName, nil, "Right");
			end
		end
	end
end
