local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)


local ColorBox = require(script.Parent.ColorBox)

function ColorMenu(props)
    local enabled = props.enabled
    local onColorBtnActivated = props.onColorBtnActivated

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.8),
        Size = UDim2.fromScale(0.5, 0.15),
        Visible = enabled,
    }, {
        UIGridLayout = Roact.createElement("UIGridLayout", {
            CellPadding = UDim2.fromScale(0.01, 0),
            CellSize = UDim2.fromScale(0.1, 0.5),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        Pink = Roact.createElement(ColorBox, {
            color = Color3.new(1, 0.666667, 1),
            onColorBtnActivated = onColorBtnActivated,
            text = "Pink",
        }),
        Orange = Roact.createElement(ColorBox, {
            color = Color3.new(1, 0.666667, 0.498039),
            onColorBtnActivated = onColorBtnActivated,
            text = "Orange",
        }),
        Blue = Roact.createElement(ColorBox, {
            color = Color3.new(0, 0.666667, 1),
            onColorBtnActivated = onColorBtnActivated,
            text = "Blue",
        }),
        Green = Roact.createElement(ColorBox, {
            color = Color3.new(0, 255, 127),
            onColorBtnActivated = onColorBtnActivated,
            text = "Green",
        })
    })
end

return ColorMenu