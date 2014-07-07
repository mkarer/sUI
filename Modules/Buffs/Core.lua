--[[

	s:UI Buffs/Debuffs

	TODO: Buff Tooltips, Buff Canceling

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

	-- Create Container Windows
	local tBuffContainer = {
		Name			= "SezzBuffContainer",
		Picture			= false,
		Moveable		= false,
		Border			= false,
		Sizable			= false,
		IgnoreMouse		= true,
		AnchorPoints	= { 0.5, 1, 1, 1 },
		AnchorOffsets	= { 0, -323, -9, -272 },
	}

	local tDebuffContainer = S:Clone(tBuffContainer);
	tDebuffContainer.AnchorOffsets = { 0, -400, -9, -349 };

	-- Buffs
	self.tBuffs = GeminiGUI:Create(tBuffContainer);
	self.tBuffs.tChildren = {};
	self.wndBuffs = self.tBuffs:GetInstance();

	-- Debuffs
	self.tDebuffs = GeminiGUI:Create(tDebuffContainer);
	self.tDebuffs.tChildren = {};
	self.wndDebuffs = self.tDebuffs:GetInstance();

	-- Activate Auras Class
	if (S.bCharacterLoaded) then
		self:EnableAuras();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "EnableAuras");
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------

function M:EnableAuras()
	-- Auras Unit Updater
	local fnUpdatePlayerUnit = function(self)
		if (not self.unit or S.myCharacter ~= self.unit) then
			self:SetUnit(S.myCharacter);
		end
	end

	-- Initialize Auras
	self.tPlayerAuras = Auras:New(fnUpdatePlayerUnit);

	-- Buffs
	self.tPlayerAuras:RegisterCallback("OnAuraAdded", "OnAuraAdded", self);
	self.tPlayerAuras:RegisterCallback("OnAuraRemoved", "OnAuraRemoved", self);

	-- Enable
	self.tPlayerAuras:UpdateUnit();
	Apollo.RegisterEventHandler("PlayerChanged", "UpdateUnit", self.tPlayerAuras);
	Apollo.RegisterEventHandler("PlayerCreated", "UpdateUnit", self.tPlayerAuras);
end

-----------------------------------------------------------------------------

local tBuffPrototype = {
	WidgetType = "Window",
	AnchorPoints = { 0, 0, 0, 0 },
	AnchorOffsets = { 0, 0, 34, 51 },
	Children = {
		{
			Name = "Duration",
			Class = "Window",
			Text = "",
			TextColor = "ffffffff",
			Font = "CRB_Pixel_O", -- CRB_Interface9_O
			DT_VCENTER = true,
			DT_CENTER = true,
			DT_SINGLELINE = true,
			AutoScaleTextOff = true,
			AnchorPoints = { 0, 0, 1, 0 },
			AnchorOffsets = { -2, -2, 2, 19 },
			IgnoreMouse = true,
			Overlapped = true,
		}, {
			Name = "Border",
			Class = "Window",
			AnchorPoints = { 0, 1, 1, 1 },
			AnchorOffsets = { 0, -34, 0, 0 },
			Picture = true,
			BGColor = "33ffffff", --ff791104
			Sprite = "ClientSprites:WhiteFill",
			IgnoreMouse = true,
			Children = {
				{
					Name = "Background",
					BGColor = "ff000000",
					Sprite = "ClientSprites:WhiteFill",
					Class = "Window",
					Picture = true,
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 3, 3, -3, -3 },
					IgnoreMouse = false,
					Children = {
						{
							Name = "Icon",
							Class = "Window",
							Picture = true,
							AnchorPoints = { 0, 0, 1, 1 },
							AnchorOffsets = { 0, 0, 0, 0 },
							IgnoreMouse = false,
							Children = {
								{
									Name = "Count",
									Class = "Window",
									Text = "",
									TextColor = "ffffffff",
									Font = "CRB_Interface12_BO",
									DT_RIGHT = true,
									DT_BOTTOM = true,
									AnchorPoints = { 0, 0, 1, 1 },
									AnchorOffsets = { 0, 0, -2, 0 },
									IgnoreMouse = true,
								},
							},
						},
					},
				},
			},
		},
	},
};

local tDebuffPrototype = S:Clone(tBuffPrototype);
tDebuffPrototype.Children[2].BGColor = "ff791104";

function M:OnAuraAdded(tAura)
	local tCache = (tAura.bIsDebuff and self.tDebuffs or self.tBuffs);
	local wndContainer = (tAura.bIsDebuff and self.wndDebuffs or self.wndBuffs);

	if (not tCache.tChildren[tAura.idBuff]) then
		local tAuraControl = AuraControl:New(wndContainer, tAura, (tAura.bIsDebuff and tDebuffPrototype or tBuffPrototype));
		tCache.tChildren[tAura.idBuff] = tAuraControl;
		self:OrderAuras(wndContainer);
	end
end

function M:OnAuraRemoved(tAura)
	local tCache = (tAura.bIsDebuff and self.tDebuffs or self.tBuffs);
	local wndContainer = (tAura.bIsDebuff and self.wndDebuffs or self.wndBuffs);

	if (tCache.tChildren[tAura.idBuff]) then
		tCache.tChildren[tAura.idBuff]:Destroy()
		tCache.tChildren[tAura.idBuff] = nil;
		self:OrderAuras(wndContainer);
	end
end

-- Aura Sorting
local bAnchorLeft = false;
local nAuraSize = tBuffPrototype.AnchorOffsets[3];
local nAuraPadding = 4;

local TableSortAura = function(a, b)
	return (a.fTimeRemaining > b.fTimeRemaining);
end

function M:OrderAuras(wndParent)
	local tAuras = wndParent:GetChildren();

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
