-- Game.client.luau
-- Client entrypoint for Brainrot Bay (build4, written from scratch).
-- The client only draws the HUD and asks the server; every rule lives
-- on the server, so the client can never grant itself cash or brainrots.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hud = require(script.Parent.Hud)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

Hud.init(player, remotes)
