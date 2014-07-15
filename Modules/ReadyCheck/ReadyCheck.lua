--[[

	s:UI Ready Check

	I don't care if you disconnected without answering a ready check.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("ReadyCheck");
local log;

-- Constants
local knReadyCheckTimeout = 60;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	if (Apollo.GetAddon("RaidFrameBase")) then
		self:SetEnabledState(false);
	else
		self:InitializeForms();
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	Apollo.RegisterEventHandler("Group_ReadyCheck", "OnGroupReadyCheck", self);
	Apollo.RegisterTimerHandler("ReadyCheckTimeout", "OnReadyCheckTimeout", self);
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

function M:OnGroupReadyCheck(nMemberIdx, strMessage)
	local tMember = GroupLib.GetGroupMember(nMemberIdx);
	local strName = Apollo.GetString("RaidFrame_TheRaid");

	if (tMember) then
		strName = tMember.strCharacterName;
	end

	if (self.wndReadyCheckPopup and self.wndReadyCheckPopup:IsValid()) then
		self.wndReadyCheckPopup:Destroy();
	end

	self.wndReadyCheckPopup = Apollo.LoadForm(self.xmlDoc, "RaidReadyCheck", nil, self);
	self.wndReadyCheckPopup:FindChild("ReadyCheckMessage"):SetText(String_GetWeaselString(Apollo.GetString("RaidFrame_ReadyCheckStarted"), strName).."\n"..strMessage);
	Apollo.CreateTimer("ReadyCheckTimeout", knReadyCheckTimeout, false);
end

function M:OnReadyCheckResponse(wndHandler, wndControl)
	if (wndHandler == wndControl) then
		GroupLib.SetReady(wndHandler:GetName() == "ReadyCheckYesBtn");
	end

	if (self.wndReadyCheckPopup and self.wndReadyCheckPopup:IsValid()) then
		self.wndReadyCheckPopup:Destroy();
	end
end

function M:OnReadyCheckTimeout()
	if (self.wndReadyCheckPopup and self.wndReadyCheckPopup:IsValid()) then
		self.wndReadyCheckPopup:Destroy();
	end
end
