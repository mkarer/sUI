--[[

	s:UI Context Menu: Units (and Friends)

	TODO: BIG FAT conditions cleanup. (Took most of them from ContextMenuPlayer)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:ContextMenu-0.1", 1;
local ContextMenu = Apollo.GetPackage(MAJOR).tPackage;
if (ContextMenu and (ContextMenu.nVersion or 0) > MINOR) then return; end

local Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading, MatchingGame = Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading, MatchingGame;
local strfind, tonumber = string.find, tonumber;

-----------------------------------------------------------------------------
-- Menu Items
-----------------------------------------------------------------------------

local tMenuItems = {
	-- Markers
	{
		Name = "BtnMarkTarget",
		Text = Apollo.GetString("ContextMenu_MarkTarget"),
		Condition = function(self) return (self.bInGroup and self.tMyGroupData.bCanMark and self.unit); end,
		OnClick = "OnClickUnit",
		Children = {
			{
				Name = "BtnMark1",
				Icon = "Icon_Windows_UI_CRB_Marker_Bomb",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 1) end,
			},
			{
				Name = "BtnMark2",
				Icon = "Icon_Windows_UI_CRB_Marker_Ghost",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 2) end,
			},
			{
				Name = "BtnMark3",
				Icon = "Icon_Windows_UI_CRB_Marker_Mask",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 3) end,
			},
			{
				Name = "BtnMark4",
				Icon = "Icon_Windows_UI_CRB_Marker_Octopus",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 4) end,
			},
			{
				Name = "BtnMark5",
				Icon = "Icon_Windows_UI_CRB_Marker_Pig",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 5) end,
			},
			{
				Name = "BtnMark6",
				Icon = "Icon_Windows_UI_CRB_Marker_Chicken",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 6) end,
			},
			{
				Name = "BtnMark7",
				Icon = "Icon_Windows_UI_CRB_Marker_Toaster",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 7) end,
			},
			{
				Name = "BtnMark8",
				Icon = "Icon_Windows_UI_CRB_Marker_UFO",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.unit:GetTargetMarker() == 8) end,
			},
			{
				Name = "BtnMarkClear",
				Icon = "",
				OnClick = "OnClickUnit",
				Checked = function(self) return (not self.unit:GetTargetMarker()) end,
			},
		},
	},
	-- Assist
	{
		Name = "BtnAssist",
		Text = Apollo.GetString("ContextMenu_Assist"),
		Condition = function(self) return (self.unit and self.bIsACharacter and not self.bIsThePlayer); end,
		Enabled = function(self) return (self.unit:GetTarget() ~= nil); end,
		OnClick = "OnClickUnit",
	},
	-- Focus
	{
		Name = "BtnClearFocus",
		Text = Apollo.GetString("ContextMenu_ClearFocus"),
		Condition = function(self) return (self.unit and (self.unitPlayer:GetAlternateTarget() and self.unit:GetId() == self.unitPlayer:GetAlternateTarget():GetId())); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnSetFocus",
		Text = Apollo.GetString("ContextMenu_SetFocus"),
		Condition = function(self) return (self.unit and (not self.unitPlayer:GetAlternateTarget() or self.unit:GetId() ~= self.unitPlayer:GetAlternateTarget():GetId())); end,
		OnClick = "OnClickUnit",
	},
	-- Inspect
	{
		Name = "BtnInspect",
		Text = Apollo.GetString("ContextMenu_Inspect"),
		Condition = function(self) return (self.unit and self.bIsACharacter); end,
		OnClick = "OnClickUnit",
	},
	-- Group (Mentor/Locate/etc.)
	{
		Name = "BtnGroupList",
		Text = Apollo.GetString("ChatType_Party"),
		Condition = function(self) return (self.bInGroup and self.bIsACharacter and not self.bIsOfflineAccountFriend); end,
		Children = {
			{
				Name = "BtnLocate",
				Text = Apollo.GetString("ContextMenu_Locate"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.unit and self.tTargetGroupData and self.tTargetGroupData.bIsOnline and not self.tTargetGroupData.bDisconnected); end, -- Additional tTargetGroupData checks for sUF!
			},
			{
				Name = "BtnPromote",
				Text = Apollo.GetString("ContextMenu_Promote"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader); end,
				Enabled = function(self) return (self.tTargetGroupData.bIsOnline and not self.tTargetGroupData.bDisconnected); end, -- We don't want a leader who is offline...
			},
			{
				Name = "BtnVoteToDisband",
				Text = Apollo.GetString("ContextMenu_VoteToDisband"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bInMatchingGame and not self.bIsMatchingGameFinished and MatchingGame:GetPVPMatchState() ~= MatchingGame.Rules.DeathmatchPool); end,
				Enabled = function(self) return (not MatchingGame.IsVoteSurrenderActive()); end,
			},
			{
				Name = "BtnVoteToKick",
				Text = Apollo.GetString("ContextMenu_VoteToKick"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bInMatchingGame and not self.bIsMatchingGameFinished); end,
			},
			{
				Name = "BtnKick",
				Text = Apollo.GetString("ContextMenu_Kick"),
				Condition = function(self) return (not self.bIsThePlayer and self.nGroupMemberId and self.tMyGroupData.bCanKick); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnGroupGiveKick",
				Text = Apollo.GetString("ContextMenu_AllowKicks"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader and not self.tTargetGroupData.bCanKick); end,
			},
			{
				Name = "BtnGroupTakeKick",
				Text = Apollo.GetString("ContextMenu_DenyKicks"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader and self.tTargetGroupData.bCanKick); end,
			},
			{
				Name = "BtnGroupGiveInvite",
				Text = Apollo.GetString("ContextMenu_AllowInvites"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader and not self.tTargetGroupData.bCanInvite); end,
			},
			{
				Name = "BtnGroupTakeInvite",
				Text = Apollo.GetString("ContextMenu_DenyInvites"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader and self.tTargetGroupData.bCanInvite); end,
			},
			{
				Name = "BtnGroupGiveMark",
				Text = Apollo.GetString("ContextMenu_AllowMarking"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader and not self.tTargetGroupData.bCanMark); end,
			},
			{
				Name = "BtnGroupTakeMark",
				Text = Apollo.GetString("ContextMenu_DenyMarking"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.nGroupMemberId and self.tTargetGroupData and self.bAmIGroupLeader and self.tTargetGroupData.bCanMark); end,
			},
			{
				Name = "BtnMentor",
				Text = Apollo.GetString("ContextMenu_Mentor"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.unit and not self.bIsThePlayer and not bMentoringTarget and self.tTargetGroupData and self.tTargetGroupData.bIsOnline and not self.tTargetGroupData.bDisconnected); end, -- Additional tTargetGroupData checks for sUF!
			},
			{
				Name = "BtnStopMentor",
				Text = Apollo.GetString("ContextMenu_StopMentor"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tMyGroupData.bIsMentoring or self.tMyGroupData.bIsMentored); end,
			},
		},
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
				Condition = function(self) return (not self.bIsFriend and (not self.unit or self.unit:GetFaction() == self.unitPlayer:GetFaction())); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnfriend",
				Text = Apollo.GetString("ContextMenu_RemoveFriend"),
				Condition = function(self) return (self.bIsFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAddRival",
				Text = Apollo.GetString("ContextMenu_AddRival"),
				Condition = function(self) return (not self.bIsRival); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnrival",
				Text = Apollo.GetString("ContextMenu_RemoveRival"),
				Condition = function(self) return (self.bIsRival and not self.tAccountFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAddNeighbor",
				Text = Apollo.GetString("ContextMenu_AddNeighbor"),
				Condition = function(self) return (not self.bIsNeighbor and (not self.unit or self.unit:GetFaction() == self.unitPlayer:GetFaction())); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnneighbor",
				Text = Apollo.GetString("ContextMenu_RemoveNeighbor"),
				Condition = function(self) return (self.bIsNeighbor and not self.tAccountFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAccountFriend",
				Text = Apollo.GetString("ContextMenu_PromoteFriend"),
				Condition = function(self) return (self.bIsFriend and not self.bIsAccountFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnaccountFriend",
				Text = Apollo.GetString("ContextMenu_UnaccountFriend"),
				Condition = function(self) return (self.tAccountFriend ~= nil); end,
				OnClick = "OnClickUnit",
			},
		},
	},
	-- Ignore
	{
		Name = "BtnIgnore",
		Text = Apollo.GetString("ContextMenu_Ignore"),
		Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer and not (self.tFriend and self.tFriend.bIgnore) and (self.tAccountFriend == nil or self.tAccountFriend.fLastOnline == 0)); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnUnignore",
		Text = Apollo.GetString("ContextMenu_Unignore"),
		Condition = function(self) return (self.tFriend and self.tFriend.bIgnore); end,
		OnClick = "OnClickUnit",
	},
	-- Duel
	{
		Name = "BtnDuel",
		Text = Apollo.GetString("ContextMenu_Duel"),
		OnClick = "OnClickUnit",
		Condition = function(self)
			local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules();
			return (self.unit and (not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.bIsACharacter and not self.bIsThePlayer and not GameLib.GetDuelOpponent(self.unitPlayer));
		end,
	},
	{
		Name = "BtnForfeit",
		Text = Apollo.GetString("ContextMenu_ForfeitDuel"),
		OnClick = "OnClickUnit",
		Condition = function(self)
			local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules();
			return (self.unit and (not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.bIsACharacter and not self.bIsThePlayer and GameLib.GetDuelOpponent(self.unitPlayer));
		end,
	},
	-- Trade
	{
		Name = "BtnTrade",
		Text = Apollo.GetString("ContextMenu_Trade"),
		Condition = function(self) return (self.unit and self.bIsACharacter and not self.bIsThePlayer); end,
		OnClick = "OnClickUnit",
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
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnAccountWhisper",
		Text = Apollo.GetString("ContextMenu_AccountWhisper"),
		Condition = function(self) return (not self.bIsThePlayer and self.bCanAccountWisper); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnInvite",
		Text = Apollo.GetString("ContextMenu_InviteToGroup"),
		Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer and not self.nGroupMemberId and (not self.bInGroup or (self.tMyGroupData.bCanInvite and self.bCanWhisper))); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnLeaveGroup",
		Text = Apollo.GetString("ContextMenu_LeaveGroup"),
		Condition = function(self) return (self.bIsThePlayer and self.bInGroup); end,
		OnClick = "OnClickUnit",
	},
};

-----------------------------------------------------------------------------
-- Context Menu
-----------------------------------------------------------------------------

function ContextMenu:OnClickUnit(wndControl, wndHandler)
	local strButton = wndControl:GetName();

	if (not strButton or strButton == "Button") then
		return;
	elseif (strButton == "BtnSetFocus") then
		-- Set Focus
		if (self.unit) then
			self.unitPlayer:SetAlternateTarget(self.unit.__proto__ or self.unit);
		end
	elseif (strButton == "BtnClearFocus") then
		-- Clear Focus
		self.unitPlayer:SetAlternateTarget();
	elseif (strButton == "BtnMarkTarget") then
		-- Set First Available Mark
		if (self.unit) then
			local nResult = 8;
			local nCurrent = self.unit:GetTargetMarker() or 0;
			local tAvailableMarkers = GameLib.GetAvailableTargetMarkers();
			for idx = nCurrent, 8 do
				if (tAvailableMarkers[idx]) then
					nResult = idx;
					break;
				end
			end
			self.unit:SetTargetMarker(nResult);
		end
	elseif (strButton == "BtnMarkClear") then
		if (self.unit) then
			self.unit:ClearTargetMarker();
		end
	elseif (strfind(strButton, "BtnMark(%d)")) then
		if (self.unit) then
			local _, _, strMark = strfind(strButton, "BtnMark(%d)");
			strMark = tonumber(strMark);

			if (wndControl:IsChecked() and strMark < 8) then
				self.unit:SetTargetMarker(strMark);
			else
				self.unit:ClearTargetMarker();
			end
		end
	elseif (strButton == "BtnAssist") then
		if (self.unit) then
			GameLib.SetTargetUnit(self.unit:GetTarget());
		end
	elseif (strButton == "BtnInspect") then
		if (self.unit) then
			self.unit:Inspect();
		end
	elseif (strButton == "BtnAddFriend") then
		FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Friend, self.strTarget);
	elseif (strButton == "BtnUnfriend") then
		FriendshipLib.Remove(self.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Friend);
	elseif (strButton == "BtnAccountFriend") then
		FriendshipLib.AccountAddByUpgrade(self.tCharacterData.tFriend.nId);
	elseif (strButton == "BtnUnaccountFriend") then
		if (self.tAccountFriend and self.tAccountFriend.nId) then
			Event_FireGenericEvent("EventGeneric_ConfirmRemoveAccountFriend", self.tAccountFriend.nId); -- TODO
		end
	elseif (strButton == "BtnAddRival") then
		FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Rival, self.strTarget);
	elseif (strButton == "BtnUnrival") then
		FriendshipLib.Remove(self.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Rival);
	elseif (strButton == "BtnAddNeighbor") then
		HousingLib.NeighborInviteByName(self.strTarget);
	elseif (strButton == "BtnUnneighbor") then
		Print(Apollo.GetString("ContextMenu_NeighborRemoveFailed")); -- TODO
	elseif (strButton == "BtnIgnore") then
		FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Ignore, self.strTarget);
	elseif (strButton == "BtnUnignore") then
		FriendshipLib.Remove(self.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Ignore);
	elseif (strButton == "BtnDuel") then
		GameLib.InitiateDuel(self.unit);
	elseif (strButton == "BtnForfeit") then
		GameLib.ForfeitDuel(self.unit);
	elseif (strButton == "BtnTrade") then
		local eCanTradeResult = P2PTrading.CanInitiateTrade(self.unit);
		if (eCanTradeResult == P2PTrading.P2PTradeError_Ok) then
			Event_FireGenericEvent("P2PTradeWithTarget", self.unit);
		elseif (eCanTradeResult == P2PTrading.P2PTradeError_TargetRangeMax) then
			Event_FireGenericEvent("GenericFloater", self.unitPlayer, Apollo.GetString("ContextMenu_PlayerOutOfRange"));
			self.unit:ShowHintArrow();
		else
			Event_FireGenericEvent("GenericFloater", self.unitPlayer, Apollo.GetString("ContextMenu_TradeFailed"));
		end
	elseif (strButton == "BtnWhisper") then
		Event_FireGenericEvent("GenericEvent_ChatLogWhisper", self.strTarget);
	elseif (strButton == "BtnAccountWhisper") then
		if (self.tCharacterData.tAccountFriend ~= nil and self.tCharacterData.tAccountFriend.arCharacters ~= nil and self.tCharacterData.tAccountFriend.arCharacters[1] ~= nil) then
			local strDisplayName = self.tCharacterData.tAccountFriend.strCharacterName;
			local strRealmName = self.tCharacterData.tAccountFriend.arCharacters[1].strRealm;
			Event_FireGenericEvent("Event_EngageAccountWhisper", strDisplayName, self.strTarget, strRealmName);
		end
	elseif (strButton == "BtnInvite") then
		GroupLib.Invite(self.strTarget);
	elseif (strButton == "BtnKick") then
		GroupLib.Kick(self.nGroupMemberId);
	elseif (strButton == "BtnLeaveGroup") then
		GroupLib.LeaveGroup();
	-- TODO
	elseif (strButton == "BtnPromote") then
		GroupLib.Promote(self.nGroupMemberId, "");
	elseif (strButton == "BtnGroupGiveMark") then
		GroupLib.SetCanMark(self.nGroupMemberId, true);
	elseif (strButton == "BtnGroupTakeMark") then
		GroupLib.SetCanMark(self.nGroupMemberId, false);
	elseif (strButton == "BtnGroupGiveKick") then
		GroupLib.SetKickPermission(self.nGroupMemberId, true);
	elseif (strButton == "BtnGroupTakeKick") then
		GroupLib.SetKickPermission(self.nGroupMemberId, false);
	elseif (strButton == "BtnGroupGiveInvite") then
		GroupLib.SetInvitePermission(self.nGroupMemberId, true);
	elseif (strButton == "BtnGroupTakeInvite") then
		GroupLib.SetInvitePermission(self.nGroupMemberId, false);
	elseif (strButton == "BtnLocate") then
		if (self.unit) then
			self.unit:ShowHintArrow();
		end
	elseif (strButton == "BtnMarkClear") then
		self.unit:ClearTargetMarker();
	elseif (strButton == "BtnVoteToDisband") then
		MatchingGame.InitiateVoteToSurrender();
	elseif (strButton == "BtnVoteToKick") then
		MatchingGame.InitiateVoteToKick(self.nGroupMemberId);
	elseif (strButton == "BtnMentor") then
		GroupLib.AcceptMentoring(self.unit);
	elseif (strButton == "BtnStopMentor") then
		GroupLib.CancelMentoring();
	elseif (strButton == "BtnReportChat" and self.nReportId) then
		local tResult = ChatSystemLib.PrepareInfractionReport(self.nReportId);
		self:BuildReportConfirmation(tResult.strDescription, tResult.bSuccess);
	elseif (strButton and string.find(strButton, "BtnMark") ~= 0) then
		self.unit:SetTargetMarker(tonumber(string.sub(strButton, string.len("BtnMark_"))));
	end

	self:Close(true);
end

function ContextMenu:FindFriend(strName, bAccountFriend)
	local strRealm = GameLib.GetRealmName();
	local tFriends = bAccountFriend and FriendshipLib.GetAccountList() or FriendshipLib.GetList();

	for _, tFriend in ipairs(tFriends) do
		if (not bAccountFriend and tFriend.strCharacterName == strName and tFriend.strRealmName == strRealm) then
			return tFriend;
		elseif (bAccountFriend and tFriend.arCharacters) then
			for _, tCharacter in ipairs(tFriend.arCharacters) do
				if (tCharacter.strCharacterName == strName and tCharacter.strRealm == strRealm) then
					return tFriend;
				end
			end
		end
	end
end

function ContextMenu:GenerateUnitMenu(unit)
	if (not unit) then return; end

	-- Player
	self.unitPlayer = GameLib.GetPlayerUnit();
	self.bInGroup = GroupLib.InGroup();
	self.bAmIGroupLeader = GroupLib.AmILeader();
	self.tMyGroupData = GroupLib.GetGroupMember(1);
	self.tPlayerFaction = self.unitPlayer:GetFaction();

	-- Check if Unitstring is the Player (TODO: Can unit string come from another realm?)
	if (type(unit) == "string" and unit == self.unitPlayer:GetName()) then
		unit = self.unitPlayer;
	end

	-- Friend IDs
	if (type(unit) == "number") then
		self.bFriendMenu = true;
		self.nFriendId = unit;
		self.tFriend = FriendshipLib.GetById(unit);
		self.tAccountFriend = FriendshipLib.GetAccountById(unit);

		if (self.tFriend) then
			unit = self.tFriend.strCharacterName;
		elseif (self.tAccountFriend) then
			if (self.tAccountFriend.arCharacters and self.tAccountFriend.arCharacters[1]) then
				unit = self.tAccountFriend.arCharacters[1].strCharacterName;
			else
				-- Offline Account Friend
				self.bIsOfflineAccountFriend = true;
				unit = self.tAccountFriend.strCharacterName;
			end
		end
	end

	if (type(unit) == "string") then
		-- Unitless Properties
		self.unit = nil;
		self.strTarget = unit;
		self.bIsACharacter = true; -- TODO
		self.bIsThePlayer = false;
	else
		-- Unit Properties
		self.unit = unit;
		self.strTarget = unit:GetName();
		self.bIsACharacter = unit:IsACharacter();
		self.bIsThePlayer = unit:IsThePlayer();
	end

	self.tCharacterData = GameLib.SearchRelationshipStatusByCharacterName(self.strTarget);
	self.nGroupMemberId = (self.tCharacterData and self.tCharacterData.nPartyIndex) or nil;
	self.tTargetGroupData = (not self.bIsThePlayer and self.tCharacterData and self.tCharacterData.nPartyIndex) and GroupLib.GetGroupMember(self.tCharacterData.nPartyIndex) or nil;

	-- Mentoring
	if (self.bInGroup and not self.bIsThePlayer and self.tTargetGroupData) then
		local bMentoringTarget = false;
		for _, nMentorIdx in ipairs(self.tTargetGroupData.tMentoredBy) do
			if (tMyGroupData.nMemberIdx == nMentorIdx) then
				bMentoringTarget = true;
				break
			end
		end

		if (self.tTargetGroupData.bIsOnline and not bMentoringTarget and self.tTargetGroupData.nLevel < self.tMyGroupData.nLevel) then
			self.bMentoringTarget = true;
		end
	end

	-- Friend (TODO: Testing)
	if (self.bIsACharacter) then
		if (not self.bFriendMenu) then
			self.tFriend = self:FindFriend(self.strTarget); -- bFriend, bRival, bIgnore
			self.tAccountFriend = self:FindFriend(self.strTarget, true);
			self.nFriendId = (self.tFriend and self.tFriend.nId) or (self.tAccountFriend and self.tAccountFriend.nId) or nil;
		end

		self.bCanAccountWisper = not self.bIsOfflineAccountFriend and (self.tAccountFriend ~= nil and self.tAccountFriend.arCharacters and self.tAccountFriend.arCharacters[1] ~= nil);
		if (self.bCanAccountWisper) then
--			self.bCanWhisper = (self.tAccountFriend.arCharacters[1] ~= nil and self.tAccountFriend.arCharacters[1].strRealm == GameLib.GetRealmName() and self.tAccountFriend.arCharacters[1].nFactionId == self.tPlayerFaction);
			self.bCanWhisper = (self.tAccountFriend.arCharacters[1].nFactionId == self.tPlayerFaction);
		else
			self.bCanWhisper = not self.bIsOfflineAccountFriend and (self.bIsACharacter and (not self.unit or (self.unit and self.unit:GetFaction() == self.tPlayerFaction)) and (self.tFriend == nil or (self.tFriend ~= nil and not self.tFriend.bIgnore)));
		end

		self.bIsFriend = (self.tFriend ~= nil and self.tFriend.bFriend) or (self.tCharacterData ~= nil and self.tCharacterData.tFriend ~= nil and self.tCharacterData.tFriend.bFriend);
		self.bIsRival = (self.tFriend ~= nil and self.tFriend.bRival) or (self.tCharacterData ~= nil and self.tCharacterData.tFriend ~= nil and self.tCharacterData.tFriend.bRival);
		self.bIsNeighbor = (self.tFriend ~= nil and self.tFriend.bNeighbor) or (self.tCharacterData ~= nil and self.tCharacterData.tFriend ~= nil and self.tCharacterData.tFriend.bNeighbor);
		self.bIsAccountFriend = (self.tAccountFriend ~= nil or (self.tCharacterData ~= nil and self.tCharacterData.tAccountFriend ~= nil));
	end

	-- PVP
	self.bInMatchingGame = MatchingGame.IsInMatchingGame();
	self.bIsMatchingGameFinished = MatchingGame.IsMatchingGameFinished();

	-- Create Window
	self:CreateWindow();

	if (not self.tParent) then
		self:AddHeader(self.strTarget);
		self:AddItems(tMenuItems);
	end

	return self;
end

--[[
local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local log = S.Log;
]]