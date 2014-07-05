--[[

	s:UI Debugging Stuff

	Not needed for any module or the core itself.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

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
