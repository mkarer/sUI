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
local log;

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
end

function AuraControl:Destroy()
	-- We can't reuse windows (right?), so we have to self-destruct ;)
	-- Remove Timers, Destroy windows
end

function AuraControl:Update()
	-- Update Timer + Count
end

function AuraControl:UpdateDuration(fDuration)
end

function AuraControl:UpdateCount(nCount)
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

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function AuraControl:New(wndParent, tAuraData, tWindow)
	-- tWindow: GeminiGUI window prototype
	self = setmetatable({}, { __index = AuraControl });

	-- Initialize Properties
	self.fDuration = 0;
	self.nCount = 0;
	self.tAura = tAuraData;

	-- Create Aura Window
	local wndMain = tUserDataWrapper:New(tWindow:GetInstance(self, wndParent));
	self.wndMain = wndMain;

	-- Update Icon Sprite
	local wndIcon = wndMain:FindChild("Icon");
	self.wndIcon = wndIcon;
	wndIcon:SetSprite(tAuraData.splEffect:GetIcon());

	-- Create Tooltip
	self:UpdateTooltip();

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
end

function AuraControl:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(AuraControl, MAJOR, MINOR, { "Gemini:Logging-1.2" });
