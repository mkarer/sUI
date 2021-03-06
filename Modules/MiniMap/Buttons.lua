--[[

	s:UI MiniMap Buttons

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local MiniMap = S:GetModule("MiniMap");
local M = MiniMap:CreateSubmodule("Buttons", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Button Container
-----------------------------------------------------------------------------

local CreateButtonContainer;
do
	local CreateButton = function(self, strName, strIcon, bLastButton, strTemplate)
		local tButton = {};
		tButton.strName = strName;
		tButton.wndMain = Apollo.LoadForm(self.xmlDoc, strTemplate or "SezzMiniMapButton", self.wndMain, tButton);
		tButton.wndMain:SetName(string.format("SezzMiniMapButton%s", strName));
		tButton.wndMain:FindChild("Icon"):SetSprite(strIcon);

		-- Move Button
		if (bLastButton) then
			tButton.wndMain:SetAnchorPoints(1, 0, 1, 1);
			tButton.wndMain:SetAnchorOffsets(-self.nButtonSize, 0, 0, 0);
		else
			local nPositionX = #self.tButtons * (self.nButtonSize + self.nButtonPadding);
			tButton.wndMain:SetAnchorOffsets(nPositionX, 0, nPositionX + self.nButtonSize, 0);
		end

		-- Done
		table.insert(self.tButtons, tButton);
		return tButton;
	end

	local GetButton = function(self, strName)
		for _, tButton in pairs(self.tButtons) do
			if (tButton.strName == strName) then
				return tButton;
			end
		end
	end

	CreateButtonContainer = function(xmlDoc)
		local tContainer = {};
		tContainer.wndMain = Apollo.LoadForm(xmlDoc, "SezzMiniMapButtonContainer", nil, tButtonContainer);
		tContainer.tButtons = {};
		tContainer.nButtonPadding = 7;
		tContainer.xmlDoc = xmlDoc;

		tContainer.CreateButton = CreateButton;
		tContainer.GetButton = GetButton;

		-- Find Button Size
		local nButtonSize = 30;
		for _, f in pairs(xmlDoc:ToTable()) do
			if (f.Name and f.Name == "SezzMiniMapButton") then
				nButtonSize = tonumber(f.RAnchorOffset) - tonumber(f.LAnchorOffset);
				break;
			end
		end

		tContainer.nButtonSize = nButtonSize;

		-- Move Container
		local nOffsetL, nOffsetT, nOffsetR, nOffsetB = tContainer.wndMain:GetAnchorOffsets();
		nOffsetL = nOffsetL + tContainer.nButtonPadding + tContainer.nButtonSize;
		tContainer.wndMain:SetAnchorOffsets(nOffsetL, nOffsetT, nOffsetR, nOffsetB);

		return tContainer;
	end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:ShowCallMissed()
	self.tButtonContainer:GetButton("Datachron").wndMain:FindChild("Pulse"):Show(true);
end

function M:HideCallMissed(event)
	self.tButtonContainer:GetButton("Datachron").wndMain:FindChild("Pulse"):Show(false);
end

function M:OnCharacterLoaded()
	if (self.tButtonContainer) then
		self.tButtonContainer:GetButton("Datachron").wndMain:FindChild("Pulse"):Show(S:HasPendingCalls());
	end
end

function M:OnDatachronDrawCallSystem(tDatachron, strNewState)
	self:OnCharacterLoaded();
end

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();

	local tDatachron = Apollo.GetAddon("Datachron");
	if (tDatachron) then
		self:PostHook(tDatachron, "DrawCallSystem", "OnDatachronDrawCallSystem");
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
	self.tButtonContainer = CreateButtonContainer(self.xmlDoc);

	-----------------------------------------------------------------------------
	-- Inventory
	-----------------------------------------------------------------------------

	local tButtonInventory = self.tButtonContainer:CreateButton("Inventory", "IconInventory");
	tButtonInventory.wndMain:SetTooltip(Apollo.GetString("InterfaceMenu_Inventory"));

	tButtonInventory.ToggleInventory = function(self, wndHandler)
		local tInventory = Apollo.GetAddon("Inventory");
		if (tInventory) then
			tInventory:OnToggleVisibility();
		end
	end

	tButtonInventory.wndMain:AddEventHandler("ButtonCheck", "ToggleInventory", tButtonInventory);
	tButtonInventory.wndMain:AddEventHandler("ButtonUncheck", "ToggleInventory", tButtonInventory);

	if (S:IsAddOnLoaded("Inventory")) then
		self:OnAddonAvailable(nil, "Inventory");
	else
		self:RegisterEvent("Sezz_AddonAvailable", "OnAddonAvailable");
	end

	self:RegisterEvent("ToggleInventory", "OnInventoryToggle");
	self:RegisterEvent("InterfaceMenu_ToggleInventory", "OnInventoryToggle");
	self:RegisterEvent("ToggleInventory", "OnInventoryToggle");

	-----------------------------------------------------------------------------
	-- Datachron
	-----------------------------------------------------------------------------
	self.tButtonContainer:CreateButton("Datachron", "IconDatachron");
	if (g_wndDatachron) then
		self:OnAddonAvailable(nil, "Datachron", Apollo.GetAddon("Datachron"));
	else
		self:RegisterEvent("Sezz_AddonAvailable", "OnAddonAvailable");
	end
	
	self:RegisterEvent("DatachronCallCleared", "HideCallMissed");
	self:RegisterEvent("StopTalkingCommDisplay", "HideCallMissed");
	self:RegisterEvent("DatachronCallIncoming", "ShowCallMissed");
	self:RegisterEvent("DatachronCallMissed", "ShowCallMissed");

	if (S.bCharacterLoaded) then
		self:OnAddonAvailable();
	else
		self:RegisterEvent("Sezz_CharacterLoaded", "OnCharacterLoaded");
	end
	
	-----------------------------------------------------------------------------
	-- Dash Indicator
	-----------------------------------------------------------------------------
	local tButtonDash = self.tButtonContainer:CreateButton("Dash", "IconDash2");

	tButtonDash.ToggleDash = function(self, wndHandler)
		local bDashEnabled = not wndHandler:IsChecked();

		Apollo.SetConsoleVariable("player.doubleTapToDash", bDashEnabled);
		self:UpdateTooltip();
	end

	tButtonDash.UpdateIcon = function(self)
		local wndIcon = self.wndMain:FindChild("Icon");

		if (self.wndMain:ContainsMouse()) then
			-- Show "Disable Touble-Tap Dash" Icon
			wndIcon:SetSprite("IconBlock");
--		elseif (self.wndMain:IsChecked()) then
--			-- Dash is disabled, show X
--			wndIcon:SetSprite("IconDashDisabled");
		else
			-- Show amount
			if (self.nDashAmount >= 0 and self.nDashAmount <= 2) then
				wndIcon:SetSprite("IconDash"..self.nDashAmount);
			else
				log:warn("Player can dash %d times - why?", self.nDashAmount);
				wndIcon:SetSprite("CRB_NameplateSprites:sprNp_Health_FillPurple");
			end
		end
	end

	tButtonDash.SetAmount = function(self, nAmount, nAmountMax)
		self.nDashAmount = nAmount;
		self.nDashAmountMax = nAmountMax;
		self:UpdateIcon();
		self:UpdateTooltip();
	end

	tButtonDash.UpdateTooltip = function(self)
		-- Stolen from HealthShieldBar.lua
		local strEvadeTooltop = Apollo.GetString(not self.wndMain:IsChecked() and "HealthBar_EvadeDoubleTapTooltip" or "HealthBar_EvadeKeyTooltip");
		local strDisplayTooltip = String_GetWeaselString(strEvadeTooltop, self.nDashAmount, self.nDashAmountMax);
		self.wndMain:SetTooltip(strDisplayTooltip);
	end

	-- Set Current State/Amount
	local bDashEnabled = Apollo.GetConsoleVariable("player.doubleTapToDash");
	tButtonDash.wndMain:SetCheck(not bDashEnabled);
	tButtonDash:SetAmount(S:GetDashAmount(true));
	self:RegisterEvent("Sezz_PlayerDashChanged", "OnDashChanged");

	-- Events
	tButtonDash.wndMain:AddEventHandler("ButtonCheck", "ToggleDash", tButtonDash);
	tButtonDash.wndMain:AddEventHandler("ButtonUncheck", "ToggleDash", tButtonDash);
	tButtonDash.wndMain:AddEventHandler("MouseEnter", "UpdateIcon", tButtonDash);
	tButtonDash.wndMain:AddEventHandler("MouseExit", "UpdateIcon", tButtonDash);

	-----------------------------------------------------------------------------
	-- Settings
	-----------------------------------------------------------------------------
	local tButtonSettings = self.tButtonContainer:CreateButton("Settings", "IconSettings", true, "SezzMiniMapButtonPush");
	tButtonSettings.wndMain:SetTooltip("s:UI");

	tButtonSettings.ToggleConfiguration = function(self)
		local tMenu = Apollo.GetPackage("Sezz:Controls:ContextMenu-0.1").tPackage:GetRootMenu();
		tMenu:Initialize(); -- Remove old data/windows/etc.
		tMenu:AddHeader("s:UI");
		tMenu:AddItems({
			-- One Level
			{
				Name = "Test1",
				Text = "Test 1",
				OnClick = { "ToggleConfiguration", S },
				Children = {
					{
						Name = "Test11",
						Text = "Test 1-1",
					},
					{
						Name = "Test12",
						Text = "Test 1-2",
					},
					{
						Name = "Test13",
						Text = "Test 1-3",
					},
				},
			},
			-- Multiple Levels
			{
				Name = "Test2",
				Text = "Test 2",
				OnClick = { "ToggleConfiguration", S },
				Children = {
					{
						Name = "Test21",
						Text = "Test 2-1",
						Children = {
							{ Name = "Test31", Text = "Test 3-1", Children = {
								{ Name = "Test41", Text = "Test 4-1", Children = {
									{ Name = "Test51", Text = "Test 5-1" },
									},
								},

								},
							},
						},
					},
					{
						Name = "Test22",
						Text = "Test 2-2",
					},
					{
						Name = "Test23",
						Text = "Test 2-3",
					},
				},
			},
			-- Nexus Meter
			{
				Name = "BtnNexusMeterToggle",
				Text = "Toggle Nexus Meter",
				OnClick = function() Apollo.GetAddon("NexusMeter"):SlashHandler("", "toggle"); end,
				Enabled = function() return (Apollo.GetAddon("NexusMeter") ~= nil); end
			},
			-- Settings
			{
				Name = "BtnSettings",
				Text = Apollo.GetString("GuildRegistration_SettingsLabel"),
				OnClick = { "ToggleConfiguration", S },
				CloseMenuOnClick = true,
			},
			{
			},
			{
				Name = "BtnReloadUI",
				Text = "Reload UI",
				OnClick = { "RequestReloadUI", _G },
			},
		});
		tMenu:Show();
	end

	tButtonSettings.wndMain:AddEventHandler("ButtonSignal", "ToggleConfiguration", tButtonSettings);
	
	-----------------------------------------------------------------------------
	-- Done
	-----------------------------------------------------------------------------
	self.xmlDoc = nil;
end

-----------------------------------------------------------------------------

function M:OnAddonAvailable(strEvent, strAddon, tAddon)
	if (strAddon == "Datachron") then
		self:UpdateDatachronButton();
	elseif (strAddon == "Inventory") then
		local tInventory = Apollo.GetAddon("Inventory");
		self:PostHook(tInventory, "OnToggleVisibility", "OnInventoryToggle");
		self:PostHook(tInventory, "OnInventoryClosed", "OnInventoryToggle");
	end
end

-----------------------------------------------------------------------------

function M:UpdateDatachronButton()
	local tButtonDatachron = self.tButtonContainer:GetButton("Datachron");

	tButtonDatachron.UpdateTooltip = function(self)
		if (self.wndMain:IsChecked()) then
			self.wndMain:SetTooltip(Apollo.GetString("CRB_Datachron_MinimizeBtn_Desc"));
		else
			self.wndMain:SetTooltip(Apollo.GetString("Datachron_Maximize"));
		end
	end

	tButtonDatachron.ToggleDatachron = function(self, wndHandler)
		g_wndDatachron:Show(wndHandler:IsChecked());
		self:UpdateTooltip();
	end

	tButtonDatachron.wndMain:AddEventHandler("ButtonCheck", "ToggleDatachron", tButtonDatachron);
	tButtonDatachron.wndMain:AddEventHandler("ButtonUncheck", "ToggleDatachron", tButtonDatachron);
	tButtonDatachron.wndMain:SetCheck(g_wndDatachron:IsVisible());
	tButtonDatachron:UpdateTooltip();

	Apollo.GetAddon("Datachron").wndMinimized:Show(false, false);

	g_wndDatachron:SetAnchorOffsets(-549, -322, -160, -18);
end

-----------------------------------------------------------------------------

function M:OnInventoryToggle()
	local tInventory = Apollo.GetAddon("Inventory");
	local bInventoryOpen = false;

	if (tInventory) then
		bInventoryOpen = tInventory.wndMain:IsShown();
	end

	local tButtonInventory = self.tButtonContainer:GetButton("Inventory");
	tButtonInventory.wndMain:SetCheck(bInventoryOpen);
end

-----------------------------------------------------------------------------


function M:OnDashChanged(event, nCurrent, nMax)
	local tButtonDash = self.tButtonContainer:GetButton("Dash");
	tButtonDash:SetAmount(nCurrent, nMax);
end
