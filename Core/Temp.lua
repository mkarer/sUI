--[[

	s:UI Temp File

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Temp", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	if (S.bCharacterLoaded) then
--		self:EventHandler();
	else
--		self:RegisterEvent("Sezz_CharacterLoaded", "EventHandler");
	end

--	self:RegisterEvent("ObscuredAddonVisible", "EventHandler");
	self:RegisterEvent("Group_AcceptInvite", "EventHandler");
	self:RegisterEvent("Group_Add", "EventHandler");
	self:RegisterEvent("Group_DeclineInvite", "EventHandler");
	self:RegisterEvent("Group_FlagsChanged", "EventHandler");
--	self:RegisterEvent("Group_Invite_Result", "EventHandler"); -- strCharName, eRsult (0=inv sent, 2=accepted)
	self:RegisterEvent("Group_Invited", "EventHandler");
--	self:RegisterEvent("Group_Join", "EventHandler"); -- some joined group, member indexes will change?
	self:RegisterEvent("Group_JoinRequest", "EventHandler");
--	self:RegisterEvent("Group_Left", "EventHandler"); -- someone left, member indexes will change (last frame needs to be disabled)
	self:RegisterEvent("Group_LootRulesChanged", "EventHandler");
	self:RegisterEvent("Group_MemberConnect", "EventHandler");
--	self:RegisterEvent("Group_MemberFlagsChanged", "EventHandler"); -- nMemberIdx, bFromPromotion, tChangedFlags (inv/kick/mark/disconnected/dps/healer/mainass/maintank/pending/raidass/ready/rolelocked/tank)
--	self:RegisterEvent("Group_MemberPromoted", "EventHandler");
--	self:RegisterEvent("Group_Mentor", "EventHandler");
	self:RegisterEvent("Group_MentorLeftAOI", "EventHandler");
	self:RegisterEvent("Group_MentorRelationship", "EventHandler");
--	self:RegisterEvent("Group_Operation_Result", "EventHandler"); -- strName, eResult (GroupLib.ActionResult)
--	self:RegisterEvent("Group_ReadyCheck", "EventHandler"); -- initiating_playerindex message
	self:RegisterEvent("Group_Referral", "EventHandler");
	self:RegisterEvent("Group_Remove", "EventHandler"); -- someone has been removed, member indexes will change (last frame needs to be disabled)
	self:RegisterEvent("Group_Request_Result", "EventHandler"); -- nonleader invites someone arg1=player arg2=20/21=? arg3=false=?
--	self:RegisterEvent("Group_Updated", "EventHandler"); -- happens all the time, no args
--	self:RegisterEvent("Group_UpdatePosition", "EventHandler"); -- also all the time, table with tables with nIndex to associate unit and coords
--	self:RegisterEvent("UnitNameChanged", "EventHandler"); -- tUnit, strNewName (quest mobs etc)
end

function S:Test()
end

function M:EventHandler(event, ...)
	log:debug(event);

	local tArgs = {...};
	if (#tArgs > 0) then
		log:debug(tArgs);
	end
end
