local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RX = require(ReplicatedStorage.Packages.RX)
local Dispatcher = require(ReplicatedStorage.Packages.Dispatcher)

local TestService = {}
TestService.__index = TestService

function TestService.new()
	local self = setmetatable({}, TestService)

	return self
end

function TestService:initialize()
	self:runDataTests()
end

function TestService:runDataTests()
	-- error(`Data tests not implemented`)
	Dispatcher:Publish("WhatEventName", "Hello")
	Dispatcher:Publish("WhatEventName2", "Hello")
end

return TestService
