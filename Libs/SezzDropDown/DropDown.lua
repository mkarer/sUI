--[[

	s:UI Drop Down Menu

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:DropDown-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local DropDown = APkg and APkg.tPackage or {};
local GeminiGUI, GeminiLogging, log;
local Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading = Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading;
local max, strlen, ceil = math.max, string.len, math.ceil;

-----------------------------------------------------------------------------

local knXCursorOffset = -20 -200;
local knYCursorOffset = -6;

----------------------------------------------------------------------------
-- Window Definitions
-----------------------------------------------------------------------------

local tWDefDropDownMenu = {
	Name = "DropDownMenu",
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

local tWDefDropDownButton = {
	WidgetType = "PushButton",
	Name = "Button",
	Base = "BK3:btnHolo_ListView_Mid",
	AnchorPoints = { 0, 0, 1, 0 },
	AnchorOffsets = { 0, 0, 0, 25 },
	Overlapped = true,
--	Events = {
--		ButtonSignal = function(self, wndControl, wndHandler) Print("Clicked: "..wndControl:GetName()); end,
--	},
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

local tWDefDropDownIconCheckbox = {
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

local tWDefDropDownSeparator = {
	Name = "Separator",
	Picture = true,
	AnchorPoints = { 0, 0, 1, 0 },
	AnchorOffsets = { 2, 0, -2, 6 },
	Sprite = "CRB_Basekit:kitDivider_Horiz_HoloDashed",
	IgnoreMouse = true,
};

-----------------------------------------------------------------------------
-- Drop Down Menu
-----------------------------------------------------------------------------

function DropDown:CreateWindow()
	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	self.wndMain = GeminiGUI:Create(tWDefDropDownMenu):GetInstance(self, self.wndParent or "TooltipStratum");
	self.wndMain:Invoke();
	self.wndButtonList = self.wndMain:FindChild("ButtonList");
	self.tAnchorOffsets = { self.wndMain:GetAnchorOffsets() };
	self.wndMain:AddEventHandler("MouseExit", "HideSubMenu", self);
	self.wndMain:AddEventHandler("WindowClosed", "OnWindowClosed", self);
end

function DropDown:Init(strType, oData)
	-- Cleanup
	self.bIsIconList = false;
	self.bUpdatedPosition = false;

	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	-- Initialize Data
	if (strType == "Unit" and oData) then
		self:GenerateUnitMenu(oData);
	end

	return self;
end

function DropDown:AddHeader(strTitle)
	if (not strTitle or strlen(strTitle) == 0) then return; end

	local wndTitle = GeminiGUI:Create(tWDefMenuTitle):GetInstance(self, self.wndButtonList);

	self.tAnchorOffsets[3] = max(150, Apollo.GetTextWidth(tWDefMenuTitle.Font, strTitle) + 10);
	wndTitle:SetText(strTitle);
	self.bHasHeader = true;
end

function DropDown:AddItems(tItems)
	if (type(tItems) == "string") then tItems = tMenuItems[tItems]; end
	if (type(tItems) ~= "table") then return; end

	for _, tButton in ipairs(tItems) do
log:debug(tButton.Name)

		if (not tButton.Condition or tButton.Condition(self)) then
			if (tButton.Text or tButton.Icon) then
				-- Children
				local bCreateButton = true;
				local bHasVisibleChildren = (tButton.Children and #tButton.Children > 0);
				if (bHasVisibleChildren) then
					bHasVisibleChildren = false;

					for _, tChild in ipairs(tButton.Children) do
						if (tChild.Condition and tChild.Condition(self)) then
							bHasVisibleChildren = true;
							break;
						end
					end

					bCreateButton = bHasVisibleChildren;
				end

				if (bCreateButton) then
					local wndButton = GeminiGUI:Create(tButton.Icon and tWDefDropDownIconCheckbox or tWDefDropDownButton):GetInstance(self, self.wndButtonList);

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
					if (tButton.OnClick or (tButton.Children and #tButton.Children > 0)) then
						if (tButton.Children and #tButton.Children > 0) then
							wndButton:AddEventHandler("ButtonSignal", "OnClickIgnore");
						else
							wndButton:AddEventHandler("ButtonSignal", tButton.OnClick);
						end
					end

					-- Enabled State
					if (tButton.Enabled) then
						wndButton:Enable(tButton.Enabled(self));
					end

					-- Submenu Indicator/Events
					if (bHasVisibleChildren) then
						wndButton:SetData(tButton.Children);
						wndButton:FindChild("BtnCheckboxArrow"):Show(true, true);
						wndButton:AddEventHandler("MouseEnter", "ShowSubMenu");
					else
						wndButton:AddEventHandler("MouseEnter", "HideSubMenu");
						wndButton:AddEventHandler("MouseMove", "HideSubMenu");
					end
				end
			else
				GeminiGUI:Create(tWDefDropDownSeparator):GetInstance(self, self.wndButtonList);
			end
		end
	end
end

function DropDown:Position()
	-- Resize
	if (self.bIsIconList) then
		-- Checkbox Icons
		local nHeight = ceil(#self.wndButtonList:GetChildren() / 3) * tWDefDropDownIconCheckbox.AnchorOffsets[4];

		if (self.bHasHeader) then
			nHeight = nHeight + tWDefMenuTitle.AnchorOffsets[4];
		else
			self.tAnchorOffsets[3] = 3 * tWDefDropDownIconCheckbox.AnchorOffsets[3];
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

function DropDown:Show()
	if (not self.bUpdatedPosition) then
		self:Position();
	end

	self.wndMain:Show(true, true);
	self.wndMain:ToFront();
	self.wndMain:Enable(true)
end

function DropDown:ShowSubMenu(wndHandler, wndControl)
	if (not wndHandler or wndHandler ~= wndControl) then return; end
	local strName = wndHandler:GetName();
	local tSubMenu = self.tChildren[strName];

	if (not tSubMenu) then
		log:debug("new submenu %s", strName)
		tSubMenu = DropDown:New(self, wndHandler);
		tSubMenu:Init("Unit", self.unit);
		tSubMenu:AddItems(wndHandler:GetData());
		self.tChildren[strName] = tSubMenu;
	end

	tSubMenu:Show();
	self.tActiveSubMenu = tSubMenu;
	wndHandler:SetCheck(true);
end

function DropDown:HideSubMenu(wndHandler, wndControl)
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
end

function DropDown:OnClickIgnore(wndHandler, wndControl)
	if (wndHandler:GetData()) then
		self:ShowSubMenu(wndHandler, wndControl);
	end
end

function DropDown:Close(bCloseParent)
	self.wndMain:Close();
	if (self.tParent and self.tParent.tActiveSubMenu == self) then
		self.wndParent:SetCheck(false);
		self.tParent.tActiveSubMenu = nil;
	end

	if (self.tParent and bCloseParent) then
		self.tParent:Close(true);
	end
end

function DropDown:Destroy()
	for _, tSubMenu in pairs(self.tChildren) do
		tSubMenu:Destroy();
	end

	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	self = nil;
	return self;
end

function DropDown:OnWindowClosed()
	self.wndMain:Show(false, true);

	if (not self.tParent) then
		-- Root menu closed!
		for strName, tDropDown in pairs(self.tChildren) do
			self.tChildren[strName] = tDropDown:Destroy();
		end

		-- TODO
		self.unit = nil;
		self.unitPlayer = nil;
		self.bInGroup = nil;
		self.bAmIGroupLeader = nil;
		self.tMyGroupData = nil;
		self.strTarget = nil;
		self.tCharacterData = nil;
		self.tPlayerFaction = nil;
		self.bIsACharacter = nil;
		self.bIsThePlayer = nil;
		self.nGroupMemberId = nil;
		self.tTargetGroupData = nil;
		self.tFriend = nil;
		self.tAccountFriend = nil;
		self.bCanAccountWisper = nil;
		self.bCanWhisper = nil;
		self.bIsFriend = nil;
		self.bIsRival = nil;
		self.bIsNeighbor = nil;
		self.bIsAccountFriend = nil;
		self.bMentoringTarget = nil;
	end
end

function DropDown:CheckWindowBounds()
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
		self.tAnchorOffsets[4] = self.tAnchorOffsets[2] + knYCursorOffset;
		self.tAnchorOffsets[2] = self.tAnchorOffsets[4] - nHeight;
	end

	if (not bSafeX or not bSafeY) then
		self.wndMain:SetAnchorOffsets(unpack(self.tAnchorOffsets));
		return false;
	end

	return true;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function DropDown:New(tParent, wndParent)

	 return setmetatable({
		tParent = tParent,
		wndParent = wndParent,
		tChildren = {},
	}, { __index = self });
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function DropDown:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	if (GeminiLogging and Apollo.GetAddon("GeminiConsole")) then
		log = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender = "GeminiConsole"
		});
	else
		log = setmetatable({}, { __index = function() return function(o) Print(tostring(o)); end; end });
	end

	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;

	-- Listen to Carbine's Context Menu Events
	local tDropDown = DropDown:New();

	function tDropDown:OnNewContextMenuPlayer(wndParent, strTarget, unitTarget, nReportId)
	end

	function tDropDown:OnNewContextMenuPlayerDetailed(wndParent, strTarget, unitTarget, nReportId)
	end

	function tDropDown:OnNewContextMenuFriend(wndParent, nFriendId)
	end

	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuPlayer", "OnNewContextMenuPlayer", tDropDown);
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuPlayerDetailed", "OnNewContextMenuPlayerDetailed", tDropDown);
	Apollo.RegisterEventHandler("GenericEvent_NewContextMenuFriend", "OnNewContextMenuFriend", tDropDown);
end

function DropDown:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(DropDown, MAJOR, MINOR, { "Gemini:GUI-1.0" });
