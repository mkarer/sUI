--[[

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	Core Animations

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

local FadeIn = function(self, wndHandler)
	local wndParent = wndHandler:GetParent();

	if (wndParent) then
		self:_FadeIn(wndParent);
	else
		if (wndHandler:IsEnabled()) then
			wndHandler:SetOpacity(1, 4);
		end
	end
end

local FadeOut = function(self, wndHandler)
	if (wndHandler:ContainsMouse()) then return; end
	local wndParent = wndHandler:GetParent();
	
	if (wndParent) then
		self:_FadeOut(wndParent);
	else
		if (wndHandler:IsEnabled()) then
			wndHandler:SetOpacity(0, 2);
		end
	end
end

function S:EnableMouseOverFade(wndHandler, tLuaEventHandler, isChild, bDontChangeOpacity)
	-- AddEventHandler sucks.
	tLuaEventHandler._FadeIn = FadeIn;
	tLuaEventHandler._FadeOut = FadeOut;

	wndHandler:AddEventHandler("MouseEnter", "_FadeIn", tLuaEventHandler);
	wndHandler:AddEventHandler("MouseExit", "_FadeOut", tLuaEventHandler);

	if (not isChild) then
		if (not bDontChangeOpacity) then
			wndHandler:SetOpacity(0, 100);
		end

		for _, wndChild in pairs(wndHandler:GetChildren()) do
			self:EnableMouseOverFade(wndChild, tLuaEventHandler, true);
		end
	end
end

function S:DisableMouseOverFade(wndHandler, tLuaEventHandler, isChild, bDontChangeOpacity)
	wndHandler:RemoveEventHandler("MouseEnter", "_FadeIn", tLuaEventHandler);
	wndHandler:RemoveEventHandler("MouseExit", "_FadeOut", tLuaEventHandler);

	if (not isChild) then
		if (not bDontChangeOpacity) then
			wndHandler:SetOpacity(1, 100);
		end

		for _, wndChild in pairs(wndHandler:GetChildren()) do
			self:DisableMouseOverFade(wndChild, tLuaEventHandler, true);
		end
	end
end
