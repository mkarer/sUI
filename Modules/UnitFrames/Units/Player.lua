--[[

	s:UI Player Unit Frame

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local UnitFramesCore = S:GetModule("UnitFramesCore");
local M = UnitFramesCore:CreateSubmodule("Player");
local log;

-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

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
			BGColor="UI_WindowBGDefault", TextColor="UI_WindowTextDefault",
			Border="0", Picture="1", SwallowMouseClicks="1", Moveable="0", Escapable="0", IgnoreMouse="1",
			Overlapped="1", TooltipColor="", Sprite="BasicSprites:WhiteFill", Tooltip="",
			Name="SezzUIPanel", NoClip="1",
		},
	};
	
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
