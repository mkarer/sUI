--[[

	s:UI Action Bars

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("ActionBars", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log, ActionBarFrame;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
--	self:RegisterEvent("OnCharacterCreated");

	ActionBarFrame = Apollo.GetAddon("ActionBarFrame");
	if (ActionBarFrame) then
--		self:RegisterEvent("ActionBarReady");
--		self:PostHook(ActionBarFrame, "InitializeBars", "StyleButtons");
		self:PostHook(ActionBarFrame, "InitializeBars", "ActionBarReady");
	else
		log:debug("Sorry, the default ActionBarFrame addon is disabled!");
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
-- Styling
-----------------------------------------------------------------------------

function M:ActionBarReady()
	self:StyleButtons();
	self:StyleActionBars();
end

function M:StyleActionBars()
	log:debug("***** StyleActionBars");

	-- Remove Artwork
	for _, f in pairs(ActionBarFrame.wndArt:GetChildren()) do
		S:RemoveArtwork(f);
	end

	-----------------------------------------------------------------------------
	-- Main/LAS Bar
	-- 8x ActionBarItemBig (ID: 1-8)
	-----------------------------------------------------------------------------
	--ActionBarFrame.wndBar1:SetScale(0.8); -- Scaling
	-- Move Bar (Center)
	-- Remove Button Shadows
	local barMain = ActionBarFrame.wndBar1;
	
	-- Style Buttons
	for i, button in ipairs(barMain:GetChildren()) do
		self:StyleButton(button);
	end

	-----------------------------------------------------------------------------
	-- Right Bar
	-- 12x ActionBarItemSmall (ID: 23-34)
	-----------------------------------------------------------------------------
	local barRight = ActionBarFrame.wndBar3;
	local buttonWidth = 36; --barRight:GetChildren()[1]:GetWidth(); -- 42
	local buttonHeight = 47; --barRight:GetChildren()[1]:GetHeight(); -- 53
	local buttonNum = 12;

	local buttonPadding = 3;
	local barHeight = buttonNum * buttonHeight + (buttonNum - 1) * buttonPadding;
	local barHeightOffset = math.ceil(barHeight / 2);

	barRight:SetAnchorOffsets(-buttonWidth, -barHeightOffset, 0, barHeightOffset); -- TODO: Somehow the bar anchors don't work, the bar width stays at 490px
	barRight:SetAnchorPoints(1, 0.5, 1, 0.5);

	-- Style & Re-Arrange Buttons
	for i, button in ipairs(barRight:GetChildren()) do
		self:StyleButton(button);

		local buttonPosition = (i - 1) * (buttonHeight + buttonPadding);
		button:Show(true);
		button:SetAnchorPoints(1, 0, 1, 0);
		button:SetAnchorOffsets(-buttonWidth, buttonPosition, 0, buttonPosition + buttonHeight);
--		button:SetAnchorOffsets(0, (i - 1) * buttonHeight, buttonWidth, i * buttonHeight);
	end

	-----------------------------------------------------------------------------
	-- Left Bar
	-- 12x ActionBarItemSmall (ID: 11-22)
	-----------------------------------------------------------------------------
	local barLeft = ActionBarFrame.wndBar2;

	-- Style Buttons
	for i, button in ipairs(barLeft:GetChildren()) do
		self:StyleButton(button);
	end
end

function M:StyleButton(button)
	-- Button Container		
	S:RemoveArtwork(button);
	button:SetStyle("Picture", 1);
--	button:SetSprite("ActionButton");
	button:SetSprite("PowerBarButtonBG");

	-- Button Control
	local buttonControl = button:FindChild("ActionBarBtn");
	buttonControl:RemoveStyleEx("DrawShortcutBottom"); -- Shit doesn't work!
	buttonControl:SetAnchorPoints(0, 0, 1, 1);
	buttonControl:SetAnchorOffsets(2, 2, -2, -2);

	-- Done
	return button;
end

function M:StyleButtons()
	log:debug("***** BUTTOWNZ");

	self:StyleActionBarButtons(ActionBarFrame.wndBar1);
	self:StyleActionBarButtons(ActionBarFrame.wndBar2);
	self:StyleActionBarButtons(ActionBarFrame.wndBar3);
	self:StyleActionBarButtons(ActionBarFrame.wndMain:FindChild("Bar1ButtonSmallContainer:Buttons"));
end

local function RemoveButtonSprite(button, sprite)
	local buttonSprite = button:FindChild(sprite);
	if (buttonSprite) then
		buttonSprite:Show(false);
		buttonSprite:SetSprite(nil);
	end
end

function M:StyleActionBarButtons(bar)
	for _, f in pairs(bar:GetChildren()) do
		RemoveButtonSprite(f, "Shadow");
		RemoveButtonSprite(f, "Cover");
		RemoveButtonSprite(f, "LockSprite");
		
		local buttonInnate = f:FindChild("ActionBarInnate");
		if (buttonInnate) then
			buttonInnate:RemoveStyleEx("DrawShortcutBottom");
		end

		local buttonButton = f:FindChild("ActionBarBtn");
		if (buttonButton) then
			buttonButton:RemoveStyleEx("DrawShortcutBottom");
		end
	end
end

-----------------------------------------------------------------------------
-- Custom Action Bar
-----------------------------------------------------------------------------
function M:SetupActionBars()
	log:debug("SetupActionBars");

	local buttonSize = 36;
	local buttonBorder = 2;
	local buttonPadding = 2;

	-----------------------------------------------------------------------------
	-- Main/LAS Bar
	-- Button IDs: 0 - 7
	-----------------------------------------------------------------------------
	-- ActionSetLib.GetCurrentActionSet() -- 1 bis 8
	-----------------------------------------------------------------------------
	local barMain = Apollo.LoadForm(self.xmlDoc, "SezzActionBar1ButtonContainer", nil, self);
	barMain:Show(true, true);
	barMain:DestroyChildren();

	local barPositionY = -200; -- Calculated from Bottom
	local barWidth = 8 * buttonSize + 7 * buttonPadding;
	local barHeight = buttonSize;
	local barWidthOffset = math.ceil(barWidth / 2);

	barMain:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barHeight);

	for i = 0, 7 do
		-- SezzActionBarButton UseBaseButtonArt=1 would enable our custom Button with Mouseover/Press Sprites, but hides everything else?
		local f = Apollo.LoadForm(self.xmlDoc, "SezzActionBarItem", barMain, self);
		f:SetName("SezzActionBar1Button"..(i + 1));

		local button = f:FindChild("SezzActionBarButton");
		local buttonPosition = i * (buttonSize + buttonPadding);

		button:SetContentId(i);
		f:SetAnchorOffsets(buttonPosition, 0, buttonPosition + buttonSize, buttonSize);

		-- Temporary Solution to show/hide Button Border
		-- Should be called whenever the button content changes
		if (button:GetContent().strIcon == "") then
			f:SetSprite(nil);
		else
			f:SetSprite("ActionButton");
		end

		if (i == 0) then log:debug(button); end
		if (i == 0) then log:debug(button:GetData()); end
		if (i == 0) then log:debug(button:GetContent()); end
	end
end

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

