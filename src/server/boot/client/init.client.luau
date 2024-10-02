local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Dispatcher = require(Packages:WaitForChild("Dispatcher"))
local Promise = require(Packages:WaitForChild("Promise"))
local start = tick()

Promise.new(function(resolve, reject)
	local initialized = {}
	local dispatch = Dispatcher.new()

	for _, module in script:GetChildren() do
		local required = require(module).new({
			dispatch = dispatch,
		})
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
	end)
	:catch(function(err)
		warn(err)
	end)
