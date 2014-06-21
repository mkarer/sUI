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
	local tActionBars = Apollo.GetAddon("ActionBarFrame");
	for _, f in pairs(tActionBars.wndArt:GetChildren()) do
		self:RemoveArtwork(f);
	end

	-- Class Resources
	local tClassResources = Apollo.GetAddon("ClassResources");

	if (S.myClassId == GameLib.CodeEnumClass.Spellslinger) then
		self:RemoveArtwork(tClassResources.wndMain:FindChild("SlingerBaseFrame_InCombat"));
		self:RemoveArtwork(tClassResources.wndMain:FindChild("SlingerBaseFrame_OutOfCombat"));
		self:RawHook(tClassResources, "OnSlingerEnteredCombat", S.Dummy);
	elseif (S.myClassId == GameLib.CodeEnumClass.Esper) then
		self:RemoveArtwork(tClassResources.wndMain:FindChild("EsperBaseFrame_InCombat"));
		self:RemoveArtwork(tClassResources.wndMain:FindChild("EsperBaseFrame_OutOfCombat"));
		--self:RawHook(tClassResources, "OnEsperEnteredCombat", S.Dummy);
	elseif (S.myClassId == GameLib.CodeEnumClass.Engineer) then
		self:RemoveArtwork(tClassResources.wndMain:FindChild("MainResourceFrame"));
	elseif (S.myClassId == GameLib.CodeEnumClass.Medic) then
		self:RemoveArtwork(tClassResources.wndMain:FindChild("MedicBaseFrame_InCombat"));
		self:RemoveArtwork(tClassResources.wndMain:FindChild("MedicBaseFrame_OutOfCombat"));
--	elseif (S.myClassId == GameLib.CodeEnumClass.Warrior) then
	end

	-- Experience Bar
	local tExperienceBar = Apollo.GetAddon("XPBar");
	for _, f in pairs(tExperienceBar.wndArt:GetChildren()) do
		self:RemoveArtwork(f);
	end

end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------

function M:RemoveArtwork(f)
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
