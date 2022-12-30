local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)
local Sift = require(Common.Sift)

function SimpleButton(props)
	return Roact.createElement("TextButton", Sift.Dictionary.mergeDeep(props, {
		Size = UDim2.fromScale(0.85, 1),
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		[Roact.Children] = {
			UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 2,
			}),
		}
	}))
end

return SimpleButton