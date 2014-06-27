--[[

	s:UI MiniMap Modifications

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("MiniMap", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log, tMiniMap;

-----------------------------------------------------------------------------

local fnHookedMiniMapOnLoad = function(self)
	-- Replace MiniMap XML Data
	self.xmlDoc = M.xmlDoc;
	self.xmlDoc:RegisterCallback("OnDocumentReady", self);
end

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
--	self:PostHook(tMiniMap, "BuildCustomMarkerInfo", "HideGuardOverlays");
	self:HideGuardOverlays();

	-- Zoom Out
	tMiniMap.fSavedZoomLevel = 1;
	tMiniMap.wndMiniMap:SetZoomLevel(1);

	-- Move/Resize Windows
	local nSize = tMiniMap.wndMain:GetWidth();
	local nScale = 0.6;
	local nSizeUpscaled = nSize / nScale;

	tMiniMap.wndMiniMap:SetScale(nScale);
	tMiniMap.wndMiniMap:SetAnchorOffsets(0, 0, nSizeUpscaled - nSize, nSizeUpscaled - nSize); -- Scaling currently doesn't work very vell

--	tMiniMap.wndMain:SetAnchorOffsets(-204, -204, 0, 0);
log:debug(nSizeUpscaled - nSize)
	-- TODO: Set Position in XML File
end

function M:HideGuardOverlays()
	tMiniMap.tMinimapMarkerInfo.CityDirections = nil;
end

--[[
BuildCustomMarkerInfo

	tMinimapMarkerInfo.CityDirections.bShown = false


MiniMap:OnDocumentReady()

	self.wndMinimapButtons 	= self.wndMain:FindChild("ButtonContainer")
	if self.fSavedZoomLevel then
		self.wndMiniMap:SetZoomLevel( self.fSavedZoomLevel)      ---- 1
	end


self.wndZoneName

function MiniMap:OnRotateMapUncheck()
	--self.wndMinimapOptions:FindChild("OptionsBtnRotate"):FindChild("Image"):SetSprite("CRB_UIKitSprites:btn_radioSMALLNormal")
	self.wndMiniMap:SetMapOrientation(0)
end

options frame = unter map

function MiniMap:GetDefaultUnitInfo()
	local tInfo =
	{
		strIcon = "",
		strIconEdge = "MiniMapObjectEdge",
		crObject = CColor.new(1, 1, 1, 1),
		crEdge = CColor.new(1, 1, 1, 1),
		bAboveOverlay = false,
	}
	return tInfo
end

--]]
