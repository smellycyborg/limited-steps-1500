local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local ItemsReplicated = Common.Items

local Janitor = require(Common.Janitor)
local Comm = require(Common.Comm)
local ItemsData = require(script.Parent.items)
local GamePassesData = require(script.Parent.gamePasses)

local DEFAULT_STEPS = 1500
local MAX_STEPS = 2000
local WAIT_TIME_FOR_STEPS_TO_ADD = 57
local RUNNING_TICK_TIME = (0.3)

local ADD_STEPS_NOTIFICATION_MESSAGE = "steps have been added to your total steps.  Thanks for playing!"

local serverComm = Comm.ServerComm.new(ReplicatedStorage, "MainComm")

local Sdk = {
    _playerData = {},
    _playerDataStore = DataStoreService:GetDataStore("PlayerData"),
    _connections = {},
    _signals = {

    },
    contributions = 0,
}

local function updateStepsUi(player)
    if (player.Character) then
        local stepsBillBoardGui = player.Character:FindFirstChild("StepsGui")
        if (not stepsBillBoardGui) then
            return
        end

        local stepsCountTextLabel = stepsBillBoardGui.StepsCountTextLabel

        stepsCountTextLabel.Text = Sdk:GetValue(player, "Steps") .. " STEPS"
    end
end

local function onSetPlayerStepsLabelColor(player, colorName)
    local character = player.Character
    local stepsGui = character:FindFirstChild("StepsGui")
    if not stepsGui then
        return
    end

    local color

    if colorName == "Pink" then
        color = Color3.new(255, 170, 255)
    elseif colorName == "Orange" then
        color = Color3.new(1, 0.666667, 0.498039)
    elseif colorName == "Green" then
        color = Color3.new(0, 255, 127)
    elseif colorName == "Blue" then
        color = Color3.new(0, 0.666667, 1)
    end

    stepsGui.StepsCountTextLabel.TextColor3 = color
end

local function onHumanoidRunning(player, speed)
    local hasSpeed = speed > 0.09

    if (hasSpeed) then
        Sdk:SetBool(player, "isRunning", true)
    else
        Sdk:SetBool(player, "isRunning", false)
    end
end

local function characterAdded(character)
    local player = Players:GetPlayerFromCharacter(character)
    local humanoid = character.Humanoid

    local stepsGui = Instance.new("BillboardGui")
    stepsGui.Name = "StepsGui"
    stepsGui.Size = UDim2.fromScale(1, 1)
    stepsGui.StudsOffset = Vector3.new(0, 3.5, 0)
    stepsGui.Parent = character

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "StepsCountTextLabel"
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.Text = Sdk:GetValue(player, "Steps") .. " STEPS"
    textLabel.TextColor3 = Color3.new(0.270588, 1, 0.658824)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
	textLabel.Parent = stepsGui

    Sdk._connections[player]:Add(setPlayerStepsLabelColor:Connect(onSetPlayerStepsLabelColor))
    Sdk._connections[player]:Add(humanoid.Running:Connect(function(speed)
        onHumanoidRunning(player, speed)
    end))
        
end

local function characterRemoving(character)
    local player = Players:GetPlayerFromCharacter(character)
    local hasJanitor = Sdk._connections[player]

    if (hasJanitor) then
        Sdk._connections[player]:Cleanup()
    end
end

local function playerAdded(player)
    local STEPS_TO_ADD = 10
    local DEFAULT_SCHEMA = {
        Steps = DEFAULT_STEPS,
        isGroupMember = false,
        isRunning = false,
        tookSteps = false,
        gaveSteps = false,
        gamePasses = {
            UnlimitedSteps = false,
        },
	}
	
	Sdk._connections[player] = Janitor.new()

    local playerData
    local success, data = pcall(function()
        -- gets and returns player data from player data store using data store service
        return Sdk._playerDataStore:GetAsync(player.UserId)
    end)

    if (success) then
        if data ~= nil then
            playerData = data
        else
            playerData = DEFAULT_SCHEMA
        end
    else
        playerData = DEFAULT_SCHEMA
        warn("MESSAGE/Error:  Failed to Get Async for ", player.Name, ".")
    end

    Sdk._playerData[player] = playerData

    local currentSteps = Sdk:GetValue(player, "Steps")
    local hasUnlimitedSteps = Sdk:GetGamePass(player, "UnlimitedSteps")
    local stepsText = hasUnlimitedSteps and "Unlimited Steps" or currentSteps

    -- int value containing steps count (child of player)
    local stepsValue = Instance.new("IntValue")
    stepsValue.Name = "StepsValue"
    stepsValue.Value = stepsText
    stepsValue.Parent = player

	player.CharacterAdded:Connect(characterAdded)
    player.CharacterRemoving:Connect(characterRemoving)

    print("Connections:  ", Sdk._connections, "  Data:  ", Sdk._playerData)

	-- Todo add conditions for task.spawn()
    while task.wait() do
        -- checks to see if layer i still in game and if not will break loop
        local playerExist = Sdk._playerData[player]
        if (not playerExist) then
            break
        end

        -- checks to see if player has unlimited steps gamepass and if so break loop
        if hasUnlimitedSteps then
            break
        end

        -- checks to see if players steps are zero and if true then turn off movement conrols
        local stepsHitZero = Sdk:GetValue(player, "Steps") == 0
        if (stepsHitZero) then
            setMovementControlsSignal:Fire(player, true)
        end

        -- task for adding steps per time spent in game
        task.spawn(function()
            local gaveSteps = Sdk:GetValue(player, "gaveSteps")

            if (not gaveSteps) then
                Sdk:IncrementValue(player, "Steps", STEPS_TO_ADD)

                updateStepsUi(player)
                notificationSignal:Fire(player, {
                    message = ADD_STEPS_NOTIFICATION_MESSAGE, 
                    number = STEPS_TO_ADD 
				})
				
				Sdk:SetBool(player, "gaveSteps", true)
				
				task.wait(WAIT_TIME_FOR_STEPS_TO_ADD)
				
                Sdk:SetBool(player, "gaveSteps", false)
            end
        end)

        -- task for taking away steps per time spent while running
        task.spawn(function()
            local isRunning = Sdk:GetValue(player, "isRunning")
            local tookSteps = Sdk:GetValue(player, "tookSteps")

            if (isRunning and not tookSteps) then
                Sdk:SubtractValue(player, "Steps", 1)
                updateStepsUi(player)

                Sdk:SetBool(player, "tookSteps", true)

                task.wait(RUNNING_TICK_TIME)

                Sdk:SetBool(player, "tookSteps", false)
            end
        end)
    end
end

local function playerRemoving(player)
    local playerData = Sdk._playerData[player]

	local success, err = pcall(function()
        -- save player data
        Sdk._playerDataStore:SetAsync(string.format("Player_%d", player.UserId), playerData)
    end)

    if (not success) then
        warn(err)
    end

	Sdk._playerData[player] = nil
	Sdk._connections[player]:Destroy()
    Sdk._connections[player] = nil
	
	print("Connections:  ", Sdk.connections, "  Data:  ", Sdk._playerData)
end

local function onGetItemsFunction(_player)
    return ItemsData
end

local function onGetGamePasses(gamePassName)
    return GamePassesData
end

local function onGetPlayerGamePasses(player)
    return Sdk._playerData[player].gamePasses
end

local function findItem(item)
    for _, tool in pairs(ItemsReplicated:GetChildren()) do
        if (tool.Name == item) then
            return tool
        end
    end
end

local function onHandleItemForPlayer(player, item, isEquip)
    local foundItem

    if (not isEquip) then
        foundItem = player.Backpack:FindFirstChild(item) or player.Character:FindFirstChild(item)
        if (foundItem) then
            return
        end

        foundItem = findItem(item)
        
        local itemClone = foundItem:Clone()
        itemClone.TextureId = ItemsData[item].imageId
        itemClone.ToolTip = item
        itemClone.Parent = player.Backpack
    elseif (isEquip) then
        foundItem = player.Backpack:FindFirstChild(item) or player.Character:FindFirstChild(item)
        if not foundItem then
            print("MESSAGE/info:  ", item, " was not in ", player.Name, "'s backpack to be destroyed.")
        else
            foundItem:Destroy()
        end
    end
end

function Sdk.init()

    notificationSignal = serverComm:CreateSignal("NotificationSignal")
    setMovementControlsSignal = serverComm:CreateSignal("SetMovementControlsSignal")
    local handleItemForPlayer = serverComm:CreateSignal("HandleItemForPlayer")
    setPlayerStepsLabelColor = serverComm:CreateSignal("SetPlayerStepsLabelColor")

    serverComm:BindFunction("GetItemsFunction", onGetItemsFunction)
    serverComm:BindFunction("GetGamePasses", onGetGamePasses)
    serverComm:BindFunction("GetPlayerGamePasses", onGetPlayerGamePasses)

    -- bindings
    Players.PlayerAdded:Connect(playerAdded)
    Players.PlayerRemoving:Connect(playerRemoving)

    handleItemForPlayer:Connect(onHandleItemForPlayer)

end

--// methods

function Sdk:IncrementValue(player, key, amount)
    self._playerData[player][key]+=amount
end

function Sdk:SubtractValue(player, key, amount)
    self._playerData[player][key]-=amount
end

function Sdk:GetValue(player, key)
    return self._playerData[player][key]
end
    
function Sdk:GetGamePass(player, key)
    return self._playerData[player].gamePasses[key]
end

function Sdk:SetBool(player, key, bool)
    self._playerData[player][key] = bool
end

return Sdk
