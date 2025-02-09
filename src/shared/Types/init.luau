export type PlayerProfile = {
	new: (player: Player) -> PlayerProfile,

	_player: Player,
	_profile: {},
	_replica: {},

	-- INTERNAL API
	Get: (self: PlayerProfile, keyToGet: string, tableToSearch: {}) -> any,
	Set: (self: PlayerProfile, keyToSet: string, valueToSet: any, tableToSearch: {}, path: { string }) -> boolean,
}

return {}
