--[[

	s:UI MiniMap Inline Buttons

	TODO: Maybe they would be better on the left side of the MiniMap?

	Martin Karer / Sezz, 2014-2015
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local MiniMap = S:GetModule("MiniMap");
local M = MiniMap:CreateSubmodule("InlineButtons", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Button Container
-----------------------------------------------------------------------------

local CreateButtonContainer;
do
	local CreateButton = function(self, strName, strIcon, bLastButton, strTemplate)
		local tButton = {};
		tButton.strName = strName;
		tButton.wndMain = Apollo.LoadForm(self.xmlDoc, strTemplate or "SezzMiniMapInlineButton", self.wndMain, tButton);
		tButton.wndMain:SetName(string.format("SezzMiniMapInlineButton%s", strName));
		tButton.wndMain:FindChild("Icon"):SetSprite(strIcon);

		-- Move Button
		if (bLastButton) then
			tButton.wndMain:SetAnchorPoints(1, 0, 1, 1);
			tButton.wndMain:SetAnchorOffsets(-self.nButtonSize, 0, 0, 0);
		else
			local nPositionX = #self.tButtons * (self.nButtonSize + self.nButtonPadding);
			tButton.wndMain:SetAnchorOffsets(nPositionX, 0, nPositionX + self.nButtonSize, 0);
		end

		-- Done
		table.insert(self.tButtons, tButton);
		return tButton;
	end

	local GetButton = function(self, strName)
		for _, tButton in pairs(self.tButtons) do
			if (tButton.strName == strName) then
				return tButton;
			end
		end
	end

	CreateButtonContainer = function(xmlDoc)
		local tContainer = {};
		tContainer.wndMain = Apollo.LoadForm(xmlDoc, "SezzMiniMapInlineButtonContainer", nil, tButtonContainer);
		tContainer.tButtons = {};
		tContainer.nButtonPadding = 2;
		tContainer.xmlDoc = xmlDoc;

		tContainer.CreateButton = CreateButton;
		tContainer.GetButton = GetButton;

		-- Find Button Size
		local nButtonSize = 30;
		for _, f in pairs(xmlDoc:ToTable()) do
			if (f.Name and f.Name == "SezzMiniMapInlineButton") then
				nButtonSize = tonumber(f.RAnchorOffset) - tonumber(f.LAnchorOffset);
				break;
			end
		end

		tContainer.nButtonSize = nButtonSize;

		return tContainer;
	end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
	self.tButtonContainer = CreateButtonContainer(self.xmlDoc);

	-----------------------------------------------------------------------------
	-- Rapid Transport
	-----------------------------------------------------------------------------
	local tButtonRapidTransport = self.tButtonContainer:CreateButton("RapidTransport", "IconSprites:Icon_MapNode_Map_RapidTransport");
	tButtonRapidTransport.wndMain:SetTooltip(Apollo.GetString("CRB_RapidTransport"));

	tButtonRapidTransport.InvokeTaxiWindow = function(self)
		Event_FireGenericEvent("InvokeTaxiWindow");
	end

	tButtonRapidTransport.wndMain:AddEventHandler("ButtonSignal", "InvokeTaxiWindow", tButtonRapidTransport);
	MiniMap:UpdateRapidTransportBtnHook(); -- Show/Hide

	-----------------------------------------------------------------------------
	-- Mail
	-----------------------------------------------------------------------------
	local tButtonMail = self.tButtonContainer:CreateButton("Mail", "Icon_Windows32_UI_CRB_InterfaceMenu_Mail");
	tButtonMail.wndMain:SetTooltip(Apollo.GetString("InterfaceMenu_Mail"));

	tButtonMail.ToggleMail = function(self)
		ChatSystemLib.Command("/ToggleMailWindow");
	end

	tButtonMail.wndMain:AddEventHandler("ButtonSignal", "ToggleMail", tButtonMail);

	self.tButtonContainer.ShowMailButton = function(self)
		self:GetButton("Mail").wndMain:Show(true);
	end

	self.tButtonContainer.HideMailButton = function(self)
		self:GetButton("Mail").wndMain:Show(false);
	end

	Apollo.RegisterEventHandler("Sezz_NewMailAvailable", "ShowMailButton", self.tButtonContainer);
	Apollo.RegisterEventHandler("Sezz_MailAvailable", "ShowMailButton", self.tButtonContainer);
	Apollo.RegisterEventHandler("Sezz_NoMailAvailable", "HideMailButton", self.tButtonContainer);

	local nUnreadMessages, nReadMessages = S:GetMailAmount();
	tButtonMail.wndMain:Show(nUnreadMessages + nReadMessages > 0, true);

	-----------------------------------------------------------------------------
	-- Done
	-----------------------------------------------------------------------------
	self.xmlDoc = nil;
end
