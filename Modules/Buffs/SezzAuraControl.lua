--[[

	s:UI Aura Window

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:Aura-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local AuraControl = APkg and APkg.tPackage or {};
local GeminiGUI, GeminiTimer, log;

-- Lua API
local format, floor, mod = string.format, math.floor, math.mod;

-----------------------------------------------------------------------------
-- Tooltips
-----------------------------------------------------------------------------

local GenerateBuffTooltipForm = function(luaCaller, wndParent, splSource, tFlags)
	-- Stolen from ToolTips.lua (because it's only available after "ToolTips" is loaded)
	-- TODO: Remove and fetch it when it's finally available...

	-- Initial Bad Data Checks
	if splSource == nil then
		return
	end

	local wndTooltip = wndParent:LoadTooltipForm("ui\\Tooltips\\TooltipsForms.xml", "BuffTooltip_Base", luaCaller)
	wndTooltip:FindChild("NameString"):SetText(splSource:GetName())

    -- Dispellable
	local eSpellClass = splSource:GetClass()
	if eSpellClass == Spell.CodeEnumSpellClass.BuffDispellable or eSpellClass == Spell.CodeEnumSpellClass.DebuffDispellable then
		wndTooltip:FindChild("DispellableString"):SetText(Apollo.GetString("Tooltips_Dispellable"))
	else
		wndTooltip:FindChild("DispellableString"):SetText("")
	end

	-- Calculate width
	local nNameLeft, nNameTop, nNameRight, nNameBottom = wndTooltip:FindChild("NameString"):GetAnchorOffsets()
	local nNameWidth = Apollo.GetTextWidth("CRB_InterfaceLarge", splSource:GetName())
	local nDispelWidth = Apollo.GetTextWidth("CRB_InterfaceMedium", wndTooltip:FindChild("DispellableString"):GetText())
	local nOffset = math.max(0, nNameWidth + nDispelWidth + (nNameLeft * 4) - wndTooltip:FindChild("NameString"):GetWidth())

	-- Resize Tooltip width
	wndTooltip:SetAnchorOffsets(0, 0, wndTooltip:GetWidth() + nOffset, wndTooltip:GetHeight())

	-- General Description
	wndTooltip:FindChild("GeneralDescriptionString"):SetText(wndParent:GetBuffTooltip())
	wndTooltip:FindChild("GeneralDescriptionString"):SetHeightToContentHeight()

	-- Resize tooltip height
	wndTooltip:SetAnchorOffsets(0, 0, wndTooltip:GetWidth(), wndTooltip:GetHeight() + wndTooltip:FindChild("GeneralDescriptionString"):GetHeight())

	return wndTooltip
end

local GetBuffTooltip = function(self)
	return self.strBuffTooltip;
end

-----------------------------------------------------------------------------
-- Window Control Metatable
-----------------------------------------------------------------------------

local tUserDataWrapper = {};
local tUserDataMetatable = {};

function tUserDataMetatable:__index(strKey)
	local proto = rawget(self, "__proto__");
	local field = proto and proto[strKey];

	if (type(field) ~= "function") then
		return field;
	else
		return function(obj, ...)
			if (obj == self) then
				return field(proto, ...);
			else
				return field(obj, ...);
			end
		end
	end
end

function tUserDataWrapper:New(o)
	return setmetatable({__proto__ = o}, tUserDataMetatable);
end

-----------------------------------------------------------------------------

function AuraControl:Enable()
	-- Create/Enable Timer
	if (not self.tmrUpdater and not self.bAura) then
		self.tmrUpdater = self:ScheduleRepeatingTimer("UpdateTimeLeft", 0.1);
	end

	return self;
end

function AuraControl:Destroy()
	-- We can't reuse windows (right?), so we have to self-destruct ;)
	self:CancelTimer(self.tmrUpdater, true);
	self.wndIcon:RemoveEventHandler("MouseButtonUp", self);
	self.wndMain:Destroy();
	self = nil;
end

local TimeBreakDown = function(nSeconds)
    local nDays = floor(nSeconds / (60 * 60 * 24));
    local nHours = floor((nSeconds - (nDays * (60 * 60 * 24))) / (60 * 60));
    local nMinutes = floor((nSeconds - (nDays * (60 * 60 * 24)) - (nHours * (60 * 60))) / 60);
    local nSeconds = mod(nSeconds, 60);

    return nDays, nHours, nMinutes, nSeconds;
end

function AuraControl:UpdateDuration(fDuration)
	-- (float) fDuration: time left in seconds from unit:GetBuffs(), we need to convert this to milliseconds
	if (not self.bAura) then
		local nDuration = floor(fDuration * 1000);
		local nEndTime = GameLib.GetTickCount() + nDuration;

		if (not self.nEndTime or self.nEndTime ~= nEndTime) then
			if (self.nEndTime) then
				log:debug("%s endtimer changed from %d to %d", self.tAura.splEffect:GetName(), self.nEndTime or 0, nEndTime);
			end

			self.nEndTime = nEndTime;
			self:UpdateTimeLeft();
		end
	end
end

function AuraControl:UpdateTimeLeft()
	local nTimeLeft = floor((self.nEndTime - GameLib.GetTickCount()) / 1000);

	if (self.bAura or nTimeLeft < 0) then -- nTimeLeft < 0 = Carbine's Bug!
		self.wndDuration:SetText("");
	else
		local nDays, nHours, nMinutes, nSeconds = TimeBreakDown(nTimeLeft);

		if (nTimeLeft < 3600) then
			-- Less than 1h, [MM:SS]
			self.wndDuration:SetText(format("%02d:%02d", nMinutes, nSeconds));
		elseif (nTimeLeft >= 36000) then
			-- 10 hours or more, [HHh]
			self.wndDuration:SetText(format("%1dh", nHours));
		else
			-- from 1 to 9 hours, [HHh:MM]
			self.wndDuration:SetText(format("%1dh:%02d", nHours, nMinutes));
		end
	end
end

function AuraControl:UpdateCount(nCount)
	self.nCount = nCount;
	self.wndCount:SetText(nCount);
	self.wndCount:Show(nCount > 1, true);
end

function AuraControl:UpdateTooltip()
	if (not self.wndMain.GetBuffTooltip) then
		self.wndMain.GetBuffTooltip = GetBuffTooltip;
	end

	if (not self.wndMain.strBuffTooltip) then
		self.wndMain.strBuffTooltip = self.tAura.splEffect:GetFlavor();
	end

	GenerateBuffTooltipForm(self.wndIcon, self.wndMain, self.tAura.splEffect);
end

function AuraControl:CancelAura(wndHandler, wndControl, eMouseButton)
	if (eMouseButton == GameLib.CodeEnumInputMouse.Right) then
		log:debug("Cancel Aura: %s (ID: %d)", self.tAura.splEffect:GetName(), self.tAura.splEffect:GetId());
	end
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function AuraControl:New(wndParent, tAuraData, tWindowPrototype)
	-- tWindowPrototype: GeminiGUI window prototype
	self = setmetatable({}, { __index = AuraControl });

	-- Initialize Properties
	self.tAura = tAuraData;

	-- Create Aura Window
	local wndMain = tUserDataWrapper:New(GeminiGUI:Create(tWindowPrototype):GetInstance(self, wndParent));
	self.wndMain = wndMain;

	-- Update Icon Sprite
	local wndIcon = wndMain:FindChild("Icon");
	self.wndIcon = wndIcon;
	wndIcon:SetSprite(tAuraData.splEffect:GetIcon());

	-- Update Duration
	self.bAura = (tAuraData.fTimeRemaining == 0);
	self.wndDuration = wndMain:FindChild("Duration");
	self:UpdateDuration(tAuraData.fTimeRemaining);

	-- Update Stack Counter
	self.wndCount = wndMain:FindChild("Count");
	self:UpdateCount(tAuraData.nCount);

	-- Create Tooltip
	self:UpdateTooltip();

	-- Add Click Event (Cancel Aura)
	self.wndIcon:AddEventHandler("MouseButtonUp", "CancelAura", self);

	-- Return
	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function AuraControl:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
	Apollo.GetPackage("Gemini:Timer-1.0").tPackage:Embed(self);
end

function AuraControl:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(AuraControl, MAJOR, MINOR, { "Gemini:Logging-1.2", "Gemini:GUI-1.0", "Gemini:Timer-1.0" });
