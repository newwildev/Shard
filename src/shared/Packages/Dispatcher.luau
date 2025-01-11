export type Dispatcher = {
	new: () -> Dispatcher,
	Subscribe: (event: string, callback: (payload: any) -> ()) -> nil,
	subscribe: (event: string, callback: (payload: any) -> ()) -> nil,
	SubscribeOnce: (event: string, callback: (payload: any) -> ()) -> nil,
	Unsubscribe: (event: string) -> nil,
	unsubscribe: (event: string) -> nil,
	Publish: (event: string, payload: any) -> nil,
	publish: (event: string, payload: any) -> nil,
	PublishDeferred: (event: string, payload: any) -> nil,
}

local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher.new()
	local self = setmetatable({}, Dispatcher)

	self._subscriptions = {}

	return self
end

function Dispatcher:Subscribe(event: string, callback: (payload: any) -> ())
	if not self._subscriptions[event] then
		self._subscriptions[event] = {}
	end

	self._subscriptions[event] = {
		callback = callback,
	}
end

function Dispatcher:subscribe(event: string, callback: (payload: any) -> ())
	self:Subscribe(event, callback)
end

function Dispatcher:SubscribeOnce(event: string, callback: (payload: any) -> ())
	local function callbackOnce(...)
		self:Unsubscribe(event)
		callback(...)
	end

	self:Subscribe(event, callbackOnce)
end

function Dispatcher:Unsubscribe(event: string)
	if self._subscriptions[event] then
		self._subscriptions[event] = nil
	end
end

function Dispatcher:unsubscribe(event: string)
	self:Unsubscribe(event)
end

function Dispatcher:Publish(event: string, ...: any)
	if not self._subscriptions[event] then
		return
	end

	return self._subscriptions[event].callback(...)
end

function Dispatcher:PublishDeferred(event: string, ...: any)
	local args = {...}
	task.defer(function()
		self:Publish(event, unpack(args))
	end)
end

function Dispatcher:publish(event: string, ...: any)
	self:Publish(event, ...)
end

return Dispatcher
