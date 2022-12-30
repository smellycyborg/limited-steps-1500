local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)

function SpecificItem(props)
	local name = props.name
	local imageId = props.imageId
	local onButtonActivated = props.onButtonActivated
	local inInventory = props.inInventory

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		ImageLabel = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 0.8),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = imageId,
			ScaleType = Enum.ScaleType.Fit,
		}),
		TextLabel = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0, 0.8),
			Text = name,
			TextScaled = true,
			BorderSizePixel = 0,
			BackgroundColor3 = inInventory and Color3.new(1, 0.333333, 0) or Color3.new(0, 0.666667, 1),
		}),
		Button = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			[Roact.Event.Activated] = function(rbx)
				onButtonActivated(rbx)
			end
		})
	})
end

return SpecificItem