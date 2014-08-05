--[[

	s:UI Auction House

	Structure:

		Shopping List
			Node (Category/Family/Type)
				Search
					Filter
					Filter
				Search
					Filter
				Search
					Filter
				Search
					Filter
					Filter
					Filter
			Node (Category/Family/Type)
				Search
					Filter
					Filter
				Search
					Filter

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:GetModule("AuctionHouse");

-----------------------------------------------------------------------------
-- Favorites
-----------------------------------------------------------------------------

function M:RestoreProfile()
	if (not self.P.ItemPrices) then
		self.P.ItemPrices = {};
	end

	self.P.ShoppingList = {
		{
			Name = "BoE Pre-Raid Gear",
			Searches = {
				{
					nTypeId = 79,
					strSearchQuery = "Mister Fuzion's Futuristic Flagellators",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 79,
					strSearchQuery = "Adventus' CW-3 RSN Hurricane Force Chargers",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 1032,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Warden Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Glaciax's Ice Crystal Disruptor",
					tCustomFilter = {
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 10,
					strSearchQuery = "Adventus' MA-2H Sacred Cowl",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Wisdom] = 90,
						},
						RuneSlots = 2, Special = 71600,
					},
				},
				{
					nTypeId = 11,
					strSearchQuery = "Adventus' MA-3S Sacred Burden",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 30, [Unit.CodeEnumProperties.Wisdom] = 65,
						},
						RuneSlots = 3, Special = 54141,
					},
				},
				{
					nTypeId = 11,
					strSearchQuery = "Torine Lifecaller Shoulders",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 8,
					strSearchQuery = "Adventus' MA-4C Sacred Dust Coat",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 45, [Unit.CodeEnumProperties.Wisdom] = 95,
						},
						RuneSlots = 3, Special = 71545,
					},
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Doomcaller Jacket",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Doomcaller Hands",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 44, [Unit.CodeEnumProperties.Strength] = 30,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 13,
					strSearchQuery = "Captain Onghr's Piratical Polywraps",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "River-Fording Boots",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Assist Module",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 299,
					strSearchQuery = "Thundering Quill",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Zen State",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Dysentery Prevention Pill",
				},
				{
					nTypeId = 79,
					strSearchQuery = "Protostar VP Exclusive Oscillators",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 79,
					strSearchQuery = "Adventus' CW-4 RSN Magma Refibrillators",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 1032, [Unit.CodeEnumProperties.Technology] = 90,
						},
						RuneSlots = 3, Special = 53872,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Lord Hoarfrost's Frozen Field Generator",
				},
				{
					nTypeId = 10,
					strSearchQuery = "Epochos' MA-1H Combat Capuchin",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 10,
					strSearchQuery = "Heroic Neo Headband",
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Curseblade Jacket",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Curseblade Hands",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Tragg's Vaguely Legal Armbands",
				},
				{
					nTypeId = 9,
					strSearchQuery = "Adventus' MA-3L Tech Flexipants",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "Bullet-Riddled Boots",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 51,
					strSearchQuery = "Rocktown Rock-Solid Power Sword",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 51,
					strSearchQuery = "Adventus' CW-4 GRS Earthbound Power Sword",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 619,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Frozen Corrupter Agony Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Defender Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Heroic Neo Head Guard",
				},
				{
					nTypeId = 15,
					strSearchQuery = "Grim-Grim Blightmask Vest",
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Blightmask Greaves",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Chemogrip",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 50, [Unit.CodeEnumProperties.BaseHealth] = 1400,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 51,
					strSearchQuery = "Haggar's Horrible Heavy Blade",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 51,
					strSearchQuery = "Adventus' CW-4 GRS Earthbound Power Sword",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 619, [Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Epochos' HA-1H Combat Helmet",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 18,
					strSearchQuery = "Epochos' HA-1S Combat Shoulders",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 15,
					strSearchQuery = "Type III Galactium Weave Plastron",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Curseblade Greaves",
				},
				{
					nTypeId = 16,
					strSearchQuery = "Galactium Protoweave Leg Plates",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 3, Special = 53803,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 2, Special = 54026,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 45,
					strSearchQuery = "Protostar VP Exclusive Equalizers",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 45,
					strSearchQuery = "Adventus' CW-3 PTL Loamsooth Carbine",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 1032, [Unit.CodeEnumProperties.Wisdom] = 80,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Warden Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Glaciax's Ice Crystal Disruptor",
				},
				{
					nTypeId = 1,
					strSearchQuery = "Grim-Grim Doomcaller Tunic",
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Doomcaller Hands",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Assist Module",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Thundering Quill",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Zen State",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Dysentery Prevention Pill",
				},
				{
					nTypeId = 45,
					strSearchQuery = "Mister Fuzion's Futuristic Firearms",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 45,
					strSearchQuery = "Adventus' CW-3 PTL Loamsooth Carbine",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 1032, [Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 3,
					strSearchQuery = "Epochos' LA-1H Combat Hood",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 4,
					strSearchQuery = "Fibermod Starloom Mantle",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 1,
					strSearchQuery = "Improved Fibermod Starloom Jacket",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 6,
					strSearchQuery = "TheUrge Smartfunction Starloom Grips",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 85,
						},
						RuneSlots = 2, Special = 53844,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Zok the Butcher's Bloodied Wrist Wraps",
				},
				{
					nTypeId = 2,
					strSearchQuery = "Skurgeborn Darkweave",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3, Special = 71724,
					},
				},
				{
					nTypeId = 5,
					strSearchQuery = "TheUrge Smartfiber Starloom Boots",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 298,
					strSearchQuery = "Daredevil",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Glitterfang Implant",
				},
				{
					nTypeId = 204,
					strSearchQuery = "Haggar's Horrible Heavy Blaster",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 204,
					strSearchQuery = "Adventus' CW-4 HVG Earthbound Slug Thrower",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 619,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Frozen Corrupter Agony Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Defender Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Heroic Neo Head Guard",
				},
				{
					nTypeId = 15,
					strSearchQuery = "Grim-Grim Blightmask Vest",
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Blightmask Greaves",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Chemogrip",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 50, [Unit.CodeEnumProperties.BaseHealth] = 1400,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 204,
					strSearchQuery = "Barugh's Buccaneer Big Bertha",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 204,
					strSearchQuery = "Adventus' CW-4 HVG Earthbound Slug Thrower",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 619, [Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Epochos' HA-1H Combat Helmet",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 18,
					strSearchQuery = "Epochos' HA-1S Combat Shoulders",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 15,
					strSearchQuery = "Type III Galactium Weave Plastron",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 15,
					strSearchQuery = "Grim-Grim Curseblade Vest",
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Curseblade Greaves",
				},
				{
					nTypeId = 16,
					strSearchQuery = "Type II Galactium Weave Leg Plates",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 2, Special = 54026,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Epitaph-Engraved Sabatons",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Daredevil",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Glitterfang Implant",
				},
				{
					nTypeId = 48,
					strSearchQuery = "Mazzaki's Lightning Swift Hooks",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Frozen Corrupter Agony Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Defender Aegis",
				},
				{
					nTypeId = 10,
					strSearchQuery = "Dawn Guard's Hood",
				},
				{
					nTypeId = 8,
					strSearchQuery = "Adventus' MA-2C Tech Hauberk",
					tCustomFilter = {
						MinStats = {
							MinArmor = 1235, [Unit.CodeEnumProperties.BaseHealth] = 1000,
						},
						RuneSlots = 2, Special = 71704,
					},
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Blightmask Jacket",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Blightmask Hands",
				},
				{
					nTypeId = 12,
					strSearchQuery = "Oxian Hide Boots",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Chemogrip",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 50, [Unit.CodeEnumProperties.BaseHealth] = 1400,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 48,
					strSearchQuery = "Bloody Zena's Professional Decapitators",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 48,
					strSearchQuery = "Epochos' CW-1 CLS Barbs",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 70,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 10,
					strSearchQuery = "Epochos' MA-1H Combat Capuchin",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 10,
					strSearchQuery = "Legendary League Cowl",
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Hexweave Jacket",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Zok the Butcher's Bloodied Grapplers",
				},
				{
					nTypeId = 9,
					strSearchQuery = "Adventus' MA-3L Tech Flexipants",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "Epochos' MA-1B Combat Foot Guards",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "Epitaph-Engraved Boots",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 46,
					strSearchQuery = "Barugh's Buccaneer Bladed Astral Star",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 46,
					strSearchQuery = "Adventus' CW-3 PSB Hurricane Neuroblade",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 1032,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Warden Aegis",
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Doomcaller Hands",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Zen State",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Dysentery Prevention Pill",
				},
				{
					nTypeId = 46,
					strSearchQuery = "Rocktown Rolling Gyroblade",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 3,
					strSearchQuery = "Epochos' LA-1H Combat Hood",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 4,
					strSearchQuery = "Fibermod Starloom Mantle",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 1,
					strSearchQuery = "Improved Fibermod Starloom Jacket",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 6,
					strSearchQuery = "TheUrge Smartfunction Starloom Grips",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 85,
						},
						RuneSlots = 2, Special = 53844,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Zok the Butcher's Bloodied Wrist Wraps",
				},
				{
					nTypeId = 2,
					strSearchQuery = "Skurgeborn Darkweave",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 115,
						},
						RuneSlots = 3, Special = 71724,
					},
				},
				{
					nTypeId = 5,
					strSearchQuery = "TheUrge Smartfiber Starloom Boots",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
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
		{
			Name = "Medic Heal",
			Searches = {
				{
					nTypeId = 79,
					strSearchQuery = "Mister Fuzion's Futuristic Flagellators",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 79,
					strSearchQuery = "Adventus' CW-3 RSN Hurricane Force Chargers",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 1032,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Warden Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Glaciax's Ice Crystal Disruptor",
					tCustomFilter = {
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 10,
					strSearchQuery = "Adventus' MA-2H Sacred Cowl",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Wisdom] = 90,
						},
						RuneSlots = 2, Special = 71600,
					},
				},
				{
					nTypeId = 11,
					strSearchQuery = "Adventus' MA-3S Sacred Burden",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 30, [Unit.CodeEnumProperties.Wisdom] = 65,
						},
						RuneSlots = 3, Special = 54141,
					},
				},
				{
					nTypeId = 11,
					strSearchQuery = "Torine Lifecaller Shoulders",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 8,
					strSearchQuery = "Adventus' MA-4C Sacred Dust Coat",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 45, [Unit.CodeEnumProperties.Wisdom] = 95,
						},
						RuneSlots = 3, Special = 71545,
					},
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Doomcaller Jacket",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Doomcaller Hands",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 44, [Unit.CodeEnumProperties.Strength] = 30,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 13,
					strSearchQuery = "Captain Onghr's Piratical Polywraps",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "River-Fording Boots",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Assist Module",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 299,
					strSearchQuery = "Thundering Quill",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Zen State",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Dysentery Prevention Pill",
				},
			},
		},
		{
			Name = "Medic DPS",
			Searches = {
				{
					nTypeId = 79,
					strSearchQuery = "Protostar VP Exclusive Oscillators",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 79,
					strSearchQuery = "Adventus' CW-4 RSN Magma Refibrillators",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 1032, [Unit.CodeEnumProperties.Technology] = 90,
						},
						RuneSlots = 3, Special = 53872,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Lord Hoarfrost's Frozen Field Generator",
				},
				{
					nTypeId = 10,
					strSearchQuery = "Epochos' MA-1H Combat Capuchin",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 10,
					strSearchQuery = "Heroic Neo Headband",
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Curseblade Jacket",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Curseblade Hands",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Tragg's Vaguely Legal Armbands",
				},
				{
					nTypeId = 9,
					strSearchQuery = "Adventus' MA-3L Tech Flexipants",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "Bullet-Riddled Boots",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
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
		{
			Name = "Warrior Tank",
			Searches = {
				{
					nTypeId = 51,
					strSearchQuery = "Rocktown Rock-Solid Power Sword",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 51,
					strSearchQuery = "Adventus' CW-4 GRS Earthbound Power Sword",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 619,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Frozen Corrupter Agony Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Defender Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Heroic Neo Head Guard",
				},
				{
					nTypeId = 15,
					strSearchQuery = "Grim-Grim Blightmask Vest",
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Blightmask Greaves",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Chemogrip",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 50, [Unit.CodeEnumProperties.BaseHealth] = 1400,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
			},
		},
		{
			Name = "Warrior DPS",
			Searches = {
				{
					nTypeId = 51,
					strSearchQuery = "Haggar's Horrible Heavy Blade",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 51,
					strSearchQuery = "Adventus' CW-4 GRS Earthbound Power Sword",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 619, [Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Epochos' HA-1H Combat Helmet",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 18,
					strSearchQuery = "Epochos' HA-1S Combat Shoulders",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 15,
					strSearchQuery = "Type III Galactium Weave Plastron",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Curseblade Greaves",
				},
				{
					nTypeId = 16,
					strSearchQuery = "Galactium Protoweave Leg Plates",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 3, Special = 53803,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 2, Special = 54026,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
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
		{
			Name = "Spellslinger Heal",
			Searches = {
				{
					nTypeId = 45,
					strSearchQuery = "Protostar VP Exclusive Equalizers",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 45,
					strSearchQuery = "Adventus' CW-3 PTL Loamsooth Carbine",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 1032, [Unit.CodeEnumProperties.Wisdom] = 80,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Warden Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Glaciax's Ice Crystal Disruptor",
				},
				{
					nTypeId = 1,
					strSearchQuery = "Grim-Grim Doomcaller Tunic",
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Doomcaller Hands",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Assist Module",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Thundering Quill",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Zen State",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Dysentery Prevention Pill",
				},
			},
		},
		{
			Name = "Spellslinger DPS",
			Searches = {
				{
					nTypeId = 45,
					strSearchQuery = "Mister Fuzion's Futuristic Firearms",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 45,
					strSearchQuery = "Adventus' CW-3 PTL Loamsooth Carbine",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 1032, [Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 3,
					strSearchQuery = "Epochos' LA-1H Combat Hood",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 4,
					strSearchQuery = "Fibermod Starloom Mantle",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 1,
					strSearchQuery = "Improved Fibermod Starloom Jacket",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 6,
					strSearchQuery = "TheUrge Smartfunction Starloom Grips",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 85,
						},
						RuneSlots = 2, Special = 53844,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Zok the Butcher's Bloodied Wrist Wraps",
				},
				{
					nTypeId = 2,
					strSearchQuery = "Skurgeborn Darkweave",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3, Special = 71724,
					},
				},
				{
					nTypeId = 5,
					strSearchQuery = "TheUrge Smartfiber Starloom Boots",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 298,
					strSearchQuery = "Daredevil",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Glitterfang Implant",
				},
			},
		},
		{
			Name = "Engineer Tank",
			Searches = {
				{
					nTypeId = 204,
					strSearchQuery = "Haggar's Horrible Heavy Blaster",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 204,
					strSearchQuery = "Adventus' CW-4 HVG Earthbound Slug Thrower",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 619,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Frozen Corrupter Agony Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Defender Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Heroic Neo Head Guard",
				},
				{
					nTypeId = 15,
					strSearchQuery = "Grim-Grim Blightmask Vest",
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Blightmask Greaves",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Chemogrip",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 50, [Unit.CodeEnumProperties.BaseHealth] = 1400,
						},
						RuneSlots = 2,
					},
				},
			},
		},
		{
			Name = "Engineer DPS",
			Searches = {
				{
					nTypeId = 204,
					strSearchQuery = "Barugh's Buccaneer Big Bertha",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 204,
					strSearchQuery = "Adventus' CW-4 HVG Earthbound Slug Thrower",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.AssaultPower] = 619, [Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 17,
					strSearchQuery = "Epochos' HA-1H Combat Helmet",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 18,
					strSearchQuery = "Epochos' HA-1S Combat Shoulders",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 15,
					strSearchQuery = "Type III Galactium Weave Plastron",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 15,
					strSearchQuery = "Grim-Grim Curseblade Vest",
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 20,
					strSearchQuery = "Grim-Grim Curseblade Greaves",
				},
				{
					nTypeId = 16,
					strSearchQuery = "Type II Galactium Weave Leg Plates",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 2, Special = 54026,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Galactium Protomorph Treads",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 19,
					strSearchQuery = "Epitaph-Engraved Sabatons",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Daredevil",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Dexterity] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
				{
					nTypeId = 301,
					strSearchQuery = "Hunter's Helper Scope",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Overcharged Pell Databoard",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Glitterfang Implant",
				},
			},
		},
		{
			Name = "Stalker Tank",
			Searches = {
				{
					nTypeId = 48,
					strSearchQuery = "Mazzaki's Lightning Swift Hooks",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Frozen Corrupter Agony Aegis",
				},
				{
					nTypeId = 53,
					strSearchQuery = "Defender Aegis",
				},
				{
					nTypeId = 10,
					strSearchQuery = "Dawn Guard's Hood",
				},
				{
					nTypeId = 8,
					strSearchQuery = "Adventus' MA-2C Tech Hauberk",
					tCustomFilter = {
						MinStats = {
							MinArmor = 1235, [Unit.CodeEnumProperties.BaseHealth] = 1000,
						},
						RuneSlots = 2, Special = 71704,
					},
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Blightmask Jacket",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Blightmask Hands",
				},
				{
					nTypeId = 12,
					strSearchQuery = "Oxian Hide Boots",
				},
				{
					nTypeId = 298,
					strSearchQuery = "Tempest Force Chemogrip",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Technology] = 50, [Unit.CodeEnumProperties.BaseHealth] = 1400,
						},
						RuneSlots = 2,
					},
				},
			},
		},
		{
			Name = "Stalker DPS",
			Searches = {
				{
					nTypeId = 48,
					strSearchQuery = "Bloody Zena's Professional Decapitators",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 48,
					strSearchQuery = "Epochos' CW-1 CLS Barbs",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 70,
						},
						RuneSlots = 3, Special = 53923,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 10,
					strSearchQuery = "Epochos' MA-1H Combat Capuchin",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 10,
					strSearchQuery = "Legendary League Cowl",
				},
				{
					nTypeId = 8,
					strSearchQuery = "Grim-Grim Hexweave Jacket",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 13,
					strSearchQuery = "Zok the Butcher's Bloodied Grapplers",
				},
				{
					nTypeId = 9,
					strSearchQuery = "Adventus' MA-3L Tech Flexipants",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "Epochos' MA-1B Combat Foot Guards",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 80,
						},
						RuneSlots = 2,
					},
				},
				{
					nTypeId = 12,
					strSearchQuery = "Epitaph-Engraved Boots",
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Strength] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
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
		{
			Name = "Esper Heal",
			Searches = {
				{
					nTypeId = 46,
					strSearchQuery = "Barugh's Buccaneer Bladed Astral Star",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 46,
					strSearchQuery = "Adventus' CW-3 PSB Hurricane Neuroblade",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.SupportPower] = 1032,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Warden Aegis",
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Doomcaller Hands",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Zen State",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Regenerative Matrix",
				},
				{
					nTypeId = 301,
					strSearchQuery = "Dysentery Prevention Pill",
				},
			},
		},
		{
			Name = "Esper DPS",
			Searches = {
				{
					nTypeId = 46,
					strSearchQuery = "Rocktown Rolling Gyroblade",
					tCustomFilter = {
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 53,
					strSearchQuery = "Berserker Aegis",
				},
				{
					nTypeId = 3,
					strSearchQuery = "Epochos' LA-1H Combat Hood",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 115,
						},
						RuneSlots = 2, Special = 54123,
					},
				},
				{
					nTypeId = 4,
					strSearchQuery = "Fibermod Starloom Mantle",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 105,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 1,
					strSearchQuery = "Improved Fibermod Starloom Jacket",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 115,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Grim-Grim Hexweave Hands",
				},
				{
					nTypeId = 6,
					strSearchQuery = "TheUrge Smartfunction Starloom Grips",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 85,
						},
						RuneSlots = 2, Special = 53844,
					},
				},
				{
					nTypeId = 6,
					strSearchQuery = "Zok the Butcher's Bloodied Wrist Wraps",
				},
				{
					nTypeId = 2,
					strSearchQuery = "Skurgeborn Darkweave",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 115,
						},
						RuneSlots = 3, Special = 71724,
					},
				},
				{
					nTypeId = 5,
					strSearchQuery = "TheUrge Smartfiber Starloom Boots",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 80,
						},
						RuneSlots = 2, Special = 54017,
					},
				},
				{
					nTypeId = 299,
					strSearchQuery = "Adventus' AS-2 SS Battle Support System",
					tCustomFilter = {
						MinStats = {
							[Unit.CodeEnumProperties.Magic] = 70,
						},
						RuneSlots = 3,
					},
				},
				{
					nTypeId = 215,
					strSearchQuery = "Operational Amplifier",
				},
				{
					nTypeId = 215,
					strSearchQuery = "Optimization Routines",
					tCustomFilter = {
						MinLevel = 50,
					},
				},
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
		{
			Name ="4+ Rune Slots",
			Searches = {
				-- Armor / 4+ Rune Slots
				{
					nFamilyId = 1,
					tCustomFilter = {
						RuneSlots = 4,
						MinLevel = 45,
					},
				},
				-- Weapons / 4+ Rune Slots
				{
					nFamilyId = 2,
					tCustomFilter = {
						RuneSlots = 4,
						MinLevel = 45,
					},
				},
			},
		},
	};
end
