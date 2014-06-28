--[[

	s:UI MiniMap Buttons

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local MiniMap = S:GetModule("MiniMap");
local M = MiniMap:CreateSubmodule("Buttons", "Gemini:Event-1.0");
local log;

-----------------------------------------------------------------------------
-- Button Container
-----------------------------------------------------------------------------

local CreateButtonContainer;
do
	local CreateButton = function(self, strName, strIcon, bLastButton)
		local tButton = {};
		tButton.strName = strName;
		tButton.wndMain = Apollo.LoadForm(self.xmlDoc, "SezzMiniMapButton", self.wndMain, tButton);
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

	-- Add Buttons
	self.tButtonContainer = CreateButtonContainer(self.xmlDoc);

	-----------------------------------------------------------------------------
	-- Inventory
	-----------------------------------------------------------------------------

	self.tButtonContainer:CreateButton("Inventory", "IconInventory");

	-----------------------------------------------------------------------------
	-- Datachron
	-----------------------------------------------------------------------------
	self.tButtonContainer:CreateButton("Datachron", "IconDatachron");
	if (g_wndDatachron) then
		self:UpdateDatachronButton();
	else
		self:RegisterEvent("Sezz_AddonAvailable", "UpdateDatachronButton");
	end

	-- Dash Indicator
	self.tButtonContainer:CreateButton("Dash", "IconDash2");

	-- Settings
	self.tButtonContainer:CreateButton("Settings", "IconSettings", true);

	-- Done
	self.xmlDoc = nil;
end

function M:UpdateDatachronButton(strEvent, strAddon)
	if (not strEvent or strAddon == "Datachron") then
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
--		g_wndDatachron:DestroyAllPixies();
--		g_wndDatachron:FindChild("Framing"):SetSprite("SezzUIBorder");
--		g_wndDatachron:FindChild("Framing"):SetSprite(nil);

		if (strEvent) then
			self:UnregisterEvent(strEvent);
		end
	end
end
