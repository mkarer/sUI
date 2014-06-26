--[[

	s:UI Window Helper Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:GetWindowPosition(wndHandler)
	local nX, nY = wndHandler:GetPos();

	if (wndHandler:GetParent()) then
		local nParentX, nParentY = self:GetWindowPosition(wndHandler:GetParent());
		nX = nX + nParentX;
		nY = nY + nParentY;
	end
	
	return nX, nY;
end
