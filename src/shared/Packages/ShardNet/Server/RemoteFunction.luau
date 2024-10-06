local RemoteFunction = {}
RemoteFunction.__index = RemoteFunction

function RemoteFunction.new(remoteFunction: RemoteFunction, callback: (player: Player, args: any) -> ())
	local self = setmetatable({}, RemoteFunction)

	self._remoteFunction = remoteFunction

	self:Connect(callback)

	return self
end
-- NOTE: I DO NOT HAVE A INVOKE CLIENT METHOD BECAUSE THAT IS BAD PRACTICE GENERALLY
-- NOTE: IF YOU WANT THAT TO BE USEABLE DON'T USE THIS NETWORKING MODULE

-- NOTE: YOU CAN REBIND THE CONNECT FUNCTION BY USING THIS API CALL
function RemoteFunction:Connect(callback: (player: Player, args: any) -> ())
	self._remoteFunction.OnServerInvoke = function(player: Player, ...)
		return callback(player, ...)
	end
end

function RemoteFunction:Destroy()
	self._remoteFunction:Destroy()
end

return RemoteFunction
