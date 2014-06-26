--[[

	s:UI Action Bars

	Notes:

		Left Bar IDs: [ABar] 12-23
		Right Bar IDs: [ABar] 24-35
		Additional IDs: [ABar] 36-47 (unused by Carbine's ActionBarFrame)
		Vehicle Bar: [RMSBar] 0-5

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
		barPadding = 4,
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

	for _, f in pairs(ActionBarFrame.wndShadow:GetChildren()) do
		S:RemoveArtwork(f);
	end

	-- Hide Bars
	ActionBarFrame.wndBar1:Show(false, true);
	ActionBarFrame.wndBar2:Show(false, true);
	ActionBarFrame.wndBar3:Show(false, true);
	ActionBarFrame.wndMain:FindChild("Bar1ButtonSmallContainer"):Show(false, true);

	-- Move Bars
	self:RepositionUnstyledBars();
end

function M:RepositionUnstyledBars()
	-- Temporarly move stuff
	ActionBarFrame.wndMain:FindChild("PotionFlyout"):SetAnchorOffsets(317, -112, 409, 65)
end

-----------------------------------------------------------------------------
-- Custom Action Bar
-----------------------------------------------------------------------------

function M:SetupActionBars()
	-----------------------------------------------------------------------------
	-- Main/LAS Bar
	-- Button IDs: 0 - 7
	-----------------------------------------------------------------------------
	local barMain = self:CreateActionBar("SezzActionBarMain", "LAS", true, 0, 7, false, 30);
	local barWidthOffset = math.ceil(barMain.Width / 2);
	local barPositionY = -162; -- Calculated from Bottom
	barMain.wndMain:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barMain.Height);

	-- Update Events
	self.barMain = barMain;
	self:RegisterMessage("LIMITED_ACTION_SET_CHANGED", "UpdateActionBarButtonBorders") -- Stupid hack until AbilityBookChange works as expected
	self:UpdateActionBarButtonBorders();

	-----------------------------------------------------------------------------
	-- Bottom Bar
	-- ButtonIDs: 12 - 23 (Left Bar)
	-----------------------------------------------------------------------------
	local barBottomItems = {
		{ type = "GC", id = 18, menu = "Recall" }, -- Recall
		{ type = "GC", id = 26, menu = "Mount" }, -- Mount
		{ type = "A", id = 12 },
		{ type = "A", id = 13 },
		{ type = "A", id = 14 },
		{ type = "A", id = 15 },
		{ type = "A", id = 16 },
		{ type = "A", id = 17 },
		{ type = "A", id = 18 },
		{ type = "A", id = 19 },
		{ type = "A", id = 20 },
		{ type = "A", id = 21 },
		{ type = "A", id = 22 },
		{ type = "A", id = 23 },
		{ type = "GC", id = 27, menu = "Potion" }, -- Potion
	};

	local barBottom = self:CreateActionBar("SezzActionBarBottom", barBottomItems, true, nil, nil, true);
	local barWidthOffset = math.ceil(barBottom.Width / 2);
	local barPositionOffset = 6;
	barBottom.wndMain:SetAnchorOffsets(-barWidthOffset, -barBottom.Height - barPositionOffset, barWidthOffset, -barPositionOffset);
	self.barBottom = barBottom;

	-----------------------------------------------------------------------------
	-- Right Bar
	-- ButtonIDs: 24 - 35
	-----------------------------------------------------------------------------
	local barRight = self:CreateActionBar("SezzActionBarRight", "A", false, 24, 35, true);
	local barHeightOffset = math.ceil(barRight.Height / 2);
	barRight.wndMain:SetAnchorOffsets(-barRight.Width, -barHeightOffset, 0, barHeightOffset);
	barRight.wndMain:SetAnchorPoints(1, 0.5, 1, 0.5);
	self.barRight = barRight;

	-----------------------------------------------------------------------------
	-- Extra Bar
	-----------------------------------------------------------------------------
	local barExtraItems = {
		{ type = "LAS", id = 8 }, -- Gadget
		{ type = "LAS", id = 9, menu = "Path" }, -- Path Ability
		{ type = "GC", id = 2, menu = "Stance" }, -- Stance (Innate Ability)
	};

	local barExtra = self:CreateActionBar("SezzActionBarGadget", barExtraItems, true, nil, nil, false, 30);
	local barPositionY = -162;
	barExtra.wndMain:SetAnchorOffsets(-math.ceil(barMain.Width / 2) - barExtra.Width + self.DB.barPadding + self.DB.buttonPadding, barPositionY, -math.ceil(barMain.Width / 2) + self.DB.barPadding + self.DB.buttonPadding, barPositionY + barExtra.Height);
end

function M:CreateActionBar(barName, buttonType, dirHorizontal, buttonIdFrom, buttonIdTo, enableFading, buttonSize)
	-- Calculate Size
	local buttonSize = buttonSize or self.DB.buttonSize;
	local barWidth, barHeight, buttonNum, buttonData;

	if (type(buttonType) == "table") then
		buttonData = buttonType;
	else
		buttonData = {};
		for i = buttonIdFrom, buttonIdTo do
			table.insert(buttonData, { type = buttonType, id = i });
		end
	end
	buttonNum = #buttonData;

	-- Orientation
	if (dirHorizontal == nil) then
		dirHorizontal = true;
	end

	if (dirHorizontal) then
		barWidth = buttonNum * buttonSize + (buttonNum - 1) * self.DB.buttonPadding + 2 * self.DB.barPadding;
		barHeight = buttonSize + 2 * self.DB.barPadding;
	else
		barWidth = buttonSize + 2 * self.DB.barPadding;
		barHeight = buttonNum * buttonSize + (buttonNum - 1) * self.DB.buttonPadding + 2 * self.DB.barPadding;
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
	for i, buttonAttributes in ipairs(buttonData) do
		-- SezzActionBarButton UseBaseButtonArt would enable our custom Button with Mouseover/Press Sprites, but hides everything else?
		local buttonContainer = {};
		buttonContainer.OnGenerateTooltip = self.OnGenerateTooltip;
		buttonContainer.wndMain = Apollo.LoadForm(self.xmlDoc, "SezzActionBarItem"..buttonAttributes.type, barContainer.wndMain, buttonContainer);
		buttonContainer.wndMain:SetName(string.format("%sButton%d", barName, i));
		buttonContainer.wndButton = buttonContainer.wndMain:FindChild("SezzActionBarButton");
		buttonContainer.wndButton:SetContentId(buttonAttributes.id);

		-- Bar Fading
		if (enableFading) then
			buttonContainer.wndMain:AddEventHandler("MouseEnter", "OnMouseEnter", barContainer);
			buttonContainer.wndMain:AddEventHandler("MouseExit", "OnMouseExit", barContainer);
		end

		-- Update Position
		local buttonPosition = (i - 1) * (buttonSize + self.DB.buttonPadding);
		if (dirHorizontal) then
			buttonContainer.wndMain:SetAnchorOffsets(buttonPosition + self.DB.barPadding, self.DB.barPadding, buttonPosition + buttonSize + self.DB.barPadding, buttonSize + self.DB.barPadding);
		else
			buttonContainer.wndMain:SetAnchorOffsets(self.DB.barPadding, buttonPosition + self.DB.barPadding, buttonSize + self.DB.barPadding, buttonPosition + buttonSize + self.DB.barPadding);
		end
		
		-- Done, Increase Index
		table.insert(barContainer.Buttons, buttonContainer);
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
