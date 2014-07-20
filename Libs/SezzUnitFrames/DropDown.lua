--[[

	s:UI Unit Drop Down Menus

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.2").tPackage;
if (UnitFrameController.ToggleMenu) then return; end

-----------------------------------------------------------------------------

local tDropDown;

function UnitFrameController:ToggleMenu(unit)
	unitPlayer = GameLib.GetPlayerUnit();
	Event_FireGenericEvent("GenericEvent_NewContextMenuPlayerDetailed", nil, unit:GetName(), unit.__proto__ or unit);

	-- Create Root Drop Down Menu Instance
	if (not tDropDown) then
		tDropDown = Apollo.GetPackage("Sezz:Controls:DropDown-0.1").tPackage:New();
	end

	-- Update Items
	if (tDropDown:Init("Unit", unit)) then
		tDropDown:Show();
	end
end
