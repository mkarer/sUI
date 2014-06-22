 --[[

	s:UI Media-related Stuff

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:RemoveArtwork(f)
	-- Destroy Pixies
	local i = 1;
	while (true) do
		local pixie = f:GetPixieInfo(i);
		if (pixie) then
			f:DestroyPixie(i);
			i = i + 1;
		else
			break;
		end
	end

	-- Unset Sprite
	f:SetSprite(nil);
end
