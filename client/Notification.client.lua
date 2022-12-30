local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local Comm = require(Common.Comm)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local notificationSignal = clientComm:GetSignal("NotificationSignal")

local WAIT_TIME_FOR_DESTROYING_NOTIFICATION = 4

local player = Players.LocalPlayer

local function onNotificationSignal(args)
    local message = args.message
    local number = args.number

    local hasNotification = player.PlayerGui:FindFirstChild("Notification")
    if hasNotification then
        repeat
            task.wait()
        until not hasNotification
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notification"
    screenGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0.5, 0.15)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.2)
    frame.Name = "NotificationHolder"
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.TextColor3 = Color3.new(1, 1, 0)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Text = (number .. " " .. message)
    textLabel.Parent = frame

    task.wait(WAIT_TIME_FOR_DESTROYING_NOTIFICATION)

    screenGui:Destroy()
end

notificationSignal:Connect(onNotificationSignal)