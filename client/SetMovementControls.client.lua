local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Common = ReplicatedStorage:WaitForChild("Common")
local Comm = require(Common.Comm)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local setMovementControlsSignal = clientComm:GetSignal("SetMovementControlsSignal")

local player = Players.LocalPlayer
local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

local function onSetMovementControlsSignal(bool)
    if (bool == true) then
        controls:Enable()
    else
        controls:Disable()
    end
end

setMovementControlsSignal:Connect(onSetMovementControlsSignal)