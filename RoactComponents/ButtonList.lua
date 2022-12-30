local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local Roact = require(Common.Roact)

local RoactComponents = script.Parent
local SimpleButton = require(RoactComponents.SimpleButton)

function ButtonList(props)
	local onButtonActivated = props.onButtonActivated
	local buttonNames = props.buttonNames

	local buttons = {}
	for _, buttonName in pairs(buttonNames) do

		local buttonColor
		if buttonName == "Items" then
			buttonColor = Color3.new(0, 0.666667, 1)
		elseif buttonName == "Shop" then
			buttonColor = Color3.new(1, 0.666667, 1)
		elseif buttonName == "Settings" then
			buttonColor = Color3.new(1, 0.666667, 0.498039)
		end

		buttons[buttonName] = Roact.createElement(SimpleButton, {
			Text = buttonName,
			BackgroundColor3 = buttonColor,
			[Roact.Event.Activated] = function(...)
				if not onButtonActivated then
					return
				end

				onButtonActivated(buttonName, ...)
			end
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.1, 0.5),
		Position = UDim2.fromScale(0.1, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0.05, 0.05)
		}),
		Buttons = Roact.createFragment(buttons)
	})
end

return ButtonList