--[[

	s:UI MiniMap Buttons

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local MiniMap = S:GetModule("MiniMap");
local M = MiniMap:CreateSubmodule("Buttons");
local log;

-----------------------------------------------------------------------------
-- Button Container
-----------------------------------------------------------------------------

local CreateButtonContainer;
do
	local CreateButton = function(self, strName, strIcon, bLastButton)
		local tButton = {};
		tButton.wndMain = Apollo.LoadForm(self.xmlDoc, "SezzMiniMapButton", self.wndMain, tButton);
		tButton.wndMain:SetName(string.format("SezzMiniMapButton%s", strName));
		tButton.wndMain:FindChild("Icon"):SetSprite(strIcon);

		-- Move Button
		local nSize = tButton.wndMain:GetWidth();
		if (bLastButton) then
			tButton.wndMain:SetAnchorPoints(1, 0, 1, 1);
			tButton.wndMain:SetAnchorOffsets(-nSize, 0, 0, 0);
		else
			local nPositionX = (#self.tButtons + 1) * (nSize + self.nButtonPadding);
			tButton.wndMain:SetAnchorOffsets(nPositionX, 0, nPositionX + nSize, 0);
		end

		-- Done
		table.insert(self.tButtons, tButton);
		return tButton;
	end

	CreateButtonContainer = function(xmlDoc)
		local tContainer = {};
		tContainer.wndMain = Apollo.LoadForm(xmlDoc, "SezzMiniMapButtonContainer", nil, tButtonContainer);
		tContainer.tButtons = {};
		tContainer.nButtonPadding = 7;
		tContainer.CreateButton = CreateButton;
		tContainer.xmlDoc = xmlDoc;

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
	local tButtonContainer = CreateButtonContainer(self.xmlDoc);

	-- Inventory
	tButtonContainer:CreateButton("Inventory", "IconInventory");

	-- Datachron
	local tButtonDatachron = tButtonContainer:CreateButton("Datachron", "IconDatachron");
--	local tDatachron = Apollo.GetAddon("Datachron");
--	tButtonDatachron:AddEventHandler("ButtonCheck", "OnRestoreDatachron", tDatachron);
--	tButtonDatachron:AddEventHandler("ButtonUncheck", "OnMinimizeDatachron", tDatachron);

	-- Dash Indicator
	tButtonContainer:CreateButton("Dash", "IconDash2");

	-- Settings
	tButtonContainer:CreateButton("Settings", "IconSettings", true);

	-- Remove XML Document
	self.xmlDoc = nil;
end

function M:CreateButton(strName, strIcon)
end
