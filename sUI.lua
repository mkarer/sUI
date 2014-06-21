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

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon(kstrAddon, true, ktDependencies, "Gemini:Hook-1.0");
local log;
local GeminiLogging;

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

function S:OnInitialize()
	-- Libraries
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	S.Log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});
	log = S.Log;

	log:debug(kstrAddon.." "..kstrVersion);

	-- Main Form
	self.xmlDoc = XmlDoc.CreateFromFile("sUI.xml");
end

function S:OnEnable()
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "Configure", nil, self);
	log:debug("Zug Zug!");

	-- Player Information
	local unitPlayer = GameLib:GetPlayerUnit();

	self.myRealm = GameLib:GetRealmName();
	self.myClassId = unitPlayer:GetClassId();
	self.myClass = self:GetClassName(self.myClassId);
	self.myLevel = unitPlayer:GetLevel();
	self.myName = unitPlayer:GetName();

	log:debug("%s@%s (Level %d %s)", self.myName, self.myRealm, self.myLevel, self.myClass);
end

function S:Dummy()
	return true;
end

function S:GetClassName(classId)
	for k, v in pairs(GameLib.CodeEnumClass) do
		if (classId == v) then
			return k;
		end
	end

	return "Unknown";
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
