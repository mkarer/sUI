--[[

	s:UI Cinematics Disabler

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("NoCinematics", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
--	log:debug("%s enabled.", self:GetName());

	-- Unit.CodeEnumCCState.DisableCinematic

--	Apollo.RegisterEventHandler("CinematicsNotify", function() log:debug("CinematicsNotify"); end);
--	Apollo.RegisterEventHandler("CinematicsCancel", function() log:debug("CinematicsCancel"); end);
	Apollo.RegisterEventHandler("ApplyCCState", "OnApplyCCState", self);
--	Apollo.RegisterEventHandler("RemoveCCState", function() log:debug("RemoveCCState"); end);
--	Apollo.RegisterEventHandler("ChangeWorld", function() log:debug("ChangeWorld"); end);
--	Apollo.RegisterEventHandler("UnitCreated", function() log:debug("UnitCreated"); end);
end

function M:OnApplyCCState(code, userdata)
	if (unitPlayer == userdata and code == Unit.CodeEnumCCState.DisableCinematic) then
		log:debug("CC Applied: DisableCinematic");
		GameLib.UIExitCinematics();
	end
end
