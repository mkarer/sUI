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
		buttonBorder = 2,
		buttonPadding = 2,
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
		self:RegisterMessage("PLAYER_LOGIN", "SetupActionBars");
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
	local buttonSize = 36;
	local buttonBorder = 2;
	local buttonPadding = 2;

	-----------------------------------------------------------------------------
	-- Main/LAS Bar
	-- Button IDs: 0 - 7
	-----------------------------------------------------------------------------
	local barMain, barWidth, barHeight = self:CreateActionBar("SezzActionBarMain", true, 0, 7);
	local barWidthOffset = math.ceil(barWidth / 2);
	local barPositionY = -200; -- Calculated from Bottom
	barMain:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barHeight);

	-- Update Events
	self.barMain = barMain;
	self:RegisterMessage("LIMITED_ACTION_SET_CHANGED", "UpdateActionBarButtonBorders") -- Stupid hack until AbilityBookChange works as expected
	self:UpdateActionBarButtonBorders();

	-----------------------------------------------------------------------------
	-- Bottom Bar (was Left Bar)
	-- ButtonIDs: 12 - 23
	-----------------------------------------------------------------------------
	local barBottom, barWidth, barHeight = self:CreateActionBar("SezzActionBarBottom", true, 12, 23);
	local barWidthOffset = math.ceil(barWidth / 2);
	local barPositionY = -160; -- Calculated from Bottom
	barBottom:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barHeight);

	-----------------------------------------------------------------------------
	-- Right Bar
	-- ButtonIDs: 24 - 35
	-----------------------------------------------------------------------------
	local barRight, barWidth, barHeight = self:CreateActionBar("SezzActionBarRight", true, 24, 35);
	local barWidthOffset = math.ceil(barWidth / 2);
	local barPositionY = -120; -- Calculated from Bottom
	barRight:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barHeight);
end

function M:CreateActionBar(barName, dirHorizontal, buttonIdFrom, buttonIdTo)
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
	local bar = Apollo.LoadForm(self.xmlDoc, "SezzActionBarContainer", nil, self);
	bar:SetName(barName);
	bar:Show(true, true);

	-- Create Action Buttons
	local buttonIndex = 0;
	for i = buttonIdFrom, buttonIdTo do
		-- SezzActionBarButton UseBaseButtonArt would enable our custom Button with Mouseover/Press Sprites, but hides everything else?
		local f = Apollo.LoadForm(self.xmlDoc, buttonForm, bar, self);
		f:SetName(string.format("%sButton%d", barName, buttonIndex + 1));

		local button = f:FindChild("SezzActionBarButton");
		button:SetContentId(i);

		-- Update Position
		local buttonPosition = buttonIndex * (self.DB.buttonSize + self.DB.buttonPadding);
		if (dirHorizontal) then
			f:SetAnchorOffsets(buttonPosition, 0, buttonPosition + self.DB.buttonSize, self.DB.buttonSize);
		else
			f:SetAnchorOffsets(0, buttonPosition, self.DB.buttonSize, buttonPosition + self.DB.buttonSize);
		end

		-- Done, Increase Index
		buttonIndex = buttonIndex + 1;
	end

	-- Done
	return bar, barWidth, barHeight;
end

function M:UpdateActionBarButtonBorders()
	-- Update LAS Bar Background Sprite (Workaround)
	for _, f in pairs(self.barMain:GetChildren()) do
		local button = f:FindChild("SezzActionBarButton");

		if (button:GetContent().strIcon == "") then
			f:SetSprite(nil);
		else
			f:SetSprite("ActionButton");
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
