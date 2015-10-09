--[[

	s:UI MiniMap Modifications

	Martin Karer / Sezz, 2014-2015
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("MiniMap", "Gemini:Hook-1.0");
M:SetDefaultModuleState(false);
local log, tMiniMap;
local tinsert = table.insert;

-----------------------------------------------------------------------------

local function UpdateMiniMapXml(xmlDoc)
	-- Modify XML
	local tXml = xmlDoc:ToTable();
	S:UpdateElementInXml(tXml, "Minimap", { LAnchorOffset = -157, TAnchorPoint = 1, TAnchorOffset = -246, RAnchorPoint = 1, RAnchorOffset = -8, BAnchorPoint = 1, BAnchorOffset = -18, RelativeToClient = 0 });
	S:UpdateElementInXml(tXml, "MinimapMouseCatcher", { Visible = 0 });
	S:FindElementInXml(tXml, "Name", "MapRingBackgroundNew", true);
	S:UpdateElementInXml(tXml, "ButtonContainer", { LAnchorPoint = 0, LAnchorOffset = 0, TAnchorPoint = 1, TAnchorOffset = -22, RAnchorPoint = 1, RAnchorOffset = 0, BAnchorPoint = 1, BAnchorOffset = 0 });
	S:UpdateElementInXml(tXml, "MapZonePvPFlag", { LAnchorPoint = 0, LAnchorOffset = 0, TAnchorPoint = 0, TAnchorOffset = -16, RAnchorPoint = 1, RAnchorOffset = 0, BAnchorPoint = 0, BAnchorOffset = 0, Font = "CRB_Pixel_O", Visible = 0 });
	S:UpdateElementInXml(tXml, "MapZoneName", { LAnchorPoint = 0, LAnchorOffset = 0, TAnchorPoint = 0, TAnchorOffset = 0, RAnchorPoint = 1, RAnchorOffset = 0, BAnchorPoint = 0, BAnchorOffset = 22, Font = "CRB_Pixel_O" });

	local tXmlMapMenuButton = S:FindElementInXml(tXml, "MapMenuButton");
	tinsert(tXmlMapMenuButton, { __XmlNode = "Event", Name = "ButtonSignal", Function = "OnMenuBtnToggle" });
	S:UpdateElementInXml(tXml, "MapMenuButton", { Base = "sUI:SezzActionButton", Font = "DefaultButton", LAnchorPoint = 0, LAnchorOffset = 0, TAnchorPoint = 0, TAnchorOffset = 0, RAnchorPoint = 0, RAnchorOffset = 22, BAnchorPoint = 1, BAnchorOffset = 0, TransitionShowHide = 0, TestAlpha = 0, Visible = 1 });

	tinsert(tXmlMapMenuButton, { __XmlNode = "Event", Name = "ButtonSignal", Function = "OnMenuBtnToggle" });
	tinsert(tXmlMapMenuButton, { __XmlNode = "Control", Class = "Window", LAnchorPoint = 0, LAnchorOffset = 2, TAnchorPoint = 0, TAnchorOffset = 2, RAnchorPoint = 1, RAnchorOffset = -2, BAnchorPoint = 1, BAnchorOffset = -2, RelativeToClient = 1, Font = "Default", Text = "", BGColor = "cc000000", TextColor = "UI_WindowTextDefault", Template = "Default", TooltipType = "OnCursor", Name = "Background", TooltipColor = "", Sprite = "sUI:MiniMapButtonBGDark", Picture = 1, IgnoreMouse = 1,
		{ __XmlNode = "Control", Class = "Window", LAnchorPoint = 0, LAnchorOffset = 0, TAnchorPoint = 0, TAnchorOffset = 0, RAnchorPoint = 1, RAnchorOffset = 0, BAnchorPoint = 1, BAnchorOffset = 0, RelativeToClient = 1, Font = "Default", Text = "", BGColor = "UI_WindowBGDefault", TextColor = "UI_WindowTextDefault", Template = "Default", TooltipType = "OnCursor", Name = "Icon", TooltipColor = "", Picture = 1, IgnoreMouse = 1, Sprite = "sUI:IconFilter" }
	});

	local tXmlMiniMap = S:FindElementInXml(tXml, "Name", "MapContent", true);
	S:UpdateElementInXml(tXmlMiniMap, "MapContent", { LAnchorPoint = 0, LAnchorOffset = 2, TAnchorPoint = 0, TAnchorOffset = 2, RAnchorPoint = 1, RAnchorOffset = 95, BAnchorPoint = 1, BAnchorOffset = 95, Mask = "", ItemRadius = 1, Scale = 0.6 });
	tinsert(tXml[1], 2, { __XmlNode = "Control", Class = Window, LAnchorPoint = 0, LAnchorOffset = 0, TAnchorPoint = 0, TAnchorOffset = 22, RAnchorPoint = 1, RAnchorOffset = 0, BAnchorPoint = 1, BAnchorOffset = -57, RelativeToClient = 1, Font = "Default", Text = "", BGColor = "UI_WindowBGDefault", TextColor = "UI_WindowTextDefault", Template = "Default", TooltipType = "OnCursor", Name = "MapContainer", TooltipColor = "", Sprite = "SezzUIBorder", Picture = 1, IgnoreMouse = 1, tXmlMiniMap });

	return XmlDoc.CreateFromTable(tXml);
end

function M:OnInitialize()
	log = S.Log;

	tMiniMap = Apollo.GetAddon("MiniMap");
	if (tMiniMap) then
		log:debug("Hooking MiniMap");
		-- Replace XML Form
		-- TODO: Load Carbine's XML file and apply changes directly (if possible)
		tMiniMap._OnDocumentReady = tMiniMap.OnDocumentReady;
		tMiniMap.OnDocumentReady = function(self)
			if (self.xmlDoc ~= nil) then
				self.xmlDoc = UpdateMiniMapXml(self.xmlDoc);
				self:_OnDocumentReady();

				local nOptionsHeight = self.wndMinimapOptions:GetHeight();
				local nOptionsWidth = self.wndMinimapOptions:GetWidth();
				local nScreenWidth, nScreenHeight = Apollo.GetScreenSize();

				self.wndMinimapOptions:Move(nScreenWidth - nOptionsWidth - 180, nScreenHeight - nOptionsHeight, nOptionsHeight, nOptionsWidth);
			end
		end

		-- PVP Flag Update
		tMiniMap.UpdatePvpFlag = M.UpdatePvpFlagHook;
		tMiniMap.UpdateRapidTransportBtn = M.UpdateRapidTransportBtnHook;
	else
		-- MiniMap addon not found, disable me.
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Update MiniMap
	self:RegisterAddonLoadedCallback("MiniMap", "UpdateMiniMap");

	-- Remove Bag Button
	self:RegisterAddonLoadedCallback("XPBar", "RemoveBagButton");
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
-- Bag Button
-----------------------------------------------------------------------------

function M:RemoveBagButton()
	-- Who put this in the XPBar addon?
	Apollo.GetAddon("XPBar").wndInvokeForm:Show(false, true);
end

-----------------------------------------------------------------------------
-- Hooked Functions
-----------------------------------------------------------------------------

local tZoneColors = {
	Sanctuary	= CColor.new(0.41, 0.8, 0.94),
	Friendly	= CColor.new(0.1, 1.0, 0.1),
	Hostile		= CColor.new(1.0, 0.1, 0.1),
	PVP			= CColor.new(1.0, 0.1, 0.1),
	Contested	= CColor.new(1.0, 0.7, 0.0),
	Default		= CColor.new(1.0, 1.0, 1.0),
};

function M:UpdatePvpFlagHook()
	local nZoneRules = GameLib.GetCurrentZonePvpRules();
	local ePlayerFaction = S.myCharacter and S.myCharacter:GetFaction() or 0;
	local colorZone;

	if (nZoneRules == GameLib.CodeEnumZonePvpRules.Sanctuary) then
		-- Sanctuary
		colorZone = tZoneColors.Sanctuary;
	elseif ((ePlayerFaction == Unit.CodeEnumFaction.ExilesPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.ExileStronghold) or (ePlayerFaction == Unit.CodeEnumFaction.DominionPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.DominionStronghold)) then
		-- Player Faction Stronghold
		colorZone = tZoneColors.Friendly;
	elseif ((ePlayerFaction == Unit.CodeEnumFaction.ExilesPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.DominionStronghold) or (ePlayerFaction == Unit.CodeEnumFaction.DominionPlayer and nZoneRules == GameLib.CodeEnumZonePvpRules.ExileStronghold)) then
		-- Opoosite Faction Stronghold
		colorZone = tZoneColors.Hostile;
	elseif (nZoneRules == GameLib.CodeEnumZonePvpRules.Pvp) then
		-- PVP
		colorZone = tZoneColors.PVP;
	elseif (nZoneRules == GameLib.CodeEnumZonePvpRules.DominionPVPStronghold or nZoneRules == GameLib.CodeEnumZonePvpRules.ExilesPVPStronghold) then
		-- PVP Stronghold
		-- Not sure where/when?
		log:debug("PVP Stronghold: %s", nZoneRules == GameLib.CodeEnumZonePvpRules.DominionPVPStronghold and "Dominion" or "Exiles");
		colorZone = tZoneColors.Contested;
	else
		-- Default
		if (GameLib.IsPvpServer()) then
			colorZone = tZoneColors.Contested;
		else
			colorZone = tZoneColors.Default;
		end
	end

	self.wndZoneName:SetTextColor(colorZone);
end

function M:UpdateRapidTransportBtnHook()
	local InlineButtons = M:GetModule("InlineButtons");
	if (InlineButtons.tButtonContainer) then
		-- MiniMap.lua:1896
		local wndRapidTransport = InlineButtons.tButtonContainer:GetButton("RapidTransport").wndMain;
		local tZone = GameLib.GetCurrentZoneMap();
		local nZoneId = 0;

		if (tZone ~= nil) then
			nZoneId = tZone.id;
		end

		local bOnArkship = tZone == nil or GameLib.IsTutorialZone(nZoneId);
		wndRapidTransport:Show(not bOnArkship or wndRapidTransport:IsShown());
	end
end
