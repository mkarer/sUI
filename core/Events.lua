--[[

	Martin Karer / Sezz, 2014
	http://www.sezz.at

	Core Events & Messages

--]]

-----------------------------------------------------------------------------

local S = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("SezzUI");

-----------------------------------------------------------------------------

function S:InitializePlayer()
	self:RegisterEvent("CharacterCreated", "OnCharacterCreated");
	Apollo.RegisterTimerHandler("SezzUITimer_DelayedInit", "OnCharacterCreated", self);
	Apollo.CreateTimer("SezzUITimer_DelayedInit", 0.10, false);
	self:OnCharacterCreated();
end

function S:OnCharacterCreated()
	local unitPlayer = GameLib.GetPlayerUnit();
	
	if (GameLib.IsCharacterLoaded() and not self.bCharacterLoaded and unitPlayer and unitPlayer:IsValid()) then
		self.bCharacterLoaded = true;
		Apollo.StopTimer("SezzUITimer_DelayedInit");
		self:UnregisterEvent("CharacterCreated");

		self.myRealm = GameLib:GetRealmName();
		self.myClassId = unitPlayer:GetClassId();
		self.myClass = self:GetClassName(self.myClassId);
		self.myLevel = unitPlayer:GetLevel();
		self.myName = unitPlayer:GetName();

		S.Log:debug("%s@%s (Level %d %s)", self.myName, self.myRealm, self.myLevel, self.myClass);
		self:SendMessage("PLAYER_LOGIN");
	else
		Apollo.StartTimer("SezzUITimer_DelayedInit");
	end
end

function S:GetClassName(classId)
	for k, v in pairs(GameLib.CodeEnumClass) do
		if (classId == v) then
			return k;
		end
	end

	return "Unknown";
end
