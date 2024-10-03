local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local ShardNet = require(ReplicatedStorage.Packages.ShardNet)
local Dispatcher = require(Packages.Dispatcher)
local Promise = require(Packages.Promise)
local start = tick()

Promise.new(function(resolve, reject)
	local initalized = {}
	local dispatch = Dispatcher.new()
	local network = ShardNet.new()

	for _, module in script:GetChildren() do
		local required = require(module).new({
			dispatch = dispatch,
			network = network,
		})

		local name = module.Name:gsub("Service$", "")
		network:fetchNamespace(name, ReplicatedStorage)
		for functionName, func in required do
			if typeof(func) == "function" then
				network:remoteFunction(functionName, name, func)
			end
		end

		if required.initialize then
			required:initialize()
		end

		initalized[module.Name] = required
	end

	for name, module in initalized do
		if module.start then
			module:start()
		end
		print(`Loaded {name}`)
	end

	resolve()
end)
	:andThen(function()
		local client = script.Parent.client
		client.Parent = ReplicatedFirst
		print(`Server Loaded Successfully in {tick() - start}s`)
	end)
	:catch(function(err)
		warn(err)
	end)
