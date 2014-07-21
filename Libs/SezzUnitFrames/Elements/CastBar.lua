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
local log, UnitFrameController;

-- Lua API
local format = string.format;

-- Spell Icons
local tSpellIcons = {};
local splVulnerability = GameLib.GetSpell(30334);
local strVulnerabilityIcon = splVulnerability:GetIcon();
local strVulnerabilityText = splVulnerability:GetName();

-----------------------------------------------------------------------------

function Element:Update()
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	local wndCastBarContainer = self.tUnitFrame.tControls.CastBarContainer;

	-- Vulnerability/Default Casts
	local nVulnerabilityTime = unit:GetCCStateTimeRemaining(Unit.CodeEnumCCState.Vulnerability) or 0;

	if (nVulnerabilityTime > 0 or unit:IsCasting() or self.tCurrentOpSpell) then
		local wndProgress	= self.tUnitFrame.tControls.CastBar;
		local wndIcon		= self.tUnitFrame.tControls.CastBarIcon;
		local wndText		= self.tUnitFrame.tControls.CastBarTextSpell;
		local wndTime		= self.tUnitFrame.tControls.CastBarTextDuration;

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

			strSpellName = strVulnerabilityText;
			nElapsed = nVulnerabilityTime;
			strSpellIcon = strVulnerabilityIcon;

			self.nVulnerabilityTime = nVulnerabilityTime;
			wndProgress:SetBarColor(UnitFrameController:ColorArrayToHex(self.tUnitFrame.tColors.CastBar.Vulnerability));
		else
			if (self.tCurrentOpSpell) then
				-- Charged Cast
				nElapsed = unit:GetCastElapsed();
				nDuration = nElapsed / (GameLib.GetSpellThresholdTimePrcntDone(self.tCurrentOpSpell.id) * 100) * 100; -- Not very exact, maybe Spell:GetChannelData() is more useful?
				strSpellName = self.tCurrentOpSpell.strName.." ["..self.tCurrentOpSpell.nCurrentTier.."/"..self.tCurrentOpSpell.nMaxTier.."]";
				strSpellIcon = tSpellIcons[self.tCurrentOpSpell.strName];
			else
				-- Cast
				nDuration, nElapsed = unit:GetCastDuration(), unit:GetCastElapsed();
				strSpellName = unit:GetCastName();
				strSpellIcon = tSpellIcons[strSpellName];
			end

			local arColor = (unit:GetInterruptArmorValue() ~= 0 and self.tUnitFrame.tColors.CastBar.Uninterruptable or self.tUnitFrame.tColors.CastBar.Normal);
			wndProgress:SetBarColor(UnitFrameController:ColorArrayToHex(arColor));
		end

		if (nDuration > 0) then
			wndProgress:SetMax(nDuration);
			wndProgress:SetProgress(nElapsed);
		else
			wndProgress:SetMax(1);
			wndProgress:SetProgress(1);
		end

		if (wndText) then
			wndText:SetText(strSpellName);
		end
		
		if (wndTime) then
			if (nVulnerabilityTime > 0) then
				wndTime:SetText(format("%00.01f", nElapsed));
			elseif (nDuration > 0 or unit:ShouldShowCastBar()) then
				local nTimeLeft = (nDuration - nElapsed);
				if (nTimeLeft > 0) then
					nTimeLeft = nTimeLeft / 1000;
				else
					nTimeLeft = 0;
				end
				
				wndTime:SetText(format("%00.01f", nTimeLeft));
			else
				wndTime:SetText();
			end
		end

		if (wndIcon) then
			wndIcon:SetSprite(strSpellIcon);
		end

		wndCastBarContainer:Show(true, true);
	else
		self.nVulnerabilityTime = 0;
		self.nVulnerabilityStart = 0;
		wndCastBarContainer:Show(false, true);
	end
end

function Element:OnStartSpellThreshold(idSpell, nMaxThresholds, eCastMethod)
	if (self.tCurrentOpSpell ~= nil and idSpell == self.tCurrentOpSpell.id) then return; end

	self.tCurrentOpSpell = {
		id = idSpell,
		nCurrentTier = 1,
		nMaxTier = nMaxThresholds,
		eCastMethod = eCastMethod,
		strName = GameLib.GetSpell(idSpell):GetName(),
	};

	self:OnUpdateSpellThreshold(idSpell, 1);
end

function Element:OnClearSpellThreshold(idSpell)
	if (self.tCurrentOpSpell ~= nil and idSpell ~= self.tCurrentOpSpell.id) then return; end

	self.tCurrentOpSpell = nil;
end

function Element:OnUpdateSpellThreshold(idSpell, nNewThreshold)
	if (self.tCurrentOpSpell == nil or idSpell ~= self.tCurrentOpSpell.id) then return; end

	self.tCurrentOpSpell.nCurrentTier = nNewThreshold;
end

function Element:Enable()
	-- Register Events
	if (self.bEnabled) then return; end

	self.bEnabled = true;
	self.nVulnerabilityTime = 0;
	self.nVulnerabilityStart = 0;
	Apollo.RegisterEventHandler("NextFrame", "Update", self);

	if (self.tUnitFrame.strUnit == "Player") then
		Apollo.RegisterEventHandler("StartSpellThreshold", 	"OnStartSpellThreshold", self);
		Apollo.RegisterEventHandler("ClearSpellThreshold", 	"OnClearSpellThreshold", self);
		Apollo.RegisterEventHandler("UpdateSpellThreshold", "OnUpdateSpellThreshold", self);
	end
end

function Element:Disable(bForce)
	-- Unregister Events
	if (not self.bEnabled and not bForce) then return; end

	self.bEnabled = false;
	Apollo.RemoveEventHandler("NextFrame", self);
	Apollo.RemoveEventHandler("StartSpellThreshold", self);
	Apollo.RemoveEventHandler("ClearSpellThreshold", self);
	Apollo.RemoveEventHandler("UpdateSpellThreshold", self);
	self.tUnitFrame.tControls.CastBarContainer:Show(false, true);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (tUnitFrame.tControls.CastBarContainer ~= nil and tUnitFrame.tControls.CastBar ~= nil);
--	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

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

function Element:CacheAbilityBookIcons()
	if (GameLib and GameLib.IsCharacterLoaded()) then
		for _, tAbility in ipairs(AbilityBook.GetAbilitiesList()) do
			if (tAbility.tTiers and tAbility.tTiers[1] and tAbility.tTiers[1].splObject) then
				tSpellIcons[tAbility.tTiers[1].strName] = tAbility.tTiers[1].splObject:GetIcon();
			end
		end

		Apollo.RemoveEventHandler("CharacterCreated", self);
	else
		Apollo.StartTimer("SezzUITimer_DelayedInitAbilityBook");
	end
end

function Element:CacheSpellIcon(tEventArgs)
	if (tEventArgs.splCallingSpell and tEventArgs.splCallingSpell.GetName and tEventArgs.splCallingSpell.GetIcon) then
		local strName, strIcon = tEventArgs.splCallingSpell:GetName(), tEventArgs.splCallingSpell:GetIcon();

		if (strName and strIcon and not tSpellIcons[strName]) then
--			log:debug("Cached: %s -> %s", strName, strIcon);
			tSpellIcons[strName] = strIcon;
		end
	end
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Element:OnLoad()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2") and Apollo.GetAddon("GeminiConsole") and Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	if (GeminiLogging) then
		log = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender ="GeminiConsole"
		});
	else
		log = setmetatable({}, { __index = function() return function(self, ...) local args = #{...}; if (args > 1) then Print(string.format(...)); elseif (args == 1) then Print(tostring(...)); end; end; end });
	end

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
	UnitFrameController:RegisterElement(MAJOR);

	-- Spell Icons
	Apollo.RegisterEventHandler("CombatLogDamage",		"CacheSpellIcon", self);
	Apollo.RegisterEventHandler("CombatLogHeal",		"CacheSpellIcon", self);
	Apollo.RegisterEventHandler("CombatLogCrafting",	"CacheSpellIcon", self);
	Apollo.RegisterEventHandler("CombatLogMount",		"CacheSpellIcon", self);

	Apollo.CreateTimer("SezzUITimer_DelayedInitAbilityBook", 0.10, false);
	Apollo.RegisterTimerHandler("SezzUITimer_DelayedInitAbilityBook", "CacheAbilityBookIcons", self);
	if (GameLib and GameLib.IsCharacterLoaded()) then
		self:CacheAbilityBookIcons();
	else
		Apollo.RegisterEventHandler("CharacterCreated", "CacheAbilityBookIcons", self);
	end
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.2" });
