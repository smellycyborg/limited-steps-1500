local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)

function ColorBox(props)
    local color = props.color
    local onColorBtnActivated = props.onColorBtnActivated
    local text = props.text

    return Roact.createElement("TextButton", {
        BackgroundColor3 = color,
        Text = text,
        TextScaled = true,
        [Roact.Event.Activated] = onColorBtnActivated,
    })
end

return ColorBox