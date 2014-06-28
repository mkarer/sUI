--[[

	s:UI Core Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:GetClassName(classId)
	for k, v in pairs(GameLib.CodeEnumClass) do
		if (classId == v) then
			return k;
		end
	end

	return "Unknown";
end

-----------------------------------------------------------------------------
-- Table Utilities
-----------------------------------------------------------------------------

function S:Clone(t)
	if (type(t) ~= "table") then
		return t;
	end

	local mt = getmetatable(t);
	local res = {};

	for k, v in pairs(t) do
		if (type(v) == "table") then
			v = self:Clone(v);
		end

		res[k] = v;
	end

	setmetatable(res, mt);
	return res;
end

function S:Combine(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v;
	end

	return t1;
end
