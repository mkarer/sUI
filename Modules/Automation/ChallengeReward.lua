--[[

	s:UI Challenge Reward Closer

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local AutomationCore = S:GetModule("AutomationCore");
local M = AutomationCore:CreateSubmodule("ChallengeReward");
local log;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self:RegisterEvent("ChallengeReward_SpinBegin", "CloseChallengeRewardPanel");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());

	self:UnregisterEvent("ChallengeReward_SpinBegin");
end

function M:CloseChallengeRewardPanel(event, ...)
	tRewardPanel = Apollo.FindWindowByName("ChallengeRewardPanelForm");
	if (tRewardPanel) then
		-- Close Reward Panel
		tRewardPanel:Close();

		-- Close Challenge Tracker
		tChallenges = Apollo.GetAddon("Challenges");
		if (tChallenges) then
			tChallenges:OnTrackerMinimizeButton();
		end
	end
end
