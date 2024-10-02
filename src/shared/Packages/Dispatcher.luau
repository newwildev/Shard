export type Dispatcher = {
	new: () -> Dispatcher,
	subscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	unsubscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	publish: (self: Dispatcher, event: string, payload: { [any]: any }) -> nil,
	watch: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
}

local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher.new()
	local self = setmetatable({}, Dispatcher)

	self._subscriptions = {}

	return self
end

function Dispatcher:subscribe(event: string, callback: (payload: { [any]: any }) -> ())
	if not self._subscriptions[event] then
		self._subscriptions[event] = {}
	end

	self._subscriptions[event] = {
		callback = callback,
	}
end

function Dispatcher:unsubscribe(event: string, callback: (payload: { [any]: any }) -> ())
	if self._subscriptions[event] then
		self._subscriptions[event] = nil
	end
end


function Dispatcher:publish(event: string, payload: { [any]: any })
	if not self._subscriptions[event] then
		return
	end

	self._subscriptions[event].callback(payload)
end

return Dispatcher
