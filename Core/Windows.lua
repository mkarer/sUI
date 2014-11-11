--[[

	s:UI Window Helper Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");
local tremove = table.remove;
-----------------------------------------------------------------------------

function S:GetWindowPosition(wndHandler)
	local nX, nY = wndHandler:GetPos();

	if (wndHandler:GetParent()) then
		local nParentX, nParentY = self:GetWindowPosition(wndHandler:GetParent());
		nX = nX + nParentX;
		nY = nY + nParentY;
	end
	
	return nX, nY;
end

function S:ResetWindowLocation(wndHandler)
	local tOptionsInterface = Apollo.GetAddon("OptionsInterface");

	if (wndHandler and tOptionsInterface and tOptionsInterface.tTrackedWindows[wndHandler:GetId()]) then
		local tSettings = tOptionsInterface.tTrackedWindows[wndHandler:GetId()];

		local tCurrentOffsets = tSettings.tCurrentLoc.nOffsets;
		local tDefaultOffsets = tSettings.tDefaultLoc.nOffsets;
		
		if (tCurrentOffsets[1] ~= tDefaultOffsets[1] or tCurrentOffsets[2] ~= tDefaultOffsets[2]) then
			if (tOptionsInterface.tTrackedWindowsByName[tSettings.strName]) then
				tOptionsInterface.tTrackedWindowsByName[tSettings.strName] = nil;
			end

			tSettings.tCurrentLoc = tSettings.tDefaultLoc;
			tSettings.bHasMoved = true;

			wndHandler:MoveToLocation(WindowLocation.new(tSettings.tCurrentLoc));
			Event_FireGenericEvent("WindowManagementUpdate", tSettings);
		end

		return true;
	end

	return false;
end

-----------------------------------------------------------------------------
-- Window Management Positioning Override
-----------------------------------------------------------------------------

local tOptionsInterface = Apollo.GetAddon("OptionsInterface");
if (tOptionsInterface) then
	local tExcludedWindows = S.DB.NoWindowManagement;

	tOptionsInterface._OnWindowManagementAdd = tOptionsInterface.OnWindowManagementAdd;
	tOptionsInterface.OnWindowManagementAdd = function(self, tSettings)
		if (tSettings and tSettings.strName and not tExcludedWindows[tSettings.strName]) then
			self:_OnWindowManagementAdd(tSettings);
		end
	end
end

-----------------------------------------------------------------------------
-- Window Form XML Manipulation
-----------------------------------------------------------------------------

function S:FindElementInXml(tXml, strNode, strValue, bRemove)
	-- Check tXml Type
	if (type(tXml) ~= "table") then return nil; end

	-- strValue is optional for backward compatibility
	if (strValue == nil) then
		strValue = strNode;
		strNode = "Name";
	end

	-- Check tXml Elements
	if (tXml[strNode] and tXml[strNode] == strValue) then
		return tXml, true;
	end

	-- Check Children
	for i, tNode in ipairs(tXml) do
		if (type(tNode) == "table") then
			local tChildNode, bIsRoot = self:FindElementInXml(tNode, strNode, strValue, bRemove);
			if (tChildNode and tChildNode[strNode] and tChildNode[strNode] == strValue) then
				if (bIsRoot and bRemove) then
					tremove(tXml, i);
				end
				return tChildNode;
			end
		end
	end

	return nil;
end

function S:UpdateElementInXml(tXml, strElementName, tData)
	local tElement = self:FindElementInXml(tXml, strElementName);
	if (tElement) then
		for k, v in pairs(tData) do
			tElement[k] = v;
		end

		return true;
	end

	return false;
end

function S:RemovePixieFromXml(tXml, strSprite, bContinueWhenFound) -- tXml: Parent Xml Data
	for i, tNode in ipairs(tXml) do
		if (tNode.__XmlNode and tNode.__XmlNode == "Pixie" and tNode.Sprite == strSprite) then
			tXml[i] = nil;

			if (not bContinueWhenFound) then
				break;
			end
		end
	end
end

-----------------------------------------------------------------------------
-- Window Metatable Wrapper
-----------------------------------------------------------------------------

local tUserDataWrapper = {};
local tUserDataMetatable = {};

function tUserDataMetatable:__index(strKey)
	local proto = rawget(self, "__proto__");
	local field = proto and proto[strKey];

	if (type(field) ~= "function") then
		return field;
	else
		return function(obj, ...)
			if (obj == self) then
				return field(proto, ...);
			else
				return field(obj, ...);
			end
		end
	end
end

function tUserDataWrapper:New(o)
	return setmetatable({__proto__ = o}, tUserDataMetatable);
end

function S:EnhanceControl(wndControl)
	return tUserDataWrapper:New(wndControl);
end

-----------------------------------------------------------------------------
-- Opacity Fix
-----------------------------------------------------------------------------

local OpacityFix = {
	tWindows = {},
};

Apollo.RegisterTimerHandler("SezzUITimer_OpacityFix", "ShowWindows", OpacityFix);
Apollo.CreateTimer("SezzUITimer_OpacityFix", 1 / 1000, false);

function OpacityFix:FixWindow(wndControl)
	self.tWindows[wndControl] = GameLib.GetTickCount();
	Apollo.StartTimer("SezzUITimer_OpacityFix");
end

function OpacityFix:ShowWindows()
	local nTicks = GameLib.GetTickCount();

	for wndControl, nTicksAdded in pairs(self.tWindows) do
		if (nTicks > nTicksAdded) then
			wndControl:Show(true, true);
			self.tWindows[wndControl] = nil;
		else
			Apollo.StartTimer("SezzUITimer_OpacityFix");
		end
	end
end

function S:ShowDelayed(wndControl)
	wndControl:Show(false, true);
	OpacityFix:FixWindow(wndControl);
end
