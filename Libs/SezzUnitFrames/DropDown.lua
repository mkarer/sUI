--[[

	s:UI Unit Drop Down Menus

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
if (UnitFrameController.ToggleMenu) then return; end

local GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
local Apollo, GameLib, GroupLib, FriendshipLib = Apollo, GameLib, GroupLib, FriendshipLib;
local max, strlen = math.max, string.len;

-----------------------------------------------------------------------------

local knXCursorOffset = -20;
local knYCursorOffset = -6;
local wndDropDown;

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
		{
			Name = "BtnLeaveGroup",
			Text = Apollo.GetString("ContextMenu_LeaveGroup"),
		},
		{
			Name = "BtnKick",
			Text = Apollo.GetString("ContextMenu_Kick"),
		},
		{
			Name = "BtnInvite",
			Text = Apollo.GetString("ContextMenu_Invite"),
		},
		{
			Name = "BtnWhisper",
			Text = Apollo.GetString("ContextMenu_Whisper"),
		},
		{
			Name = "BtnAccountWhisper",
			Text = Apollo.GetString("ContextMenu_AccountWhisper"),
		},
		{
			Name = "BtnTrade",
			Text = Apollo.GetString("ContextMenu_Trade"),
		},
		{
			Name = "BtnDuel",
			Text = Apollo.GetString("ContextMenu_Duel"),
		},
		{
			Name = "BtnForfeit",
			Text = Apollo.GetString("ContextMenu_ForfeitDuel"),
		},
		{
			Name = "BtnUnignore",
			Text = Apollo.GetString("ContextMenu_Unignore"),
		},
		{
			Name = "BtnIgnore",
			Text = Apollo.GetString("ContextMenu_Ignore"),
		},
		-- Social
		{
			Name = "BtnSocialList",
			Text = Apollo.GetString("ContextMenu_SocialLists"),
			Children = {
				{
					Name = "BtnAddFriend",
					Text = Apollo.GetString("ContextMenu_AddFriend"),
				},
				{
					Name = "BtnUnfriend",
					Text = Apollo.GetString("ContextMenu_RemoveFriend"),
				},
				{
					Name = "BtnAccountFriend",
					Text = Apollo.GetString("ContextMenu_PromoteFriend"),
				},
				{
					Name = "BtnUnaccountFriend",
					Text = Apollo.GetString("ContextMenu_UnaccountFriend"),
				},
				{
					Name = "BtnAddRival",
					Text = Apollo.GetString("ContextMenu_AddRival"),
				},
				{
					Name = "BtnUnrival",
					Text = Apollo.GetString("ContextMenu_RemoveRival"),
				},
				{
					Name = "BtnAddNeighbor",
					Text = Apollo.GetString("ContextMenu_AddNeighbor"),
				},
				{
					Name = "BtnUnneighbor",
					Text = Apollo.GetString("ContextMenu_RemoveNeighbor"),
				},
			},
		},
		{
			Name = "BtnGroupList",
			Text = Apollo.GetString("ChatType_Party"),
		},
		{
			Name = "BtnInspect",
			Text = Apollo.GetString("ContextMenu_Inspect"),
		},
		-- Focus
		{
			Name = "BtnClearFocus",
			Text = Apollo.GetString("ContextMenu_ClearFocus"),
			Condition = function(self) return (self.unit and unitPlayer:GetAlternateTarget() and self.unit:GetId() == unitPlayer:GetAlternateTarget():GetId()); end,
			OnClick = "OnClickUnit",
		},
		{
			Name = "BtnSetFocus",
			Text = Apollo.GetString("ContextMenu_SetFocus"),
			Condition = function(self) return (self.unit and (not unitPlayer:GetAlternateTarget() or self.unit:GetId() ~= unitPlayer:GetAlternateTarget():GetId())); end,
			OnClick = "OnClickUnit",
		},
		{
			Name = "BtnAssist",
			Text = Apollo.GetString("ContextMenu_Assist"),
		},
		-- Markers
		{
			Name = "BtnMarkTarget",
			Text = Apollo.GetString("ContextMenu_MarkTarget"),
			Condition = function(self) return not self.bInGroup or (self.bInGroup and self.tMyGroupData.bCanMark); end,
			Children = {
				-- TODO
			},
		},
		{
			Name = "BtnMarkerList",
			Text = Apollo.GetString("ContextMenu_SpecificMark"),
			Condition = function(self) return not self.bInGroup or (self.bInGroup and self.tMyGroupData.bCanMark); end,
		},
	},
};

-----------------------------------------------------------------------------
-- Drop Down Menu
-----------------------------------------------------------------------------

local DropDown = {
};

function DropDown:Init(strType, oData)
	-- Cleanup
	if (self.wndMain and self.wndMain:IsValid()) then
		self.wndMain:Destroy();
	end

	for strKey in pairs(self) do
		if (type(self[strKey]) ~= "function") then
			self[strKey] = nil;
		end
	end

	-- Initialize
	if (strType == "Unit") then
		self.unit = oData;

		self.unitPlayer = GameLib.GetPlayerUnit();
		self.bInGroup = GroupLib.InGroup();
		self.bAmIGroupLeader = GroupLib.AmILeader();
		self.tMyGroupData = GroupLib.GetGroupMember(1);
		self.strTarget = self.unit:GetName();
		self.tCharacterData = GameLib.SearchRelationshipStatusByCharacterName(strTarget);
		self.tTargetGroupData = (tCharacterData and tCharacterData.nPartyIndex) and GroupLib.GetGroupMember(tCharacterData.nPartyIndex) or nil;
		self.strTitle = self.unit:GetName();
		self.tPlayerFaction = self.unitPlayer:GetFaction();

		local nFriendId = nil;
		if (nFriendId) then
			self.tFriend = FriendshipLib.GetById(nFriendId)
			if (self.tFriend ~= nil) then
				self.strTarget = self.tFriend.strCharacterName;
			end

			self.tAccountFriend = FriendshipLib.GetAccountById(nFriendId);
			if (self.tAccountFriend ~= nil) then
				if (self.tAccountFriend.arCharacters and self.tAccountFriend.arCharacters[1] ~= nil) then
					self.strTarget = self.tAccountFriend.arCharacters[1].strCharacterName;
				end
			end
		end
	else
		-- Invalid Menu Type
		return;
	end

	-- Create Window
	self.wndMain = GeminiGUI:Create(tWDefDropDownMenu):GetInstance(self, "TooltipStratum");
	self.wndMain:Invoke();
	self.wndButtonList = self.wndMain:FindChild("ButtonList");
	self.tAnchorOffsets = { self.wndMain:GetAnchorOffsets() };

	-- Set Content
	self:AddHeader(self.strTitle);
	self:AddItems(tMenuItems[strType]);

	return self.wndMain;
end

function DropDown:AddHeader(strTitle)
	if (not strTitle or strlen(strTitle) == 0) then return; end

	local wndTitle = GeminiGUI:Create(tWDefMenuTitle):GetInstance(self, self.wndButtonList);
	
	self.tAnchorOffsets[3] = max(150, Apollo.GetTextWidth(tWDefMenuTitle.Font, strTitle) + 10);
	wndTitle:SetText(strTitle);
end

function DropDown:AddItems(tItems)
	if (type(tItems) ~= "table") then return; end

	for _, tButton in ipairs(tItems) do
		if (not tButton.Condition or tButton.Condition(self)) then
			if (tButton.Text) then
				local wndButton = GeminiGUI:Create(tWDefDropDownButton):GetInstance(tButton, self.wndButtonList);

				if (tButton.Name) then
					wndButton:SetName(tButton.Name)
				end

				wndButton:SetText(tButton.Text);

				if (tButton.OnClick) then
					wndButton:AddEventHandler("ButtonSignal", tButton.OnClick, self);
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

	local tCursor = Apollo.GetMouse();
	self.wndMain:Move(tCursor.x - knXCursorOffset, tCursor.y - knYCursorOffset, self.wndMain:GetWidth(), self.wndMain:GetHeight());
	self:CheckWindowBounds();
end

function DropDown:CheckWindowBounds()
	local tMouse = Apollo.GetMouse();
	local nWidth =  self.wndMain:GetWidth();
	local nHeight = self.wndMain:GetHeight();
	self.tAnchorOffsets = { self.wndMain:GetAnchorOffsets() };

	local nMaxScreenWidth, nMaxScreenHeight = Apollo.GetScreenSize();
	local nNewX = nWidth + tMouse.x - knXCursorOffset + 10; -- Holo border needs ~10px
	local nNewY = nHeight + tMouse.y - knYCursorOffset + 10; -- Holo border needs ~10px

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

function DropDown:OnClickUnit(wndControl, wndHandler)
	local wndDropDown = wndControl:GetParent():GetParent();
	local unit = wndDropDown:GetData();
	if (not unit) then return; end

	local strButton = wndControl:GetName();
	if (not strButton or strButton == "Button") then
		return;
	elseif (strButton == "BtnSetFocus") then
		unitPlayer:SetAlternateTarget(unit.__proto__ or unit);
	elseif (strButton == "BtnClearFocus") then
		unitPlayer:SetAlternateTarget();
	end

	wndDropDown:Close();
end


-----------------------------------------------------------------------------

local function CreateDropDownMenu(strType, oData)
	-- Destroy old menu
	if (wndDropDown and wndDropDown:IsValid()) then
		wndDropDown:Destroy();
	end

	-- Create Container
	wndDropDown = GeminiGUI:Create(tWDefDropDownMenu):GetInstance(self, "TooltipStratum");
	wndDropDown:SetData(oData);
	wndDropDown:Invoke();
	local nLeft, nTop, nRight, nBottom = wndDropDown:GetAnchorOffsets();

	-- Create Buttons
	local wndButtonList = wndDropDown:FindChild("ButtonList");

	-- Title
	if (tMenuTitles[strType]) then
		local wndButton = GeminiGUI:Create(tWDefMenuTitle):GetInstance(nil, wndButtonList);
		local strTitle = type(tMenuTitles[strType]) ~= "function" and tMenuTitles[strType] or tMenuTitles[strType](oData);
		wndButton:SetText(strTitle);
		nRight = max(150, Apollo.GetTextWidth(tWDefMenuTitle.Font, strTitle) + 10);
	end

	-- Buttons
	for _, tButton in ipairs(tMenuItems[strType]) do
		if (not tButton.Condition or tButton.Condition(oData)) then
			if (tButton.Text) then
				local wndButton = GeminiGUI:Create(tWDefDropDownButton):GetInstance(tButton, wndButtonList);

				if (tButton.Name) then
					wndButton:SetName(tButton.Name)
				end

				wndButton:SetText(tButton.Text);

				if (tButton.OnClick) then
					wndButton:AddEventHandler("ButtonSignal", tButton.OnClick, DropDown);
				end
			else
				GeminiGUI:Create(tWDefDropDownSeparator):GetInstance(self, wndButtonList);
			end
		end
	end

	-- Arrange Buttons
	local nHeight = wndButtonList:ArrangeChildrenVert(0);
	wndDropDown:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nHeight);

	-- Set Position to Cursor
	local tCursor = Apollo.GetMouse();
	wndDropDown:Move(tCursor.x - knXCursorOffset, tCursor.y - knYCursorOffset, wndDropDown:GetWidth(), wndDropDown:GetHeight());
	CheckWindowBounds();

	-- Done
	return wndDropDown;
end

function UnitFrameController:ToggleMenu(unit)
	local bInRaid, bInGroup, nGroupSize = GroupLib.InRaid(), GroupLib.InGroup(), GroupLib.GetMemberCount();
	local bShowLeaderOptions = ((bInGroup or bInRaid) and unit:IsThePlayer() and GroupLib.GetGroupMember(1).bIsLeader);

	unitPlayer = GameLib.GetPlayerUnit();
--	Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, unit:GetName(), unit.__proto__ or unit);
--	CreateDropDownMenu("Unit", unit);



	if (DropDown:Init("Unit", unit)) then
		DropDown:Show();
	end
end
