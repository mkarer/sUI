--[[

	s:UI Tooltips

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local M = S:CreateSubmodule("Tooltips", "Gemini:Hook-1.0");
local log, ToolTips;

-- Constants
local ktClassStrings = {
	[GameLib.CodeEnumClass.Warrior]			= Apollo.GetString("ClassWarrior"),
	[GameLib.CodeEnumClass.Engineer]		= Apollo.GetString("ClassEngineer"),
	[GameLib.CodeEnumClass.Esper]			= Apollo.GetString("ClassESPER"),
	[GameLib.CodeEnumClass.Medic]			= Apollo.GetString("ClassMedic"),
	[GameLib.CodeEnumClass.Stalker]			= Apollo.GetString("ClassStalker"),
	[GameLib.CodeEnumClass.Spellslinger]	= Apollo.GetString("ClassSpellslinger"),
};

local ktClassIcons = {
	[GameLib.CodeEnumClass.Warrior] 		= "IconSprites:Icon_Windows_UI_CRB_Warrior",
	[GameLib.CodeEnumClass.Engineer] 		= "IconSprites:Icon_Windows_UI_CRB_Engineer",
	[GameLib.CodeEnumClass.Esper] 			= "IconSprites:Icon_Windows_UI_CRB_Esper",
	[GameLib.CodeEnumClass.Medic] 			= "IconSprites:Icon_Windows_UI_CRB_Medic",
	[GameLib.CodeEnumClass.Stalker] 		= "IconSprites:Icon_Windows_UI_CRB_Stalker",
	[GameLib.CodeEnumClass.Spellslinger] 	= "IconSprites:Icon_Windows_UI_CRB_Spellslinger",
};

local ktPathStrings = {
	[PlayerPathLib.PlayerPathType_Soldier]		= Apollo.GetString("PlayerPathSoldier"),
	[PlayerPathLib.PlayerPathType_Settler]		= Apollo.GetString("PlayerPathSettler"),
	[PlayerPathLib.PlayerPathType_Scientist]	= Apollo.GetString("PlayerPathExplorer"),
	[PlayerPathLib.PlayerPathType_Explorer]		= Apollo.GetString("PlayerPathScientist"),
};

local ktPathIcons = {
	[PlayerPathLib.PlayerPathType_Soldier]    = "Icon_Windows_UI_CRB_Soldier",
	[PlayerPathLib.PlayerPathType_Settler]    = "Icon_Windows_UI_CRB_Colonist",
	[PlayerPathLib.PlayerPathType_Scientist]  = "Icon_Windows_UI_CRB_Scientist",
	[PlayerPathLib.PlayerPathType_Explorer]   = "Icon_Windows_UI_CRB_Explorer",
};

local ktFactionStrings = {
	[Unit.CodeEnumFaction.ExilesPlayer]		= Apollo.GetString("CRB_Exile"),
	[Unit.CodeEnumFaction.DominionPlayer]	= Apollo.GetString("CRB_Dominion"),
};

local ktRaceStrings = {
	[GameLib.CodeEnumRace.Human]	= Apollo.GetString("RaceHuman"),
	[GameLib.CodeEnumRace.Granok]	= Apollo.GetString("RaceGranok"),
	[GameLib.CodeEnumRace.Aurin]	= Apollo.GetString("RaceAurin"),
	[GameLib.CodeEnumRace.Draken]	= Apollo.GetString("RaceDraken"),
	[GameLib.CodeEnumRace.Mechari]	= Apollo.GetString("RaceMechari"),
	[GameLib.CodeEnumRace.Chua]		= Apollo.GetString("RaceChua"),
	[GameLib.CodeEnumRace.Mordesh]	= Apollo.GetString("CRB_Mordesh"),
};

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------

function M:OnInitialize()
	log = S.Log;

	ToolTips = Apollo.GetAddon("ToolTips");
	if (ToolTips and not ToolTips._OnGenerateWorldObjectTooltip) then
		self:PostHook(ToolTips, "OnDocumentReady", "UpdateWorldTooltipContainer");
--		ToolTips._OnGenerateWorldObjectTooltip = ToolTips.OnGenerateWorldObjectTooltip;
--		ToolTips.OnGenerateWorldObjectTooltip = self.OnGenerateWorldObjectTooltip;
	else
		self:SetEnabledState(false);
	end
end

function M:OnEnable()
	log:debug("%s enabled.", self:GetName());
end

function M:OnDisable()
	log:debug("%s disabled.", self:GetName());
end

function M:UpdateWorldTooltipContainer()
	GameLib.GetWorldTooltipContainer():SetTooltipType(0);
end

-----------------------------------------------------------------------------
-- Unit Tooltips
-----------------------------------------------------------------------------

--[[
local sub = string.sub;

function M:OnGenerateWorldObjectTooltip(wndHandler, wndControl, eToolTipType, unit, strPropName)
	if (eToolTipType == Tooltip.TooltipGenerateType_UnitOrProp) then
		if (sub(wndHandler:GetName(), 1, 4) == "Sezz") then
--			M:GenerateUnitTooltip(wndHandler, unit);
			ToolTips:UnitTooltipGen(wndHandler, unit, strPropName);
		else
			ToolTips:_OnGenerateWorldObjectTooltip(wndHandler, wndControl, eToolTipType, unit, strPropName);
		end
	end
end

function M:GenerateUnitTooltip(wndParent, unit)
	local strTooltip = unit:GetName();

	-- Name
	if (unit:GetGroupValue() > 0) then
		strTooltip = strTooltip.."\n"..String_GetWeaselString(Apollo.GetString("TargetFrame_GroupSize"), unit:GetGroupValue());
	end

	-- Level/Race/Class
	if (unit:IsACharacter()) then
		local strInfo = "";
		local nLevel = unit:GetLevel();
		if (nLevel) then
			strInfo = strInfo..nLevel.." ";
		end

		local nRaceId = unit:GetRaceId();
		if (nRaceId and ktRaceStrings[nRaceId]) then
			strInfo = strInfo..ktRaceStrings[nRaceId].." ";
		end

		local nClassId = unit:GetClassId();
		if (nClassId and ktClassStrings[nClassId]) then
			strInfo = strInfo..ktClassStrings[nClassId].." ";
		end

		-- Path
		local nPathId = unit:GetPlayerPathType();
		if (nPathId and ktPathStrings[nPathId]) then
			strInfo = strInfo.."("..ktPathStrings[nPathId]..")";
		end

		if (string.len(strInfo) > 0) then
			strTooltip = strTooltip.."\n"..strInfo;
		end
	end

	return wndParent:SetTooltip(strTooltip);
end
--]]
