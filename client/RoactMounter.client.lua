local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local Roact = require(Common.Roact)

local RoactComponents = Common.RoactComponents

local MainContainer = require(RoactComponents.MainContainer)

local player = Players.LocalPlayer

Roact.mount(Roact.createElement(MainContainer), player:WaitForChild("PlayerGui"), "MainContainer")
