Please note:
	As a World of Warcraft addon developer I *VERY OFTEN* refer to WoW-related stuff, because that's what I'm used to.

* Game Events
	* ADD Shitload of events (http://wowprogramming.com/docs/events)

* Controls
	* FIX TreeView Cannot change background sprite/color of the selected item
	* FIX TreeView Cannot click some nodes/sometimes the wrong nodes will be expanded/collapsed (I don't have a sample currently, just use Rover)
	* FIX Eventless controls have a huge impact on FPS/performance even when they are not visible, Control:Enable(false) works as a workaround, but this is stuipd when it isn't visible anyways (eg: custom grid/table)

* Control Events
	* FIX MouseButtonUp // self.wndMain:AddEventHandler("MouseButtonUp", "OnMouseClick", self);
	* ADD MouseButtonClick
	* FIX MouseWheel // Camera shouldn't change zoom level when using the mousewheel on a window that also has a MouseWheel event handler (I think there are more events affected by this)

* Unit
	* ADD GetCastingSpell
	* ADD GetCastingSpellId
	* ADD GetCastingSpellIcon (but you'll also have to add actual icons :p)
	* FIX GetBuffs - fTimeRemaining doesn't change when a buff is refreshed (tested with Deadly Chain) -- Update 07/31 Deadly Chain is fixed! -- Update 08/25 Still/Again bugged on PTR.
	* ~~FIX GetBuffs - Some debuffs aren't in the array (like Frostbitten Chill, Coldburrow Cavern low body temp debuff), same issue with buffs~~
	* ADD GetBuffs - fTimeGained would be awesome
	* ADD GetBuffs - unitSource would be even more awesome

* MLWindow (Or just add coloring to every text like it works in WoW, this would make it stupid easy.)
	* ADD DT_SINGLELINE
	* ADD DT_WORDBREAK

* Spell
	* ADD GetBuffTooltip/GetBuffFlavor/GetBuffSpell (whatever, just something like that)

* Threat
	* ADD Data for everyone.

* Others
	* Slash /CoMMandS should be case insensitive!
	* Add a way to create a unit tooltip.
	* Allow us to map a keybindings to a macro (or change actionbutton content, I think we're able to set keybindings for them).
	* Addon settings for addons with ":" in their name in toc.xml are saved in (and loaded from) the alternate NTFS data stream of a file named [everything_before:] (in my case specific case the data for "s:UI" will be saved to "s" instead of sUI_0_Char.xml) (Apollo.GetAddonInfo() also has problems, but it works when removing the ":"). (Update: GetAddonInfo used the folder name, that's why it didn't find my addon)
