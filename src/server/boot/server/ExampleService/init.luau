local ExampleService = {}
ExampleService.__index = ExampleService

function ExampleService.new(props: { [any]: any }): ExampleService
	local self = setmetatable({}, ExampleService)

	self.network = props.network
	self.dispatch = props.dispatch

	self.functionName = self.network:remoteFunction(
		"functionName",
		"ExampleService",
		function(player, data: { [any]: any })
			print(player, data)

			return "Hello, World!"
		end
	)

	self.remoteEvent = self.network:remoteEvent("ExampleEvent", "ExampleService")

	return self
end

function ExampleService:initialize()
	print(self.dispatch)
	self.remoteEvent:Connect(function(player, data: { [any]: any })
		print(player, data)
	end)
end

return ExampleService
