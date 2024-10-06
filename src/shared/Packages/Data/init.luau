local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ReplicatedStorage.Libraries.ProfileService)
local Settings = require(script.Components.Settings)

local DataService = {}
DataService.__index = DataService

function DataService.new()
	local self = setmetatable({}, DataService)

	self._profileStore = ProfileService.GetProfileStore("PlayerData", Settings.TEMPLATE)
	self._profiles = {}

	self:initialize()

	return self
end

function DataService:_playerAdded(player: Player)
	local profile = self._profileStore:LoadProfileAsync(`{player.UserId}{Settings.SUFFIX}`)
	if not profile then
		warn(`Failed to load profile for player {player.UserId}`)
		player:Kick(Settings.MESSAGE)
		return
	end

	profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
	profile:ListenToRelease(function()
		self._profiles[player] = nil
		-- The profile could've been loaded on another Roblox server:
		player:Kick()
	end)
	if player:IsDescendantOf(Players) == true then
		self._profiles[player] = profile
	else
		-- Player left before the profile loaded:
		profile:Release()
	end
end

function DataService:_playerRemoving(player: Player)
	local profile = self._profiles[player]
	if profile then
		profile:Release()
	end
end

function DataService:getProfile(player: Player)
	local profile = nil
	while profile == nil and player:IsDescendantOf(Players) == true do
		profile = self._profiles[player]
		task.wait()
	end

	return profile
end

function DataService:initialize()
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:_playerAdded(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		self:_playerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_playerRemoving(player)
	end)
end

return DataService
