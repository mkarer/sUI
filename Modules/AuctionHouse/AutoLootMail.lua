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

	Apollo.RegisterTimerHandler("SezzUITimer_AutoLootMail", "CheckMail", self);
	Apollo.CreateTimer("SezzUITimer_AutoLootMail", 1, false);
end

function M:OnEnable()
	self:RegisterEvent("Sezz_NewMailAvailable", "CheckMail");
	self:RegisterEvent("Sezz_MailAvailable", "CheckMail");
	self:RegisterEvent("Sezz_NoMailAvailable", "CheckMail");
	self:RegisterEvent("MailResult", "OnMailResult");

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

function M:CheckMail()
	local nUnreadMessages, nReadMessages = S:GetMailAmount();

	if (nUnreadMessages + nReadMessages > 0) then
		self:GetMail();

		if (not self.bStopProcessing) then
			Apollo.StartTimer("SezzUITimer_AutoLootMail");
		end
	end
end

function M:RefreshFlip()
	-- Refresh Flip
	if (Flip and Flip.bLoadOk and Flip.market.wndMain:IsShown()) then
		Flip.market:RefreshCX();
	end
end

function M:OnMailResult(event, eResult)
   if (eResult == GameLib.CodeEnumGenericError.Mail_MailBoxOutOfRange or eResult == GameLib.CodeEnumGenericError.Item_InventoryFull) then
   		self.bStopProcessing = true;
   	else
   		self.bStopProcessing = false;
   	end
end
