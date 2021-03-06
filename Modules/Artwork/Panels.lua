--[[

	s:UI Panels

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Panels");
local log;

-----------------------------------------------------------------------------

local tXMLData = {
	__XmlNode = "Forms",
	{ -- Form
		__XmlNode="Form", Class="Window",
		LAnchorPoint=".5", LAnchorOffset="-230",
		TAnchorPoint="0", TAnchorOffset="0",
		RAnchorPoint=".5", RAnchorOffset="230",
		BAnchorPoint="0", BAnchorOffset="212",
		RelativeToClient="1", Template="Default",
		Font="Default", Text="", TooltipType="OnCursor",
		BGColor="00000000", TextColor="UI_WindowTextDefault",
		Border="0", Picture="1", SwallowMouseClicks="1", Moveable="0", Escapable="0", IgnoreMouse="1",
		Overlapped="1", TooltipColor="", Sprite="BasicSprites:WhiteFill", Tooltip="",
		Name="SezzUIPanel", NoClip="1",
	},
};

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self.tPanels = {};
	self.xmlDoc = XmlDoc.CreateFromTable(tXMLData);
end

function M:OnEnable()
	self:CreatePanel(CColor.new(0, 0, 0, 0.3), { 0, 1, 1, 1 }, { 0, -250, 0, -59 });
	self:CreatePanel(CColor.new(1, 1, 1, 0.6), { 0, 1, 1, 1 }, { 0, -251, 0, -250 });
	self:CreatePanel(CColor.new(1, 1, 1, 0.6), { 0, 1, 1, 1 }, { 0, -59, 0, -58 });
end

-----------------------------------------------------------------------------
-- Panel Creation
-----------------------------------------------------------------------------

function M:CreatePanel(tColor, tAnchorPoints, tAnchorOffsets, tParent)
	local wndPanel = Apollo.LoadForm(self.xmlDoc, "SezzUIPanel", "InWorldHudStratum", tParent or self.tPanels); -- FixedHudStratumLow
	wndPanel:SetName("SezzUIPanel"..(#self.tPanels + 1));
	wndPanel:SetAnchorPoints(unpack(tAnchorPoints));
	wndPanel:SetAnchorOffsets(unpack(tAnchorOffsets));
	wndPanel:SetBGColor(tColor);
	
	table.insert(self.tPanels, wndPanel);
	return wndPanel;
end
