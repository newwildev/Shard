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
	Dispatcher:Subscribe("WhatEventName", function(message)
		print("TestService received message: ", message)
	end)

	local newDisptacher = Dispatcher.new()
	newDisptacher:Subscribe("WhatEventName2", function(message)
		print("TestService received message: ", message)
	end)

	newDisptacher:Publish("WhatEventName2", "Hello World fromw within")
	print("Running data tests")
end

return TestService
