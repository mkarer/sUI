--[[

	s:UI Addon Settings

	TODO: Tutorial Anchor

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AddonSettings", "Gemini:Hook-1.0");
local log;

-- Lua API
local abs = math.abs;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	self:UpdateQuestTrackerForms();
	self:UpdateQuestTrackerSorting();
	self:OverrideNameplatesSettings();
	self:UpdateDatachronForms();
	self:HideAythQuestTracker();
	self:HideTrackMaster();
	self:UpdateHarvester();
	self:EnableJunkIt();
	self:UpdateLootNotificationWindow();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Events
	self:RegisterEvent("Sezz_AddonAvailable", "OnAddonAvailable");
	self:CheckAddonAvailable("FloatTextPanel");
	self:CheckAddonAvailable("SprintMeter");

	-- Quest Tracker
	self:UpdateQuestTrackerForms();
	self:UpdateQuestTrackerSorting();
end

-----------------------------------------------------------------------------
-- Events
-----------------------------------------------------------------------------

function M:CheckAddonAvailable(strAddon)
	if (S:IsAddOnLoaded(strAddon)) then
		self:OnAddonAvailable(nil, strAddon, Apollo.GetAddon(strAddon));
	end
end

function M:OnAddonAvailable(strEvent, strAddon, tAddon)
	if (strAddon == "FloatTextPanel") then
		local wndHintArrow = tAddon.wndHintArrowDistance;
		if (wndHintArrow) then
			local tAnchors = { wndHintArrow:GetAnchorOffsets() };
			tAnchors[2] = tAnchors[2] + 100;
			tAnchors[4] = tAnchors[4] + 100;
			wndHintArrow:SetAnchorOffsets(unpack(tAnchors));
		end
	elseif (strAddon == "SprintMeter") then
		tAddon.wndMain:FindChild("ProgBar"):SetStyle("IgnoreMouse", 1);
	end
end

-----------------------------------------------------------------------------
-- Name Plates
-----------------------------------------------------------------------------

function M:OverrideNameplatesSettings()
	local tNameplates = Apollo.GetAddon("Nameplates");

	if (tNameplates) then
		-- Default Settings
		tNameplates._OnRestore = tNameplates.OnRestore;
		tNameplates.OnRestore = function(self, eType, tSavedData)
			if (eType == GameLib.CodeEnumAddonSaveLevel.Character) then
				S:Combine(tSavedData, {
					bHideInCombat = false,
					bShowCastBarMain = true,
					bShowCastBarTarget = true,
					bShowCertainDeathMain = true,
					bShowDispositionFriendly = true,
					bShowDispositionFriendlyPlayer = true,
					bShowDispositionHostile = true,
					bShowDispositionNeutral = true,
					nMaxRange = 100,
				});

				tNameplates:_OnRestore(eType, tSavedData); -- Can't use self, because OnRestore needs karSavedProperties
			end
		end

		-- Speech Bubble + Gibbed Units Fix
		tNameplates._UpdateNameplateVisibility = tNameplates.UpdateNameplateVisibility;
		tNameplates.UpdateNameplateVisibility = function(self, tNameplate)
			tNameplate.bGibbed = false;
			tNameplate.bSpeechBubble = false;
			self:_UpdateNameplateVisibility(tNameplate);
		end
	end
end

-----------------------------------------------------------------------------
-- Datachron
-----------------------------------------------------------------------------

function M:UpdateDatachronForms()
	local tDatachron = Apollo.GetAddon("Datachron");

	if (tDatachron and not tDatachron._OnLoad) then
		tDatachron._OnLoad = tDatachron.OnLoad;
		tDatachron.OnLoad = function(self)
			self:_OnLoad();

			local tXml = self.xmlDoc:ToTable();
			S:UpdateElementInXml(tXml, "Framing", { Sprite = "" });
			S:UpdateElementInXml(tXml, "Datachron", { Sprite = "" });
			self.xmlDoc = XmlDoc.CreateFromTable(tXml);
		end
	end

	local tDatachronScientist = Apollo.GetAddon("PathScientistContent");

	if (tDatachronScientist and not tDatachronScientist._OnLoad) then
		tDatachronScientist._OnLoad = tDatachronScientist.OnLoad;
		tDatachronScientist.OnLoad = function(self)
			self:_OnLoad();

			local tXml = self.xmlDoc:ToTable();
			S:UpdateElementInXml(tXml, "ScientistDatachron", { Template = "Default" });
			S:UpdateElementInXml(tXml, "DatachronScientistBottom", { Sprite = "" });
			self.xmlDoc = XmlDoc.CreateFromTable(tXml);
		end

		tDatachronScientist._OnLoadFromDatachron = tDatachronScientist.OnLoadFromDatachron;
		tDatachronScientist.OnLoadFromDatachron = function(self)
			tDatachronScientist:_OnLoadFromDatachron();
			self.wndMain:FindChild("CompletedScreen"):DestroyAllPixies()
		end
	end
end

-----------------------------------------------------------------------------
-- Quest Tracker
-----------------------------------------------------------------------------

function M:UpdateQuestTrackerForms()
	local tQuestTracker = Apollo.GetAddon("QuestTracker");

	if (tQuestTracker and not tQuestTracker._OnLoad) then
		tQuestTracker.bHasMoved = true; -- Fix Position Change on starting a Challenge

		tQuestTracker._OnLoad = tQuestTracker.OnLoad;
		tQuestTracker.OnLoad = function(self)
			self:_OnLoad();

			local tXml = self.xmlDoc:ToTable();
			S:UpdateElementInXml(tXml, "QuestTrackerForm", { LAnchorPoint = 1, LAnchorOffset = -345, TAnchorPoint = 0, TAnchorOffset = 0, RAnchorPoint = 1, RAnchorOffset = -20, BAnchorPoint = 1, BAnchorOffset = -271 });
			S:UpdateElementInXml(tXml, "QuestTrackerScroll", { Template = "ScrollableWindowHiddenScrollbars" });
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

-----------------------------------------------------------------------------
-- Ayth_Quest
-----------------------------------------------------------------------------

function M:HideAythQuestTracker()
	local tAyth = Apollo.GetAddon("Ayth_Quest");
	if (tAyth) then
		if (tAyth.tUserSettings) then
			tAyth.tUserSettings.showAythTracker = false;
		end

		if (not tAyth._OnRestore) then
			tAyth._OnRestore = tAyth.OnRestore;
			tAyth.OnRestore = function(self, eType, tSavedData)
				self:_OnRestore(eType, tSavedData);
				self.tUserSettings.showAythTracker = false;
			end
		end
	end
end

-----------------------------------------------------------------------------
-- TrackMaster
-----------------------------------------------------------------------------

function M:HideTrackMaster()
	local tTrackMaster = Apollo.GetAddon("TrackMaster");
	if (tTrackMaster and not tTrackMaster._OnRestore) then
		tTrackMaster.pinned = false;

		tTrackMaster._OnRestore = tTrackMaster.OnRestore;
		tTrackMaster.OnRestore = function(self, eType, tSavedData)
			if (eType == GameLib.CodeEnumAddonSaveLevel.Character) then
				if (type(tSavedData) ~= "table") then
					tSavedData = {};
				end

				tSavedData.Pinned = false;
			end

			self:_OnRestore(eType, tSavedData);
		end
	end
end

-----------------------------------------------------------------------------
-- JunkIt
-----------------------------------------------------------------------------

function M:EnableJunkIt()
	local tJunkIt = Apollo.GetAddon("JunkIt");
	if (tJunkIt and not tJunkIt._OnRestore) then
		tJunkIt.config.autoSell = true;
		tJunkIt.config.autoRepair = true;

		tJunkIt._OnRestore = tJunkIt.OnRestore;
		tJunkIt.OnRestore = function(self, eType, tSavedData)
			self:_OnRestore(eType, tSavedData);
			self.config.autoSell = true;
			self.config.autoRepair = true;
		end
	end
end


-----------------------------------------------------------------------------
-- Harvester
-----------------------------------------------------------------------------

function M:UpdateHarvester()
	local tHarvester = Apollo.GetAddon("Harvester");

	-- Enable TrackMaster
	if (tHarvester and not tHarvester._OnRestore) then
		if (tHarvester.settings) then
			tHarvester.settings.Options.TrackMaster = (Apollo.GetAddon("TrackMaster") ~= nil);
		end

		tHarvester._OnRestore = tHarvester.OnRestore;
		tHarvester.OnRestore = function(self, eType, tSavedData)
			self:_OnRestore(eType, tSavedData);
		    self.settings.Options.TrackMaster = (Apollo.GetAddon("TrackMaster") ~= nil);
		end
	end
end

-----------------------------------------------------------------------------
-- LootNotificationWindow
-----------------------------------------------------------------------------

function M:UpdateLootNotificationWindow()
	local tAddon = Apollo.GetAddon("LootNotificationWindow");

	if (tAddon and not tAddon._OnLoad) then
		tAddon._OnLoad = tAddon.OnLoad;
		tAddon.OnLoad = function(self)
			self:_OnLoad();

			local tXml = self.xmlDoc:ToTable();
			S:UpdateElementInXml(tXml, "LootStackForm", { LAnchorPoint = 0, LAnchorOffset = 20, RAnchorPoint = 0, RAnchorOffset = 260 });
			self.xmlDoc = XmlDoc.CreateFromTable(tXml);
		end
	end
end
