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
		barPadding = 4, -- Menu needs atleast 4!
	};
	self.tBars = {};
	self:EnableProfile();

	-- Action Bar Hooks
	ActionBarFrame = Apollo.GetAddon("ActionBarFrame");
	if (ActionBarFrame) then
		self:PostHook(ActionBarFrame, "InitializeBars", "HideDefaultActionBars");
		self:PostHook(ActionBarFrame, "RedrawBarVisibility", "HideDefaultActionBars");
	end

	-- System Menu
	self:RegisterAddonLoadedCallback("InterfaceMenuList", "EnableMainMenuFading");
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
-- Settings
-----------------------------------------------------------------------------

function M:RestoreProfile()
	if (S.myCharacter) then
		GameLib.SetShortcutMount(self.P.SelectedMount or 0);
		GameLib.SetShortcutPotion(self.P.SelectedPotion or 0);
		-- self:UnregisterMessage("CHARACTER_LOADED", "RestoreProfile");
	else
		-- self:RegisterMessage("CHARACTER_LOADED", "RestoreProfile");
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

function M:EnableMainMenuFading()
	-- The window is HUGE
	S:EnableMouseOverFade(Apollo.GetAddon("InterfaceMenuList").wndMain, Apollo.GetAddon("InterfaceMenuList"));
end

-----------------------------------------------------------------------------
-- Custom Action Bar
-----------------------------------------------------------------------------

function M:SetupActionBars()
	self:RestoreProfile(); -- TODO: RegisterMessage doesn't handle multiple handlers

	-----------------------------------------------------------------------------
	-- Main/LAS Bar
	-- Button IDs: 0 - 7
	-----------------------------------------------------------------------------
	local barMain = self:CreateActionBar("Main", "LAS", true, 0, 7, false, 30);
	local barWidthOffset = math.ceil(barMain.Width / 2);
	local barPositionY = -162; -- Calculated from Bottom
	barMain.wndMain:SetAnchorOffsets(-barWidthOffset, barPositionY, barWidthOffset, barPositionY + barMain.Height);
	self.tBars[barMain.strName] = barMain;

	-- Update Events
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

	local barBottom = self:CreateActionBar("Bottom", barBottomItems, true, nil, nil, true);
	local barWidthOffset = math.ceil(barBottom.Width / 2);
	local barPositionOffset = 6;
	barBottom.wndMain:SetAnchorOffsets(-barWidthOffset, -barBottom.Height - barPositionOffset, barWidthOffset, -barPositionOffset);
	self.tBars[barBottom.strName] = barBottom;

	-----------------------------------------------------------------------------
	-- Right Bar
	-- ButtonIDs: 24 - 35
	-----------------------------------------------------------------------------
	local barRight = self:CreateActionBar("Right", "A", false, 24, 35, true);
	local barHeightOffset = math.ceil(barRight.Height / 2);
	barRight.wndMain:SetAnchorOffsets(-barRight.Width, -barHeightOffset, 0, barHeightOffset);
	barRight.wndMain:SetAnchorPoints(1, 0.5, 1, 0.5);
	self.tBars[barRight.strName] = barRight;

	-----------------------------------------------------------------------------
	-- Extra Bar
	-----------------------------------------------------------------------------
	local barExtraItems = {
		{ type = "LAS", id = 8 }, -- Gadget
		{ type = "LAS", id = 9, menu = "Path" }, -- Path Ability
		{ type = "GC", id = 2, menu = "Stance" }, -- Stance (Innate Ability)
	};

	local barExtra = self:CreateActionBar("Extra", barExtraItems, true, nil, nil, false, 30);
	local barPositionY = -162;
	barExtra.wndMain:SetAnchorOffsets(-math.ceil(barMain.Width / 2) - barExtra.Width + self.DB.barPadding + self.DB.buttonPadding, barPositionY, -math.ceil(barMain.Width / 2) + self.DB.barPadding + self.DB.buttonPadding, barPositionY + barExtra.Height);
	self.tBars[barExtra.strName] = barExtra;
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
	barContainer.wndMain:SetName("SezzActionBar"..barName);
	barContainer.wndMain:Show(true, true);
	barContainer.strName = barName;
	barContainer.Buttons = {};

	-- Create Action Buttons
	local buttonIndex = 0;
	for i, buttonAttributes in ipairs(buttonData) do
		-- SezzActionBarButton UseBaseButtonArt would enable our custom Button with Mouseover/Press Sprites, but hides everything else?
		local buttonContainer = {};
		buttonContainer.Attributes = buttonAttributes;
		buttonContainer.OnGenerateTooltip = self.OnGenerateTooltip;
		buttonContainer.wndMain = Apollo.LoadForm(self.xmlDoc, "SezzActionBarItem"..buttonAttributes.type, barContainer.wndMain, buttonContainer);
		buttonContainer.wndMain:SetName(string.format("SezzActionBar%sButton%d", barName, i));
		buttonContainer.wndButton = buttonContainer.wndMain:FindChild("SezzActionBarButton");
		buttonContainer.wndButton:SetContentId(buttonAttributes.id);

		-- Enable Menu
		if (buttonAttributes.menu and dirHorizontal) then
			buttonContainer.wndMenuToggle = buttonContainer.wndMain:FindChild("MenuToggle");
			buttonContainer.wndMenuToggle:Show(true, true);

			buttonContainer.wndMenu = Apollo.LoadForm(self.xmlDoc, "ActionBarFlyout", nil, buttonContainer);
			buttonContainer.wndMenu:Show(false, true);

			buttonContainer.wndMenuToggle:AttachWindow(buttonContainer.wndMenu); -- Fixes CloseOnExternalClick, but introduces other (visual) problems, good for now.

			-- Close Menu Function
			function buttonContainer:CloseMenu()
				self.wndMenu:Show(false, true); -- Override fading applied by "Escapable"

				if (enableFading) then
					-- Check if other menus on the same bar are visible
					local bMenusVisible = false;
					for _, wndBarButtonContainer in pairs(barContainer.Buttons) do
						if (wndBarButtonContainer.wndMenu and wndBarButtonContainer.wndMenu:IsVisible()) then
							bMenusVisible = true;
							break;
						end
					end

					-- Enable fading if the last menu was closed
					if (not bMenusVisible) then
						S:EnableMouseOverFade(barContainer.wndMain, barContainer, false, true);

						-- Fade out when cursor is somewhere else (pressed Esc to close close the menus)
						if (not barContainer.wndMain:ContainsMouse()) then
							barContainer:_FadeOut(barContainer.wndMain);
						end
					end
				end
			end

			-- Click Menu Item Function
			local SelectMenuItemDummy = function()
				log:debug("SelectMenuItem NOT SPECIFIED");
			end

			buttonContainer.SelectMenuItem = SelectMenuItemDummy;

			local SelectMenuItemStance = function(self, wndHandler, wndControl)
				GameLib.SetCurrentClassInnateAbilityIndex(wndHandler:GetData())
				self:CloseMenu();
			end

			local SelectMenuItemMount = function(self, wndHandler, wndControl)
				M.P["SelectedMount"] = wndHandler:GetData();
				GameLib.SetShortcutMount(wndHandler:GetData());
				self:CloseMenu();
			end

			local SelectMenuItemPotion = function(self, wndHandler, wndControl)
				M.P["SelectedPotion"] = wndHandler:GetData();
				GameLib.SetShortcutPotion(wndHandler:GetData());
				self:CloseMenu();
			end

			local SelectMenuItemPath = function(self, wndHandler, wndControl)
				S:ChangePathAbility(wndHandler:GetData());
				self:CloseMenu();
			end

			-- Toggle Menu Function
			function buttonContainer:ToggleMenu()
				if (not self.wndMenu:IsVisible()) then
					-- Generate List
					local nMenuEntries = 0;
					local nMenuHeight = 0;
					self.wndMenu:DestroyChildren();

					if (self.Attributes.menu == "Stance") then
						buttonContainer.SelectMenuItem = SelectMenuItemStance;

						local nCountSkippingTwo = 0;
						for idx, spellObject in pairs(GameLib.GetClassInnateAbilitySpells().tSpells) do
							if idx % 2 == 1 then
								nCountSkippingTwo = nCountSkippingTwo + 1;
								local wndCurr = Apollo.LoadForm(M.xmlDoc, "ActionBarFlyoutButton", self.wndMenu, self);

								-- Icon
								wndCurr:FindChild("Icon"):SetSprite(spellObject:GetIcon());

								-- Hotkey
								-- local strKeyBinding = GameLib.GetKeyBinding("SetStance"..nCountSkippingTwo) -- hardcoded formatting
								-- wndCurr:FindChild("StanceBtnKeyBind"):SetText(strKeyBinding == "<Unbound>" and "" or strKeyBinding)

								-- Data
								wndCurr:SetData(nCountSkippingTwo);

								-- Tooltip
								if (Tooltip and Tooltip.GetSpellTooltipForm) then
									wndCurr:SetTooltipDoc(nil);
									Tooltip.GetSpellTooltipForm(self, wndCurr, spellObject);
								end

								-- Position
								local buttonPosition = nMenuEntries * (buttonSize + M.DB.buttonPadding);
								wndCurr:SetAnchorOffsets(0, buttonPosition, buttonSize, buttonPosition + buttonSize);
								nMenuHeight = buttonPosition + buttonSize;
								nMenuEntries = nMenuEntries + 1;

								wndCurr:AddEventHandler("ButtonSignal", "SelectMenuItem", buttonContainer);
							end
						end
					elseif (self.Attributes.menu == "Mount") then
						buttonContainer.SelectMenuItem = SelectMenuItemMount;

						local tMountList = AbilityBook.GetAbilitiesList(Spell.CodeEnumSpellTag.Mount) or {};
						for i, tMountData in pairs(tMountList) do
							local tSpellObject = tMountData.tTiers[1].splObject;
							local wndCurr = Apollo.LoadForm(M.xmlDoc, "ActionBarFlyoutButton", self.wndMenu, self);

							-- Icon
							wndCurr:FindChild("Icon"):SetSprite(tSpellObject:GetIcon());

							-- Data
							wndCurr:SetData(tSpellObject:GetId());

							-- Tooltip
							if (Tooltip and Tooltip.GetSpellTooltipForm) then
								wndCurr:SetTooltipDoc(nil);
								Tooltip.GetSpellTooltipForm(self, wndCurr, tSpellObject, {});
							end

							-- Position
							local buttonPosition = (i - 1) * (buttonSize + M.DB.buttonPadding);
							wndCurr:SetAnchorOffsets(0, buttonPosition, buttonSize, buttonPosition + buttonSize);
							nMenuHeight = buttonPosition + buttonSize;

							-- Events
							wndCurr:AddEventHandler("ButtonSignal", "SelectMenuItem", buttonContainer);
						end
					elseif (self.Attributes.menu == "Recall") then
						local tAbilities = S:GetRecallAbilitiesList();

						for i, nAbilityId in pairs(tAbilities) do
							local wndCurr = Apollo.LoadForm(M.xmlDoc, "ActionBarFlyoutActionButton", self.wndMenu, self);

							-- Content ID
							wndCurr:FindChild("Button"):SetContentId(nAbilityId);

							-- Position
							local buttonPosition = (i - 1) * (buttonSize + M.DB.buttonPadding);
							wndCurr:SetAnchorOffsets(0, buttonPosition, buttonSize, buttonPosition + buttonSize);
							nMenuHeight = buttonPosition + buttonSize;

							-- Events
							wndCurr:AddEventHandler("GenerateTooltip", "OnGenerateTooltip", buttonContainer);
						end
						
						-- Events (TODO)
						-- Apollo.RegisterEventHandler("ChangeWorld", 					"_RefreshMenuItemsIfMenuIsVisible", buttonContainer);
						-- Apollo.RegisterEventHandler("HousingNeighborhoodRecieved", 	"_RefreshMenuItemsIfMenuIsVisible", buttonContainer);
						-- Apollo.RegisterEventHandler("GuildResult", 					"_RefreshMenuItemsIfMenuIsVisible", buttonContainer);
						-- Apollo.RegisterEventHandler("AbilityBookChange", 			"_RefreshMenuItemsIfMenuIsVisible", buttonContainer);
					elseif (self.Attributes.menu == "Potion") then
						buttonContainer.SelectMenuItem = SelectMenuItemPotion;
						local tPotions = S:GetInventoryByCategory(48);

						for id, tPotion in pairs(tPotions) do
							local wndCurr = Apollo.LoadForm(M.xmlDoc, "ActionBarFlyoutButton", self.wndMenu, self);

							-- Icon
							wndCurr:FindChild("Icon"):SetSprite(tPotion.tItem:GetIcon());

							-- Count
							if (tPotion.nCount > 1) then
								wndCurr:FindChild("Count"):SetText(tPotion.nCount);
							end

							-- Data
							wndCurr:SetData(id);

							-- Tooltip
							if (Tooltip and Tooltip.GetItemTooltipForm) then
								wndCurr:SetTooltipDoc(nil);
								Tooltip.GetItemTooltipForm(self, wndCurr, tPotion.tItem, {});
							end

							-- Position
							local buttonPosition = nMenuEntries * (buttonSize + M.DB.buttonPadding);
							wndCurr:SetAnchorOffsets(0, buttonPosition, buttonSize, buttonPosition + buttonSize);
							nMenuHeight = buttonPosition + buttonSize;
							nMenuEntries = nMenuEntries + 1;

							-- Events
							wndCurr:AddEventHandler("ButtonSignal", "SelectMenuItem", buttonContainer);
						end
					elseif (self.Attributes.menu == "Path") then
						buttonContainer.SelectMenuItem = SelectMenuItemPath;
						local tAbilities = S:GetPathAbilities();

						for id, tAbilityData in pairs(tAbilities) do
							local tSpellObject = tAbilityData.tTiers[tAbilityData.nCurrentTier].splObject;
							local wndCurr = Apollo.LoadForm(M.xmlDoc, "ActionBarFlyoutButton", self.wndMenu, self);

							-- Icon
							wndCurr:FindChild("Icon"):SetSprite(tSpellObject:GetIcon());

							-- Data
							wndCurr:SetData(id);

							-- Tooltip
							if (Tooltip and Tooltip.GetSpellTooltipForm) then
								wndCurr:SetTooltipDoc(nil);
								Tooltip.GetSpellTooltipForm(self, wndCurr, tSpellObject, {});
							end

							-- Position
							local buttonPosition = nMenuEntries * (buttonSize + M.DB.buttonPadding);
							wndCurr:SetAnchorOffsets(0, buttonPosition, buttonSize, buttonPosition + buttonSize);
							nMenuHeight = buttonPosition + buttonSize;
							nMenuEntries = nMenuEntries + 1;

							-- Events
							wndCurr:AddEventHandler("ButtonSignal", "SelectMenuItem", buttonContainer);
						end
					end

					-- Show menu (if it has items)
					if (nMenuHeight > 0) then
						-- Set Position
						local nToggleX, nToggleY = S:GetWindowPosition(self.wndMenuToggle);
						nToggleX = nToggleX + self.wndMenuToggle:GetWidth() / 2;
						self.wndMenu:SetAnchorOffsets(nToggleX - buttonSize / 2, nToggleY - nMenuHeight, nToggleX + buttonSize / 2, nToggleY);

						-- Show Menu
						self.wndMenu:Show(true, true);

						-- Disable Bar Fading
						if (enableFading) then
							S:DisableMouseOverFade(barContainer.wndMain, barContainer, false, true);
						end
						self.wndMenu:ToFront();
					end
				else
					-- Close Menu
					self:CloseMenu();
				end
			end

			-- Menu events
			buttonContainer.wndMenuToggle:AddEventHandler("ButtonCheck", "ToggleMenu", buttonContainer); -- ButtonUp, because ButtonSignal doesn't work
			buttonContainer.wndMenu:AddEventHandler("WindowClosed", "CloseMenu", buttonContainer);
		end

		-- Update Position
		local buttonPosition = (i - 1) * (buttonSize + self.DB.buttonPadding);
		if (dirHorizontal) then
			buttonContainer.wndMain:SetAnchorOffsets(buttonPosition + self.DB.barPadding, self.DB.barPadding - (buttonAttributes.menu and 4 or 0), buttonPosition + buttonSize + self.DB.barPadding, buttonSize + self.DB.barPadding + (buttonAttributes.menu and 4 or 0));

			-- Fix Button Offsets
			if (buttonAttributes.menu) then
				--buttonContainer.wndButton:SetAnchorOffsets(2, 4, -2, -4);
				if (buttonContainer.wndMain:FindChild("ButtonBorder")) then
					buttonContainer.wndMain:FindChild("ButtonBorder"):SetAnchorOffsets(0, 4, 0, -4);
				end
			end
		else
			buttonContainer.wndMain:SetAnchorOffsets(self.DB.barPadding, buttonPosition + self.DB.barPadding, buttonSize + self.DB.barPadding, buttonPosition + buttonSize + self.DB.barPadding);
		end

		-- Done, Increase Index
		table.insert(barContainer.Buttons, buttonContainer);
	end

	if (enableFading) then
		S:EnableMouseOverFade(barContainer.wndMain, barContainer);
	end

	-- Done
	return barContainer;
end

function M:UpdateActionBarButtonBorders()
	-- Update LAS Bar Background Sprite (Workaround)
	for i, buttonContainer in ipairs(self.tBars["Main"].Buttons) do
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
