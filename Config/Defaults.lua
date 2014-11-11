--[[

	s:UI Configuration

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local Apollo = Apollo;

-----------------------------------------------------------------------------

S.DB = {
	Colors = {
		Classes = {
			[GameLib.CodeEnumClass.Engineer]		= "A41A31",
			[GameLib.CodeEnumClass.Esper]			= "74DDFF",
			[GameLib.CodeEnumClass.Medic]			= "FFFFFF",
			[GameLib.CodeEnumClass.Stalker]			= "DDD45F",
			[GameLib.CodeEnumClass.Spellslinger]	= "826FAC",
			[GameLib.CodeEnumClass.Warrior]			= "AB855E",
		},
	},

	Modules = {
		-- Auras
		Buffs = {
			Filter = {
				[70391] = true, -- Authentication Dividends
			}
		},
		-- Auction House
		AutoLootMail = {
			bEnabled = true,
		},
		AuctionHouse = {
			bEnabled = true,
			-- GUI
			strFont = "CRB_Pixel", -- Nameplates
			strFontLarge = "CRB_ButtonHeader",
		},
		-- Crit Line
		CritLine = {},
		-- Action Bars
		ActionBars = {
			buttonSize = 36,
			buttonPadding = 2,
			barPadding = 10, -- Menu needs atleast 10 because the toggle is ignored by ContainsMouse()
		},
	},

	-- Hide Windows from Window Management
	-- This should disable/override user customization (Interface Options / Window)
	NoWindowManagement = {
		[Apollo.GetString("MiniMap_Title")] = true,
		[Apollo.GetString("CRB_QuestTracker")] = true,
		[Apollo.GetString("HUDAlert_VacuumLoot")] = true,
		[Apollo.GetString("MarketplaceAuction_AuctionHouse")] = true,
	},

	-- Module Debugging
	-- Disable to filter the messages in GeminiConsole
	["debug"] = {
--		["Modules"] = false,			-- Module Prototype
		["Modules/Chat"] = false,		-- Chat Module
		["Modules/Automation"] = false,	-- Automation Module
--		["Modules/MiniMap"] = false,	-- Minimap Module
--		["Modules/Tooltips"] = false,	-- Tooltips Module
--		["Modules/ActionBars"] = false,	-- ActionBars Module
		["Modules/DataText"] = false,	-- DataText Module
		["RandomCraft"] = false,
		["ArtworkRemover"] = false,
		["PowerBar"] = false,
		["ConsoleVariables"] = false,
	},
};
