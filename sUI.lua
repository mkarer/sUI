--[[

	s:UI (SezzUI)
	Minimalistic User Interface

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

require "Window";
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

local kstrAddon = "SezzUI";
local kiVersionData = { 0, 0, 1 };
local kstrVersion = "v"..kiVersionData[1].."."..kiVersionData[2].."."..kiVersionData[3];
local ktDependencies = {
	"GameExit", -- Adding a dependency makes the addon load sooner, required to hook Carbine addons' OnLoad...
};

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon(kstrAddon, true, ktDependencies, "Gemini:Hook-1.0", "Gemini:Event-1.0", "Gemini:Timer-1.0");
local log;

-- Lua API
local strfind, gsub, strmatch, strsub = string.find, string.gsub, string.match, string.sub;

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

local function logDebug(self, ...)
	if (not S.DB or not S.DB.debug) then
		self:_debug(...);
	end

	-- Debugging Filter	
	
	local debugInfo = debug.getinfo(2);
	local caller = gsub(debugInfo.source, "\\", "/");
	local pathRootIndex = strfind(caller, "/Addons/sUI/") ~= nil and (strfind(caller, "/Addons/sUI/") + 12) or (strfind(caller, "/Addons/") + 8);
	local dir, file, ext = strmatch(strsub(caller, pathRootIndex), "(.-)([^/]-([^%.]+))$");
	dir = dir:sub(1, -2);
	file = string.gsub(file, "."..ext, "");

	if (not dir or not file) then
		self:_debug(...);
	elseif (S.DB.debug[dir] == nil and S.DB.debug[file] == nil) then
		self:_debug(...);
	elseif ((S.DB.debug[dir] ~= nil and S.DB.debug[dir] ~= true) and (S.DB.debug[file] ~= nil and S.DB.debug[file] ~= true)) then
		self:_debug(...);
	end

end

function S:OnInitialize()
	-- Libraries
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2") and Apollo.GetAddon("GeminiConsole") and Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	if (GeminiLogging) then
		S.Log = GeminiLogging:GetLogger({
			level = GeminiLogging.DEBUG,
			pattern = "%d %n %c %l - %m",
			appender ="GeminiConsole"
		});

		S.Log._debug = S.Log.debug;
		S.Log.debug = logDebug;
	else
		S.Log = setmetatable({debug = logDebug}, { __index = function(t, k) local f = rawget(t, k); if (f) then return f; else return function(self, ...) local args = #{...}; if (args > 1) then Print(string.format(...)); elseif (args == 1) then Print(tostring(...)); end; end; end; end });
	end

	log = S.Log;
	log:debug(kstrAddon.." "..kstrVersion);
	self:FlushLogQueue();

	-- Media
	Apollo.LoadSprites("Media/Icons.xml");
	Apollo.LoadSprites("Media/Sprites.xml");
	Apollo.LoadSprites("Media/Fonts/04b_11.xml");

	-- Main Form
	self.xmlDoc = XmlDoc.CreateFromFile("sUI.xml");

	-- Initialization
	self:InitializePlayer();
	self:CheckExternalAddons();
end

function S:OnEnable()
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "Configure", nil, self);
	log:debug("Zug Zug!");
end

function S:Dummy()
	return true;
end

-----------------------------------------------------------------------------------------------
-- Main Form (TEMP)
-----------------------------------------------------------------------------------------------
function S:CloseConfiguration()
	self.wndMain:Close();
end

function S:OnConfigure()
	self.wndMain:Show(true);
	self.wndMain:ToFront();
end

function S:ToggleConfiguration()
	self.wndMain:Show(not self.wndMain:IsShown());
	if (self.wndMain:IsShown()) then
		self.wndMain:ToFront();
	end
end

-----------------------------------------------------------------------------------------------
-- Global (TEMP, for debugging)
-----------------------------------------------------------------------------------------------

_G["S"] = S;
