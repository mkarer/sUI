--[[

	s:UI Automatically loot mail when in range

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("AutoLootMail");
local log, MagicMail, Flip;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	MagicMail = Apollo.GetAddon("MagicMail");
	Flip = Apollo.GetAddon("Flip");

	self:SetEnabledState(S.DB.Modules.AutoLootMail.bEnabled and MagicMail ~= nil);
end

function M:OnEnable()
	self:RegisterEvent("Sezz_NewMailAvailable", "GetMail");
	self:RegisterEvent("LootedItem", "RefreshFlip");
	self:RegisterEvent("LootedGold", "RefreshFlip");
end

function M:OnDisable()
	self:UnregisterAllEvents();
end

function M:GetMail()
	-- Retrieve Mail
	MagicMail:OnSlashCommand();
end

function M:RefreshFlip()
	-- Refresh Flip
	if (Flip and Flip.bLoadOk and Flip.market.wndMain:IsShown()) then
		Flip.market:RefreshCX();
	end
end
