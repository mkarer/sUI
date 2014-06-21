--[[

	s:UI Cinematics Disabler

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("NoCinematics", "Gemini:Hook-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
	self:DisableCinematics();

	Apollo.RegisterEventHandler("CinematicsNotify", "OnCinematicsNotify", self);
	Apollo.RegisterEventHandler("CinematicsCancel", "OnCinematicsCancel", self);
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());

	local tCinematics = Apollo.GetAddon("Cinematics");
	Apollo.RegisterEventHandler("CinematicsNotify", "OnCinematicsNotify", tCinematics);
	Apollo.RegisterEventHandler("CinematicsCancel", "OnCinematicsCancel", tCinematics);
end

function M:DisableCinematics()
	if (not Apollo.GetAddonInfo("Cinematics") or not Apollo.GetAddonInfo("Cinematics").bLoadOnStart) then
		-- Cinemeatics Addon is disabled :)
		return;
	end

	local tCinematics = Apollo.GetAddon("Cinematics");
	self:Unhook(tCinematics, "OnLoad");

	if (tCinematics.wndCin) then
		log:debug("Removing Events");
		Apollo.RemoveEventHandler("CinematicsNotify", tCinematics);
		Apollo.RemoveEventHandler("CinematicsCancel", tCinematics);
	else
		self:PostHook(tCinematics, "OnLoad", "DisableCinematics");
	end
end

function M:OnCinematicsNotify(msg, param)
	log:debug("OnCinematicsNotify");
	log:debug(msg);
	log:debug(param);
	self.cinematic = param;
	Cinematics_Cancel(param);
end

function M:OnCinematicsCancel(param)
	log:debug("OnCinematicsCancel");
	log:debug(param);
end
