local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local RoactComponents = Common:WaitForChild("RoactComponents")

local Roact = require(Common.Roact)
local Janitor = require(Common.Janitor)
local Sift = require(Common.Sift)
local Comm = require(Common.Comm)

local SpecificItem = require(RoactComponents.SpecificItem)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local handleItemForPlayer = clientComm:GetSignal("HandleItemForPlayer")
local getItems = clientComm:GetFunction("GetItemsFunction")

local ItemsScreen = Roact.Component:extend("ItemsScreen")

function ItemsScreen:init()
	self.state = {
		serverItems = {},
		inventory = {},
    }

    self.absoluteContentSize, self.updateAbsoluteContentSize = Roact.createBinding(Vector2.new())

	self.onAbsoluteContentSizeChanged = function(rbx)
		self.updateAbsoluteContentSize(rbx.AbsoluteContentSize)
	end

	self.onButtonActivated = function(rbx)
		self:setState(function(state)
			local item = rbx.Parent.Name
			local foundItem = Sift.Array.find(state.inventory, item)
			if foundItem then
				handleItemForPlayer:Fire(item, true)
				return { inventory = Sift.Array.removeIndex(state.inventory, foundItem) }
			else
				handleItemForPlayer:Fire(item, false)
				return { inventory = Sift.Array.push(state.inventory, item)}
			end
		end)
	end

	self._janitor = Janitor.new()
end

function ItemsScreen:didMount()

	task.spawn(function()
		local serverItems = getItems() 
		self:setState({ serverItems = serverItems })
	end)
end

function ItemsScreen:didUpdate(oldProps, oldState)
	if not Sift.Dictionary.equals(oldState.serverItems, self.state.serverItems) then
		-- Todo update itemss
	end
end

function ItemsScreen:willUnmount()
	self._janitor:Destroy()
end

function ItemsScreen:render()
	local enabled = self.props.enabled
	local inventory = self.state.inventory
	local serverItems = self.state.serverItems

    local items = {}
	for item, data in pairs(serverItems) do
		local inInventory = Sift.Array.find(inventory, item)

		items[item] = Roact.createElement(SpecificItem, {
			name = item or "",
			imageId = data.imageId,
			onButtonActivated = self.onButtonActivated,
			inInventory = inInventory,
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0.666667, 1),
		Visible = enabled,
	}, {
		ScrollingFrame = Roact.createElement("ScrollingFrame", {
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = self.absoluteContentSize:map(function(absoluteContentSize)
				return UDim2.new(0, 0, 0, absoluteContentSize.Y)
			end),
		}, {
			UIGridLayout = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.fromScale(0.05, 0.05),
				CellSize = UDim2.fromScale(0.2, 0.3),
				SortOrder = Enum.SortOrder.LayoutOrder,
				[Roact.Change.AbsoluteContentSize] = self.onAbsoluteContentSizeChanged,
			}),
			Item = Roact.createFragment(items),
		})
	})
end

return ItemsScreen