--[[

	s:UI Drop Down Menu: Units

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:Controls:DropDown-0.1", 1;
local DropDown = Apollo.GetPackage(MAJOR).tPackage;
if (DropDown and (DropDown.nVersion or 0) > MINOR) then return; end

local Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading, MatchingGame = Apollo, GameLib, GroupLib, FriendshipLib, P2PTrading, MatchingGame;

-----------------------------------------------------------------------------
-- Menu Items
-----------------------------------------------------------------------------

local tMenuItems = {
	-- Markers
	{
		Name = "BtnMarkTarget",
		Text = Apollo.GetString("ContextMenu_MarkTarget"),
		Condition = function(self) return (self.bInGroup and self.tMyGroupData.bCanMark); end,
--		Condition = function(self) return not self.bInGroup or (self.bInGroup and self.tMyGroupData.bCanMark); end,
		OnClick = "OnClickUnit",
		Children = {
			-- TODO
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
		Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer); end,
		Enabled = function(self) return (self.unit:GetTarget() ~= nil); end,
		OnClick = "OnClickUnit",
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
		Condition = function(self) return (self.bInGroup and self.bIsACharacter); end,
		Children = {
			{
				Name = "BtnMentor",
				Text = Apollo.GetString("ContextMenu_Mentor"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (not self.bIsThePlayer and not bMentoringTarget); end,
			},
			{
				Name = "BtnStopMentor",
				Text = Apollo.GetString("ContextMenu_StopMentor"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tMyGroupData.bIsMentoring or self.tMyGroupData.bIsMentored); end,
			},
			{
				Name = "BtnGroupTakeInvite",
				Text = Apollo.GetString("ContextMenu_DenyInvites"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader and self.bCanInvite); end,
			},
			{
				Name = "BtnGroupGiveInvite",
				Text = Apollo.GetString("ContextMenu_AllowInvites"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader and not self.bCanInvite); end,
			},
			{
				Name = "BtnGroupTakeKick",
				Text = Apollo.GetString("ContextMenu_DenyKicks"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader and self.bCanKick); end,
			},
			{
				Name = "BtnGroupGiveKick",
				Text = Apollo.GetString("ContextMenu_AllowKicks"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader and not self.bCanKick); end,
			},
			{
				Name = "BtnGroupTakeMark",
				Text = Apollo.GetString("ContextMenu_DenyMarking"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader and self.bCanMark); end,
			},
			{
				Name = "BtnGroupGiveMark",
				Text = Apollo.GetString("ContextMenu_AllowMarking"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader and not self.bCanMark); end,
			},
			{
				Name = "BtnVoteToKick",
				Text = Apollo.GetString("ContextMenu_VoteToKick"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bInMatchingGame and not self.bIsMatchingGameFinished); end,
			},
			{
				Name = "BtnVoteToDisband",
				Text = Apollo.GetString("ContextMenu_VoteToDisband"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bInMatchingGame and not self.bIsMatchingGameFinished and MatchingGame:GetPVPMatchState() ~= MatchingGame.Rules.DeathmatchPool); end,
				Enabled = function(self) return (not MatchingGame.IsVoteSurrenderActive()); end,
			},
			{
				Name = "BtnPromote",
				Text = Apollo.GetString("ContextMenu_Promote"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData and self.bAmIGroupLeader); end,
			},
			{
				Name = "BtnLocate",
				Text = Apollo.GetString("ContextMenu_Locate"),
				OnClick = "OnClickUnit",
				Condition = function(self) return (self.tTargetGroupData); end,
			},
		},
	},
	{
		Name = "BtnInspect",
		Text = Apollo.GetString("ContextMenu_Inspect"),
		Condition = function(self) return (self.bIsACharacter); end,
		OnClick = "OnClickUnit",
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
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnfriend",
				Text = Apollo.GetString("ContextMenu_RemoveFriend"),
				Condition = function(self) return (self.bIsFriend); end,
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
				Condition = function(self) return (self.tAccountFriend ~= nil and self.bIsAccountFriend); end,
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
				Condition = function(self) return (self.bIsRival and self.tAccountFriend == nil); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnAddNeighbor",
				Text = Apollo.GetString("ContextMenu_AddNeighbor"),
				Condition = function(self) return (not self.bIsNeighbor and self.unit:GetFaction() == self.unitPlayer:GetFaction()); end,
				OnClick = "OnClickUnit",
			},
			{
				Name = "BtnUnneighbor",
				Text = Apollo.GetString("ContextMenu_RemoveNeighbor"),
				Condition = function(self) return (self.bIsNeighbor and self.tAccountFriend == nil); end,
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
			return ((not eCurrentZonePvPRules or eCurrentZonePvPRules ~= GameLib.CodeEnumZonePvpRules.Sanctuary) and self.bIsACharacter and not self.bIsThePlayer and not GameLib.GetDuelOpponent(self.unitPlayer));
		end,
	},
	{
		Name = "BtnForfeit",
		Text = Apollo.GetString("ContextMenu_ForfeitDuel"),
		OnClick = "OnClickUnit",
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
		Condition = function(self) return (self.bIsACharacter and not self.bIsThePlayer and (not self.bInGroup or (self.tMyGroupData.bCanInvite and self.bCanWhisper))); end,
		OnClick = "OnClickUnit",
	},
	{
		Name = "BtnKick",
		Text = Apollo.GetString("ContextMenu_Kick"),
		Condition = function(self) return (not self.bIsThePlayer and self.bIsACharacter and self.bInGroup and self.unit:IsInYourGroup() and self.tMyGroupData.bCanKick); end,
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
-- Drop Down Menu
-----------------------------------------------------------------------------

function DropDown:FindFriend(unit, bAccountFriend)
	-- Untested!
	local strName = unit:GetName();
	local strRealm = GameLib:GetRealmName();
	local tFriends = bAccountFriend and FriendshipLib.GetAccountList() or FriendshipLib.GetList();

	for _, tFriend in ipairs(tFriends) do
		if (not bAccountFriend and tFriend.strCharacterName == strName and tFriend.strRealmName == strRealm) then
			return tFriend;
		elseif (bAccountFriend and tFriend.strCharacterName == strName) then
			local unitFriend = FriendshipLib.GetUnitById(tFriend.nId);
			if (unitFriend and unitFriend:GetId() == unit:GetId()) then -- No Realm in Account Friends List?
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
			-- Set Focus
			self.unitPlayer:SetAlternateTarget(self.unit.__proto__ or self.unit);
		elseif (strButton == "BtnClearFocus") then
			-- Clear Focus
			self.unitPlayer:SetAlternateTarget();
		elseif (strButton == "BtnMarkTarget") then
			-- Set First Available Mark
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
		elseif (strButton == "BtnAssist") then
			GameLib.SetTargetUnit(self.unit:GetTarget());
		elseif (strButton == "BtnInspect") then
			self.unit:Inspect();
		elseif (strButton == "BtnSocialList") then
		elseif (strButton == "BtnAddFriend") then
			FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Friend, self.strTarget);
		elseif (strButton == "BtnUnfriend") then
		FriendshipLib.Remove(self.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Friend);
		elseif (strButton == "BtnAccountFriend") then
			FriendshipLib.AccountAddByUpgrade(self.tCharacterData.tFriend.nId);
		elseif (strButton == "BtnUnaccountFriend") then
			if (self.tAccountFriend and self.tAccountFriend.nId) then
				Event_FireGenericEvent("EventGeneric_ConfirmRemoveAccountFriend", self.tAccountFriend.nId);
			end
		elseif (strButton == "BtnAddRival") then
			FriendshipLib.AddByName(FriendshipLib.CharacterFriendshipType_Rival, self.strTarget);
		elseif (strButton == "BtnUnrival") then
			FriendshipLib.Remove(self.tCharacterData.tFriend.nId, FriendshipLib.CharacterFriendshipType_Rival);
		elseif (strButton == "BtnAddNeighbor") then
			HousingLib.NeighborInviteByName(self.strTarget);
		elseif (strButton == "BtnUnneighbor") then
			Print(Apollo.GetString("ContextMenu_NeighborRemoveFailed")); -- TODO!
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
			self.unit:ShowHintArrow();
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
	self.tCharacterData = GameLib.SearchRelationshipStatusByCharacterName(self.strTarget);
	self.tPlayerFaction = self.unitPlayer:GetFaction();
	self.bIsACharacter = unit:IsACharacter();
	self.bIsThePlayer = unit:IsThePlayer();
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

	-- PVP
	self.bInMatchingGame = MatchingGame.IsInMatchingGame();
	self.bIsMatchingGameFinished = MatchingGame.IsMatchingGameFinished();

	-- Create Window
	self:CreateWindow();

	if (not self.tParent) then
		self:AddHeader(unit:GetName());
		self:AddItems(tMenuItems);
	end

	return self;
end