--[[

	s:UI Toggle Sound Shortcut (CTRL-S)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("SoundToggle");
local log, fVolume;

local tTextOption = {
	strFontFace = "CRB_HeaderGigantic_O",
	fDuration = 1,
	fScale = 1,
	fExpand = 1,
	fVibrate = 0,
	fSpinAroundRadius = 0,
	fFadeInDuration = 0,
	fFadeOutDuration = 0,
	fVelocityDirection = 0,
	fVelocityMagnitude = 0,
	fAccelDirection = 0,
	fAccelMagnitude = 0,
	fEndHoldDuration = 0,
	eLocation = CombatFloater.CodeEnumFloaterLocation.Top,
	fOffsetDirection = 0,
	fOffset = -320,
	eCollisionMode = CombatFloater.CodeEnumFloaterCollisionMode.Horizontal,
	fExpandCollisionBoxWidth = 1,
	fExpandCollisionBoxHeight = 1,
	nColor = 0xFFD800,
	iUseDigitSpriteSet = nil,
	bUseScreenPos = true,
	bShowOnTop = true,
	fRotation = 0,
	fDelay = 0,
	nDigitSpriteSpacing = 0,
	arFrames= 	{
		[1] = { fTime = 0,		fScale = 1.5,	fAlpha = 0.8, },
		[2] = { fTime = 0.1,	fScale = 1,		fAlpha = 0.8, },
		[3] = { fTime = 1.1,	fScale = 1,		fAlpha = 0.8,	fVelocityDirection = 0, },
		[4] = { fTime = 1.3,	fScale = 1,		fAlpha = 0.0,	fVelocityDirection = 0, },
	},
};

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:EnableProfile();
end

function M:OnEnable()
	Apollo.RegisterEventHandler("SystemKeyDown", "OnSystemKeyDown", self);

	if (not self.DB.Volume) then
		self:RestoreProfile();
	end
end

function M:OnDisable()
	Apollo.RemoveEventHandler("SystemKeyDown", self);
end

function M:RestoreProfile()
	if (not self.DB.Volume or self.DB.Volume <= 0 or self.DB.Volume > 1) then
		self.DB.Volume = tonumber(Apollo.GetConsoleVariable("sound.volumeMaster")) or 1;
	end
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:ToggleSound()
	local fCurrentVolume = Apollo.GetConsoleVariable("sound.volumeMaster");

	local tParams = {
		unitTarget = GameLib.GetControlledUnit(),
		tTextOption = S:Clone(tTextOption),
	};

	if (fCurrentVolume == 0) then
		tParams.strText = "Sound enabled.";
		Apollo.SetConsoleVariable("sound.volumeMaster", self.DB.Volume);
	else
		tParams.strText = "Sound disabled.";
		self.DB.Volume = fCurrentVolume;
		Apollo.SetConsoleVariable("sound.volumeMaster", 0);
	end

	Event_FireGenericEvent("Float_RequestShowTextFloater", LuaEnumMessageType.SystemMessage, tParams);
end

function M:OnSystemKeyDown(nKey)
	if (nKey == 83 and Apollo.IsControlKeyDown()) then
		self:ToggleSound();
	end
end
