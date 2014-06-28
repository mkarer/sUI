--[[

	s:UI Window Helper Functions

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

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
