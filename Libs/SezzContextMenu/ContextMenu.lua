--[[

	s:UI Context Menu

	How to add a context menu:

		local tMenu = Apollo.GetPackage("Sezz:Controls:ContextMenu-0.1").tPackage:GetRootMenu();
		tMenu:Initialize(); -- Remove old data/windows/etc. and create a new empty window

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:ContextMenu-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local ContextMenu = APkg and APkg.tPackage or {};
local GeminiGUI, GeminiLogging, log;
local Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading = Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading;
local max, strlen, ceil = math.max, string.len, math.ceil;
local ContextMenuRoot;

-----------------------------------------------------------------------------

local knXCursorOffset = -20;-- -220
local knYCursorOffset = -6;

----------------------------------------------------------------------------
-- Window Definitions
-----------------------------------------------------------------------------

local tWDefContextMenu = {
	Name = "ContextMenu",
--	Template = "HoloWindowSound", -- Annoying sound!
	CloseOnExternalClick = true,
	Escapable = true,
	NoClip = true,
	Overlapped = true,
	NewWindowDepth = true,
	IgnoreMouse = true,
	AnchorPoints = { 0, 0, 0, 0 },
	AnchorOffsets = { 0, 0, 150, 0 },
	Children = {
		{
			Name = "ButtonList",
			AnchorFill = true,
		},
		{
			Name = "HoloFraming",
			Sprite = "BK3:UI_BK3_Holo_Framing_3",
			Picture = true,
			AnchorPoints = { 0, 0, 1, 1 },
			AnchorOffsets = { -30, -30, 30, 30 },
			NoClip = true,
		},
	},
};

local tWDefMenuTitle = {
	Name = "Title",
	AnchorPoints = { 0, 0, 1, 0 },
	AnchorOffsets = { 0, 0, 0, 25 },
	Overlapped = true,
	DT_CENTER = true,
	DT_VCENTER = true,
	Font = "CRB_Header10",
};

local tWDefContextMenuButton = {
	WidgetType = "PushButton",
	Name = "Button",
	Base = "BK3:btnHolo_ListView_Mid",
	AnchorPoints = { 0, 0, 1, 0 },
	AnchorOffsets = { 0, 0, 0, 25 },
	Overlapped = true,
	DT_CENTER = false,
	Font = "CRB_InterfaceSmall",
	Children = {
		{
			Name = "BtnCheckboxArrow",
			AnchorPoints = { 1, 0.5, 1, 0.5 },
			AnchorOffsets = { -22, -10, -2, 10 },
			Sprite = "Crafting_CircuitSprites:btnCircuit_Holo_RightArrowNormal",
			Picture = true,
			BGColor = "UI_AlphaPercent65",
			IgnoreMouse = true,
			Visible = false,
		},
	},
};

local tWDefContextMenuIconCheckbox = {
	WidgetType = "CheckBox",
	Name = "IconCheckbox",
	Base = "BK3:btnHolo_ListView_Mid",
	RadioGroup = "ContextMenuPlayer_MarkerIcons_GlobalRadioGroup", -- TODO
	NormalTextColor = "UI_BtnTextGrayListNormal",
	AnchorPoints = { 0, 0, 0, 0 },
	AnchorOffsets = { 0, 0, 37, 37 },
	Overlapped = true,
	Border = false,
	DrawAsCheckbox = false,
	Children = {
		{
			Name = "ZIndexFix", -- TODO
			AnchorPoints = { 0, 0, 1, 1 },
			AnchorOffsets = { 0, 0, 0, 0 },
			IgnoreMouse = true,
			Children = {
				{
					Name = "Icon",
					AnchorPoints = { 0, 0, 1, 1 },
					AnchorOffsets = { 4, 4, -4, -4 },
					Picture = true,
					IgnoreMouse = true,
				},
			},
		},
	},
};

local tWDefContextMenuSeparator = {
	Name = "Separator",
	Picture = true,
	AnchorPoints = { 0, 0, 1, 0 },
	AnchorOffsets = { 2, 0, -2, 6 },
	Sprite = "CRB_Basekit:kitDivider_Horiz_HoloDashed",
	IgnoreMouse = true,
};

-----------------------------------------------------------------------------
-- Item Events
-----------------------------------------------------------------------------

local tDefaultEvents = {};

function tDefaultEvents:HideSubMenu(wndHandler, wndControl)
	local tRoot = wndHandler:GetData().ContextMenu;
	while (tRoot.tParent) do
		tRoot = tRoot.tParent;
	end

	local tActive = tRoot;
	while (tActive) do
		if (tActive.wndMain:ContainsMouse()) then
			if (tActive.tActiveSubMenu) then
				-- menu has an open submenu
				if (tActive.tActiveSubMenu.tActiveSubMenu and wndHandler:GetName() ~= "ContextMenu" and tActive.tActiveSubMenu.tActiveSubMenu ~= tActive.tActiveSubMenu.tChildren[wndHandler]) then
					-- open child menu, opening another menu from another level, close active one
					tActive.tActiveSubMenu.tActiveSubMenu = tActive.tActiveSubMenu:Close();
				elseif (tActive.tActiveSubMenu.tActiveSubMenu) then
					-- child with active submenu, check next level
					tActive = tActive.tActiveSubMenu;
				else
					-- child doesnt have an active submenu
					if (wndHandler:GetName() ~= "ContextMenu" and tActive.tActiveSubMenu ~= tActive.tChildren[wndHandler]) then
						-- active submenu shouldn't be visible anymore
						tActive.tActiveSubMenu = tActive.tActiveSubMenu:Close();
					end
					break;
				end
			else
				-- no active submenu
				break;
			end
		elseif (tActive.tActiveSubMenu) then
			-- menu doesn have mouse, check child
			tActive = tActive.tActiveSubMenu;
		else
			-- doesn't has mouse, no children, close if not root
			if (tActive.tParent) then
				tRoot.tActiveSubMenu = tRoot.tActiveSubMenu:Close();
			end
			break;
		end
	end

--[[
	if (self.tActiveSubMenu and not self.tActiveSubMenu.wndMain:ContainsMouse()) then
		if ((wndHandler == self.wndMain and not wndHandler:ContainsMouse()) or wndHandler ~= self.wndMain) then
			self.tActiveSubMenu:Close();
			self.tActiveSubMenu = nil;
		end
	elseif (self.wndParent and not self.wndMain:ContainsMouse() and (not self.wndParent:ContainsMouse() or self.tParent.tActiveSubMenu ~= self)) then
		self:Close();

		if (self.tParent.tActiveSubMenu == self) then
			self.tParent.tActiveSubMenu = nil;
		end
	end
--]]
end

function tDefaultEvents:ShowSubMenu(wndHandler, wndControl)
	if (not wndHandler or wndHandler ~= wndControl) then return; end
	local tMenu = wndHandler:GetData().ContextMenu;
	local tSubMenu = tMenu.tChildren[wndHandler];

	if (not tSubMenu) then
		tSubMenu = ContextMenu:New(tMenu, wndHandler);
		tSubMenu:CreateWindow();
		tSubMenu:AddItems(wndHandler:GetData().Children);
		tMenu.tChildren[wndHandler] = tSubMenu;
	end

	if (tMenu.tActiveSubMenu and tMenu.tActiveSubMenu ~= tSubMenu) then
		tMenu:HideSubMenu(wndHandler, wndControl);
	end

	tSubMenu:Show();
	tMenu.tActiveSubMenu = tSubMenu;
	wndHandler:SetCheck(true);
end

-----------------------------------------------------------------------------
-- Context Menu
-----------------------------------------------------------------------------

function ContextMenu:CreateWindow()
	self.wndMain = GeminiGUI:Create(tWDefContextMenu):GetInstance(self, self.wndParent or "TooltipStratum");
	self.wndMain:SetData({ ContextMenu = self });
	self.wndMain:Invoke();
	self.wndButtonList = self.wndMain:FindChild("ButtonList");
	self.tAnchorOffsets = { self.wndMain:GetAnchorOffsets() };
	self.wndMain:AddEventHandler("MouseExit", "HideSubMenu", self);
	self.wndMain:AddEventHandler("WindowClosed", "OnWindowClosed", self);

	return self;
end

function ContextMenu:AddHeader(strTitle)
	if (not strTitle or strlen(strTitle) == 0) then return; end

	local wndTitle = GeminiGUI:Create(tWDefMenuTitle):GetInstance(self, self.wndButtonList);

	self.tAnchorOffsets[3] = max(150, Apollo.GetTextWidth(tWDefMenuTitle.Font, strTitle) + 10);
	wndTitle:SetText(strTitle);
	self.bHasHeader = true;
end

function ContextMenu:AddItems(tItems)
	if (type(tItems) == "string") then tItems = tMenuItems[tItems]; end
	if (type(tItems) ~= "table") then return; end

	for _, tButton in ipairs(tItems) do
--Print(tButton.Name)
		if (not tButton.Condition or tButton.Condition(self)) then
			if (tButton.Text or tButton.Icon) then
				-- Determine if the item has visible children
				local bCreateButton = true;
				local bHasVisibleChildren = (tButton.Children and #tButton.Children > 0);
				if (bHasVisibleChildren) then
					bHasVisibleChildren = false;

					for _, tChild in ipairs(tButton.Children) do
						if (not tChild.Condition or (tChild.Condition and tChild.Condition(self))) then
							bHasVisibleChildren = true;
							break;
						end
					end

					bCreateButton = bHasVisibleChildren;
				end

				if (bCreateButton) then
					-- Events
					-- TODO
					local tEventHandler, strEventHandler, fnEventHandler = self;

					if (tButton.OnClick or (tButton.Children and #tButton.Children > 0)) then
						if (not tButton.OnClick and bHasVisibleChildren) then
							-- No custom event but children - ignore clicks
							strEventHandler = "OnClickIgnore";
							tEventHandler = self;
						elseif (tButton.OnClick) then
							-- Custom event handler
							if (type(tButton.OnClick) == "string") then
								-- One of the ContextMenu event handlers
								strEventHandler = tButton.OnClick;
								tEventHandler = self;
							elseif (type(tButton.OnClick) == "function") then
								-- Function
								fnEventHandler = function(self, wndHandler, wndControl, ...)
									if (wndHandler ~= wndControl) then return; end
									return tButton.OnClick(wndHandler, wndControl, ...);
								end;

								tEventHandler = self.tEventHandlers;
							elseif (type(tButton.OnClick) == "table") then
								-- Function, Event Handler
								fnEventHandler = function(self, wndHandler, wndControl, ...)
									if (wndHandler ~= wndControl) then return; end
									local strFunction = tButton.OnClick[1];
									local tEventHandler = tButton.OnClick[2];

									return tEventHandler[strFunction](tEventHandler, wndHandler, wndControl, ...);
								end;
								tEventHandler = self.tEventHandlers;
							end
						end

						if (tButton.CloseMenuOnClick) then
							local fnEventHandlerBeforeClose = fnEventHandler or function() end;
							fnEventHandler = function(self, wndHandler, wndControl, ...)
								if (wndHandler ~= wndControl) then return; end
								local retVal = fnEventHandlerBeforeClose(self, wndHandler, wndControl, ...)
								wndHandler:GetData().ContextMenu:Close(true);
								return retVal;
							end
						end
					end

					-- Create Button
					local wndButton = GeminiGUI:Create(tButton.Icon and tWDefContextMenuIconCheckbox or tWDefContextMenuButton):GetInstance(tEventHandler, self.wndButtonList);
					wndButton:SetData({
						ContextMenu = self,
						Children = bHasVisibleChildren and tButton.Children or nil,
					});

					if (tButton.Name) then
						wndButton:SetName(tButton.Name)
					end

					if (tButton.Text) then
						wndButton:SetText(tButton.Text);
					end

					-- Icon Checkbox
					if (tButton.Icon) then
						wndButton:FindChild("Icon"):SetSprite(tButton.Icon);
						wndButton:SetCheck(tButton.Checked and tButton.Checked(self));
						self.bIsIconList = true;
					end

					-- Click Event
					if (fnEventHandler) then
						strEventHandler = tostring(wndButton);
						tEventHandler[strEventHandler] = fnEventHandler;
					end

					if (strEventHandler) then
						if (tButton.Icon) then
							wndButton:AddEventHandler("ButtonCheck", strEventHandler, tEventHandler);
							wndButton:AddEventHandler("ButtonUncheck", strEventHandler, tEventHandler);
						else
							wndButton:AddEventHandler("ButtonSignal", strEventHandler, tEventHandler);
						end
					end

					-- Enabled State
					if (tButton.Enabled) then
						wndButton:Enable(tButton.Enabled(self));
					end

					-- Submenu Indicator/Events
					if (bHasVisibleChildren) then
						wndButton:FindChild("BtnCheckboxArrow"):Show(true, true);
						wndButton:AddEventHandler("MouseEnter", "ShowSubMenu", tEventHandler);
					else
						wndButton:AddEventHandler("MouseEnter", "HideSubMenu", tEventHandler);
						wndButton:AddEventHandler("MouseMove", "HideSubMenu", tEventHandler);
					end
				end
			else
				GeminiGUI:Create(tWDefContextMenuSeparator):GetInstance(self, self.wndButtonList);
			end
		end
	end
end

function ContextMenu:Show()
	if (not self.bUpdatedPosition) then
		self:Position();
	end

	self.wndMain:Show(true, true);
	self.wndMain:ToFront();
	self.wndMain:Enable(true)
end

function ContextMenu:ContainsMouse()
	if (self.tActiveSubMenu) then
		return self.tActiveSubMenu:ContainsMouse();
	else
		return self.wndMain:ContainsMouse();
	end
end

function ContextMenu:Close(bCloseParent)
	self.wndMain:Close();
	if (self.tParent and self.tParent.tActiveSubMenu == self) then
		self.wndParent:SetCheck(false);
		self.tParent.tActiveSubMenu = nil;
	end

	if (self.tParent and bCloseParent) then
		self.tParent:Close(true);
	end
end

function ContextMenu:Initialize()
	return self:Destroy(true):CreateWindow();
end

function ContextMenu:Destroy(bSkipSelf, bKeepWindow)
	for strKey, tContextMenu in pairs(self.tChildren) do
		self.tChildren[strKey] = tContextMenu:Destroy();
	end

	if (not bKeepWindow and self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	if (not bSkipSelf) then
		self = nil;
	elseif (not bKeepWindow) then
		self.bIsIconList = false;
		self.bUpdatedPosition = false;
		self.tEventHandlers = setmetatable({}, { __index = tDefaultEvents });
	end

	return self;
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

function ContextMenu:OnWindowClosed()
	self.wndMain:Show(false, true);
	self:Destroy(true, true);
end

function ContextMenu:OnClickIgnore(wndHandler, wndControl)
	if (wndHandler:GetData().Children) then
		self:ShowSubMenu(wndHandler, wndControl);
	end
end

-----------------------------------------------------------------------------
-- Positioning
-----------------------------------------------------------------------------

function ContextMenu:CheckWindowBounds()
	local nWidth =  self.wndMain:GetWidth();
	local nHeight = self.wndMain:GetHeight();
	self.tAnchorOffsets = { self.wndMain:GetAnchorOffsets() };

	local nMaxScreenWidth, nMaxScreenHeight = Apollo.GetScreenSize();

	-- Get Menu Position
	local nPosX, nPosY;
	if (self.wndParent) then
		nPosX, nPosY = self.wndParent:GetPos();
		nPosX = nPosX + self.wndParent:GetWidth();

		local wndParent = self.wndParent:GetParent();
		while (wndParent) do
			local nPosXParent, nPosYParent = wndParent:GetPos();
			nPosX = nPosX + nPosXParent;
			nPosY = nPosY + nPosYParent;

			wndParent = wndParent:GetParent();
		end
	else
		local tCursor = Apollo.GetMouse();
		nPosX = tCursor.x - knXCursorOffset + 10; -- Holo border needs about 10px!
		nPosY = tCursor.y - knYCursorOffset + 10;
	end

	local nNewX = nWidth + nPosX;
	local nNewY = nHeight + nPosY;

	local bSafeX = (nNewX <= nMaxScreenWidth);
	local bSafeY = (nNewY <= nMaxScreenHeight);

	if (not bSafeX) then
		local nRightOffset;

		if (not self.wndParent) then
			nRightOffset = nNewX - nMaxScreenWidth;
		else
			-- Child Menu: Anchor to the left of it's parent
			nRightOffset = self.wndParent:GetWidth() + self.wndMain:GetWidth();
		end

		self.tAnchorOffsets[1] = self.tAnchorOffsets[1] - nRightOffset;
		self.tAnchorOffsets[3] = self.tAnchorOffsets[3] - nRightOffset;
	end

	if (not bSafeY) then
		local nBottom = self.tAnchorOffsets[2] + knYCursorOffset;

		if (self.wndParent) then
			for wndItem, tMenu in pairs(self.tParent.tChildren) do
				if (tMenu == self) then
					nBottom = wndItem:GetHeight();
					break;
				end
			end
		end

		self.tAnchorOffsets[4] = nBottom;
		self.tAnchorOffsets[2] = self.tAnchorOffsets[4] - nHeight;
	end

	if (not bSafeX or not bSafeY) then
		self.wndMain:SetAnchorOffsets(unpack(self.tAnchorOffsets));
		return false;
	end

	return true;
end

function ContextMenu:Position()
	-- Resize
	if (self.bIsIconList) then
		-- Checkbox Icons
		local nHeight = ceil(#self.wndButtonList:GetChildren() / 3) * tWDefContextMenuIconCheckbox.AnchorOffsets[4];

		if (self.bHasHeader) then
			nHeight = nHeight + tWDefMenuTitle.AnchorOffsets[4];
		else
			self.tAnchorOffsets[3] = 3 * tWDefContextMenuIconCheckbox.AnchorOffsets[3];
		end

		self.tAnchorOffsets[4] = nHeight;
		self.wndMain:SetAnchorOffsets(unpack(self.tAnchorOffsets));
		self.wndButtonList:ArrangeChildrenTiles(0);
	else
		-- Default Menu
		self.tAnchorOffsets[4] = self.tAnchorOffsets[2] + self.wndButtonList:ArrangeChildrenVert(0);
		self.wndMain:SetAnchorOffsets(unpack(self.tAnchorOffsets));
	end

	local nPosX, nPosY;

	if (self.wndParent) then
		nPosX = self.wndParent:GetWidth();
		nPosY = 0;
	else
		local tCursor = Apollo.GetMouse();
		nPosX = tCursor.x - knXCursorOffset;
		nPosY = tCursor.y - knYCursorOffset;
	end

	self.wndMain:Move(nPosX, nPosY, self.wndMain:GetWidth(), self.wndMain:GetHeight());
	self:CheckWindowBounds();

	self.bUpdatedPosition = true;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function ContextMenu:New(tParent, wndParent)
	-- TODO: There should be only ONE root menu, because you can only show one
	local tMenu = setmetatable({
		tParent = tParent,
		wndParent = wndParent,
		tChildren = {},
		tEventHandlers = setmetatable({}, { __index = tDefaultEvents }),
		tData = tParent and tParent.tData or {},
		nLevel = tParent and tParent.nLevel + 1 or 1,
	}, { __index = self });

	-- Events
	tMenu.ShowSubMenu = tMenu.tEventHandlers.ShowSubMenu;
	tMenu.HideSubMenu = tMenu.tEventHandlers.HideSubMenu;

	return tMenu;
end

function ContextMenu:GetRootMenu()
	return ContextMenuRoot;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function ContextMenu:OnLoad()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2") and Apollo.GetAddon("GeminiConsole") and Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	if (GeminiLogging) then
		log = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender ="GeminiConsole"
		});
	else
		log = setmetatable({}, { __index = function() return function(self, ...) local args = #{...}; if (args > 1) then Print(string.format(...)); elseif (args == 1) then Print(tostring(...)); end; end; end });
	end

	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;

	-- Create Root Menu
	ContextMenuRoot = ContextMenu:New();

	function ContextMenuRoot:OnNewContextMenuPlayer(wndParent, strTarget, unitTarget, nReportId)
		if (self:GenerateUnitMenu(unitTarget or strTarget, nReportId)) then
			self:Show();
		end
	end

	function ContextMenuRoot:OnNewContextMenuFriend(wndParent, nFriendId)
		if (self:GenerateUnitMenu(nFriendId)) then
			self:Show();
		end
	end

	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuPlayer", "OnNewContextMenuPlayer", ContextMenuRoot);
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuPlayerDetailed", "OnNewContextMenuPlayer", ContextMenuRoot);
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuFriend", "OnNewContextMenuFriend", ContextMenuRoot);
end

function ContextMenu:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(ContextMenu, MAJOR, MINOR, { "Gemini:GUI-1.0" });
