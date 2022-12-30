local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)

function GamePassComponent(props)
    local name = props.name
    local ownsGamePass = props.ownsGamePass
    local onGamePassButtonActivated = props.onGamePassButtonActivated

    local buyButtonText = ownsGamePass and "OWNED" or "BUY"

    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.new(0, 0.666667, 1),
    }, {
        GamePassTitle = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 0.75),
            Text = name,
            TextScaled = true,
        }),
        BuyButton = Roact.createElement("TextButton", {
            Position = UDim2.fromScale(0, 0.75),
            Size = UDim2.fromScale(1, 0.25),
            Text = buyButtonText,
            TextScaled = true,
            [Roact.Event.Activated] = onGamePassButtonActivated,
        })
    })
end

return GamePassComponent