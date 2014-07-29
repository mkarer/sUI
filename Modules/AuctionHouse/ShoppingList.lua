--[[

	s:UI Auction House

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-----------------------------------------------------------------------------
-- Favorites
-----------------------------------------------------------------------------

function M:RestoreProfile()
	M.P.ShoppingList = {
		{
			Name = "Profitable Stuff",
			Searches = {


				-- Armor / 4+ Rune Slots
				{
					nFamilyId = 1,
					tCustomFilter = {
						RuneSlots = 4,
					},
				},
				-- Weapons / 4+ Rune Slots
				{
					nFamilyId = 2,
					tCustomFilter = {
						RuneSlots = 4,
					},
				},
				-- Best in Slot / Spellslinger DPS / Weapons
				{
					nCategoryId = 16,
					strSearchQuery = "Mister Fuzion's Futuristic Firearms",
				},
				{
					nCategoryId = 16,
					strSearchQuery = "Adventus' CW-3 PTL Loamsooth Carbine",
					tCustomFilter = {
						RuneSlots = 2,
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 1032,
							[Unit.CodeEnumProperties.Dexterity] = 90,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Shield
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				-- Best in Slot / Spellslinger DPS / Head
				{
					nTypeId = 3,
					strSearchQuery = "Epochos' LA-1H Combat Hood",
					tCustomFilter = {
						-- Special: Concentration
						RuneSlots = 2,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Shoulder
				{
					nTypeId = 4,
					strSearchQuery = "Fibermod Starloom Mantle",
					tCustomFilter = {
						RuneSlots = 3,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 105,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Chest
				{
					nTypeId = 1,
					strSearchQuery = "Fibermod Starloom Mantle",
					tCustomFilter = {
						RuneSlots = 3,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Hands
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 6,
					strSearchQuery = "TheUrge Smartfunction Starloom Grips",
					tCustomFilter = {
						-- Special: Rage
						RuneSlots = 2,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 85,
						},
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Zok the Butcher's Bloodied Wrist Wraps",
				},
				-- Best in Slot / Spellslinger DPS / Legs
				{
					nTypeId = 2,
					strSearchQuery = "Skurgeborn Darkweave",
					tCustomFilter = {
						-- Special: Power Dash
						RuneSlots = 3,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Feet
				{
					nTypeId = 5,
					strSearchQuery = "TheUrge Smartfiber Starloom Boots",
					tCustomFilter = {
						-- Special: Calisthenics
						RuneSlots = 2,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Weapon Attachment
				{
					nTypeId = 298,
					strSearchQuery = "Daredevil",
				},
				-- Best in Slot / Spellslinger DPS / Support System
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						RuneSlots = 2,
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 70,
						},
					},
				},
				-- Best in Slot / Spellslinger DPS / Gadget
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				-- Best in Slot / Spellslinger DPS / Implant
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
			},
		},
	};
end
