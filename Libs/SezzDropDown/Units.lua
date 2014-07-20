--[[

	s:UI Drop Down Menu: Units

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:DropDown-0.1", 1;
local DropDown = Apollo.GetPackage(MAJOR).tPackage;
if (DropDown and (DropDown.nVersion or 0) > MINOR) then return; end

local Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading = Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading;

-----------------------------------------------------------------------------
-- Menu Items
-----------------------------------------------------------------------------

local tMenuItems = {
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
};

-----------------------------------------------------------------------------
-- Drop Down Menu
-----------------------------------------------------------------------------

function DropDown:FindFriend(unit, bAccountFriend)
	-- Untested!
	local strName = unit:GetName();
	local tFriends = bAccountFriend and FriendshipLib.GetAccountList() or FriendshipLib.GetList();

	for _, tFriend in ipairs(tFriends) do
		if (tFriend.strCharacterName == strName) then
			local unitFriend = FriendshipLib.GetUnitById(tFriend.nId);
			if (unitFriend:GetId() == unit:GetId()) then
				return tFriend;
			end
		end
	end
end

function DropDown:OnClickUnit(wndControl, wndHandler)
	if (self.unit and self.unit:IsValid()) then
		local strButton = wndControl:GetName();

		if (not strButton or strButton == "Button") then
			return;
		elseif (strButton == "BtnSetFocus") then
			self.unitPlayer:SetAlternateTarget(self.unit.__proto__ or self.unit);
		elseif (strButton == "BtnClearFocus") then
			self.unitPlayer:SetAlternateTarget();
		end
	end

	self:Close(true);
end

function DropDown:GenerateUnitMenu(unit)
	self.unit = unit;
	self.unitPlayer = GameLib.GetPlayerUnit();
	self.bInGroup = GroupLib.InGroup();
	self.bAmIGroupLeader = GroupLib.AmILeader();
	self.tMyGroupData = GroupLib.GetGroupMember(1);
	self.strTarget = unit:GetName();
	self.tCharacterData = GameLib.SearchRelationshipStatusByCharacterName(strTarget);
	self.tTargetGroupData = (tCharacterData and tCharacterData.nPartyIndex) and GroupLib.GetGroupMember(tCharacterData.nPartyIndex) or nil;
	self.tPlayerFaction = self.unitPlayer:GetFaction();
	self.bIsACharacter = unit:IsACharacter();
	self.bIsThePlayer = unit:IsThePlayer();

	-- Friend (TODO: Testing)
	if (self.bIsACharacter) then
		self.tFriend = self:FindFriend(unit); -- bFriend, bRival, bIgnore
		if (self.tFriend ~= nil) then
			self.strTarget = self.tFriend.strCharacterName;
		end

		self.tAccountFriend = self:FindFriend(unit, true);
		if (self.tAccountFriend ~= nil) then
			if (self.tAccountFriend.arCharacters and self.tAccountFriend.arCharacters[1] ~= nil) then
				self.strTarget = self.tAccountFriend.arCharacters[1].strCharacterName;
			end
		end

		self.bCanAccountWisper = (tAccountFriend ~= nil and tAccountFriend.arCharacters and tAccountFriend.arCharacters[1] ~= nil);
		if (self.bCanAccountWisper) then
			self.bCanWhisper = (tAccountFriend.arCharacters[1] ~= nil and tAccountFriend.arCharacters[1].strRealm == GameLib.GetRealmName() and tAccountFriend.arCharacters[1].nFactionId == self.tPlayerFaction);
		else
			self.bCanWhisper = (self.bIsACharacter and unit:GetFaction() == self.tPlayerFaction and (tFriend == nil or (tFriend ~= nil and not tFriend.bIgnore)));
		end

		self.bIsFriend = (self.tFriend ~= nil and self.tFriend.bFriend) or (self.tCharacterData ~= nil and self.tCharacterData.tFriend ~= nil and self.tCharacterData.tFriend.bFriend);
		self.bIsRival = (self.tFriend ~= nil and self.tFriend.bRival) or (self.tCharacterData ~= nil and self.tCharacterData.tFriend ~= nil and self.tCharacterData.tFriend.bRival);
		self.bIsNeighbor = (self.tFriend ~= nil and self.tFriend.bNeighbor) or (self.tCharacterData ~= nil and self.tCharacterData.tFriend ~= nil and self.tCharacterData.tFriend.bNeighbor);
		self.bIsAccountFriend = (self.tAccountFriend ~= nil or (self.tCharacterData ~= nil and self.tCharacterData.tAccountFriend ~= nil));
	end

	self:CreateWindow();

	if (not self.tParent) then
		self:AddHeader(unit:GetName());
		self:AddItems(tMenuItems);
	end

	return self;
end
