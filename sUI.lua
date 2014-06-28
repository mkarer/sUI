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
	"GeminiConsole",
};

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon(kstrAddon, true, ktDependencies, "Gemini:Hook-1.0", "Gemini:Event-1.0", "Gemini:Timer-1.0");
local log;
local GeminiLogging;

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

local function logDebug(self, ...)
	if (not S.DB or not S.DB.debug) then
		self:_debug(...);
	end

	-- Debugging Filter	
	local debugInfo = debug.getinfo(2);
	local caller = string.gsub(debugInfo.short_src, "\\", "/");
	local pathRootIndex = caller:find("Addons/sUI/") + 11;
	local dir, file, ext = string.match(caller:sub(pathRootIndex), "(.-)([^/]-([^%.]+))$");
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
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	S.Log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});
	log = S.Log;
	log._debug = log.debug;
	log.debug = logDebug;
	log:debug(kstrAddon.." "..kstrVersion);

	-- Media
	Apollo.LoadSprites("Media/Icons.xml");
	Apollo.LoadSprites("Media/Sprites.xml");

	-- Main Form
	self.xmlDoc = XmlDoc.CreateFromFile("sUI.xml");

	-- Initialization
	self:InitializePlayer();
	self:CheckExternalAddons();
	-- TODO: Check/Reset Default Recall Command (see RecallFrame.lua, RefreshDefaultCommand/ResetDefaultCommand)
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
end

-----------------------------------------------------------------------------------------------
-- Global (TEMP, for debugging)
-----------------------------------------------------------------------------------------------

_G["S"] = S;
