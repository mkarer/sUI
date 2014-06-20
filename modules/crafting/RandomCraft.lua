--[[

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	s:UI RandomCraft Module
	Adds a "Random Craft" button to the Crafting UI for daily quests/mass crafting (when the actual result doesn't matter).

--]]

require "Window";
require "CraftingLib";

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:NewModule("RandomCraft", "Gemini:Event-1.0");
local log;

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

local tCustomizableMicrochipTypes, tCraftingAttributes;

function M:OnInitialize()
	log = S.Log;
	self:InitializeForms("modules/crafting/");
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());

	-- Initialize Data
	tCustomizableMicrochipTypes = {
		[Item.CodeEnumMicrochipType.Capacitor]	= true,
		[Item.CodeEnumMicrochipType.Resistor]	= true,
		[Item.CodeEnumMicrochipType.Inductor]	= true,
	};

	tCraftingAttributes = {
		[Unit.CodeEnumProperties.Dexterity] 					= true,
		[Unit.CodeEnumProperties.Technology] 					= true,
		[Unit.CodeEnumProperties.Magic] 						= true,
		[Unit.CodeEnumProperties.Wisdom] 						= true,
		[Unit.CodeEnumProperties.Stamina] 						= true,
		[Unit.CodeEnumProperties.Strength] 						= true,
		[Unit.CodeEnumProperties.Rating_AvoidReduce] 			= true,
		[Unit.CodeEnumProperties.Rating_CritChanceIncrease] 	= true,
		[Unit.CodeEnumProperties.RatingCritSeverityIncrease] 	= true,
		[Unit.CodeEnumProperties.Rating_AvoidIncrease] 			= true,
		[Unit.CodeEnumProperties.Rating_CritChanceDecrease] 	= true,
		[Unit.CodeEnumProperties.BaseHealth] 					= true,
		[Unit.CodeEnumProperties.ManaPerFiveSeconds] 			= true,
		[Unit.CodeEnumProperties.Armor] 						= true,
		[Unit.CodeEnumProperties.ShieldCapacityMax] 			= true,
	};

	-- Addon References
	self.Crafting = Apollo.GetAddon("Crafting");

	-- Event Handlers
	self:RegisterEvent("GenericEvent_StartCircuitCraft", "CreateButton");
	self:RegisterEvent("GenericEvent_CraftingSummaryIsFinished", "EnableButton");
	self:RegisterEvent("CraftingInterrupted", "EnableButton");
	self:RegisterEvent("GenericEvent_CraftSummaryMsg", "EnableButton");
	self:RegisterEvent("GenericEvent_StartCraftCastBar", "DisableButton");
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
	self:UnregisterAllEvents();
end

-----------------------------------------------------------------------------
-- User Interface
-----------------------------------------------------------------------------

function M:EnableButton()
	if (not self.wndRandomCraftButton) then
		self:CreateButton();
	end
	
	self.wndRandomCraftButton:Show(true);
	self.wndRandomCraftButton:Enable(true);
end

function M:DisableButton()
	if (not self.wndRandomCraftButton) then
		self:CreateButton();
	end

	self.wndRandomCraftButton:Show(true);
	self.wndRandomCraftButton:Enable(false);
end

function M:HideButton()
	if (not self.wndRandomCraftButton) then
		self:CreateButton();
	end

	self.wndRandomCraftButton:Show(false);
	self.wndRandomCraftButton:Enable(false);
end

function M:CreateButton()
	if (self.wndRandomCraftButton) then
		-- Button already exists - check materials when called by GenericEvent_StartCircuitCraft (Q&D)
		local wndNoMaterialsBlocker = self.Crafting.wndMain:FindChild("NoMaterialsBlocker");
		if (wndNoMaterialsBlocker and not wndNoMaterialsBlocker:IsVisible()) then
			self:EnableButton();
		else
			self:HideButton();
		end
		return;
	end

	log:debug("Adding Random Craft Button");

	-- Create Button
	self.wndRandomCraftButton = Apollo.LoadForm(self.xmlDoc, "RandomCraftButton", self.Crafting.wndMain, self);
	self.wndRandomCraftButton:SetText("Random Craft")

	-- Add Event Handler
	self.wndRandomCraftButton:AddEventHandler("ButtonSignal", "StartRandomCraft", self);

	-- Check Materials
	self:CreateButton();
end

-----------------------------------------------------------------------------
-- Crafting
-----------------------------------------------------------------------------

--[[

	Notes/Useful/Interesting Stuff

	Apollo.GetAddon("Crafting").luaSchematic.tSocketButtons
	Apollo.GetAddon("Crafting").luaSchematic.tSocketItems <-- Socketed Stuff (Power Core, Microchips)
		tSocketItems[4] Brutality (or whatever, check with layout indexes) :GetItemId() -> tAdditives
		tSocketItems[nLayoutLoc]

	local nTradeskillId = tSchematicInfo.eTradeskillId;

	tSchematicInfo.tSockets => table mit sockeln eSocketType
	log:debug(tSchematicInfo.tSockets);
	log:debug(tCurrentCraft);

	tSchematicInfo = CraftingLib.GetSchematicInfo(tCurrentCraft.nSchematicId);
	log:debug(tSchematicInfo.tSockets);

--]]

function M:StartRandomCraft()
	-- Check if user started crafting/clicked on "Start Crafting"
	local tCurrentCraft = CraftingLib.GetCurrentCraft();
	if (not tCurrentCraft) then
		-- Try to start crafting
		local wndPreviewStartCraftButton = self.Crafting.wndMain:FindChild("PreviewStartCraftBtn");
		if (wndPreviewStartCraftButton) then
			self.Crafting:OnPreviewStartCraft(wndPreviewStartCraftButton);
			self:StartRandomCraft();
		else
			log:error("Unable to start crafting, please try manually!");
		end
		return;
	end

	log:debug("Starting Random Craft...");

	-- Initialize
	local tAdditives = {}; -- NYI, maybe useful later if we don't want to use the default crafting addon
	local tAlreadyPresentTypes = {};
	local tSchematicInfo = CraftingLib.GetSchematicInfo(tCurrentCraft.nSchematicId);
	log:debug("Name: "..tSchematicInfo.strName);

	-- Specify Power Core
	local tAvailableCores = CraftingLib.GetAvailablePowerCores(tCurrentCraft.nSchematicId);
	if (tAvailableCores) then
		local wndPowerCorePicker = self.Crafting.wndMain:FindChild("PowerCorePicker"):FindChild("PowerCorePickerBtn");

		for _, tCurrentPowerCore in pairs(tAvailableCores) do
			if (tCurrentPowerCore:GetBackpackCount() > 0) then
				-- Set Power Core
				log:debug("Power Core: %s (Item ID: %d, Type: %d)", tCurrentPowerCore:GetName(), tCurrentPowerCore:GetItemId(), tCurrentPowerCore:GetMicrochipInfo().eType);
--				log:debug(tCurrentPowerCore);

				local nPowerCoreItemId = tCurrentPowerCore:GetItemId();
				wndPowerCorePicker:SetData(tCurrentPowerCore);
				self.Crafting.luaSchematic:OnPowerCoreItemBtn(wndPowerCorePicker);
				table.insert(tAdditives, nPowerCoreItemId);
				break;
			end
		end
	end

	-- Get already selected Microchip Types
	for i, tSocket in pairs(tSchematicInfo.tSockets) do
		local itemChip = self.Crafting.luaSchematic:GetSystemSocketItem(i);
		if (itemChip ~= nil) then
			local tCurrItemChipInfo = itemChip:GetMicrochipInfo();
			if (tCurrItemChipInfo and tCurrItemChipInfo.idUnitProperty) then
				log:debug("Property already in use: %s (Id: %d)", self:GetAttributeName(tCurrItemChipInfo.idUnitProperty), tCurrItemChipInfo.idUnitProperty);
				tAlreadyPresentTypes[tCurrItemChipInfo.idUnitProperty] = true;
			end
		end
	end

	-- Specify Microchips
	for i = 1, #tSchematicInfo.tSockets do
		local tSocket = tSchematicInfo.tSockets[i];
		local nLayoutIndex = self.Crafting.luaSchematic.tLayoutIdxToLoc[i];
		local strMicroChipName = self:GetMicrochipName(tSocket.eSocketType);

		if (tCustomizableMicrochipTypes[tSocket.eSocketType] and tSocket.bIsChangeable) then
			-- Set Microchip
			-- item:GetMicrochipInfo()
			log:debug("Customizable: %s (Index: %d/LayoutIndex: %d, Type: %d)", strMicroChipName, i, nLayoutIndex, tSocket.eSocketType);

			-- Use first available Attribute
			local iSelectedAttributeId;
			for iAttributeId, strAttributeName in pairs(tCraftingAttributes) do
				if (not tAlreadyPresentTypes[iAttributeId]) then
					iSelectedAttributeId = iAttributeId;
					tAlreadyPresentTypes[iAttributeId] = true;
					break;
				end
			end

			if (not iSelectedAttributeId) then
				-- Out Of Attributes (WTF)
				log:error("Error: Unable to find a unused property for %s!", strMicroChipName);
			else
				-- Select Attribute
				log:debug("Selecting Attribute: %s (Id: %d)", self:GetAttributeName(iSelectedAttributeId), iSelectedAttributeId);

				local wndSocketButton = self.Crafting.luaSchematic.tSocketButtons[nLayoutIndex];
				wndSocketButton:SetText(self:GetMicrochipName(tSocket.eSocketType));

				local wndCurcuitPickerButton = wndSocketButton:FindChild("CircuitPickerBtn");
				if (wndCurcuitPickerButton) then
					-- Quick HACK, /BOO
					wndCurcuitPickerButton:SetData({ nLayoutIndex, iSelectedAttributeId });
					self.Crafting.luaSchematic:OnBuildPropertyPicker(wndCurcuitPickerButton);
					wndCurcuitPickerButton:SetData({ wndSocketButton, iSelectedAttributeId, nLayoutIndex });
					self.Crafting.luaSchematic:OnPropertyBtn(wndCurcuitPickerButton);
				end
			end
		elseif (tSocket.eSocketType ~= Item.CodeEnumMicrochipType.PowerSource) then
			log:debug("Locked: %s (Index: %d/LayoutIndex: %d, Type: %d)", strMicroChipName, i, nLayoutIndex, tSocket.eSocketType);
			table.insert(tAdditives, 0);
		end
	end


	-- Start Crafting
--	log:debug(tAdditives);
--	log:debug(self.Crafting.luaSchematic:HelperGetUserSelection()); -- tMicrochips
	local wndCraftButton = self.Crafting.wndMain:FindChild("CraftButton");
	if (wndCraftButton and wndCraftButton:IsEnabled()) then
		self.Crafting:OnCraftBtnClicked();
	end
end

-----------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------

function M:GetMicrochipName(type)
	-- Not all of them have CRB_Type strings, will check that later (maybe)
	for k, v in pairs(Item.CodeEnumMicrochipType) do
		if (v == type) then
			local strTranslation = Apollo.GetString("CRB_"..k);
			if (string.sub(strTranslation, 1, 1) == "#") then
				return k;
			else
				return strTranslation;
			end
		end
	end

	return "Unknown";
end

function M:GetAttributeName(id)
	if (id == Unit.CodeEnumProperties.Dexterity) then
		return Apollo.GetString("CRB_Finesse");
	elseif (id == Unit.CodeEnumProperties.Technology) then
		return Apollo.GetString("CRB_Tech_Attribute");
	elseif (id == Unit.CodeEnumProperties.Magic) then
		return Apollo.GetString("CRB_Moxie");
	elseif (id == Unit.CodeEnumProperties.Wisdom) then
		return Apollo.GetString("UnitPropertyInsight");
	elseif (id == Unit.CodeEnumProperties.Stamina) then
		return Apollo.GetString("CRB_Grit");
	elseif (id == Unit.CodeEnumProperties.Strength) then
		return Apollo.GetString("CRB_Brutality");
	elseif (id == Unit.CodeEnumProperties.Rating_AvoidReduce) then
		return Apollo.GetString("CRB_Strikethrough_Rating");
	elseif (id == Unit.CodeEnumProperties.Rating_CritChanceIncrease) then
		return Apollo.GetString("CRB_Critical_Chance");
	elseif (id == Unit.CodeEnumProperties.RatingCritSeverityIncrease) then
		return Apollo.GetString("CRB_Critical_Severity");
	elseif (id == Unit.CodeEnumProperties.Rating_AvoidIncrease) then
		return Apollo.GetString("CRB_Deflect_Rating");
	elseif (id == Unit.CodeEnumProperties.Rating_CritChanceDecrease) then
		return Apollo.GetString("CRB_Deflect_Critical_Hit_Rating");
	elseif (id == Unit.CodeEnumProperties.BaseHealth) then
		return Apollo.GetString("CRB_Health_Max");
	elseif (id == Unit.CodeEnumProperties.ManaPerFiveSeconds) then
		return Apollo.GetString("CRB_Attribute_Recovery_Rating");
	elseif (id == Unit.CodeEnumProperties.Armor) then
		return Apollo.GetString("CRB_Armor");
	elseif (id == Unit.CodeEnumProperties.ShieldCapacityMax) then
		return Apollo.GetString("CBCrafting_Shields");
	else
		return "Unknown";
	end
end
