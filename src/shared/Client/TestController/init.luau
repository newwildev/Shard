local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetModule = require(ReplicatedStorage.Packages.GetModule)
local TestController = {}
TestController.__index = TestController

function TestController.new()
	local self = setmetatable({}, TestController)

	return self
end

function TestController:initialize()
	print("Running test controller")
end

function TestController:start()
	print("Starting test controller")
	local module = GetModule("OtherController")
	print(module)
end

return TestController
