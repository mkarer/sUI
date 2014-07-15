--[[

	s:UI Ready Check

	I don't care if you disconnected without answering a ready check.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("ReadyCheck");
local log, GeminiGUI;

-- Constants
local knReadyCheckTimeout = 60;

-----------------------------------------------------------------------------
-- Forms
-----------------------------------------------------------------------------

function M:HideReadyCheck()
log:debug("hide rc")
	if (self.wndReadyCheckPopup and self.wndReadyCheckPopup:IsValid()) then
log:debug("hide rc")
		self.wndReadyCheckPopup:Destroy();
	end
log:debug("hide rc")
end

function M:ShowReadyCheck()
	local tReadyCheckWindow = {
		Class = "Window",
		AnchorPoints = { 0.5, 0.5, 0.5, 0.5 },
		AnchorOffsets = { -150, -150, 150, 50 },
		Name = "RaidReadyCheck",
		Picture = true,
		Overlapped = true,
		BGColor = "ffffffff",
		TextColor = "ffffffff",
		IgnoreMouse = true,
		Sprite = "CRB_Basekit:kitBase_Hybrid_Message",
		Events = {
			WindowClosed = self.OnReadyCheckResponse,
		},
		Children = {
			-- Button: Ready
			{
				Class = "Button",
				Base = "CRB_Basekit:kitBtn_Holo_Large",
				Font = "CRB_InterfaceMedium_B",
				ButtonType = "PushButton",
				AnchorPoints = { 0, 1, 0.5, 1 },
				AnchorOffsets = { 35, -75, -4, -35 },
				DT_VCENTER = true,
				DT_CENTER = true,
				Name = "ReadyCheckYesBtn",
				NormalTextColor = "ff2f94ac",
				PressedTextColor = "ff31fcf6",
				FlybyTextColor = "ff31fcf6",
				PressedFlybyTextColor = "ff31fcf6",
				DisabledTextColor = "ff333333",
				TextId = "RaidFrame_Ready",
				TooltipType = "OnCursor",
				Events = {
					ButtonSignal = self.OnReadyCheckResponse,
				},
			},
			-- Button: Not Ready
			{
				Class = "Button",
				Base = "CRB_Basekit:kitBtn_Holo_Large",
				Font = "CRB_InterfaceMedium_B",
				ButtonType = "PushButton",
				AnchorPoints = { 0.5, 1, 1, 1 },
				AnchorOffsets = { 4, -75, -35, -35 },
				DT_VCENTER = true,
				DT_CENTER = true,
				Name = "ReadyCheckNoBtn",
				NormalTextColor = "ff2f94ac",
				PressedTextColor = "ff31fcf6",
				FlybyTextColor = "ff31fcf6",
				PressedFlybyTextColor = "ff31fcf6",
				DisabledTextColor = "ff333333",
				TextId = "RaidFrame_NotReady",
				TooltipType = "OnCursor",
				Events = {
					ButtonSignal = self.OnReadyCheckResponse,
				},
			},
			-- Button: Close
			{
				Class = "Button",
				Base = "CRB_Basekit:kitBtn_Close",
				Font = "CRB_InterfaceMedium_B",
				ButtonType = "PushButton",
				AnchorPoints = { 1, 0, 1, 0 },
				AnchorOffsets = { -36, 9, -9, 38 },
				DT_VCENTER = true,
				DT_CENTER = true,
				Name = "ReadyCheckCloseBtn",
				NormalTextColor = "ff2f94ac",
				PressedTextColor = "ff31fcf6",
				FlybyTextColor = "ff31fcf6",
				PressedFlybyTextColor = "ff31fcf6",
				DisabledTextColor = "ff333333",
				TooltipType = "OnCursor",
				Events = {
					ButtonSignal = self.OnReadyCheckResponse,
				},
			},
			-- Text
			{
				Class = "Window",
				AnchorPoints = { 0, 0, 1, 0 },
				AnchorOffsets = { 35, 35, -35, 107 },
				Name = "ReadyCheckMessage",
				Font = "CRB_InterfaceMedium_B",
				BGColor = "ffffffff",
				TextColor = "ff31fcf6",
				DT_VCENTER = true,
				DT_CENTER = true,
				DT_WORDBREAK = true,
				TextId = "CRB__2",
			},
		},
	};

	self:HideReadyCheck();
	self.wndReadyCheckPopup = GeminiGUI:Create(tReadyCheckWindow):GetInstance();
	return self.wndReadyCheckPopup;
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	if (Apollo.GetAddon("RaidFrameBase")) then
		self:SetEnabledState(false);
	else
		GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage;
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self:RegisterEvent("Group_ReadyCheck", "OnGroupReadyCheck");
	self:RegisterEvent("ReadyCheckTimeout", "OnReadyCheckTimeout");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

function M:OnGroupReadyCheck(event, nMemberIdx, strMessage)
	local tMember = GroupLib.GetGroupMember(nMemberIdx);
	local strName = Apollo.GetString("RaidFrame_TheRaid");

	if (tMember) then
		strName = tMember.strCharacterName;
	end

	self:ShowReadyCheck();
	self.wndReadyCheckPopup:FindChild("ReadyCheckMessage"):SetText(String_GetWeaselString(Apollo.GetString("RaidFrame_ReadyCheckStarted"), strName).."\n"..strMessage);
	Apollo.CreateTimer("ReadyCheckTimeout", knReadyCheckTimeout, false);
end

function M:OnReadyCheckResponse(wndHandler, wndControl)
	if (wndHandler == wndControl) then
		GroupLib.SetReady(wndHandler:GetName() == "ReadyCheckYesBtn");
	end

	self:HideReadyCheck();
end

function M:OnReadyCheckTimeout()
	self:HideReadyCheck();
end
