--[[

	s:UI Toggle Sound Shortcut (CTRL-S)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("SoundToggle");
local log, fVolume;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:EnableProfile();
end

function M:OnEnable()
	Apollo.RegisterEventHandler("SystemKeyDown", "OnSystemKeyDown", self);

	if (not self.P.Volume) then
		self:RestoreProfile();
	end
end

function M:OnDisable()
	Apollo.RemoveEventHandler("SystemKeyDown", self);
end

function M:RestoreProfile()
	if (not self.P.Volume or self.P.Volume <= 0 or self.P.Volume > 1) then
		self.P.Volume = tonumber(Apollo.GetConsoleVariable("sound.volumeMaster")) or 1;
	end
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:ToggleSound()
	local fCurrentVolume = Apollo.GetConsoleVariable("sound.volumeMaster");

	if (fCurrentVolume == 0) then
		Print("Sound enabled.");
		Apollo.SetConsoleVariable("sound.volumeMaster", self.P.Volume);
	else
		Print("Sound disabled.");
		self.P.Volume = fCurrentVolume;
		Apollo.SetConsoleVariable("sound.volumeMaster", 0);
	end
end

function M:OnSystemKeyDown(nKey)
	if (nKey == 83 and Apollo.IsControlKeyDown()) then
		self:ToggleSound();
	end
end
