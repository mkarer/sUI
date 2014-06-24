--[[

	s:UI Experience Bars
	TODO: Replace XP Bar with Elder Points Bar @ 50 (and hide it when reached maximum), Idea: http://www.curse.com/ws-addons/wildstar/221697-elderbar
	TODO: Just rewrite the whole Carbine XPBar addon...

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "PlayerPathLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("Experience", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

local levelMax = 50;
local levelMaxPath = 30;

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
	self:MoveExperienceBars();
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:MoveExperienceBars()
	local tXPBar = Apollo.GetAddon("XPBar");
	if (not tXPBar) then return; end
	self:Unhook(tXPBar, "OnDocumentReady");

	if (tXPBar.wndMain) then
		log:debug("Skinning Experience Bars", self:GetName());
--		S:ApplyDebugBackdrop(tXPBar.wndMain);

		local colorExperience = ApolloColor.new("xkcdCarolinaBlue"); -- xkcdClearBlue xkcdDarkSkyBlue
		local colorRested = ApolloColor.new("xkcdPurply"); -- xkcdDarkPeriwinkle xkcdAmethyst
		local barHeight = 6; -- 4px is needed for borders (SezzUIBorderDark)
		local barPadding = 2;

		-- Move Main Frame to Player Unit Frame
		tXPBar.wndMain:SetAnchorPoints(0.25, 1, 0.25, 1);
--		tXPBar.wndMain:SetAnchorOffsets(0, -200, 300, -200 + 2 * barHeight + barPadding);
		tXPBar.wndMain:SetAnchorOffsets(86, -200, 260, -200 + 2 * barHeight + barPadding);

		-- Remove Buttons
		tXPBar.wndMain:FindChild("XPButton"):Show(false, true);
		tXPBar.wndMain:FindChild("PathButton"):Show(false, true);
		tXPBar.wndMain:FindChild("PathIcon"):Show(false, true);

		-- Move XP Bar
		tXPBar.wndMain:FindChild("XPBarContainer"):SetAnchorPoints(0, 0, 1, 0);
		tXPBar.wndMain:FindChild("XPBarContainer"):SetAnchorOffsets(0, 0, 0, barHeight);
		tXPBar.wndMain:FindChild("XPBarContainer"):SetSprite("SezzUIBorderDark");
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("RestXPBarFill"):SetAnchorPoints(0, 0, 1, 1);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("RestXPBarFill"):SetAnchorOffsets(2, 2, -2, -2);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("RestXPBarGoal"):SetAnchorPoints(0, 0, 1, 1);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("RestXPBarGoal"):SetAnchorOffsets(2, 2, -2, -2);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("RestXPBarGoal"):SetBarColor(colorRested);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("RestXPBarGoal"):SetFullSprite("ProgressBar");
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("XPBarFill"):SetAnchorPoints(0, 0, 1, 1);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("XPBarFill"):SetAnchorOffsets(2, 2, -2, -2);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("XPBarFill"):SetBarColor(colorExperience);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("XPBarFill"):SetFullSprite("ProgressBar");
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("DailyMaxEPBar"):SetAnchorPoints(0, 0, 1, 1);
		tXPBar.wndMain:FindChild("XPBarContainer"):FindChild("DailyMaxEPBar"):SetAnchorOffsets(2, 2, -2, -2);

		-- Move Path XP Bar
		tXPBar.wndMain:FindChild("PathBarContainer"):SetAnchorPoints(0, 0, 1, 0);
		tXPBar.wndMain:FindChild("PathBarContainer"):SetAnchorOffsets(0, barHeight + barPadding, 0, 2 * barHeight + barPadding);
		tXPBar.wndMain:FindChild("PathBarContainer"):SetSprite("SezzUIBorderDark");
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetAnchorPoints(0, 0, 1, 1);
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetAnchorOffsets(2, 2, -2, -2);
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetFullSprite("ProgressBar");
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetBarColor(colorExperience);

		-- Clickable Bars
		-- Stupid Event Handling, Shit doesn't always work
		tXPBar.wndMain:FindChild("XPBarContainer"):AddEventHandler("MouseButtonDown", "OnXpClicked", tXPBar);
		tXPBar.wndMain:FindChild("PathBarContainer"):AddEventHandler("MouseButtonDown", "OnPathClicked", tXPBar);

		-- Disable Color Changes
		self:PostHook(tXPBar, "RedrawAllPastCooldown", "FixExperienceBarBackground");

		-- Hide Path Bar on Max
		self:RegisterEvent("UI_XPChanged", "OnExperienceChanged");
		self:OnExperienceChanged();
	else
		self:PostHook(tXPBar, "OnDocumentReady", "MoveExperienceBars");
	end
end

function M:FixExperienceBarBackground()
	local tXPBar = Apollo.GetAddon("XPBar");
	tXPBar.wndMain:FindChild("XPBarContainer"):SetBGColor(ApolloColor.new("white"));
end

function M:OnExperienceChanged()
	local tXPBar = Apollo.GetAddon("XPBar");
	if (PlayerPathLib and PlayerPathLib.GetPathLevel() == levelMaxPath) then
		tXPBar.wndMain:FindChild("PathBarContainer"):Show(false, true);
	else
		tXPBar.wndMain:FindChild("PathBarContainer"):Show(true, true);
	end
end
