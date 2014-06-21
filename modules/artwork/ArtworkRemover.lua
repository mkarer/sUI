--[[

	s:UI Artwork Remover

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("ArtworkRemover", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Action Bars
	local tActionBarFrame = Apollo.GetAddon("ActionBarFrame");
	log:debug(tActionBarFrame);
	log:debug(tActionBarFrame.wndArt);

	for _, f in pairs(tActionBarFrame.wndArt:GetChildren()) do
		self:RemoveArtwork(f);
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------

function M:RemoveArtwork(f)
	log:debug(f:GetName());

	-- Destroy Pixies
	local i = 1;
	while (true) do
		local pixie = f:GetPixieInfo(i);
		if (pixie) then
			f:DestroyPixie(i);
			i = i + 1;
		else
			break;
		end
	end

	f:SetSprite(nil);
end
