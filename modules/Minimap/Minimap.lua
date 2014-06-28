--[[

	s:UI MiniMap Modifications

	TODO: Mail Notification

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("MiniMap", "Gemini:Event-1.0", "Gemini:Hook-1.0");
M:SetDefaultModuleState(false);
local log, tMiniMap;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();

	tMiniMap = Apollo.GetAddon("MiniMap");
	if (tMiniMap) then
		log:debug("Hooking MiniMap");
		-- Replace XML Form
		tMiniMap.OnLoad = function(self)
			self.xmlDoc = M.xmlDoc;
			self.xmlDoc:RegisterCallback("OnDocumentReady", self);
		end

		-- PVP Flag Update
		tMiniMap.UpdatePvpFlag = M.UpdatePvpFlagHook;
	else
		-- MiniMap addon not found, disable me.
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Update MiniMap
	self:RegisterAddonLoadedCallback("MiniMap", "UpdateMiniMap");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:UpdateMiniMap()
	-- Hide Guards
	self:PostHook(tMiniMap, "BuildCustomMarkerInfo", "HideGuardOverlays");
	self:HideGuardOverlays();

	-- Zoom Out
	tMiniMap.fSavedZoomLevel = 1;
	tMiniMap.wndMiniMap:SetZoomLevel(1);

	-- Disable Button Fading
	self:DisableButtonFading();
	self:DisableButtons();

	-- Disable Resizing/Moving
	self:DisableCustomization();

	-- Enable Submodules
	self:EnableSubmodules();
end

function M:HideGuardOverlays()
	tMiniMap.tMinimapMarkerInfo.CityDirections = nil;
end

function M:DisableButtonFading()
	tMiniMap.wndMain:RemoveEventHandler("MouseEnter");
	tMiniMap.wndMain:RemoveEventHandler("MouseExit");
end

function M:DisableButtons()
	tMiniMap.wndMain:FindChild("ZoomInButton"):Enable(false);
	tMiniMap.wndMain:FindChild("ZoomOutButton"):Enable(false);
	tMiniMap.wndMain:FindChild("MapToggleBtn"):Enable(false);
	tMiniMap.wndMain:FindChild("MiniMapResizeArtForPixie"):Enable(false);
end

function M:DisableCustomization()
	tMiniMap.wndMain:RemoveStyle("Sizable");
	tMiniMap.wndMain:RemoveStyle("Moveable");
	tMiniMap.wndMain:AddStyle("IgnoreMouse");
	tMiniMap.wndMiniMap:RemoveStyle("IgnoreMouse");
end

-----------------------------------------------------------------------------
-- Hooked Functions
-----------------------------------------------------------------------------

function M:UpdatePvpFlagHook()
	local nZoneRules = GameLib.GetCurrentZonePvpRules();
	local ePlayerFaction = S.myCharacter:GetFaction();
	local colorZone;

	if (nZoneRules == GameLib.CodeEnumZonePvpRules.Sanctuary) then
		-- Sanctuary
		colorZone = CColor.new(0.41, 0.8, 0.94);
	elseif ((ePlayerFaction == Unit.CodeEnumFaction.ExilesPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.ExileStronghold) or (ePlayerFaction == Unit.CodeEnumFaction.DominionPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.DominionStronghold)) then
		-- Player Faction Stronghold
		colorZone = CColor.new(0.1, 1.0, 0.1);
	elseif ((ePlayerFaction == Unit.CodeEnumFaction.ExilesPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.DominionStronghold) or (ePlayerFaction == Unit.CodeEnumFaction.DominionPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.ExileStronghold)) then
		-- Opoosite Faction Stronghold
		colorZone = CColor.new(1.0, 0.1, 0.1);
	elseif (nZoneRules == GameLib.CodeEnumZonePvpRules.Pvp) then
		-- PVP
		colorZone = CColor.new(1.0, 0.1, 0.1);
	elseif (nZoneRules == GameLib.CodeEnumZonePvpRules.DominionPVPStronghold or nZoneRules == GameLib.CodeEnumZonePvpRules.ExilesPVPStronghold) then
		-- PVP Stronghold
		-- Not sure where/when?
		log:debug("PVP Stronghold: %s", nZoneRules == GameLib.CodeEnumZonePvpRules.DominionPVPStronghold and "Dominion" or "Exiles");
		colorZone = CColor.new(1.0, 0.7, 0.0);
	else
		-- Default
		if (GameLib.IsPvpServer()) then
		colorZone = CColor.new(1.0, 0.7, 0.0);
		else
			colorZone = CColor.new(1.0, 1.0, 1.0);
		end
	end

	self.wndZoneName:SetTextColor(colorZone);
end
