--[[

	s:UI Unit Frame Element: Cast Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:CastBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local UnitFrameController, log;

-- Lua API
local format = string.format;

-- Spell Icons
local tSpellIcons = {};

-----------------------------------------------------------------------------

local Update = function(self)
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local wndCastBar = self.tUnitFrame.wndCastBar;

	if (unit:IsCasting()) then
		local wndProgress = wndCastBar:FindChild("Progress");
		local wndIcon = wndCastBar:FindChild("Icon");
		local wndText = wndCastBar:FindChild("Text");
		local wndTime = wndCastBar:FindChild("Time");

		local nDuration, nElapsed = unit:GetCastDuration(), unit:GetCastElapsed();
		local strSpellName = unit:GetCastName();

		wndProgress:SetMax(nDuration);
		wndProgress:SetProgress(nElapsed);

		if (wndText) then
			wndText:SetText(strSpellName);
		end
		
		if (wndTime) then
			wndTime:SetText(format("%00.01f", (nDuration - nElapsed) / 1000));
		end

		if (wndIcon) then
			wndIcon:SetSprite(tSpellIcons[strSpellName]);
		end
		
		wndCastBar:Show(true, true);
	else
		wndCastBar:Show(false, true);
	end
end

local Enable = function(self)
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
	Apollo.RegisterEventHandler("VarChange_FrameCount", "Update", self);
end

local Disable = function(self, bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
	Apollo.RemoveEventHandler("VarChange_FrameCount", self);
	self.tUnitFrame.wndCastBar:Show(false, true);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.wndCastBar ~= nil);
	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	self = setmetatable({}, self);
	self.__index = self;

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;

	-- Reference Unit Frame
	self.tUnitFrame = tUnitFrame;

	-- Expose Methods
	self.Enable = Enable;
	self.Disable = Disable;
	self.Update = Update;

	-- Done
	self:Disable(true);

	return self;
end

-----------------------------------------------------------------------------
-- Spell Icons
-----------------------------------------------------------------------------

function Element:CacheSpellIcon(tEventArgs)
	if (tEventArgs.splCallingSpell and tEventArgs.splCallingSpell.GetName and tEventArgs.splCallingSpell.GetIcon) then
		local strName, strIcon = tEventArgs.splCallingSpell:GetName(), tEventArgs.splCallingSpell:GetIcon();

		if (strName and strIcon and not tSpellIcons[strName]) then
			log:debug("Cached: %s -> %s", strName, strIcon);
			tSpellIcons[strName] = strIcon;
		end
	end
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Element:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
	UnitFrameController:RegisterElement(MAJOR);

	-- Spell Icons
	Apollo.RegisterEventHandler("CombatLogDamage", "CacheSpellIcon", self);
	Apollo.RegisterEventHandler("CombatLogHeal", "CacheSpellIcon", self);
	Apollo.RegisterEventHandler("CombatLogCrafting", "CacheSpellIcon", self);
	Apollo.RegisterEventHandler("CombatLogMount", "CacheSpellIcon", self);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
