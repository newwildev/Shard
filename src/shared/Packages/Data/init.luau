local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Libraries = ReplicatedStorage.Libraries

local PlayerProfile = require(script.Components.PlayerProfile)
local ProfileStore = require(Libraries.ProfileStore)
local Replica = require(Libraries.Replica.ReplicaServer)
local Settings = require(script.Components.Settings)

local Data = {}
Data.__index = Data

function Data.new()
	local self = setmetatable({}, Data)

	self._playerStore = ProfileStore.New("PlayerStore", Settings.TEMPLATE)
	if RunService:IsStudio() and Settings.DEBUG_MOCK then
		print(` i'm m o C k ing yuou`)
		self._playerStore = self._playerStore.Mock
	end

	self._profiles = {} :: { [Player]: typeof(self._playerStore:StartSessionAsync()) }

	self:_initialize()

	return self
end

-- API
function Data:GetProfileAsync(player: Player)
	local profile = nil
	while profile == nil and player.Parent == Players do
		profile = self._profiles[player]
		task.wait()
	end

	return profile
end

-- INTERNAL
function Data:_playerAdded(player: Player)
	local profile = nil

	while player.Parent == Players and not ProfileStore.IsClosing do
		profile = self._playerStore:StartSessionAsync(`{player.UserId}{Settings.SUFFIX}`, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})

		if profile ~= nil then
			break
		end
	end

	if profile == nil then
		player:Kick(`{Settings.LOAD_FAILED_MESSAGE}`)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		self._profiles[player] = nil
		player:Kick(`{Settings.SEESION_END_MESSAGE}`)
	end)

	if player.Parent ~= Players then
		profile:EndSession()
	end

	local replica = Replica.New({
		Token = Replica.Token("PlayerData"),
		Data = profile.Data,
		Tags = {
			Player = player,
		},
	})
	replica:Replicate()

	self._profiles[player] = PlayerProfile.new(player, profile, replica)
end

function Data:_mountPlayerAdded()
	Players.PlayerAdded:Connect(function(player)
		self:_playerAdded(player)
	end)

	for _, player in Players:GetPlayers() do
		self:_playerAdded(player)
	end
end

function Data:_mountPlayerRemoving()
	Players.PlayerRemoving:Connect(function(player)
		local profile = self._profiles[player]:GetProfile()
		if profile then
			profile:EndSession()
		end
	end)
end

function Data:_initialize()
	self:_mountPlayerAdded()
	self:_mountPlayerRemoving()
end

return Data
