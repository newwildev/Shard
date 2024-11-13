export type Dispatcher = {
	new: () -> Dispatcher,
	Subscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	Unsubscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	Publish: (self: Dispatcher, event: string, payload: { [any]: any }) -> nil,
}

local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher.new()
	local self = setmetatable({}, Dispatcher)

	self._subscriptions = {}

	return self
end

function Dispatcher:Subscribe(event: string, callback: (payload: { [any]: any }) -> ())
	if not self._subscriptions[event] then
		self._subscriptions[event] = {}
	end

	self._subscriptions[event] = {
		callback = callback,
	}
end

function Dispatcher:Unsubscribe(event: string, callback: (payload: { [any]: any }) -> ())
	if self._subscriptions[event] then
		self._subscriptions[event] = nil
	end
end


function Dispatcher:Publish(event: string, payload: { [any]: any })
	if not self._subscriptions[event] then
		return
	end

	self._subscriptions[event].callback(payload)
end

return Dispatcher
