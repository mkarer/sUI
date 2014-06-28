--[[

	s:UI Chat Window Position
	TODO: Input box is still buggy and I also want to hide/change the channel related buttons.

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local ChatCore = S:GetModule("ChatCore");
local M = ChatCore:NewModule("Position", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Move Chat Window
	local wndChat = Apollo.FindWindowByName("ChatWindow");
	wndChat:SetAnchorPoints(0, 1, 0, 1);
	wndChat:SetAnchorOffsets(10, -270, 500, -55);

	-- Hook Channel Creation
	self:PostHook(ChatCore.tChatLog, "OnAddNewTabChat", "UpdateChatChannel");
	self:PostHook(ChatCore.tChatLog, "OnAddNewTabCombat", "UpdateChatChannel");

	-- Update Channel Windows
	for _, wndChannel in pairs(ChatCore.tChatLog.tChatWindows) do
		self:UpdateChatChannel(wndChannel);
	end
end

function M:UpdateChatChannel(wndChannel, wndChannelHooked)
	local wndChannel = wndChannelHooked and ChatCore.tChatLog.tChatWindows[#ChatCore.tChatLog.tChatWindows] or wndChannel;

	-- Move Input Box
	local artFooter = wndChannel:FindChild("BGArt_Footer");
	artFooter:SetAnchorPoints(0, 0, 1, 0);
	artFooter:SetAnchorOffsets(-23, -50, 5, -20);

	local btnBeginChat = wndChannel:FindChild("BeginChat");
	btnBeginChat:SetAnchorPoints(0, 0, 0, 0);
	btnBeginChat:SetAnchorOffsets(-16, -43, 2, -25);

	local inputBox = wndChannel:FindChild("Input");
	inputBox:SetAnchorPoints(0, 0, 1, 0);
	inputBox:SetAnchorOffsets(0, -45, -20, -25);

	local inputType = wndChannel:FindChild("InputType");
	inputType:SetAnchorPoints(0, 0, 1, 0);
	inputType:SetAnchorOffsets(5, -50, -30, -20);

	local emotesButton = wndChannel:FindChild("EmoteBtn");
	emotesButton:SetAnchorPoints(1, 0, 1, 0);
	emotesButton:SetAnchorOffsets(-29, -25, -4, -5);

	local emotesMenu = wndChannel:FindChild("EmoteMenu");
	emotesMenu:SetAnchorPoints(1, 0, 1, 0);
	emotesMenu:SetAnchorOffsets(-164, -286, 2, -50);

	local inputCatcher = wndChannel:FindChild("MouseCatcher");
	inputCatcher:SetAnchorOffsets(-5, -31, 5, 5);

	local chat = wndChannel:FindChild("Chat");
--	chat:SetAnchorOffsets(-18, 25, -1, -1);
	chat:SetAnchorOffsets(-18, 2, -1, -1);

	-- Hide/Move Channel Buttons
	wndChannel:FindChild("InputTypeBtn"):Show(false, true);
--	wndChannel:FindChild("Options"):Show(false, true);
	wndChannel:FindChild("Options"):SetAnchorPoints(1, 0, 1, 0);
	wndChannel:FindChild("Options"):SetAnchorOffsets(-37, -11, -16, 11); -- Just in case...
	wndChannel:FindChild("CloseBtn"):Show(false, true);
	wndChannel:FindChild("AddChatWindow"):Show(false, true);

	-- Bigger Options Form
	wndChannel:FindChild("OptionsSubForm"):SetAnchorOffsets(-20, 2, 0, 0);

	-- Hide Background
	wndChannel:FindChild("BGArt"):SetSprite(nil);
end
