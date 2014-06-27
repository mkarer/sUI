--[[

	s:UI Configuration

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

S.DB = {
	colors = {
		classes = {
			[GameLib.CodeEnumClass.Engineer]		= "A41A31",
			[GameLib.CodeEnumClass.Esper]			= "74DDFF",
			[GameLib.CodeEnumClass.Medic]			= "FFFFFF",
			[GameLib.CodeEnumClass.Stalker]			= "DDD45F",
			[GameLib.CodeEnumClass.Spellslinger]	= "826FAC",
			[GameLib.CodeEnumClass.Warrior]			= "AB855E",
		},
	},

	-- Module Debugging
	-- Disable to filter the messages in GeminiConsole
	["debug"] = {
		["Modules/Chat"] = false,
		["RandomCraft"] = false,
		["ArtworkRemover"] = false,
		["PowerBar"] = false,
		["ConsoleVariables"] = false,
	},
};
