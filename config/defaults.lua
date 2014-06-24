--[[

	s:UI Configuration

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------
-- Default Settings
-----------------------------------------------------------------------------

S.DB = {
	-- Module Debugging
	-- Disable to filter the messages in GeminiConsole
	["debug"] = {
		["RandomCraft"] = false,
		["ArtworkRemover"] = false,
		["PowerBar"] = false,
		["ConsoleVariables"] = false,
	},
};
