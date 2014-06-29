--[[

	s:UI Tooltips

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Tooltips");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();

	local tTooltips = Apollo.GetAddon("ToolTips");
	if (tTooltips) then
		-- OnLoad Hook
		-- Applies our XML
		tTooltips.OnLoad = function(self)
			self.xmlDoc = M.xmlDoc;
			self.xmlDoc:RegisterCallback("OnDocumentReady", self);
		end

		-- OnDocumentReady Hook
		-- Applies our WorldTooltipContainer (they hardcoded TooltipsForms.xml)
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

--[[
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
	else
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end
