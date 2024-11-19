local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Client = script.Client
local Server = script.Server

export type ShardNet = {
	new: () -> ShardNet,
	fetchNamespace: (self: ShardNet, name: string, parent: any?) -> Folder?,
	construct: (self: ShardNet, name: string) -> { [string]: { RF: RemoteFunction?, RE: RemoteEvent? } },
	remoteFunction: (
		self: ShardNet,
		functionName: string,
		namespaceName: string,
		callback: (player: Player, args: any) -> any
	) -> RemoteFunction,
	remoteEvent: (self: ShardNet, eventName: string, namespaceName: string) -> RemoteEvent,
}

local ShardNet = {}
ShardNet.__index = ShardNet

function ShardNet.new()
	local self = setmetatable({}, ShardNet)

	self._remoteEvents = {}
	self._remoteFunctions = {}

	return self
end

function ShardNet:fetchNamespace(name: string)
	if RunService:IsServer() then
		local remoteFolder = ReplicatedStorage:FindFirstChild("Remote") or Instance.new("Folder", ReplicatedStorage)
		remoteFolder.Name = "Remote"

		if remoteFolder:FindFirstChild(name, true) then
			return remoteFolder:FindFirstChild(name, true)
		end

		local namespace = Instance.new("Folder")
		local REMOTE_EVENTS = Instance.new("Folder", namespace)
		local REMOTE_FUNCTIONS = Instance.new("Folder", namespace)

		namespace.Name = name
		REMOTE_EVENTS.Name = "RE"
		REMOTE_FUNCTIONS.Name = "RF"

		namespace.Parent = remoteFolder

		return namespace
	end

	local namespace = ReplicatedStorage.Remote:FindFirstChild(name, true)

	if namespace then
		return namespace
	end

	return nil
end

function ShardNet:construct(name: string)
	local RunContext = RunService:IsServer() and Server or Client
	if RunContext == Server then
		error("Construct can only be called on the client")
	end

	local namespace = self:fetchNamespace(name)
	local constructed = {}

	if not namespace then
		return {}
	end

	for _, remoteFunction in namespace.RF:GetChildren() do
		constructed[remoteFunction.Name] = require(RunContext.RemoteFunction).new(remoteFunction) -- { RF = remoteFunction
	end

	for _, remoteEvent in namespace.RE:GetChildren() do
		constructed[remoteEvent.Name] = require(RunContext.RemoteEvent).new(remoteEvent)
	end

	return constructed
end

-- TODO: UPDATE SO WE DON'T HAVE TO PROVIDE THE NAMESPACE NAME IT SHOULD BE AUTOMATIC
-- NOTE: MAYBE REQUIRE NETWORK? INSTEAD OF INJECTING NO NEED FOR GLOBAL NETWORK ANYMORE
function ShardNet:remoteFunction(
	functionName: string,
	namespaceName: string,
	callback: (player: Player, args: any) -> any
)
	local RunContext = RunService:IsServer() and Server or Client
	if RunContext == Client then
		error("Cannot create RemoteFunction on the client")
	end
	local name = namespaceName:gsub("Service$", "")

	local namespace = self:fetchNamespace(name)
	local remoteFunction = Instance.new("RemoteFunction", namespace.RF)

	remoteFunction.Name = functionName

	table.insert(self._remoteFunctions, remoteFunction)

	return require(RunContext.RemoteFunction).new(remoteFunction, callback)
end

function ShardNet:remoteEvent(eventName: string, namespaceName: string)
	local RunContext = RunService:IsServer() and Server or Client
	if RunContext == Client then
		error("Cannot create RemoteEvent on the client")
	end
	local name = namespaceName:gsub("Service$", "")

	local namespace = self:fetchNamespace(name)
	local remoteEvent = Instance.new("RemoteEvent", namespace.RE)

	remoteEvent.Name = eventName

	table.insert(self._remoteEvents, remoteEvent)

	return require(RunContext.RemoteEvent).new(remoteEvent)
end

return ShardNet
