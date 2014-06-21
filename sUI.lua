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

local sUI = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon(kstrAddon, true, ktDependencies);
local log;
local GeminiLogging;

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

function sUI:OnInitialize()
	-- Libraries
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	sUI.Log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});
	log = sUI.Log;

	log:debug(kstrAddon.." "..kstrVersion);

	-- Main Form
	self.xmlDoc = XmlDoc.CreateFromFile("sUI.xml");
end

function sUI:OnEnable()
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "Configure", nil, self);
	log:debug("Zug Zug!");
end

-----------------------------------------------------------------------------------------------
-- Main Form (TEMP)
-----------------------------------------------------------------------------------------------
function sUI:CloseConfiguration()
	self.wndMain:Close();
end

function sUI:OnConfigure()
	self.wndMain:Show(true);
end
