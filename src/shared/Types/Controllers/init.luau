export type Dispatcher = {
	new: () -> Dispatcher,
	subscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	unsubscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	publish: (self: Dispatcher, event: string, payload: { [any]: any }) -> nil,
	watch: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
}

export type ExampleController = {
	new: (props: { dispatch: Dispatcher }) -> ExampleController,
	initialize: (self: ExampleController) -> nil,
	start: (self: ExampleController) -> nil,
	dispatch: Dispatcher,
}

return {}
