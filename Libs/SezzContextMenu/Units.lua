--[[

	s:UI Context Menu: Units (and Friends)

	TODO: BIG FAT conditions cleanup. (Took most of them from ContextMenuPlayer)

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:ContextMenu-0.1", 1;
local ContextMenu = Apollo.GetPackage(MAJOR).tPackage;
if (ContextMenu and (ContextMenu.nVersion or 0) > MINOR) then return; end

local Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading, MatchingGame, ChatSystemLib = Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading, MatchingGame, ChatSystemLib;
local strfind, tonumber = string.find, tonumber;

-----------------------------------------------------------------------------
-- Menu Items
-----------------------------------------------------------------------------

local tMenuItems = {
	-- Markers
	{
		Name = "BtnMarkTarget",
		Text = Apollo.GetString("ContextMenu_MarkTarget"),
		Condition = function(self) return (self.tData.bInGroup and self.tData.tMyGroupData.bCanMark and self.tData.unit); end,
		OnClick = "OnClickUnit",
		Children = {
			{
				Name = "BtnMark1",
				Icon = "Icon_Windows_UI_CRB_Marker_Bomb",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 1) end,
			},
			{
				Name = "BtnMark2",
				Icon = "Icon_Windows_UI_CRB_Marker_Ghost",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 2) end,
			},
			{
				Name = "BtnMark3",
				Icon = "Icon_Windows_UI_CRB_Marker_Mask",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 3) end,
			},
			{
				Name = "BtnMark4",
				Icon = "Icon_Windows_UI_CRB_Marker_Octopus",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 4) end,
			},
			{
				Name = "BtnMark5",
				Icon = "Icon_Windows_UI_CRB_Marker_Pig",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 5) end,
			},
			{
				Name = "BtnMark6",
				Icon = "Icon_Windows_UI_CRB_Marker_Chicken",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 6) end,
			},
			{
				Name = "BtnMark7",
				Icon = "Icon_Windows_UI_CRB_Marker_Toaster",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 7) end,
			},
			{
				Name = "BtnMark8",
				Icon = "Icon_Windows_UI_CRB_Marker_UFO",
				OnClick = "OnClickUnit",
				Checked = function(self) return (self.tData.unit:GetTargetMarker() == 8) end,
			},
			{
				Name = "BtnMarkClear",
				Icon = "",
				OnClick = "OnClickUnit",
				Checked = function(self) return (not self.tData.unit:GetTargetMarker()) end,
			},
		},
	},
	-- Assist
	{
		Name = "BtnAssist",
		Text = Apollo.GetString("ContextMenu_Assist"),
		Condition = function(self) return (self.tData.unit and self.tData.bIsACharacter and not self.tData.bIsThePlayer); end,
		Enabled = function(self) return (self.tData.unit:GetTarget() ~= nil); end,
		OnClick = "OnClickUnit",
	},
	-- Focus
	{
		Name = "BtnClearFocus",
		Text = Apollo.GetString("ContextMenu_ClearFocus"),
		Condition = function(self) return (self.tData.unit and (self.tData.unitPlayer:GetAlternateTarget() and self.tData.unit:GetId() == self.tData.unitPlayer:GetAlternateTarget():GetId())); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnSetFocus",
		Text = Apollo.GetString("ContextMenu_SetFocus"),
		Condition = function(self) return (self.tData.unit and (not self.tData.unitPlayer:GetAlternateTarget() or self.tData.unit:GetId() ~= self.tData.unitPlayer:GetAlternateTarget():GetId())); end,
		OnClick = "OnClickUnit",
	},
	-- Inspect
	{
		Name = "BtnInspect",
		Text = Apollo.GetString("ContextMenu_Inspect"),
		Condition = function(self) return (self.tData.unit and self.tData.bIsACharacter); end,
		OnClick = "OnClickUnit",
	},
	-- Group (Mentor/Locate/etc.)
	{
		Name = "BtnGroupList",
		Text = Apollo.GetString("ChatType_Party"),
		Condition = function(self) return (self.tData.bInGroup and self.tData.bIsACharacter and not self.tData.bIsOfflineAccountFriend); end,
		Children = {
			{
				Name = "BtnLocate",
				Text = Apollo.GetString("ContextMenu_Locate"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.unit and self.tData.tTargetGroupData and self.tData.tTargetGroupData.bIsOnline and not self.tData.tTargetGroupData.bDisconnected); end, -- Additional tTargetGroupData checks for sUF!
			},
			{
				Name = "BtnPromote",
				Text = Apollo.GetString("ContextMenu_Promote"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader); end,
				Enabled = function(self) return (self.tData.tTargetGroupData.bIsOnline and not self.tData.tTargetGroupData.bDisconnected); end, -- We don't want a leader who is offline...
			},
			{
				Name = "BtnVoteToDisband",
				Text = Apollo.GetString("ContextMenu_VoteToDisband"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.tTargetGroupData and self.tData.bInMatchingGame and not self.tData.bIsMatchingGameFinished and MatchingGame:GetPVPMatchState() ~= MatchingGame.Rules.DeathmatchPool); end,
				Enabled = function(self) return (not MatchingGame.IsVoteSurrenderActive()); end,
			},
			{
				Name = "BtnVoteToKick",
				Text = Apollo.GetString("ContextMenu_VoteToKick"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bInMatchingGame and not self.tData.bIsMatchingGameFinished); end,
			},
			{
				Name = "BtnKick",
				Text = Apollo.GetString("ContextMenu_Kick"),
				Condition = function(self) return (not self.tData.bIsThePlayer and self.tData.nGroupMemberId and self.tData.tMyGroupData.bCanKick); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnGroupGiveKick",
				Text = Apollo.GetString("ContextMenu_AllowKicks"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader and not self.tData.tTargetGroupData.bCanKick); end,
			},
			{
				Name = "BtnGroupTakeKick",
				Text = Apollo.GetString("ContextMenu_DenyKicks"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader and self.tData.tTargetGroupData.bCanKick); end,
			},
			{
				Name = "BtnGroupGiveInvite",
				Text = Apollo.GetString("ContextMenu_AllowInvites"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader and not self.tData.tTargetGroupData.bCanInvite); end,
			},
			{
				Name = "BtnGroupTakeInvite",
				Text = Apollo.GetString("ContextMenu_DenyInvites"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader and self.tData.tTargetGroupData.bCanInvite); end,
			},
			{
				Name = "BtnGroupGiveMark",
				Text = Apollo.GetString("ContextMenu_AllowMarking"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader and not self.tData.tTargetGroupData.bCanMark); end,
			},
			{
				Name = "BtnGroupTakeMark",
				Text = Apollo.GetString("ContextMenu_DenyMarking"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.nGroupMemberId and self.tData.tTargetGroupData and self.tData.bAmIGroupLeader and self.tData.tTargetGroupData.bCanMark); end,
			},
			{
				Name = "BtnMentor",
				Text = Apollo.GetString("ContextMenu_Mentor"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.unit and not self.tData.bIsThePlayer and not bMentoringTarget and self.tData.tTargetGroupData and self.tData.tTargetGroupData.bIsOnline and not self.tData.tTargetGroupData.bDisconnected); end, -- Additional tTargetGroupData checks for sUF!
			},
			{
				Name = "BtnStopMentor",
				Text = Apollo.GetString("ContextMenu_StopMentor"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tData.tMyGroupData.bIsMentoring or self.tData.tMyGroupData.bIsMentored); end,
			},
		},
	},
	-- Social
	{
		Name = "BtnSocialList",
		Text = Apollo.GetString("ContextMenu_SocialLists"),
		Condition = function(self) return (self.tData.bIsACharacter and not self.tData.bIsThePlayer); end,
		Children = {
			{
				Name = "BtnAddFriend",
				Text = Apollo.GetString("ContextMenu_AddFriend"),
				Condition = function(self) return (not self.tData.bIsFriend and (not self.tData.unit or self.tData.unit:GetFaction() == self.tData.unitPlayer:GetFaction())); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnfriend",
				Text = Apollo.GetString("ContextMenu_RemoveFriend"),
				Condition = function(self) return (self.tData.bIsFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAddRival",
				Text = Apollo.GetString("ContextMenu_AddRival"),
				Condition = function(self) return (not self.tData.bIsRival); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnrival",
				Text = Apollo.GetString("ContextMenu_RemoveRival"),
				Condition = function(self) return (self.tData.bIsRival and not self.tData.tAccountFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAddNeighbor",
				Text = Apollo.GetString("ContextMenu_AddNeighbor"),
				Condition = function(self) return (not self.tData.bIsNeighbor and (not self.tData.unit or self.tData.unit:GetFaction() == self.tData.unitPlayer:GetFaction())); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnneighbor",
				Text = Apollo.GetString("ContextMenu_RemoveNeighbor"),
				Condition = function(self) return (self.tData.bIsNeighbor and not self.tData.tAccountFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAccountFriend",
				Text = Apollo.GetString("ContextMenu_PromoteFriend"),
				Condition = function(self) return (self.tData.bIsFriend and not self.tData.bIsAccountFriend); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnaccountFriend",
				Text = Apollo.GetString("ContextMenu_UnaccountFriend"),
				Condition = function(self) return (self.tData.tAccountFriend ~= nil); end,
				OnClick = "OnClickUnit",
			},
		},
	},
	-- Ignore
	{
		Name = "BtnIgnore",
		Text = Apollo.GetString("ContextMenu_Ignore"),
		Condition = function(self) return (self.tData.bIsACharacter and not self.tData.bIsThePlayer and not (self.tData.tFriend and self.tData.tFriend.bIgnore) and (self.tData.tAccountFriend == nil or self.tData.tAccountFriend.fLastOnline == 0)); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnUnignore",
		Text = Apollo.GetString("ContextMenu_Unignore"),
		Condition = function(self) return (self.tData.tFriend and self.tData.tFriend.bIgnore); end,
		OnClick = "OnClickUnit",
	},
	-- Duel
	{
		Name = "BtnDuel",
		Text = Apollo.GetString("ContextMenu_Duel"),
		OnClick = "OnClickUnit",
		Condition = function(self)
			local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules();
			return (self.tData.unit and (not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.tData.bIsACharacter and not self.tData.bIsThePlayer and not GameLib.GetDuelOpponent(self.tData.unitPlayer));
		end,
	},
	{
		Name = "BtnForfeit",
		Text = Apollo.GetString("ContextMenu_ForfeitDuel"),
		OnClick = "OnClickUnit",
		Condition = function(self)
			local eCurrentZonePvPRules = GameLib.GetCurrentZonePvpRules();
			return (self.tData.unit and (not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.tData.bIsACharacter and not self.tData.bIsThePlayer and GameLib.GetDuelOpponent(self.tData.unitPlayer));
		end,
	},
	-- Trade
	{
		Name = "BtnTrade",
		Text = Apollo.GetString("ContextMenu_Trade"),
		Condition = function(self) return (self.tData.unit and self.tData.bIsACharacter and not self.tData.bIsThePlayer); end,
		OnClick = "OnClickUnit",
		Enabled = function(self)
			local eCanTradeResult = P2PTrading.CanInitiateTrade(self.tData.unit.__proto__ or self.tData.unit);
			return (eCanTradeResult == P2PTrading.P2PTradeError_Ok or eCanTradeResult == P2PTrading.P2PTradeError_TargetRangeMax);
		end,
	},
	-- Whisper
	{
		Name = "BtnWhisper",
		Text = Apollo.GetString("ContextMenu_Whisper"),
		Condition = function(self) return (not self.tData.bIsThePlayer and self.tData.bCanWhisper); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnAccountWhisper",
		Text = Apollo.GetString("ContextMenu_AccountWhisper"),
		Condition = function(self) return (not self.tData.bIsThePlayer and self.tData.bCanAccountWisper); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnInvite",
		Text = Apollo.GetString("ContextMenu_InviteToGroup"),
		Condition = function(self) return (self.tData.bIsACharacter and not self.tData.bIsThePlayer and not self.tData.nGroupMemberId and (not self.tData.bInGroup or (self.tData.tMyGroupData.bCanInvite and self.tData.bCanWhisper))); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnLeaveGroup",
		Text = Apollo.GetString("ContextMenu_LeaveGroup"),
		Condition = function(self) return (self.tData.bIsThePlayer and self.tData.bInGroup); end,
		OnClick = "OnClickUnit",
	},
	-- Report
	{
		Name = "BtnReportChat",
		Text = Apollo.GetString("ContextMenu_ReportSpam"),
		Condition = function(self) return (self.tData.nReportId ~= nil); end,
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
		if (self.tData.unit) then
			self.tData.unitPlayer:SetAlternateTarget(self.tData.unit.__proto__ or self.tData.unit);
		end
	elseif (strButton == "BtnClearFocus") then
		-- Clear Focus
		self.tData.unitPlayer:SetAlternateTarget();
	elseif (strButton == "BtnMarkTarget") then
		-- Set First Available Mark
		if (self.tData.unit) then
			local nResult = 8;
			local nCurrent = self.tData.unit:GetTargetMarker() or 0;
			local tAvailableMarkers = GameLib.GetAvailableTargetMarkers();
			for idx = nCurrent, 8 do
				if (tAvailableMarkers[idx]) then
					nResult = idx;
					break;
				end
			end
			self.tData.unit:SetTargetMarker(nResult);
		end
	elseif (strButton == "BtnMarkClear") then
		if (self.tData.unit) then
			self.tData.unit:ClearTargetMarker();
		end
	elseif (strfind(strButton, "BtnMark(%d)")) then
		if (self.tData.unit) then
			local _, _, strMark = strfind(strButton, "BtnMark(%d)");
			strMark = tonumber(strMark);

			if (wndControl:IsChecked() and strMark < 8) then
				self.tData.unit:SetTargetMarker(strMark);
			else
				self.tData.unit:ClearTargetMarker();
			end
		end
	elseif (strButton == "BtnAssist") then
		if (self.tData.unit) then
			GameLib.SetTargetUnit(self.tData.unit:GetTarget());
		end
	elseif (strButton == "BtnInspect") then
		if (self.tData.unit) then
			self.tData.unit:Inspect();
		end
	elseif (strButton == "BtnAddFriend") then
		FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Friend, self.tData.strTarget);
	elseif (strButton == "BtnUnfriend") then
		FriendshipLib.Remove(self.tData.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Friend);
	elseif (strButton == "BtnAccountFriend") then
		FriendshipLib.AccountAddByUpgrade(self.tData.tCharacterData.tFriend.nId);
	elseif (strButton == "BtnUnaccountFriend") then
		if (self.tData.tAccountFriend and self.tData.tAccountFriend.nId) then
			Event_FireGenericEvent("EventGeneric_ConfirmRemoveAccountFriend", self.tData.tAccountFriend.nId); -- TODO
		end
	elseif (strButton == "BtnAddRival") then
		FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Rival, self.tData.strTarget);
	elseif (strButton == "BtnUnrival") then
		FriendshipLib.Remove(self.tData.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Rival);
	elseif (strButton == "BtnAddNeighbor") then
		HousingLib.NeighborInviteByName(self.tData.strTarget);
	elseif (strButton == "BtnUnneighbor") then
		Print(Apollo.GetString("ContextMenu_NeighborRemoveFailed")); -- TODO
	elseif (strButton == "BtnIgnore") then
		FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Ignore, self.tData.strTarget);
	elseif (strButton == "BtnUnignore") then
		FriendshipLib.Remove(self.tData.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Ignore);
	elseif (strButton == "BtnDuel") then
		GameLib.InitiateDuel(self.tData.unit);
	elseif (strButton == "BtnForfeit") then
		GameLib.ForfeitDuel(self.tData.unit);
	elseif (strButton == "BtnTrade") then
		local eCanTradeResult = P2PTrading.CanInitiateTrade(self.tData.unit);
		if (eCanTradeResult == P2PTrading.P2PTradeError_Ok) then
			Event_FireGenericEvent("P2PTradeWithTarget", self.tData.unit);
		elseif (eCanTradeResult == P2PTrading.P2PTradeError_TargetRangeMax) then
			Event_FireGenericEvent("GenericFloater", self.tData.unitPlayer, Apollo.GetString("ContextMenu_PlayerOutOfRange"));
			self.tData.unit:ShowHintArrow();
		else
			Event_FireGenericEvent("GenericFloater", self.tData.unitPlayer, Apollo.GetString("ContextMenu_TradeFailed"));
		end
	elseif (strButton == "BtnWhisper") then
		Event_FireGenericEvent("GenericEvent_ChatLogWhisper", self.tData.strTarget);
	elseif (strButton == "BtnAccountWhisper") then
		if (self.tData.tCharacterData.tAccountFriend ~= nil and self.tData.tCharacterData.tAccountFriend.arCharacters ~= nil and self.tData.tCharacterData.tAccountFriend.arCharacters[1] ~= nil) then
			local strDisplayName = self.tData.tCharacterData.tAccountFriend.strCharacterName;
			local strRealmName = self.tData.tCharacterData.tAccountFriend.arCharacters[1].strRealm;
			Event_FireGenericEvent("Event_EngageAccountWhisper", strDisplayName, self.tData.strTarget, strRealmName);
		end
	elseif (strButton == "BtnInvite") then
		GroupLib.Invite(self.tData.strTarget);
	elseif (strButton == "BtnKick") then
		GroupLib.Kick(self.tData.nGroupMemberId);
	elseif (strButton == "BtnLeaveGroup") then
		GroupLib.LeaveGroup();
	-- TODO
	elseif (strButton == "BtnPromote") then
		GroupLib.Promote(self.tData.nGroupMemberId, "");
	elseif (strButton == "BtnGroupGiveMark") then
		GroupLib.SetCanMark(self.tData.nGroupMemberId, true);
	elseif (strButton == "BtnGroupTakeMark") then
		GroupLib.SetCanMark(self.tData.nGroupMemberId, false);
	elseif (strButton == "BtnGroupGiveKick") then
		GroupLib.SetKickPermission(self.tData.nGroupMemberId, true);
	elseif (strButton == "BtnGroupTakeKick") then
		GroupLib.SetKickPermission(self.tData.nGroupMemberId, false);
	elseif (strButton == "BtnGroupGiveInvite") then
		GroupLib.SetInvitePermission(self.tData.nGroupMemberId, true);
	elseif (strButton == "BtnGroupTakeInvite") then
		GroupLib.SetInvitePermission(self.tData.nGroupMemberId, false);
	elseif (strButton == "BtnLocate") then
		if (self.tData.unit) then
			self.tData.unit:ShowHintArrow();
		end
	elseif (strButton == "BtnMarkClear") then
		self.tData.unit:ClearTargetMarker();
	elseif (strButton == "BtnVoteToDisband") then
		MatchingGame.InitiateVoteToSurrender();
	elseif (strButton == "BtnVoteToKick") then
		MatchingGame.InitiateVoteToKick(self.tData.nGroupMemberId);
	elseif (strButton == "BtnMentor") then
		GroupLib.AcceptMentoring(self.tData.unit);
	elseif (strButton == "BtnStopMentor") then
		GroupLib.CancelMentoring();
	elseif (strButton == "BtnReportChat" and self.tData.nReportId) then
		local tResult = ChatSystemLib.PrepareInfractionReport(self.tData.nReportId);
		Apollo.GetAddon("ContextMenuPlayer"):BuildReportConfirmation(tResult.strDescription, tResult.bSuccess); -- TODO
	elseif (strButton and string.find(strButton, "BtnMark") ~= 0) then
		self.tData.unit:SetTargetMarker(tonumber(string.sub(strButton, string.len("BtnMark_"))));
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

function ContextMenu:GenerateUnitMenu(unit, nReportId)
	if (not unit) then return; end

	-- Cleanup
	self:Initialize();

	-- Chat
	self.tData.nReportId = nReportId;

	-- Player
	self.tData.unitPlayer = GameLib.GetPlayerUnit();
	self.tData.bInGroup = GroupLib.InGroup();
	self.tData.bAmIGroupLeader = GroupLib.AmILeader();
	self.tData.tMyGroupData = GroupLib.GetGroupMember(1);
	self.tData.tPlayerFaction = self.tData.unitPlayer:GetFaction();

	-- Check if Unitstring is the Player (TODO: Can unit string come from another realm?)
	if (type(unit) == "string" and unit == self.tData.unitPlayer:GetName()) then
		unit = self.tData.unitPlayer;
	end

	-- Friend IDs
	if (type(unit) == "number") then
		self.tData.bFriendMenu = true;
		self.tData.nFriendId = unit;
		self.tData.tFriend = FriendshipLib.GetById(unit);
		self.tData.tAccountFriend = FriendshipLib.GetAccountById(unit);

		if (self.tData.tFriend) then
			unit = self.tData.tFriend.strCharacterName;
		elseif (self.tData.tAccountFriend) then
			if (self.tData.tAccountFriend.arCharacters and self.tData.tAccountFriend.arCharacters[1]) then
				unit = self.tData.tAccountFriend.arCharacters[1].strCharacterName;
			else
				-- Offline Account Friend
				self.tData.bIsOfflineAccountFriend = true;
				unit = self.tData.tAccountFriend.strCharacterName;
			end
		end
	else
		self.tData.bFriendMenu = false;
		self.tData.nFriendId = nil;
		self.tData.tFriend = nil;
		self.tData.tAccountFriend = nil;
		self.tData.bIsOfflineAccountFriend = false;
	end

	if (type(unit) == "string") then
		-- Unitless Properties
		self.tData.unit = nil;
		self.tData.strTarget = unit;
		self.tData.bIsACharacter = true; -- TODO
		self.tData.bIsThePlayer = false;
	else
		-- Unit Properties
		self.tData.unit = unit;
		self.tData.strTarget = unit:GetName();
		self.tData.bIsACharacter = unit:IsACharacter();
		self.tData.bIsThePlayer = unit:IsThePlayer();
	end

	self.tData.tCharacterData = GameLib.SearchRelationshipStatusByCharacterName(self.tData.strTarget);
	self.tData.nGroupMemberId = (self.tData.tCharacterData and self.tData.tCharacterData.nPartyIndex) or nil;
	self.tData.tTargetGroupData = (not self.tData.bIsThePlayer and self.tData.tCharacterData and self.tData.tCharacterData.nPartyIndex) and GroupLib.GetGroupMember(self.tData.tCharacterData.nPartyIndex) or nil;

	-- Mentoring
	if (self.tData.bInGroup and not self.tData.bIsThePlayer and self.tData.tTargetGroupData) then
		local bMentoringTarget = false;
		for _, nMentorIdx in ipairs(self.tData.tTargetGroupData.tMentoredBy) do
			if (tMyGroupData.nMemberIdx == nMentorIdx) then
				bMentoringTarget = true;
				break
			end
		end

		if (self.tData.tTargetGroupData.bIsOnline and not bMentoringTarget and self.tData.tTargetGroupData.nLevel < self.tData.tMyGroupData.nLevel) then
			self.tData.bMentoringTarget = true;
		end
	else
		self.tData.bMentoringTarget = false;
	end

	-- Friend (TODO: Testing)
	if (self.tData.bIsACharacter) then
		if (not self.tData.bFriendMenu) then
			self.tData.tFriend = self:FindFriend(self.tData.strTarget); -- bFriend, bRival, bIgnore
			self.tData.tAccountFriend = self:FindFriend(self.tData.strTarget, true);
			self.tData.nFriendId = (self.tData.tFriend and self.tData.tFriend.nId) or (self.tData.tAccountFriend and self.tData.tAccountFriend.nId) or nil;
		end

		self.tData.bCanAccountWisper = not self.tData.bIsOfflineAccountFriend and (self.tData.tAccountFriend ~= nil and self.tData.tAccountFriend.arCharacters and self.tData.tAccountFriend.arCharacters[1] ~= nil);
		if (self.tData.bCanAccountWisper) then
--			self.tData.bCanWhisper = (self.tData.tAccountFriend.arCharacters[1] ~= nil and self.tData.tAccountFriend.arCharacters[1].strRealm == GameLib.GetRealmName() and self.tData.tAccountFriend.arCharacters[1].nFactionId == self.tData.tPlayerFaction);

			self.tData.bCanWhisper = (self.tData.tAccountFriend.arCharacters[1].nFactionId == self.tData.tPlayerFaction);
		else
			self.tData.bCanWhisper = not self.tData.bIsOfflineAccountFriend and (self.tData.bIsACharacter and (not self.tData.unit or (self.tData.unit and self.tData.unit:GetFaction() == self.tData.tPlayerFaction)) and (self.tData.tFriend == nil or (self.tData.tFriend ~= nil and not self.tData.tFriend.bIgnore)));
		end

		self.tData.bIsFriend = (self.tData.tFriend ~= nil and self.tData.tFriend.bFriend) or (self.tData.tCharacterData ~= nil and self.tData.tCharacterData.tFriend ~= nil and self.tData.tCharacterData.tFriend.bFriend);
		self.tData.bIsRival = (self.tData.tFriend ~= nil and self.tData.tFriend.bRival) or (self.tData.tCharacterData ~= nil and self.tData.tCharacterData.tFriend ~= nil and self.tData.tCharacterData.tFriend.bRival);
		self.tData.bIsNeighbor = (self.tData.tFriend ~= nil and self.tData.tFriend.bNeighbor) or (self.tData.tCharacterData ~= nil and self.tData.tCharacterData.tFriend ~= nil and self.tData.tCharacterData.tFriend.bNeighbor);
		self.tData.bIsAccountFriend = (self.tData.tAccountFriend ~= nil or (self.tData.tCharacterData ~= nil and self.tData.tCharacterData.tAccountFriend ~= nil));
	else
		self.tData.bCanWhisper = false;
		self.tData.bCanAccountWisper = false;
		self.tData.bIsFriend = false;
		self.tData.bIsRival = false;
		self.tData.bIsNeighbor = false;
		self.tData.bIsAccountFriend = false;
	end

	-- PVP
	self.tData.bInMatchingGame = MatchingGame.IsInMatchingGame();
	self.tData.bIsMatchingGameFinished = MatchingGame.IsMatchingGameFinished();

	if (not self.tParent) then
		self:AddHeader(self.tData.strTarget);
		self:AddItems(tMenuItems);
	end

	return self;
end

--[[
local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local log = S.Log;
]]