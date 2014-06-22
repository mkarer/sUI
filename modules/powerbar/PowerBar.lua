--[[

	s:UI Class Power Bar

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("PowerBar", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
	self.PowerButtons = {};
	self.PowerBars = {};
	self.DB = {
		["alwaysVisible"] = false,
		["buttons"] = 0,
		["bars"] = 0,
	};
end

function M:OnEnable()
	if (S.myClass ~= "Spellslinger") then return; end
	log:debug("%s enabled.", self:GetName());

	-- Create Anchor
	self.wndAnchor = Apollo.LoadForm(self.xmlDoc, "PowerBarAnchor", nil, self);
	self.wndAnchor:Show(false);

	-- Load Class Configuration
	self:ReloadConfiguration();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:ReloadConfiguration()
	-- Spellslinger Hardcoded

	-- Create Buttons
	self.DB.buttons = 4;
	local nButtonSize = 36;
	local nButtonPadding = 4;
	local nBarWidth = self.DB.buttons * nButtonSize + (self.DB.buttons - 1) * nButtonPadding;

	self.wndAnchor:SetAnchorOffsets(-nBarWidth / 2, 100, nBarWidth / 2, 200); -- Resize Anchor

	for i = 1, self.DB.buttons do
		local button = Apollo.LoadForm(self.xmlDoc, "PowerButton", self.wndAnchor, self);
		button:SetName("PowerButton"..i);

		if (i > 1) then
			local nAnchorOffsetLeft = (i - 1) * (nButtonSize + nButtonPadding);
			button:SetAnchorOffsets(nAnchorOffsetLeft, 0, nAnchorOffsetLeft + nButtonSize, nButtonSize);
		end

		self.PowerButtons[i] = button;
	end

	-- Create Bars
	self.DB.bars = 1;
	local nBarHeight = 2 + nButtonPadding;

	for i = 1, self.DB.bars do
		local bar = Apollo.LoadForm(self.xmlDoc, "PowerBar", self.wndAnchor, self);
		bar:SetName("PowerBar"..i);

		local nAnchorOffsetTop = nButtonSize + nButtonPadding;
		bar:SetAnchorOffsets(0, nAnchorOffsetTop, 0, nAnchorOffsetTop + nBarHeight);

		self.PowerBars[i] = bar;
	end

	-- Add Events
	-- Carbine uses OnUpdate, I'll use that too (although this propably sucks)
	Apollo.RegisterEventHandler("VarChange_FrameCount", "UpdatePower", self);

	-- Show/Hide
	if (not self.DB.alwaysVisible) then
		Apollo.RegisterEventHandler("UnitEnteredCombat", "ToggleVisibility", self);

		local unitPlayer = GameLib.GetPlayerUnit();
		if (unitPlayer) then
			self:ToggleVisibility(unitPlayer, unitPlayer:IsInCombat());
		end
	else
		self.wndAnchor:Show(true);
	end

	-- Disable Class Resources Addon
	self:DisableCarbineClassResources();
end

function M:UpdatePower()
	-- Spellslinger Hardcoded
	local unitPlayer = GameLib.GetPlayerUnit();
	if (not unitPlayer) then return; end

	local bInCombat = unitPlayer:IsInCombat();
	if (not bInCombat and not self.DB.alwaysVisible) then return; end

	-- Buttons
	local nResourceMax = unitPlayer:GetMaxResource(4);
	local nResourceCurrent = unitPlayer:GetResource(4);
	local nResourceMaxDiv4 = nResourceMax / 4;
	local bSurgeActive = GameLib.IsSpellSurgeActive();

	for i = 1, self.DB.buttons do
		local button = self.PowerButtons[i];
		local nPartialProgress = nResourceCurrent - (nResourceMaxDiv4 * (i - 1));
		local bThisBubbleFilled = nPartialProgress >= nResourceMaxDiv4;

		if (bThisBubbleFilled) then
			button:FindChild("Icon"):SetSprite("PowerBarButton"..(bSurgeActive and "Surged" or "Filled"));
		else
			button:FindChild("Icon"):SetSprite("PowerBarButtonEmpty");
		end
	end

	-- Bars
	local nManaMax = math.floor(unitPlayer:GetMaxMana());
	local nManaCurrent = math.floor(unitPlayer:GetMana());

	local bar = self.PowerBars[1];
	bar:FindChild("Progress"):SetMax(nManaMax);
	bar:FindChild("Progress"):SetProgress(nManaCurrent);
end

function M:ToggleVisibility(unit, bInCombat)
	local unitPlayer = GameLib.GetPlayerUnit();
	if (not unitPlayer or unit ~= unitPlayer) then return; end

	self.wndAnchor:Show(bInCombat, false, bInCombat and 0.2 or 0.5);
end

function M:DisableCarbineClassResources()
	local tClassResources = Apollo.GetAddon("ClassResources");
	self:Unhook(tClassResources, "OnCharacterCreated");

	if (tClassResources.wndMain) then
		Apollo.RemoveEventHandler("VarChange_FrameCount", tClassResources);
		Apollo.RemoveEventHandler("UnitEnteredCombat", tClassResources);
		tClassResources.wndMain:Show(false);
	else
		self:PostHook(tClassResources, "OnCharacterCreated", "DisableCarbineClassResources");
	end
end
