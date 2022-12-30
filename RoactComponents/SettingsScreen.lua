local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)

local RoactComponents = script.Parent
local SimpleButton = require(RoactComponents.SimpleButton)

local DESCRIPTION = "Change your steps text label color!"
local BUTTON_TEXT = "PICK COLOR"

function SettingsScreen(props)
	local enabled = props.enabled
	local colorMenuEnabled = props.colorMenuEnabled
	local onSettingsBtnActivated = props.onSettingsBtnActivated

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 0.666667, 0.498039),
		Visible = enabled
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 3,
		}),
		TextLabel = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.8),
			Text = DESCRIPTION,
			TextScaled = true,
			TextWrapped = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamSemibold,
		}),
		ButtonContainer = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0, 0.8),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Buttons = Roact.createElement(SimpleButton, {
				Text =  BUTTON_TEXT,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				[Roact.Event.Activated] = onSettingsBtnActivated,
			})
		})
	})
end

return SettingsScreen