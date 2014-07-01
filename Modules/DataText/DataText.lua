--[[

	s:UI Data Text

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("DataText");
local log;
local strformat, tostring = string.format, tostring;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	self.tFontSmall = S:CreatePixelFont("04b_11", 8);
	self.tFontLarge = S:CreatePixelFont("04b_11", 24);
	self.tColorClock = CColor.new(1, 1, 1, 0.2);

	self.wndMain = Apollo.LoadForm(self.xmlDoc, "DataText", nil, self);
	self.wndMain:Show(true, true);

	-- Start Clock Timer + Update Time
	self.timerClock = ApolloTimer.Create(2, true, "UpdateText", self);
	self.timerMemory = ApolloTimer.Create(300, true, "UpdateAddondMemory", self); -- LAAAAG
	self.timerStats = ApolloTimer.Create(3, true, "UpdateLatency", self);

	-- Update Memory/Stats
	self:UpdateAddondMemory();
	self:UpdateLatency();

	-- Update Durability
	self:RegisterEvent("ItemDurabilityUpdate", "UpdateDurability");
	self:RegisterEvent("Sezz_CharacterLoaded", "UpdateDurability");
	self:UpdateDurability();

	-- Show Text
	self:UpdateText();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Clock
-----------------------------------------------------------------------------

function M:UpdateText(a)
	-- Get Time
	local tTime = GameLib.GetLocalTime();
	local strTime = strformat("%02d:%02d", tostring(tTime.nHour), tostring(tTime.nMinute));

	-- Update Text
	local strStats = strformat("%dFPS %.1fMB %dMS %d%%", self.nFPS, self.nAddonMemory, self.nLatency, self.nDurability);

	self.tFontLarge:Draw(self.wndMain:FindChild("Clock"), strTime, true, self.tColorClock);
	self.tFontSmall:Draw(self.wndMain:FindChild("Stats"), strStats, true);
end


-----------------------------------------------------------------------------
-- Latency / FPS
-----------------------------------------------------------------------------

function M:UpdateLatency()
	self.nLatency = GameLib.GetLatency();
	self.nFPS = GameLib.GetFrameRate();
end

-----------------------------------------------------------------------------
-- Durability
-----------------------------------------------------------------------------

function M:UpdateDurability()
	local nDurabilityLowest = 100;

	if (S.bCharacterLoaded) then
		local tItems = S.myCharacter:GetEquippedItems();

		for _, tItem in ipairs(tItems) do
			local nDurabilityMax = tItem:GetMaxDurability();
			local nDurabilityCurrent = tItem:GetDurability();

			if (nDurabilityMax > 0) then
				local nDurabilityPercent = math.floor(nDurabilityCurrent / (nDurabilityMax / 100));

				if (nDurabilityPercent < nDurabilityLowest) then
					nDurabilityLowest = nDurabilityPercent;
				end
			end
		end
	end

	self.nDurability = nDurabilityLowest;
end

-----------------------------------------------------------------------------
-- Addon Memory
-----------------------------------------------------------------------------

local tAddonsCarbine = {
	["Abilities"] = true,
	["AbilityAMPs"] = true,
	["AbilityVendor"] = true,
	["AccountInventory"] = true,
	["Achievements"] = true,
	["ActionBarFrame"] = true,
	["ActionBarShortcut"] = true,
	["AdventureClueTracker"] = true,
	["AdventureMalgrave"] = true,
	["AdventureNorthernWilds"] = true,
	["AdventureWhitevale"] = true,
	["ArenaTeam"] = true,
	["BankViewer"] = true,
	["BuildMap"] = true,
	["CastBar"] = true,
	["Challenges"] = true,
	["Character"] = true,
	["ChatLog"] = true,
	["Cinematics"] = true,
	["Circles"] = true,
	["ClassResources"] = true,
	["CombatLog"] = true,
	["CommDisplay"] = true,
	["ContextMenuPlayer"] = true,
	["Costumes"] = true,
	["Crafting"] = true,
	["CraftingGrid"] = true,
	["CraftingResume"] = true,
	["CraftingSummaryScreen"] = true,
	["CrowdControlGameplay"] = true,
	["CSI"] = true,
	["CustomerSurvey"] = true,
	["Datachron"] = true,
	["Death"] = true,
	["Dialog"] = true,
	["ErrorDialog"] = true,
	["FloatText"] = true,
	["FriendsList"] = true,
	["GalacticArchive"] = true,
	["GameExit"] = true,
	["GroupFrame"] = true,
	["Guild"] = true,
	["GuildAlerts"] = true,
	["GuildBank"] = true,
	["GuildContentInfo"] = true,
	["GuildContentPerks"] = true,
	["GuildContentRoster"] = true,
	["GuildDesigner"] = true,
	["GuildRegistration"] = true,
	["Hazards"] = true,
	["HealthShieldBar"] = true,
	["Housing"] = true,
	["HousingAlerts"] = true,
	["HUD"] = true,
	["HUDAlerts"] = true,
	["Inspect"] = true,
	["InstanceSettings"] = true,
	["InterfaceMenuList"] = true,
	["Inventory"] = true,
	["Keybinding"] = true,
	["LevelUpUnlocks"] = true,
	["LootNotificationWindow"] = true,
	["LoreWindow"] = true,
	["Macros"] = true,
	["Mail"] = true,
	["MarketplaceAuction"] = true,
	["MarketplaceCommodity"] = true,
	["MarketplaceCREDD"] = true,
	["MarketplaceListings"] = true,
	["MasterLoot"] = true,
	["MatchMaker"] = true,
	["MatchTracker"] = true,
	["Medic"] = true,
	["MessageManager"] = true,
	["MiniMap"] = true,
	["MountCustomization"] = true,
	["Nameplates"] = true,
	["NCCB"] = true,
	["NeedVsGreed"] = true,
	["NeighborList"] = true,
	["NonCombatSpellbook"] = true,
	["Options"] = true,
	["OptionsInterface"] = true,
	["PathExplorerContent"] = true,
	["PathScientistContent"] = true,
	["PathSettlerContent"] = true,
	["PathSoldierContent"] = true,
	["PlayerPath"] = true,
	["PlayerTicket"] = true,
	["PopupText"] = true,
	["ProgressLog"] = true,
	["PublicEventStats"] = true,
	["PublicEventVote"] = true,
	["PvPKillBoard"] = true,
	["QuestLog"] = true,
	["QuestTracker"] = true,
	["RaidFrameBase"] = true,
	["RaidFrameLeaderOptions"] = true,
	["RaidFrameMasterLoot"] = true,
	["RaidFrameTearOff"] = true,
	["RecallFrame"] = true,
	["ReportPlayer"] = true,
	["Reputation"] = true,
	["ResourceConversion"] = true,
	["RewardIcons"] = true,
	["Runecrafting"] = true,
	["RuneSets"] = true,
	["Sabotage"] = true,
	["SocialPanel"] = true,
	["SprintMeter"] = true,
	["StalkerResource"] = true,
	["StoryPanel"] = true,
	["Stuck"] = true,
	["SupplySatchel"] = true,
	["TargetFrame"] = true,
	["TaxiMap"] = true,
	["TechWarrior"] = true,
	["ToolTips"] = true,
	["Tradeskills"] = true,
	["TradeskillTrainer"] = true,
	["Trading"] = true,
	["Tutorial"] = true,
	["Util"] = true,
	["Vendor"] = true,
	["Warparty"] = true,
	["WarpartyBank"] = true,
	["Warplots"] = true,
	["Who"] = true,
	["XPBar"] = true,
	["ZoneCompletion"] = true,
	["ZoneMap"] = true,
};

function M:UpdateAddondMemory()
	if (S.inCombat) then
		-- Update later
		return;
	end

	log:debug("++++++++++++ Updating Addon Memory");

	local nAddonMemory = 0;
	local tAddons = Apollo:GetAddons();

	for _, strName in pairs(tAddons) do
		if (not tAddonsCarbine[strName]) then
			local tAddon = Apollo.GetAddonInfo(strName);
			if (tAddon and tAddon.nMemoryUsage) then
				nAddonMemory = nAddonMemory + tAddon.nMemoryUsage;
			end
		end
	end

	self.nAddonMemory = nAddonMemory / 1024 / 1024;
end
