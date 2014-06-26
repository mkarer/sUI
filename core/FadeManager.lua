--[[

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	Core Animations

--]]

require "Apollo";
require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

local FadeManager = {};

function FadeManager:FadeIn(f)
	f:SetOpacity(1, 4);
end

function FadeManager:FadeOut(f)
	f:SetOpacity(0, 2);
end

function S:Test_EnableMouseOverFade(f)
	f:AddEventHandler("MouseEnter", "FadeIn", FadeManager);
	f:AddEventHandler("MouseExit", "FadeOut", FadeManager);
	f:SetOpacity(0, 100);
end
