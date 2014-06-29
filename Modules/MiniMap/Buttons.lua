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

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
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
		self:OnAddonAvailable(nil, "Datachron");
	else
		self:RegisterEvent("Sezz_AddonAvailable", "OnAddonAvailable");
	end

	-----------------------------------------------------------------------------
	-- Dash Indicator
	-----------------------------------------------------------------------------
	local tButtonDash = self.tButtonContainer:CreateButton("Dash", "IconDash2");
	tButtonDash.wndMain:SetTooltip("Dash Indicator (NYI)");

	tButtonDash.ToggleDash = function(self, wndHandler)
		local bDashEnabled = not wndHandler:IsChecked();

		Apollo.SetConsoleVariable("player.doubleTapToDash", bDashEnabled);
	end

	tButtonDash.UpdateIcon = function(self)
		local wndIcon = self.wndMain:FindChild("Icon");

		if (self.wndMain:ContainsMouse()) then
			-- Show "Disable Touble-Tap Dash" Icon
			wndIcon:SetSprite("IconBlock");
		elseif (self.wndMain:IsChecked()) then
			-- Dash is disabled, show X
			wndIcon:SetSprite("IconDashDisabled");
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

	tButtonDash.SetAmount = function(self, nAmount)
		self.nDashAmount = nAmount;
		self:UpdateIcon();
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
	tButtonSettings.wndMain:SetTooltip("s:UI "..Apollo.GetString("GuildRegistration_SettingsLabel"));

	tButtonSettings.ToggleConfiguration = function(self)
		S:ToggleConfiguration();
	end

	tButtonSettings.wndMain:AddEventHandler("ButtonSignal", "ToggleConfiguration", tButtonSettings);
	
	-----------------------------------------------------------------------------
	-- Done
	-----------------------------------------------------------------------------
	self.xmlDoc = nil;
end

-----------------------------------------------------------------------------

function M:OnAddonAvailable(strEvent, strAddon)
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

	-- Removing Artwork only works while logging in.
	-- I don't care currently...
--	g_wndDatachron:DestroyAllPixies();
--	g_wndDatachron:FindChild("Framing"):SetSprite("SezzUIBorder");
--	g_wndDatachron:FindChild("Framing"):SetSprite(nil);
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
	tButtonDash:SetAmount(nCurrent);
end
