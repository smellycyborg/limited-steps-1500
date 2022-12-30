local PlayersService = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Common.Roact)
local Janitor = require(Common.Janitor)
local Sift = require(Common.Sift)
local Comm = require(Common.Comm)

local GamePassComponent = require(script.Parent.GamePassComponent)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local getGamePasses = clientComm:GetFunction("GetGamePasses")
local getPlayerGamePasses = clientComm:GetFunction("GetPlayerGamePasses")

local ShopScreen = Roact.Component:extend("ShopScreen")

function ShopScreen:init()
	self.state = {
		gamePasses = {},
		ownedGamePasses = {},
    }

	self.onGamePassButtonActivated = function(rbx)
		local player = PlayersService.LocalPlayer
		local gamePasses = self.state.gamePasses
		local gamePass = rbx.Parent.Name

		local gamePassID = gamePasses[gamePass].gamePassID

		local success, hasPass = pcall(function()
			return MarketplaceService:UerOwnsGamePassAsync(player.UserId, gamePassID)
		end)

		if success then
			print("MESSAGE/Info:  ", player.Name, " has ", gamePass, ".")
		else
			MarketplaceService:PromptGamePassPurchase(player, gamePassID)
		end
	end

	self._janitor = Janitor.new()
end

function ShopScreen:didMount()
	task.spawn(function()
		local gamePasses = getGamePasses()
		self:setState({ gamePasses = gamePasses })

		local playerGamePasses = getPlayerGamePasses()
		self:setState({ ownedGamePasses = playerGamePasses })
	end)
end

function ShopScreen:didUpdate(oldProps, oldState)
	if not Sift.Dictionary.equals(oldState.inventory, self.state.inventory) then
		-- Todo update inventory 
	end
end

function ShopScreen:willUnmount()
	self._janitor:Destroy()
end

function ShopScreen:render()
	local enabled = self.props.enabled
	local gamePasses = self.state.gamePasses
	local ownedGamePasses = self.state.ownedGamePasses
	local onGamePassButtonActivated = self.onGamePassButtonActivated

	local gamePassComponents = {}
	for gamePass, info in pairs(gamePasses) do
		gamePassComponents[gamePass] = Roact.createElement(GamePassComponent, {
			name = gamePass,
			ownsGamePass = ownedGamePasses[gamePass],
			onGamePassButtonActivated = onGamePassButtonActivated,
		})
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 0.666667, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Visible = enabled,
	}, {
		Frame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
		}, {
			UIGridLayout = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.fromScale(0.05, 0),
				CellSize = UDim2.fromScale(0.2, 0.4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			GamePasses = Roact.createFragment(gamePassComponents)
		})
	})
end

return ShopScreen