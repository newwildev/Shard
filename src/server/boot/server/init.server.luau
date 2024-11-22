local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Data = require(Packages.Data)
local ShardNet = require(Packages.ShardNet)
local Dispatcher = require(Packages.Dispatcher)
local Promise = require(Packages.Promise)
local start = tick()

Promise.new(function(resolve, reject)
	local initalized = {}
	local dispatch = Dispatcher.new()
	local Data = Data.new()

	for _, module in script:GetChildren() do
		local network = ShardNet.new({
			moduleName = module.Name,
		})
		local required = require(module).new({
			dispatch = dispatch,
			network = network,
			data = Data,
		})

		local name = module.Name:gsub("Service$", "")
		network:fetchNamespace(name)

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
