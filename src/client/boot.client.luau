local ReplicatedStorage = game:GetService("ReplicatedStorage")
local client = ReplicatedStorage:WaitForChild("Client")
client.Parent = script.Parent
script:Destroy()
