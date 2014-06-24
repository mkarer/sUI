--[[

	s:UI Action Bars

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("ActionBars", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log, ActionBarFrame;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();

	-- Configuration
	self.DB = {
		buttonSize = 36,
		buttonPadding = 2,
		barPadding = 2,
	};

	-- ActionBarFrame Hooks
	ActionBarFrame = Apollo.GetAddon("ActionBarFrame");
	if (ActionBarFrame) then
		self:PostHook(ActionBarFrame, "InitializeBars", "HideDefaultActionBars");
		self:PostHook(ActionBarFrame, "RedrawBarVisibility", "HideDefaultActionBars");
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	if (S.bCharacterLoaded) then
		self:SetupActionBars();
	else
		self:RegisterMessage("CHARACTER_LOADED", "SetupActionBars");
	end
end

-----------------------------------------------------------------------------
-- Carbine Action Bar
-----------------------------------------------------------------------------

function M:HideDefaultActionBars()
	-- Remove Artwork
	for _, f in pairs(ActionBarFrame.wndArt:GetChildren()) do
		S:RemoveArtwork(f);
	end

	-- Hide Bars
	ActionBarFrame.wndBar1:Show(false, true);
	ActionBarFrame.wndBar2:Show(false, true);
	ActionBarFrame.wndBar3:Show(false, true);
end

-----------------------------------------------------------------------------
-- Custom Action Bar
-----------------------------------------------------------------------------

function M:SetupActionBars()
	-----------------------------------------------------------------------------
	-- Main/LAS Bar
	-- Button IDs: 0 - 7
	-----------------------------------------------------------------------------
	local barMain = self:CreateActionBar("SezzActionBarMain", true, 0, 7);
	local barWidthOffset = math.ceil(barMain.Width / 2);
	local barPositionY = -200; -- Calculated from Bottom
	barMain.wndMain:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barMain.Height);

	-- Update Events
	self.barMain = barMain;
	self:RegisterMessage("LIMITED_ACTION_SET_CHANGED", "UpdateActionBarButtonBorders") -- Stupid hack until AbilityBookChange works as expected
	self:UpdateActionBarButtonBorders();

	-----------------------------------------------------------------------------
	-- Bottom Bar
	-- ButtonIDs: 12 - 23 (Left Bar)
	-----------------------------------------------------------------------------
	local barBottom = self:CreateActionBar("SezzActionBarBottom", true, 12, 23, true);
	local barWidthOffset = math.ceil(barBottom.Width / 2);
	local barPositionY = -160; -- Calculated from Bottom
	barBottom.wndMain:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barBottom.Height);
	self.barBottom = barBottom;

	-----------------------------------------------------------------------------
	-- Right Bar
	-- ButtonIDs: 24 - 35
	-----------------------------------------------------------------------------
	local barRight = self:CreateActionBar("SezzActionBarRight", false, 24, 35, true);
	local barHeightOffset = math.ceil(barRight.Height / 2);
	barRight.wndMain:SetAnchorOffsets(-self.DB.buttonSize - self.DB.buttonPadding, -barHeightOffset, -self.DB.buttonPadding, barHeightOffset);
	barRight.wndMain:SetAnchorPoints(1, 0.5, 1, 0.5);
	self.barRight = barRight;
end

function M:CreateActionBar(barName, dirHorizontal, buttonIdFrom, buttonIdTo, enableFading)
	-- Calculate Size
	local barWidth, barHeight;
	local buttonNum = buttonIdTo - buttonIdFrom + 1;
	local buttonForm = (buttonIdTo < 8 and "SezzActionBarItemLAS" or "SezzActionBarItem");

	if (dirHorizontal) then
		barWidth = buttonNum * self.DB.buttonSize + (buttonNum - 1) * self.DB.buttonPadding;
		barHeight = self.DB.buttonSize;
	else
		barWidth = self.DB.buttonSize;
		barHeight = buttonNum * self.DB.buttonSize + (buttonNum - 1) * self.DB.buttonPadding;
	end

	-- Create Button Container
	local barContainer = {};
	barContainer.Height = barHeight;
	barContainer.Width = barWidth;
	barContainer.wndMain = Apollo.LoadForm(self.xmlDoc, "SezzActionBarContainer", nil, barContainer);
	barContainer.wndMain:SetName(barName);
	barContainer.wndMain:Show(true, true);
	barContainer.Buttons = {};

	-- Bar Fading
	function barContainer:OnMouseEnter()
		self.wndMain:SetOpacity(1, 4);
	end

	function barContainer:OnMouseExit()
		self.wndMain:SetOpacity(0, 2);
	end

	if (enableFading) then
		barContainer.wndMain:AddEventHandler("MouseEnter", "OnMouseEnter", barContainer);
		barContainer.wndMain:AddEventHandler("MouseExit", "OnMouseExit", barContainer);
		barContainer.wndMain:SetOpacity(0, 100);
	end

	-- Create Action Buttons
	local buttonIndex = 0;
	for i = buttonIdFrom, buttonIdTo do
		-- SezzActionBarButton UseBaseButtonArt would enable our custom Button with Mouseover/Press Sprites, but hides everything else?
		local buttonContainer = {};
		buttonContainer.OnGenerateTooltip = self.OnGenerateTooltip;
		buttonContainer.wndMain = Apollo.LoadForm(self.xmlDoc, buttonForm, barContainer.wndMain, buttonContainer);
		buttonContainer.wndMain:SetName(string.format("%sButton%d", barName, buttonIndex + 1));
		buttonContainer.wndButton = buttonContainer.wndMain:FindChild("SezzActionBarButton");
		buttonContainer.wndButton:SetContentId(i);

		-- Bar Fading
		if (enableFading) then
			buttonContainer.wndMain:AddEventHandler("MouseEnter", "OnMouseEnter", barContainer);
			buttonContainer.wndMain:AddEventHandler("MouseExit", "OnMouseExit", barContainer);
		end

		-- Update Position
		local buttonPosition = buttonIndex * (self.DB.buttonSize + self.DB.buttonPadding);
		if (dirHorizontal) then
			buttonContainer.wndMain:SetAnchorOffsets(buttonPosition, 0, buttonPosition + self.DB.buttonSize, self.DB.buttonSize);
		else
			buttonContainer.wndMain:SetAnchorOffsets(0, buttonPosition, self.DB.buttonSize, buttonPosition + self.DB.buttonSize);
		end

		-- Done, Increase Index
		buttonIndex = buttonIndex + 1;
		barContainer.Buttons[buttonIndex] = buttonContainer;
	end

	-- Done
	return barContainer;
end

function M:UpdateActionBarButtonBorders()
	-- Update LAS Bar Background Sprite (Workaround)
	for i, buttonContainer in ipairs(self.barMain.Buttons) do
		if (not S.myLAS[i] or S.myLAS[i] == 0) then
			buttonContainer.wndMain:SetSprite(nil);
		else
			buttonContainer.wndMain:SetSprite("ActionButton");
		end
	end
end

-----------------------------------------------------------------------------
-- Tooltips
-- Stolen from ActionBarFrame.lua
-----------------------------------------------------------------------------

function M:OnGenerateTooltip(wndControl, wndHandler, eType, arg1, arg2)
	local xml = nil;
	if (eType == Tooltip.TooltipGenerateType_ItemInstance) then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {});
	elseif eType == Tooltip.TooltipGenerateType_ItemData then -- Doesn't need to compare to item equipped
		Tooltip.GetItemTooltipForm(self, wndControl, arg1, {});
	elseif (eType == Tooltip.TooltipGenerateType_GameCommand) then
		xml = XmlDoc.new();
		xml:AddLine(arg2);
		wndControl:SetTooltipDoc(xml);
	elseif (eType == Tooltip.TooltipGenerateType_Macro) then
		xml = XmlDoc.new();
		xml:AddLine(arg1);
		wndControl:SetTooltipDoc(xml);
	elseif (eType == Tooltip.TooltipGenerateType_Spell) then
		if (Tooltip ~= nil and Tooltip.GetSpellTooltipForm ~= nil) then
			Tooltip.GetSpellTooltipForm(self, wndControl, arg1);
		end
	elseif (eType == Tooltip.TooltipGenerateType_PetCommand) then
		xml = XmlDoc.new();
		xml:AddLine(arg2);
		wndControl:SetTooltipDoc(xml);
	end
end
