--[[

	s:UI Buffs/Debuffs

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Buffs", "Gemini:Hook-1.0");
local log, GeminiGUI, Auras, AuraControl;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
	Auras = Apollo.GetPackage("Sezz:Auras-0.1").tPackage;
	AuraControl = Apollo.GetPackage("Sezz:Controls:Aura-0.1").tPackage;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self:WindowTest();

	if (S.bCharacterLoaded) then
		self:Auras_Init();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "Auras_Init");
	end

end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------

local tPlayerAuras;

function M:Auras_Init()
	local fnUpdatePlayerUnit = function(self)
		if (not self.unit or S.myCharacter ~= self.unit) then
			log:debug("XXXXXXXXXXXX update unit")
			self:SetUnit(S.myCharacter);
		end
	end


	Apollo.RegisterEventHandler("PlayerChanged", "UpdateUnit", Auras);

	tPlayerAuras = Auras:New(fnUpdatePlayerUnit);
	tPlayerAuras:RegisterCallback("OnAuraAdded", "OnBuffAdded", self);
	tPlayerAuras:RegisterCallback("OnAuraRemoved", "OnBuffRemoved", self);
	tPlayerAuras:Enable();
end

-----------------------------------------------------------------------------

local OnGenerateTooltip = function(self, wndControl, wndHandler, eType, arg1, arg2)
log:debug(wndControl)
log:debug(wndControl:IsMouseTarget())
	if (wndControl ~= wndHandler) then return; end

	local tAura = wndControl:GetData();	
	if (tAura and self.tBuffs.tChildren[tAura.idBuff]) then
--		Tooltip.GetSpellTooltipForm(self, self.tBuffs.tChildren[tAura.idBuff], tAura.splEffect, false)
--		Tooltip.GetBuffTooltipForm(self, self.tBuffs.tChildren[tAura.idBuff], tAura.splEffect, {bFutureSpell = false});
	end
end

local tAuraPrototype = {
	WidgetType = "Window",
	Picture = true,
	BGColor = "green",
	Sprite = "ClientSprites:WhiteFill",
	AnchorPoints = { 0, 0, 0, 0 },
	AnchorOffsets = { 0, 0, 34, 51 },
--	Events = {
--		GenerateTooltip = OnGenerateTooltip;
--	},
	Children = {
		{
			Name = "Duration",
			Text = "00:00",
			TextColor = "ffffffff",
			Font = "CRB_Pixel_O",
			DT_VCENTER = true,
			DT_CENTER = true,
			AnchorPoints = { 0, 0, 1, 0 },
			AnchorOffsets = { 0, 0, 0, 17 },
			IgnoreMouse = true,
	}, {
			Name = "Background",
			AnchorPoints = { 0, 1, 1, 1 },
			AnchorOffsets = { 0, -34, 0, 0 },
			Picture = true,
			BGColor = "black",
			Sprite = "ClientSprites:WhiteFill",
			Children = {
			IgnoreMouse = true,
				{
					Name = "Icon",
					Class = "Window",
					Picture = true,
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 3, 3, -3, -3 },
					IgnoreMouse = false,
				},
			},
		},
	},
};

local tAuraTemplate;

function M:WindowTest()
	local GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

	-- Setup the table definition for the window
	local tWindowDefinition = {
		Name			= "MyExampleWindow",
		Template		= "CRB_TooltipSimple",
		UseTemplateBG	= true,
		Picture			= true,
		Moveable		= true,
		Border			= true,
		Sizable			= true,
		AnchorPoints = { 0, 0, 0, 0 },
		AnchorOffsets = { 0, 50, 500, 201 },
	}

	-- Aura Container
	self.tBuffs = GeminiGUI:Create(tWindowDefinition);
	self.tBuffs.tChildren = {};
	self.wndBuffs = self.tBuffs:GetInstance();

	-- Aura Template
	tAuraTemplate = GeminiGUI:Create(tAuraPrototype);

	-- Add Sample Buf
--	tAuraTemplate:GetInstance(self, self.wndBuffs);
end

-- ToolTips.lua
local function GenerateBuffTooltipForm(luaCaller, wndParent, splSource, tFlags)
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

function M:OnBuffAdded(tAura)
	if (not self.tBuffs.tChildren[tAura.idBuff]) then
		local wndAura = tAuraTemplate:GetInstance(self, self.wndBuffs);

		local tAuraControl = AuraControl:New(self.wndBuffs, tAura, tAuraTemplate);

		-- Add GetBuffTooltip
		local game_wrapper = {}
		local game_wrapper_mt = {}

		function game_wrapper_mt:__index(key)
			local proto = rawget(self, "__proto__")
			local field = proto and proto[key]

			if type(field) ~= "function" then
				return field
			else
				return function (obj, ...)
					if obj == self then
						return field(proto, ...)
					else
						return field(obj, ...)
					end
				end
			end
		end

		function game_wrapper:new()
			return setmetatable({__proto__ = wndAura}, game_wrapper_mt)
		end

		local my_game = game_wrapper:new()
		function my_game:GetBuffTooltip()
			return self.strFlavorText;
		end

--		self.OnGenerateTooltip = OnGenerateTooltip;
		my_game.strFlavorText = tAura.splEffect:GetFlavor();



		my_game:FindChild("Icon"):SetSprite(tAura.splEffect:GetIcon());
--		my_game:FindChild("Icon"):AddEventHandler("GenerateTooltip", "OnGenerateTooltip", self);
		my_game:FindChild("Icon"):SetData(tAura);

		GenerateBuffTooltipForm(my_game:FindChild("Icon"), my_game, tAura.splEffect)

		self.tBuffs.tChildren[tAura.idBuff] = my_game;
		self:OrderBuffs();
	end
end

function M:OnBuffRemoved(tAura)
	if (self.tBuffs.tChildren[tAura.idBuff]) then
		self.tBuffs.tChildren[tAura.idBuff]:Destroy();
		self.tBuffs.tChildren[tAura.idBuff] = nil;
		self:OrderBuffs();
	end
end

-- Aura Sorting
local bAnchorLeft = false;
local nAuraSize = 34;
local nAuraPadding = 4;

local TableSortAura = function(a, b)
	return (a.fTimeRemaining > b.fTimeRemaining);
end

function M:OrderBuffs()
	local tAuras = self.wndBuffs:GetChildren();

	for i = 1, #tAuras do
		local wndAura = tAuras[i];
		local nPosX = (i - 1) * (nAuraSize + nAuraPadding);

		if (bAnchorLeft) then
			-- LTR
			wndAura:SetAnchorPoints(0, 0, 0, 0);
			wndAura:SetAnchorOffsets(nPosX, 0, nPosX + nAuraSize, 51);
		else
			-- RTL
			wndAura:SetAnchorPoints(1, 0, 1, 0);
			wndAura:SetAnchorOffsets(-nPosX - nAuraSize, 0, -nPosX, 51);
		end
	end
end
