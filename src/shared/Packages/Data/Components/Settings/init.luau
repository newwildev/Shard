local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InfiniteMath = require(ReplicatedStorage.Packages.InfiniteMath)

return {
	DEBUG_MOCK = false,
	SUFFIX = "_DEVELOPMENT_01",
	TEMPLATE = {
		Currencies = {
			Cash = InfiniteMath.new(0), -- How much money they have
			Deposited = InfiniteMath.new(0), -- How many drops they've deposited from holding -> "bank"
			Rebirths = InfiniteMath.new(0), -- How many "rebirth points" they have
			Holding = InfiniteMath.new(0), -- How many drops they're currently holding
		},
		Tycoon = {
			Droppers = {}, -- List of droppers they own
		},
		Player = {
			Inventory = {},
			Boosts = {},
			Tutorial = {
				Completed = false,
				Step = 1, -- Number of things in the tutorial
				Contributions = 0, -- Collect 5 auras, contributed 3
			},
			Stats = {
				BestDropper = 0, -- Best Dropper to Display
				DropsCollected = 0, -- Total Drops Collected All Time
				TotalRebirths = 0, -- Total Rebirths All Time
				TotalDrops = 0, -- Total Drops Dropped All Time
				TimePlayed = 0, -- Total Time Played
				FastestRebirth = 0, -- Fastest Rebirth Time from Start
				RobuxSpent = 0, -- Total Robux Spent, if they're haven't spent robux they will get put on the non p2w boards
			},
		},
	},
	MESSAGE = `You've been kicked from the game. We had an issue loading your data. Please try again.`,
}
