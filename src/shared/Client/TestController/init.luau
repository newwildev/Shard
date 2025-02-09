local TestController = {}
TestController.__index = TestController

function TestController.new()
	local self = setmetatable({}, TestController)

	return self
end

function TestController:initialize()
	print("Running test controller")
end

return TestController
