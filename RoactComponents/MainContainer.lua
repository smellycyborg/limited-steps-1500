local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local Roact = require(Common.Roact)
local Janitor = require(Common.Janitor)
local Comm = require(Common.Comm)

local Screen = require(Common.Enums.Screen)
local RoactComponents = script.Parent
local ButtonList = require(RoactComponents.ButtonList)
local SettingsScreen = require(RoactComponents.SettingsScreen)
local ItemsScreen = require(RoactComponents.ItemsScreen)
local ShopScreen = require(RoactComponents.ShopScreen)
local ColorMenu = require(RoactComponents.ColorMenu)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local setPlayerStepsLabelColor = clientComm:GetSignal("SetPlayerStepsLabelColor")

local MainContainer = Roact.Component:extend("MainContainer")

function MainContainer:init()
	self.state = {
		currentScreen = nil,
		colorMenuEnabled = false,
	}

	self._janitor = Janitor.new()

	self.onButtonActivated = function(buttonName)
		self:setState(function(state)
			return {
				currentScreen = state.currentScreen == buttonName and Roact.None or buttonName,
				colorMenuEnabled = false,
			}
		end)
	end

	self.onSettingsBtnActivated = function()
		self:setState(function(state)
			return { colorMenuEnabled = not state.colorMenuEnabled }
		end)
	end

	self.onColorBtnActivated = function(rbx)
		local colorName = rbx.Name

		setPlayerStepsLabelColor:Fire(colorName)

		self:setState({ currentScreen = Roact.None, colorMenuEnabled = false })
	end
end

function MainContainer:didMount()
    
end

function MainContainer:willUnmount()
	self._janitor:Destroy()
end

function MainContainer:render()
	local currentScreen = self.state.currentScreen
	local colorMenuEnabled = self.state.colorMenuEnabled
	local onColorBtnActivated = self.onColorBtnActivated
	local onSettingsBtnActivated = self.onSettingsBtnActivated

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		ButtonList = Roact.createElement(ButtonList, {
			buttonNames = { Screen.Items, Screen.Settings, Screen.Shop },
			onButtonActivated = self.onButtonActivated,
		}),
		ItemsScreen = Roact.createElement(ItemsScreen, {
			enabled = currentScreen == Screen.Items,
		}),
		SettingsScreen = Roact.createElement(SettingsScreen, {
			enabled = currentScreen == Screen.Settings,
			colorMenuEnabled = colorMenuEnabled,
			onSettingsBtnActivated = onSettingsBtnActivated,
		}),
		ShopScreen = Roact.createElement(ShopScreen, {
			enabled = currentScreen == Screen.Shop,
		}),
		ColorMenu = Roact.createElement(ColorMenu, {
			enabled = colorMenuEnabled,
			onColorBtnActivated = onColorBtnActivated,
		})
	})
end

return MainContainer