local TestController = {}
TestController.__index = TestController

function TestController.new(props: { [any]: any })
	local self = setmetatable({}, TestController)

	self.dispatch = props.dispatch

	return self
end

function TestController:initialize() end

function TestController:start()
	self.dispatch:publish("ExampleEvent", {
		message = "Hello, World!",
	})
end

return TestController
