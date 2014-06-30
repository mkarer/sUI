--[[

	s:UI Temp File

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Temp", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	if (S.bCharacterLoaded) then
--		self:EventHandler();
	else
--		self:RegisterEvent("Sezz_CharacterLoaded", "EventHandler");
	end

	self:RegisterEvent("InterfaceMenuList_AlertAddOn", "EventHandler"); -- Calculate
end

function M:EventHandler(event, ...)
--	log:debug(event);

	if (true) then return; end

	if (event == "InterfaceMenuList_AlertAddOn") then
		local strAddon, tAlertInfo = ...;

		if (strAddon == Apollo.GetString("InterfaceMenu_Mail")) then
			log:debug("[InterfaceMenuList_AlertAddOn] Show Mail Alert: "..(tAlertInfo[1] and "YES" or "NO"));
		end
	end

	local nUnreadMessages = 0;
	for idx, tMessage in pairs(MailSystemLib.GetInbox()) do
		local tMessageInfo = tMessage:GetMessageInfo();
		
		if (tMessageInfo and not tMessageInfo.bIsRead) then
			nUnreadMessages = nUnreadMessages + 1;
		end
	end

	log:debug("[Unread] Show Mail Alert: "..(nUnreadMessages > 0 and "YES" or "NO"));

--	ChallengeRewardPanel:OnWindowCloseDelay();

--[[	local x = AbilityBook.GetAbilitiesList();
	for _, spl in pairs(x) do
		if (spl.strName == "Impale") then
			log:debug(spl.nId);
			log:debug(spl.tTiers[1].splObject:GetIcon());
		end
	end

		-- OnLoad Hook
		tTooltips._OnLoad = tTooltips.OnLoad;
		tTooltips.OnLoad = function(self)
			self:_OnLoad();

			local tXml = self.xmlDoc:ToTable();
			for _, tNode in pairs(tXml) do
				if (tNode.Name and tNode.Name == "WorldTooltipContainer") then
					tNode.TooltipType = "OnCursor";
					break;
				end
			end

			self.xmlDoc = XmlDoc.CreateFromTable(tXml);
		end

		-- OnDocumentReady Hook
		-- Applies our WorldTooltipContainer (Carbine uses TooltipsForms.xml EVERYWHERE instead of self.xmlDoc)
		tTooltips._OnDocumentReady = tTooltips.OnDocumentReady;
		tTooltips.OnDocumentReady = function(self)
			-- Disable GameLib.SetWorldTooltipContainer
			GameLib._SetWorldTooltipContainer = GameLib.SetWorldTooltipContainer;
			GameLib.SetWorldTooltipContainer = S.Dummy;
			-- Call Original OnDocumentReady
			self:_OnDocumentReady();
			-- Create WorldTooltipContainer 
			self.wndContainer = Apollo.LoadForm(self.xmlDoc, "WorldTooltipContainer", nil, self);
			-- Enable GameLib.SetWorldTooltipContainer
			GameLib.SetWorldTooltipContainer = GameLib._SetWorldTooltipContainer;
			GameLib._SetWorldTooltipContainer = nil;
			-- Apply WorldTooltipContainer 
			GameLib.SetWorldTooltipContainer(self.wndContainer);
		end


		-- Apollo.LoadForm Hook
		-- Why is everything in ToolTips.lua hardcoded?!
		Apollo._LoadForm = Apollo.LoadForm;
		Apollo.LoadForm = function(strFile, ...)
			if (type(strFile) == "string" and (strFile == "TooltipsForms.xml" or strFile == "ui\\Tooltips\\TooltipsForms.xml")) then
				strFile = tTooltips.xmlDoc;
			end

			return Apollo._LoadForm(strFile, ...);
		end
]]
end
