--[[

	s:UI Unit Frame Element: Range

	Updates opacity when a unit is not in range, doesn't work for "real" units (not sure if that would be useful).

	Martin Karer / Sezz, 2014
	http://www.sezz.at

--]]

local MAJOR, MINOR = "Sezz:UnitFrameElement:Range-0.1", 1;
local APkg = Apollo.GetPackage(MAJOR);
if (APkg and (APkg.nVersion or 0) >= MINOR) then return; end

local NAME = string.match(MAJOR, ":(%a+)\-");
local Element = APkg and APkg.tPackage or {};
local log, UnitFrameController;

-----------------------------------------------------------------------------

function Element:Update()
	if (not self.bEnabled) then return; end

	local unit = self.tUnitFrame.unit;
	if (not unit:IsRealUnit() or unit:IsDisconnected() or not unit:IsOnline()) then
		self.tUnitFrame.wndMain:SetOpacity(self.fOutOfRangeOpacity);
	else
		self.tUnitFrame.wndMain:SetOpacity(1);
	end
end

function Element:OnGroupMemberFlagsChanged(nIndex)
	local unit = self.tUnitFrame.unit;

	if (unit.nMemberIdx and unit.nMemberIdx == nIndex) then
		self:Update();
	end
end

function Element:Enable()
	if (not self.bEnabled) then
		self.bEnabled = true;
		Apollo.RegisterEventHandler("Group_MemberFlagsChanged", "OnGroupMemberFlagsChanged", self);
	end

	self:Update();
end

function Element:Disable(bForce)
	if (not self.bEnabled and not bForce) then return; end

	self.tUnitFrame.wndMain:SetOpacity(1);
	self.bEnabled = false;
	Apollo.RemoveEventHandler("Group_MemberFlagsChanged", self);
end

local IsSupported = function(tUnitFrame)
	local bSupported = (type(tUnitFrame.tAttributes.OutOfRangeOpacity) == "number");
--	log:debug("Unit %s supports %s: %s", tUnitFrame.strUnit, NAME, string.upper(tostring(bSupported)));

	return bSupported;
end

-----------------------------------------------------------------------------
-- Constructor
-----------------------------------------------------------------------------

function Element:New(tUnitFrame)
	if (not IsSupported(tUnitFrame)) then return; end

	local self = setmetatable({ tUnitFrame = tUnitFrame }, { __index = Element });

	-- Properties
	self.bUpdateOnUnitFrameFrameCount = false;
	self.fOutOfRangeOpacity = tUnitFrame.tAttributes.OutOfRangeOpacity;

	-- Done
	self:Disable(true);

	return self;
end

-----------------------------------------------------------------------------
-- Apollo Registration
-----------------------------------------------------------------------------

function Element:OnLoad()
	GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage;
	log = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d %n %c %l - %m",
		appender = "GeminiConsole"
	});

	UnitFrameController = Apollo.GetPackage("Sezz:UnitFrameController-0.1").tPackage;
	UnitFrameController:RegisterElement(MAJOR);
end

function Element:OnDependencyError(strDep, strError)
	return false;
end

-----------------------------------------------------------------------------

Apollo.RegisterPackage(Element, MAJOR, MINOR, { "Sezz:UnitFrameController-0.1" });
