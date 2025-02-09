while workspace:GetAttribute("ServerLoaded") ~= true do
	print("Waiting for server to load...")
	task.wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Framework = require(ReplicatedStorage.Configs.Framework)
local ReplicaClient = require(ReplicatedStorage.Libraries.Replica.ReplicaClient)
local Promise = require(Packages:WaitForChild("Promise"))
local start = tick()

local totalModules = #script:GetChildren()
local loaded = 0
local initialized = {}

local function loadModule(module)
	if Framework.DEV_MODE and RunService:IsStudio() then
		task.spawn(function()
			local success, err = pcall(function()
				local required = require(module).new({})

				if required.initialize then
					required:initialize()
				end

				initialized[module.Name] = required
			end)

			if not success then
				warn(`🚫 {err}`)
			end

			loaded += 1
		end)
	else
		local required = require(module).new({})

		if required.initialize then
			required:initialize()
		end

		initialized[module.Name] = required
	end
end

Promise.new(function(resolve, reject)
	for _, module in script:GetChildren() do
		loadModule(module)
	end

	if Framework.DEV_MODE and RunService:IsStudio() then
		while loaded < totalModules do
			task.wait()
		end
	end

	for name, module in initialized do
		if module.start then
			module:start()
		end
		print(`🚀 Loaded {name}`)
	end

	resolve()
end)
	:andThen(function()
		print(`✅ Client Loaded Successfully in {tick() - start}s`)
		ReplicaClient.RequestData()
	end)
	:catch(function(err)
		warn(err)
	end)
