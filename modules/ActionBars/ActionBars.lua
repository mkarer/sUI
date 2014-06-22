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

	-- Main (LAS) Bar
	--ActionBarFrame.wndBar1:SetScale(0.8); -- Scaling
	-- Move Bar (Center)
	-- Remove Button Shadows

	-----------------------------------------------------------------------------
	-- Right Bar
	-- Contains 12x ActionBarItemSmall
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

	-- Re-Arrange Buttons
	for i, button in ipairs(barRight:GetChildren()) do
		local buttonPosition = (i - 1) * (buttonHeight + buttonPadding);
		button:Show(true);

		-- Button Container		
		S:RemoveArtwork(button);
		button:SetStyle("Picture", 1);
		button:SetSprite("PowerBarButtonBG");

		button:SetAnchorPoints(1, 0, 1, 0);
		button:SetAnchorOffsets(-buttonWidth, buttonPosition, 0, buttonPosition + buttonHeight);
--		button:SetAnchorOffsets(0, (i - 1) * buttonHeight, buttonWidth, i * buttonHeight);

		-- Button Control
		local buttonControl = button:FindChild("ActionBarBtn");
		buttonControl:RemoveStyleEx("DrawShortcutBottom"); -- Shit doesn't work!
		buttonControl:SetAnchorPoints(0, 0, 1, 1);
		buttonControl:SetAnchorOffsets(2, 2, -2, -2);

--		button:FindChild("ActionBarBtn"):SetScale(0.8)
	end
end

function M:StyleButtons()
	log:debug("***** BUTTOWNZ");

	self:StyleActionBarButtons(ActionBarFrame.wndBar1);
	self:StyleActionBarButtons(ActionBarFrame.wndBar2);
	self:StyleActionBarButtons(ActionBarFrame.wndBar3);
	self:StyleActionBarButtons(ActionBarFrame.wndMain:FindChild("Bar1ButtonSmallContainer:Buttons"));
end

function M:StyleActionBarButtons(bar)
	for _, f in pairs(bar:GetChildren()) do

		local buttonShadow = f:FindChild("Shadow");
		if (buttonShadow) then
	--		buttonShadow:Show(false);
	--		buttonShadow:SetSprite(nil);
		end

		local buttonCover = f:FindChild("Cover");
		if (buttonCover) then
	--		buttonCover:Show(false);
	--		buttonCover:SetSprite(nil);
		end

		local buttonInnate = f:FindChild("ActionBarInnate");
		if (buttonInnate) then
			log:debug(buttonInnate);
			buttonInnate:RemoveStyleEx("DrawShortcutBottom");
		end

		local buttonButton = f:FindChild("ActionBarBtn");
		if (buttonButton) then
			buttonButton:RemoveStyleEx("DrawShortcutBottom");
		end
	end
end
