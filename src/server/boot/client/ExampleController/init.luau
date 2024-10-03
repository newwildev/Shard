local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage:WaitForChild("Types"):WaitForChild("Controllers"))

local ExampleController = {}
ExampleController.__index = ExampleController

function ExampleController.new(props: { dispatch: Types.Dispatcher, network: Types.ShardNet }): Types.ExampleController
	local self = setmetatable({}, ExampleController)

	self.dispatch = props.dispatch
	self.network = props.network

	return self
end

function ExampleController:_mountDispatcher()
	self.dispatch:subscribe("ExampleEvent", function(payload: { [any]: any })
		local message = payload.message

		print(`Received message: {message}`)
	end)
end

function ExampleController:initialize()
	self:_mountDispatcher()
end

function ExampleController:start()
	self:functionName({ message = "Hello, World!" })
	self.ExampleEvent.OnClientEvent:Connect(function(payload: { [any]: any })
		local message = payload.message

		print(`Received message: {message}`)
	end)
end

return ExampleController
