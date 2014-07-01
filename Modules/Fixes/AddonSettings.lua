--[[

	s:UI Addon Settings

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AddonSettings", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	self:UpdateQuestTrackerForms();
	self:UpdateQuestTrackerSorting();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Events
	self:RegisterEvent("Sezz_AddonAvailable", "OnAddonAvailable");

	-- Quest Tracker
	self:UpdateQuestTrackerForms();
	self:UpdateQuestTrackerSorting();
end

function M:OnAddonAvailable(strEvent, strAddon)
	if (strAddon == "QuestTracker") then
	end
end

-----------------------------------------------------------------------------
-- Quest Tracker
-----------------------------------------------------------------------------

function M:UpdateQuestTrackerForms()
	local tQuestTracker = Apollo.GetAddon("QuestTracker");

	if (tQuestTracker and not tQuestTracker._OnLoad) then
		tQuestTracker._OnLoad = tQuestTracker.OnLoad;
		tQuestTracker.OnLoad = function(self)
			self:_OnLoad();

			local tXml = self.xmlDoc:ToTable();
			for _, tNode in pairs(tXml) do
				if (tNode.Name and tNode.Name == "QuestTrackerForm") then
					tNode.LAnchorPoint = 1;
					tNode.LAnchorOffset = -325;
					tNode.TAnchorPoint = 0;
					tNode.TAnchorOffset = 0;
					tNode.RAnchorPoint = 1;
					tNode.RAnchorOffset = 0;
					tNode.BAnchorPoint = 1;
					tNode.BAnchorOffset = -271;
					break;
				end
			end

			self.xmlDoc = XmlDoc.CreateFromTable(tXml);
		end
	end
end

function M:UpdateQuestTrackerSorting()
	local tQuestTracker = Apollo.GetAddon("QuestTracker");

	-- Hook ResizeEpisodes
	if (tQuestTracker and not tQuestTracker._ResizeEpisodes) then
		tQuestTracker._ResizeEpisodes = tQuestTracker.ResizeEpisodes;
		tQuestTracker.ResizeEpisodes = function(self)
			-- Sort
			local function HelperSortEpisodes(a,b)
				if (a:FindChild("EpisodeTitle") and b:FindChild("EpisodeTitle")) then
					return a:FindChild("EpisodeTitle"):GetData() < b:FindChild("EpisodeTitle"):GetData();
				elseif (b:GetName() == "SwapToQuests") then
					return true;
				end
				return false;
			end

			for idx1, wndEpisodeGroup in pairs(self.wndMain:FindChild("QuestTrackerScroll"):GetChildren()) do
				if (wndEpisodeGroup:GetName() == "EpisodeGroupItem") then
					-- Resize List
					self:OnResizeEpisodeGroup(wndEpisodeGroup);
					wndEpisodeGroup:FindChild("EpisodeGroupContainer"):ArrangeChildrenVert(0, HelperSortEpisodes);
				elseif (wndEpisodeGroup:GetName() == "EpisodeItem") then
					-- Resize List
					self:OnResizeEpisode(wndEpisodeGroup);
					wndEpisodeGroup:FindChild("EpisodeQuestContainer"):ArrangeChildrenVert(0, HelperSortEpisodes);
				end
			end

			local nAlign = questAlign;

			self.wndMain:FindChild("QuestTrackerScroll"):ArrangeChildrenVert(nAlign, function(a, b)
				if (a:GetName() == "EpisodeGroupItem" and b:GetName() == "EpisodeGroupItem") then
					return a:GetData() < b:GetData();
				elseif (b:GetName() == "SwapToQuests") then
					return true;
				end

				return false;
			end);
		end

		if (tQuestTracker.wndMain) then
			tQuestTracker:ResizeEpisodes();
		end
	end
end
