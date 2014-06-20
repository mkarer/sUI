local S = Apollo.GetAddon("s:UI")
local module = {}

-- Module Loader
function module:OnEnable()
	Apollo.RegisterSlashCommand("rl", "ReloadUI", self)
end

-- Reload UI
function module:ReloadUI()
	RequestReloadUI()
end
