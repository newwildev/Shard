local ExampleService = {}
ExampleService.__index = ExampleService

function ExampleService.new(props: { [any]: any }): ExampleService
	local self = setmetatable({}, ExampleService)

	self._dispatch = props.dispatch
	self._network = props.network

	self.functionName = function(player, data: { [any]: any })
		print(player)
		print(data.message)
	end

	self.remoteEvent = self._network:remoteEvent("ExampleEvent", "ExampleService")

	return self
end

function ExampleService:initialize()
	print(self._dispatch)
end

return ExampleService
