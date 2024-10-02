local ExampleService = {}
ExampleService.__index = ExampleService

function ExampleService.new(props: { [any]: any }): ExampleService
	local self = setmetatable({}, ExampleService)

	self.dispatch = props.dispatch

	return self
end

function ExampleService:initialize()
	print(self.dispatch)
end

return ExampleService
