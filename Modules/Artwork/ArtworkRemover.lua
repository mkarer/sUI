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

	-- Simple Artwork Removal
--	self:StyleActionBars();
	self:StyleExtraActionBar();
	self:StyleClassResources();
	self:StyleExperienceBar();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Styling Hooks
-----------------------------------------------------------------------------

--[[
function M:StyleActionBars()
	local tActionBars = Apollo.GetAddon("ActionBarFrame");
	if (not tActionBars) then return; end
	self:Unhook(tActionBars, "OnDocumentReady");

	if (tActionBars.wndArt) then
		log:debug("Styling Action Bars");
		for _, f in pairs(tActionBars.wndArt:GetChildren()) do
			S:RemoveArtwork(f);
		end
	else
		log:debug("Action Bars aren't ready yet...");
		self:PostHook(tActionBars, "OnDocumentReady", "StyleActionBars");
	end
end
--]]

function M:StyleExtraActionBar()
	local tExtraActionBar = Apollo.GetAddon("ActionBarShortcut");
	if (not tExtraActionBar) then return; end
	self:Unhook(tExtraActionBar, "OnDocumentReady");

	if (tExtraActionBar.tActionBars) then
		log:debug("Styling Extra Action Bars");
		for _, f in pairs(tExtraActionBar.tActionBars) do
			if (f) then
				S:RemoveArtwork(f);
			end
		end

		for _, f in pairs(tExtraActionBar.tActionBarsHorz) do
			if (f) then
				S:RemoveArtwork(f);
			end
		end

		for _, f in pairs(tExtraActionBar.tActionBarsVert) do
			if (f) then
				S:RemoveArtwork(f);
			end
		end

--		if (not tExtraActionBar.bSezzUIStyling) then
--			tExtraActionBar.bSezzUIStyling = true;
--			self:PostHook(tExtraActionBar, "OnDockBtn", "StyleExtraActionBar");
--			self:PostHook(tExtraActionBar, "OnOrientationBtn", "StyleExtraActionBar");
--		end
	else
		log:debug("Extra Action Bars aren't ready yet...");
		self:PostHook(tExtraActionBar, "OnDocumentReady", "StyleExtraActionBar");
	end
end

function M:StyleClassResources()
	local tClassResources = Apollo.GetAddon("ClassResources");
	if (not tClassResources) then return; end
	self:Unhook(tClassResources, "OnCharacterCreated");

	if (tClassResources.wndMain) then
		log:debug("Styling Class Resources");
		if (S.myClassId == GameLib.CodeEnumClass.Spellslinger) then
			S:RemoveArtwork(tClassResources.wndMain:FindChild("SlingerBaseFrame_InCombat"));
			S:RemoveArtwork(tClassResources.wndMain:FindChild("SlingerBaseFrame_OutOfCombat"));
			self:RawHook(tClassResources, "OnSlingerEnteredCombat", S.Dummy);
		elseif (S.myClassId == GameLib.CodeEnumClass.Esper) then
			S:RemoveArtwork(tClassResources.wndMain:FindChild("EsperBaseFrame_InCombat"));
			S:RemoveArtwork(tClassResources.wndMain:FindChild("EsperBaseFrame_OutOfCombat"));
			--self:RawHook(tClassResources, "OnEsperEnteredCombat", S.Dummy);
		elseif (S.myClassId == GameLib.CodeEnumClass.Engineer) then
			S:RemoveArtwork(tClassResources.wndMain:FindChild("MainResourceFrame"));
		elseif (S.myClassId == GameLib.CodeEnumClass.Medic) then
			S:RemoveArtwork(tClassResources.wndMain:FindChild("MedicBaseFrame_InCombat"));
			S:RemoveArtwork(tClassResources.wndMain:FindChild("MedicBaseFrame_OutOfCombat"));
	--	elseif (S.myClassId == GameLib.CodeEnumClass.Warrior) then
		end
	else
		log:debug("Class Resources aren't ready yet...");
		self:PostHook(tClassResources, "OnCharacterCreated", "StyleClassResources");
	end
end

function M:StyleExperienceBar()
	local tExperienceBar = Apollo.GetAddon("XPBar");
	if (not tExperienceBar) then return; end
	self:Unhook(tExperienceBar, "OnDocumentReady");

	if (tExperienceBar.wndArt) then
		log:debug("Styling Experience Bar");
		for _, f in pairs(tExperienceBar.wndArt:GetChildren()) do
			S:RemoveArtwork(f);
		end
	else
		log:debug("Experience Bar isn't ready yet...");
		self:PostHook(tExperienceBar, "OnDocumentReady", "StyleExperienceBar");
	end
end