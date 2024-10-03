export type Dispatcher = {
	new: () -> Dispatcher,
	subscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	unsubscribe: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
	publish: (self: Dispatcher, event: string, payload: { [any]: any }) -> nil,
	watch: (self: Dispatcher, event: string, callback: (payload: { [any]: any }) -> ()) -> nil,
}

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

export type ExampleController = {
	new: (props: { dispatch: Dispatcher }) -> ExampleController,
	initialize: (self: ExampleController) -> nil,
	start: (self: ExampleController) -> nil,
	dispatch: Dispatcher,
	network: ShardNet,
}

return {}
