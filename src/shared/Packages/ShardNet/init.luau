local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

export type ShardNet = {
	new: () -> ShardNet,
	fetchNamespace: (self: ShardNet, name: string, parent: any?) -> Folder?,
	construct: (self: ShardNet, name: string) -> { [string]: { RF: RemoteFunction?, RE: RemoteEvent? } },
	remoteFunction: (self: ShardNet, functionName: string, namespaceName: string, callback: (player: Player, args: any) -> any) -> RemoteFunction,
	remoteEvent: (self: ShardNet, eventName: string, namespaceName: string) -> RemoteEvent,
	FireAll: (self: ShardNet, eventName: string, args: any) -> nil,
	FireFilter: (self: ShardNet, eventName: string, filter: (player: Player) -> boolean, args: any) -> nil,
	Fire: (self: ShardNet, player: Player, eventName: string, ...) -> nil,
	FireDelayed: (self: ShardNet, player: Player, eventName: string, delay: number, args: any) -> nil,
}

local ShardNet = {}
ShardNet.__index = ShardNet

function ShardNet.new()
	local self = setmetatable({}, ShardNet)

	self._remoteEvents = {}
	self._remoteFunctions = {}

	return self
end

function ShardNet:fetchNamespace(name: string, parent: any)
	if RunService:IsServer() and not ReplicatedStorage:FindFirstChild(name, true) then
		local namespace = Instance.new("Folder")
		local REMOTE_EVENTS = Instance.new("Folder", namespace)
		local REMOTE_FUNCTIONS = Instance.new("Folder", namespace)

		namespace.Name = name
		REMOTE_EVENTS.Name = "RE"
		REMOTE_FUNCTIONS.Name = "RF"

		namespace.Parent = parent or ReplicatedStorage

		return namespace
	end

	local namespace = ReplicatedStorage:FindFirstChild(name, true)

	if namespace then
		return namespace
	end

	return nil
end

function ShardNet:construct(name: string)
	local namespace = self:fetchNamespace(name)
	local constructed = {}

	if namespace then
		for _, remoteFunction in namespace.RF:GetChildren() do
			constructed[remoteFunction.Name] = {
				RF = remoteFunction,
			}
		end

		for _, remoteEvent in namespace.RE:GetChildren() do
			constructed[remoteEvent.Name] = {
				RE = remoteEvent,
			}
		end
	end

	return constructed
end

function ShardNet:remoteFunction(
	functionName: string,
	namespaceName: string,
	callback: (player: Player, args: any) -> any
)
	local namespace = self:fetchNamespace(namespaceName)
	local remoteFunction = Instance.new("RemoteFunction", namespace.RF)

	remoteFunction.Name = functionName
	remoteFunction.OnServerInvoke = callback

	table.insert(self._remoteFunctions, remoteFunction)

	return remoteFunction
end

function ShardNet:remoteEvent(eventName: string, namespaceName: string)
	local name = namespaceName:gsub("Service$", "")

	local namespace = self:fetchNamespace(name)
	local remoteEvent = Instance.new("RemoteEvent", namespace.RE)

	remoteEvent.Name = eventName

	table.insert(self._remoteEvents, remoteEvent)

	return remoteEvent
end

function ShardNet:FireAll(eventName: string, ...)
	local remoteEvent = self._remoteEvents[eventName]

	if remoteEvent then
		remoteEvent:FireAllClients(...)
	end
end

function ShardNet:FireFilter(eventName: string, filter: (player: Player) -> boolean, ...)
	local remoteEvent = self._remoteEvents[eventName]

	if remoteEvent then
		for _, player in Players:GetPlayers() do
			if filter(player) then
				remoteEvent:FireClient(player, ...)
			end
		end
	end
end

function ShardNet:Fire(player: Player, eventName: string, ...)
	local remoteEvent = self._remoteEvents[eventName]

	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	end
end

function ShardNet:FireDelayed(player: Player, eventName: string, delay: number, ...)
	local remoteEvent = self._remoteEvents[eventName]

	if remoteEvent then
		local args = ...
		task.delay(delay, function()
			remoteEvent:FireClient(player, args)
		end)
	end
end

return ShardNet
