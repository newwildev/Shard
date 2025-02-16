local RunService = game:GetService("RunService")
local RunContext = RunService:IsClient() and "Client" or "Server"

local GetModule = {}
GetModule.__index = GetModule

local GetModuleSingleton = setmetatable({}, GetModule)
GetModuleSingleton._modules = {
	Client = {},
	Server = {},
}

function GetModule:Add(module, name)
	if not GetModuleSingleton._modules[RunContext] then
		GetModuleSingleton._modules[RunContext] = {}
	end
	GetModuleSingleton._modules[RunContext][name] = module
end

return setmetatable(GetModule, {
	__index = GetModuleSingleton,
	__call = function(_, module: string)
		print(`📦 Loading {module}...`)
		if not GetModuleSingleton._modules[RunContext][module] then
			warn(`🚫 {module} not found`)

			return nil
		end

		return GetModuleSingleton._modules[RunContext][module]
	end,
})
