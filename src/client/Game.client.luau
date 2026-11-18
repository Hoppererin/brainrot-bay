-- Brainrot Bay — client entrypoint.
-- Waits for the server's RemoteEvents, then starts the HUD.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local Hud = require(script.Parent.Hud)

Hud.start(remotes, player)
