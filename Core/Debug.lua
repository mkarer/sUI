--[[

	s:UI Debugging Stuff

	Not needed for any module or the core itself.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-- Lua API
local tinsert, pairs, ipairs = table.insert, pairs, ipairs;

-----------------------------------------------------------------------------

function S:DumpAbility(strName, bCompleteDump)
	local tAbilities = AbilityBook.GetAbilitiesList();

	for _, tAbility in pairs(tAbilities) do
		if (tAbility.strName == strName) then
			S.Log:debug("ID: %d", tAbility.nId);
			S.Log:debug("Icon: %s", tAbility.tTiers[1].splObject:GetIcon());

			if (bCompleteDump) then
				S.Log:debug(tAbility);
			end

			return tAbility;
		end
	end
end

-----------------------------------------------------------------------------
-- Log Messages Queue
-----------------------------------------------------------------------------

local tLogQueue = {};

S.Log = setmetatable({}, { __index = function(t, k)
	return function(self, ...)
		if (not tLogQueue[k]) then
			tLogQueue[k] = {};
		end

		if (#{...} == 1 and type(...) == "table") then
			tinsert(tLogQueue[k], { S:Clone(...) });
		else
			tinsert(tLogQueue[k], {...});
		end
	end
end});

function S:FlushLogQueue()
	if (not tLogQueue) then return; end

	for strLogLevel, tQueuedMessages in pairs(tLogQueue) do
		for _, tData in ipairs(tQueuedMessages) do
			self.Log[strLogLevel](self.Log, unpack(tData));
		end
	end

	tLogQueue = nil;
end
