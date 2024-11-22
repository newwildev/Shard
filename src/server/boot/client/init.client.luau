local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local ReplicaClient = require(ReplicatedStorage.Libraries.Replica.ReplicaClient)
local ShardNet = require(Packages:WaitForChild("ShardNet"))
local Dispatcher = require(Packages:WaitForChild("Dispatcher"))
local Promise = require(Packages:WaitForChild("Promise"))
local start = tick()

Promise.new(function(resolve, reject)
	local initialized = {}
	local dispatch = Dispatcher.new()

	for _, module in script:GetChildren() do
		local network = ShardNet.new({
			moduleName = module.Name,
		})
		local required = require(module).new({
			dispatch = dispatch,
		})

		local constructed = network:construct(module.Name:gsub("Controller$", ""))

		for name, data in constructed do
			if data._remoteFunction ~= nil then
				required[name] = function(self, ...)
					return data:Invoke(...)
				end
			end

			if data._remoteEvent ~= nil then
				required[name] = data
			end
		end

		if required.initialize then
			required:initialize()
		end

		initialized[module.Name] = required
	end

	for name, module in initialized do
		if module.start then
			module:start()
			print(`Loaded {name}`)
		end
	end

	resolve()
end)
	:andThen(function()
		print(`Client Loaded Successfully in {tick() - start}s`)
		ReplicaClient.RequestData()
	end)
	:catch(function(err)
		warn(err)
	end)
