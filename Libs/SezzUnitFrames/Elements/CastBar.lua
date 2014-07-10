--[[

	s:UI Unit Frame Element: Cast Bar

	TODO: Channeled casts should show a inversed bar (not possible because of API limitations? [Spell.CodeEnumCastMethod.Channeled])

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:CastBar-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController;

-- Lua API
local format = string.format;

-- Spell Icons
local tSpellIcons = {};

-----------------------------------------------------------------------------

function Element:Update()
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local wndCastBar = self.tUnitFrame.wndCastBar;
	local nVulnerabilityTime = unit:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability) or 0;

	if (nVulnerabilityTime > 0 or unit:ShouldShowCastBar()) then
		local wndProgress = wndCastBar:FindChild("Progress");
		local wndIcon = wndCastBar:FindChild("Icon");
		local wndText = wndCastBar:FindChild("Text");
		local wndTime = wndCastBar:FindChild("Time");

		local nDuration, nElapsed, strSpellName, strSpellIcon;

		if (nVulnerabilityTime > 0) then
			-- Vulnerability
			if (nVulnerabilityTime > self.nVulnerabilityTime) then
				-- New Vulnerability Effect
				nDuration = nVulnerabilityTime;
				self.nVulnerabilityStart = nVulnerabilityTime;
			else
				nDuration = self.nVulnerabilityStart;
			end

			strSpellName = "Vulnerability";
			nElapsed = nVulnerabilityTime;
			strSpellIcon = "CRB_ActionBarIconSprites:sprAS_TestIcon";

			self.nVulnerabilityTime = nVulnerabilityTime;
			wndProgress:SetBarColor(UnitFrameController:ColorArrayToHex(self.tUnitFrame.tColors.CastBar.Vulnerability));
		else
			-- Cast
			nDuration, nElapsed = unit:GetCastDuration(), unit:GetCastElapsed();
			strSpellName = unit:GetCastName();
			strSpellIcon = tSpellIcons[strSpellName];

			local arColor = (unit:GetInterruptArmorValue() ~= 0 and self.tUnitFrame.tColors.CastBar.Uninterruptable or self.tUnitFrame.tColors.CastBar.Normal);
			wndProgress:SetBarColor(UnitFrameController:ColorArrayToHex(arColor));
		end

		wndProgress:SetMax(nDuration);
		wndProgress:SetProgress(nElapsed);

		if (wndText) then
			wndText:SetText(strSpellName);
		end
		
		if (wndTime) then
			if (nVulnerabilityTime > 0) then
				wndTime:SetText(format("%00.01f", nElapsed));
			else
				wndTime:SetText(format("%00.01f", (nDuration - nElapsed) / 1000));
			end
		end

		if (wndIcon) then
			wndIcon:SetSprite(strSpellIcon);
		end
		
		wndCastBar:Show(true, true);
	else
		self.nVulnerabilityTime = 0;
		self.nVulnerabilityStart = 0;
		wndCastBar:Show(false, true);
	end
end

function Element:Enable()
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
	self.nVulnerabilityTime = 0;
	self.nVulnerabilityStart = 0;
	Apollo.RegisterEventHandler("NextFrame", "Update", self);
end

function Element:Disable(bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
	Apollo.RemoveEventHandler("NextFrame", self);
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

	local self = setmetatable({ tUnitFrame = tUnitFrame }, { __index = Element });

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;

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
