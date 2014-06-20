-----------------------------------------------------------------------------------------------
-- s:UI/SezzUI Minimalistic User Interface
-- Martin Karer, 2014
-----------------------------------------------------------------------------------------------

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

local sUI = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon(kstrAddon, kstrAddon.." "..kstrVersion, ktDependencies);
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

	sUI.Log:debug("Initializing...");

	-- Main Form
	self.xmlDoc = XmlDoc.CreateFromFile("sUI.xml");
end

function sUI:OnEnable()
	if (self.xmlDoc ~= nil and self.xmlDoc:IsLoaded()) then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "sUIForm", nil, self);
		if (self.wndMain == nil) then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.");
			return;
		end
		
		self.wndMain:Show(false, true);
	end

	sUI.Log:debug("Zug Zug!");
end

-----------------------------------------------------------------------------------------------
-- Main Form (TEMP)
-----------------------------------------------------------------------------------------------
function sUI:OnOK()
	sUI.Log:debug("MainForm OK");
	self.wndMain:Close();
end

function sUI:OnCancel()
	sUI.Log:debug("MainForm Cancel");
	self.wndMain:Close();
end
