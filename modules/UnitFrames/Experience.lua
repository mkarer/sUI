--[[

	s:UI Experience Bars

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("Experience", "Gemini:Event-1.0", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms();
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

	if (tXPBar.wndMain ) then
		log:debug("Skinning Experience Bars", self:GetName());

		local colorExperience = ApolloColor.new("xkcdDarkSkyBlue"); -- xkcdClearBlue xkcdDarkSkyBlue
		local colorRested = ApolloColor.new("xkcdDeepLavender"); -- xkcdDarkPeriwinkle xkcdAmethyst

		-- Move Main Frame
		tXPBar.wndMain:SetAnchorPoints(0.25, 1, 0.25, 1);
		tXPBar.wndMain:SetAnchorOffsets(0, -200, 300, -120);

		-- Move XP Button
		tXPBar.wndMain:FindChild("XPButton"):SetAnchorPoints(0, 0, 0, 0);
		tXPBar.wndMain:FindChild("XPButton"):SetAnchorOffsets(0, 0, 73, 23);

		-- Move XP Bar
		tXPBar.wndMain:FindChild("XPBarContainer"):SetAnchorPoints(0, 0, 1, 0);
		tXPBar.wndMain:FindChild("XPBarContainer"):SetAnchorOffsets(73, 5, 0, 13);
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

		-- Move Path XP Button
		tXPBar.wndMain:FindChild("PathButton"):SetAnchorPoints(0, 0, 0, 0);
		tXPBar.wndMain:FindChild("PathButton"):SetAnchorOffsets(0, 23, 73, 46);

		-- Move Path XP Bar
		tXPBar.wndMain:FindChild("PathBarContainer"):SetAnchorPoints(0, 0, 1, 0);
		tXPBar.wndMain:FindChild("PathBarContainer"):SetAnchorOffsets(73, 28, 0, 49);
		tXPBar.wndMain:FindChild("PathBarContainer"):SetSprite("SezzUIBorderDark");
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetAnchorPoints(0, 0, 1, 1);
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetAnchorOffsets(2, 2, -2, -2);
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetFullSprite("ProgressBar");
		tXPBar.wndMain:FindChild("PathBarContainer"):FindChild("PathBarFill"):SetBarColor(colorExperience);

		-- Move Path Icon
		tXPBar.wndMain:FindChild("PathIcon"):SetAnchorPoints(0, 0, 0, 0);
		tXPBar.wndMain:FindChild("PathIcon"):SetAnchorOffsets(8, 30, 26, 48);

		-- Clickable Bars
		-- Using MouseButtonDown until they add a Click/Signal event...
		tXPBar.wndMain:FindChild("XPBarContainer"):RemoveStyle("IgnoreMouse");
		tXPBar.wndMain:FindChild("XPBarContainer"):AddEventHandler("MouseButtonDown", "OnXpClicked", tXPBar);
		tXPBar.wndMain:FindChild("PathBarContainer"):RemoveStyle("IgnoreMouse");
		tXPBar.wndMain:FindChild("PathBarContainer"):AddEventHandler("MouseButtonDown", "OnPathClicked", tXPBar);


		S:ApplyDebugBackdrop(tXPBar.wndMain);
	else
		self:PostHook(tXPBar, "OnDocumentReady", "MoveExperienceBars");
	end
end
