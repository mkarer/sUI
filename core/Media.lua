 --[[

	s:UI Media-related Stuff

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:RemoveArtwork(f)
	f:DestroyAllPixies();
	f:SetSprite(nil);
end

function S:ApplyDebugBackdrop(f)
	f:SetSprite("UI_BK3_Holo_InsetSimple");
	f:SetStyle("Picture", 1);
end
