local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GetModule = require(ReplicatedStorage.Packages.GetModule)
local TestController = {}
TestController.__index = TestController

function TestController.new()
	local self = setmetatable({}, TestController)

	self._hello = "Hello World"

	return self
end

function TestController:initialize() end

return TestController
