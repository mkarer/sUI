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
local max, strlen = math.max, string.len;

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
	Events = {
		ButtonSignal = function(self, wndControl, wndHandler) Print("Clicked: "..wndControl:GetName()); end,
	},
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

local tWDefDropDownSeparator = {
	Name = "Separator",
	Picture = true,
	AnchorPoints = { 0, 0, 1, 0 },
	AnchorOffsets = { 2, 0, -2, 6 },
	Sprite = "CRB_Basekit:kitDivider_Horiz_HoloDashed",
	IgnoreMouse = true,
};

-----------------------------------------------------------------------------
-- Drop Down Menu Items
-----------------------------------------------------------------------------

local tMenuItems = {
	Unit = {
		-- Markers
		{
			Name = "BtnMarkTarget",
			Text = Apollo.GetString("ContextMenu_MarkTarget"),
			Condition = function(self) return not self.bInGroup or (self.bInGroup and self.tMyGroupData.bCanMark); end,
			Children = {
				-- TODO
			},
		},
		-- Assist
		{
			Name = "BtnAssist",
			Text = Apollo.GetString("ContextMenu_Assist"),
			Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer); end,
			Enabled = function(self) return (self.unit:GetTarget() ~= nil); end
		},
		-- Focus
		{
			Name = "BtnClearFocus",
			Text = Apollo.GetString("ContextMenu_ClearFocus"),
			Condition = function(self) return (self.unitPlayer:GetAlternateTarget() and self.unit:GetId() == self.unitPlayer:GetAlternateTarget():GetId()); end,
			OnClick = "OnClickUnit",
		},
		{
			Name = "BtnSetFocus",
			Text = Apollo.GetString("ContextMenu_SetFocus"),
			Condition = function(self) return (not self.unitPlayer:GetAlternateTarget() or self.unit:GetId() ~= self.unitPlayer:GetAlternateTarget():GetId()); end,
			OnClick = "OnClickUnit",
		},
		-- Group (Mentor/Locate/etc.)
		{
			Name = "BtnGroupList",
			Text = Apollo.GetString("ChatType_Party"),
			Condition = function(self) return (not self.bIsThePlayer and self.bInGroup); end,
		},
		{
			Name = "BtnInspect",
			Text = Apollo.GetString("ContextMenu_Inspect"),
			Condition = function(self) return (self.bIsACharacter); end,
		},
		-- Social
		{
			Name = "BtnSocialList",
			Text = Apollo.GetString("ContextMenu_SocialLists"),
			Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer); end,
			Children = {
				{
					Name = "BtnAddFriend",
					Text = Apollo.GetString("ContextMenu_AddFriend"),
					Condition = function(self) return (not self.bIsFriend and self.unit:GetFaction() == self.unitPlayer:GetFaction()); end,
				},
				{
					Name = "BtnUnfriend",
					Text = Apollo.GetString("ContextMenu_RemoveFriend"),
					Condition = function(self) return (self.bIsFriend); end,
				},
				{
					Name = "BtnAccountFriend",
					Text = Apollo.GetString("ContextMenu_PromoteFriend"),
					Condition = function(self) return (self.bIsFriend and not self.bIsAccountFriend); end,
				},
				{
					Name = "BtnUnaccountFriend",
					Text = Apollo.GetString("ContextMenu_UnaccountFriend"),
					Condition = function(self) return (self.tAccountFriend ~= nil and self.bIsAccountFriend); end,
				},
				{
					Name = "BtnAddRival",
					Text = Apollo.GetString("ContextMenu_AddRival"),
					Condition = function(self) return (not self.bIsRival); end,
				},
				{
					Name = "BtnUnrival",
					Text = Apollo.GetString("ContextMenu_RemoveRival"),
					Condition = function(self) return (self.bIsRival and self.tAccountFriend == nil); end,
				},
				{
					Name = "BtnAddNeighbor",
					Text = Apollo.GetString("ContextMenu_AddNeighbor"),
					Condition = function(self) return (not self.bIsNeighbor and self.unit:GetFaction() == self.unitPlayer:GetFaction()); end,
				},
				{
					Name = "BtnUnneighbor",
					Text = Apollo.GetString("ContextMenu_RemoveNeighbor"),
					Condition = function(self) return (self.bIsNeighbor and self.tAccountFriend == nil); end,
				},
			},
		},
		-- Ignore
		{
			Name = "BtnIgnore",
			Text = Apollo.GetString("ContextMenu_Ignore"),
			Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer and not (self.tFriend and self.tFriend.bIgnore) and (self.tAccountFriend == nil or self.tAccountFriend.fLastOnline == 0)); end,
		},
		{
			Name = "BtnUnignore",
			Text = Apollo.GetString("ContextMenu_Unignore"),
			Condition = function(self) return (self.tFriend and self.tFriend.bIgnore); end,
		},
		-- Duel
		{
			Name = "BtnDuel",
			Text = Apollo.GetString("ContextMenu_Duel"),
			Condition = function(self)
				local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules();
				return ((not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.bIsACharacter and not self.bIsThePlayer and not GameLib.GetDuelOpponent(self.unitPlayer));
			end,
		},
		{
			Name = "BtnForfeit",
			Text = Apollo.GetString("ContextMenu_ForfeitDuel"),
			Condition = function(self)
				local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules();
				return ((not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.bIsACharacter and not self.bIsThePlayer and GameLib.GetDuelOpponent(self.unitPlayer));
			end,
		},
		-- Trade
		{
			Name = "BtnTrade",
			Text = Apollo.GetString("ContextMenu_Trade"),
			Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer); end,
			Enabled = function(self)
				local eCanTradeResult = P2PTrading.CanInitiateTrade(self.unit.__proto__ or self.unit);
				return (eCanTradeResult == P2PTrading.P2PTradeError_Ok or eCanTradeResult == P2PTrading.P2PTradeError_TargetRangeMax);
			end,
		},
		-- Whisper
		{
			Name = "BtnWhisper",
			Text = Apollo.GetString("ContextMenu_Whisper"),
			Condition = function(self) return (not self.bIsThePlayer and self.bCanWhisper); end,
		},
		{
			Name = "BtnAccountWhisper",
			Text = Apollo.GetString("ContextMenu_AccountWhisper"),
			Condition = function(self) return (not self.bIsThePlayer and self.bCanAccountWisper); end,
		},
		{
			Name = "BtnInvite",
			Text = Apollo.GetString("ContextMenu_InviteToGroup"),
			Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer and (not self.bInGroup or (tMyGroupData.bCanInvite and self.bCanWhisper))); end,
		},
		{
			Name = "BtnKick",
			Text = Apollo.GetString("ContextMenu_Kick"),
			Condition = function(self) return (not self.bIsThePlayer and self.bIsACharacter and self.bInGroup and self.unit:IsInYourGroup() and self.tMyGroupData.bCanKick); end,
		},
		{
			Name = "BtnLeaveGroup",
			Text = Apollo.GetString("ContextMenu_LeaveGroup"),
			Condition = function(self) return (self.bIsThePlayer and self.bInGroup); end,
		},
	},
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
	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	-- Initialize
	if (strType == "Unit") then
		self:GenerateUnitMenu(oData);
	else
		-- Invalid Menu Type
		return;
	end

	return self;
end

function DropDown:AddHeader(strTitle)
	if (not strTitle or strlen(strTitle) == 0) then return; end

	local wndTitle = GeminiGUI:Create(tWDefMenuTitle):GetInstance(self, self.wndButtonList);
	
	self.tAnchorOffsets[3] = max(150, Apollo.GetTextWidth(tWDefMenuTitle.Font, strTitle) + 10);
	wndTitle:SetText(strTitle);
end

function DropDown:AddItems(tItems)
	if (type(tItems) == "string") then tItems = tMenuItems[tItems]; end
	if (type(tItems) ~= "table") then return; end

	for _, tButton in ipairs(tItems) do
		if (not tButton.Condition or tButton.Condition(self)) then
			if (tButton.Text) then
				local wndButton = GeminiGUI:Create(tWDefDropDownButton):GetInstance(self, self.wndButtonList);

				if (tButton.Name) then
					wndButton:SetName(tButton.Name)
				end

				wndButton:SetText(tButton.Text);

				-- Click Event
				if (tButton.OnClick) then
					wndButton:AddEventHandler("ButtonSignal", tButton.OnClick);
				end

				-- Enabled State
				if (tButton.Enabled) then
					wndButton:Enable(tButton.Enabled(self));
				end

				-- Children
				if (tButton.Children and #tButton.Children > 0) then
					wndButton:SetData(tButton.Children);
					wndButton:FindChild("BtnCheckboxArrow"):Show(true, true);
					wndButton:AddEventHandler("MouseEnter", "ShowSubMenu");
				else
					wndButton:AddEventHandler("MouseEnter", "HideSubMenu");
					wndButton:AddEventHandler("MouseMove", "HideSubMenu");
				end
			else
				GeminiGUI:Create(tWDefDropDownSeparator):GetInstance(self, self.wndButtonList);
			end
		end
	end
end

function DropDown:Show()
	self.tAnchorOffsets[4] = self.tAnchorOffsets[2] + self.wndButtonList:ArrangeChildrenVert(0);
	self.wndMain:SetAnchorOffsets(unpack(self.tAnchorOffsets));

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
	end
end

function DropDown:CheckWindowBounds()
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

	local nWidth =  self.wndMain:GetWidth();
	local nHeight = self.wndMain:GetHeight();
	self.tAnchorOffsets = { self.wndMain:GetAnchorOffsets() };

	local nMaxScreenWidth, nMaxScreenHeight = Apollo.GetScreenSize();
	local nNewX = nWidth + nPosX;
	local nNewY = nHeight + nPosY;

	local bSafeX = (nNewX <= nMaxScreenWidth);
	local bSafeY = (nNewY <= nMaxScreenHeight);

	if (not bSafeX) then
		local nRightOffset = nNewX - nMaxScreenWidth;
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
end

function DropDown:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(DropDown, MAJOR, MINOR, { "Gemini:GUI-1.0" });
