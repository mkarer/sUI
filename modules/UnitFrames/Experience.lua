--[[

	s:UI Experience Bars
	TODO: Replace XP Bar with Elder Points Bar @ 50 (and hide it when reached maximum), Idea: http://www.curse.com/ws-addons/wildstar/221697-elderbar
	TODO: Just rewrite the whole Carbine XPBar addon...

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("Experience", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log, tXPBar;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

local knLevelMax = 50;
local knLevelMaxPath = 30;

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	if (Apollo.GetAddon("XPBar")) then
		self:RegisterAddonLoadedCallback("XPBar", "MoveExperienceBars");
	else
		self:Disable();
	end
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

-----------------------------------------------------------------------------
-- Code
-----------------------------------------------------------------------------

function M:MoveExperienceBars()
	tXPBar = Apollo.GetAddon("XPBar");

	log:debug("Skinning Experience Bars", self:GetName());
--	S:ApplyDebugBackdrop(tXPBar.wndMain);

	local colorExperience = ApolloColor.new("xkcdCarolinaBlue"); -- xkcdClearBlue xkcdDarkSkyBlue
	local colorRested = ApolloColor.new("xkcdPurply"); -- xkcdDarkPeriwinkle xkcdAmethyst
	local nBarHeight = 6; -- 4px is needed for borders (SezzUIBorderDark)
	local nBarPadding = 2;
	local nBarWidth = 258;

	-- Move Main Frame to Player Unit Frame
	local nBarWidthOffset = math.ceil(nBarWidth / 2);
	local nBarPositionY = -80;
	tXPBar.wndMain:SetAnchorPoints(0.5, 1, 0.5, 1);
	tXPBar.wndMain:SetAnchorOffsets(-nBarWidthOffset, nBarPositionY, nBarWidthOffset, nBarPositionY + 2 * nBarHeight + nBarPadding);

	-- Remove Buttons
	tXPBar.wndMain:FindChild("XPButton"):Show(false, true);
	tXPBar.wndMain:FindChild("PathButton"):Show(false, true);
	tXPBar.wndMain:FindChild("PathIcon"):Show(false, true);

	-- Move XP Bar
	tXPBar.wndMain:FindChild("XPBarContainer"):SetAnchorPoints(0, 0, 1, 0);
	tXPBar.wndMain:FindChild("XPBarContainer"):SetAnchorOffsets(0, 0, 0, nBarHeight);
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
	tXPBar.wndMain:FindChild("PathBarContainer"):SetAnchorOffsets(0, nBarHeight + nBarPadding, 0, 2 * nBarHeight + nBarPadding);
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
	self:RegisterEvent("Sezz_CharacterLoaded", "OnExperienceChanged");
	self:OnExperienceChanged();
end

function M:FixExperienceBarBackground()
	tXPBar.wndMain:FindChild("XPBarContainer"):SetBGColor(ApolloColor.new("white"));
end

function M:OnExperienceChanged()
	if (PlayerPathLib and PlayerPathLib.GetPathLevel() == knLevelMaxPath) then
		tXPBar.wndMain:FindChild("PathBarContainer"):Show(false, true);
	else
		tXPBar.wndMain:FindChild("PathBarContainer"):Show(true, true);
	end
end
