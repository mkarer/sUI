--[[

	s:UI Proc-/Cooldown-/Aura-Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("ProcBar");

-----------------------------------------------------------------------------

function M:CreateAnchor()
	local GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;

	local tAnchor = {
		Name			= "ProcBarAnchor",
		Class			= "Window",
		Picture			= false,
		Moveable		= false,
		Border			= false,
		Sizable			= false,
		IgnoreMouse		= true,
		Overlapped		= true,
		AnchorPoints	= { 0.5, 0.5, 0.5, 0.5 },
		AnchorOffsets	= { -200, 140, 200, 240 },
	}

	self.wndMain = GeminiGUI:Create(tAnchor):GetInstance();

	S:ApplyDebugBackdrop(self.wndMain)
end

-----------------------------------------------------------------------------
