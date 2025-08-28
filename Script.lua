-- Удаляем старый GUI если он есть
local oldGui = game.CoreGui:FindFirstChild("CheatMenu")
if oldGui then oldGui:Destroy() end

-- Создаем основной GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CheatMenu"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Главный фрейм
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 916, 0, 508)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(4, 4, 48)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui

-- Переключение видимости
local visible = true
local tweenTime = 0.3
local function toggleGui()
    if visible then
        local tweenOut = TweenService:Create(frame, TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 0)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        frame.Visible = false
    else
        frame.Visible = true
        local tweenIn = TweenService:Create(frame, TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 916, 0, 508)})
        tweenIn:Play()
    end
    visible = not visible
end

-- Перетаскивание окна
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function makeDraggable(guiElement)
    guiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local goal = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal}):Play()
        end
    end)
end

-- Верхняя панель
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = frame
makeDraggable(topBar)

local title = Instance.new("TextLabel")
title.Text = "Cheat Hub"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 5)
title.Size = UDim2.new(0, 200, 0, 30)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local versionLabel = Instance.new("TextLabel")
versionLabel.Text = "Ver. 1.0.2"
versionLabel.Font = Enum.Font.SourceSansBold
versionLabel.TextSize = 20
versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
versionLabel.BackgroundTransparency = 1
versionLabel.Position = UDim2.new(0, 100, 0, 5)
versionLabel.Size = UDim2.new(0, 200, 0, 30)
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Parent = topBar

-- Левая панель
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 140, 1, -40)
leftPanel.Position = UDim2.new(0, 0, 0, 40)
leftPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = frame

-- Разделы
local sections = {"Player", "World", "Other", "99 NTH"}
local activeTab = "Player"
local tabs = {}

local function createSection(name)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -140, 1, -40)
    container.Position = UDim2.new(0, 140, 0, 40)
    container.BackgroundTransparency = 1
    container.Visible = (name == "Player")
    container.Name = name
    container.Parent = frame
    tabs[name] = container
    return container
end

local playerTab = createSection("Player")
local worldTab = createSection("World")
local otherTab = createSection("Other")
local nthTab = createSection("99 NTH")

local function createSidebarButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.AutoButtonColor = false
    btn.Parent = leftPanel
    btn.ClipsDescendants = true

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 8)
    uicorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        activeTab = name
        for tabName, container in pairs(tabs) do
            container.Visible = (tabName == name)
        end
    end)
end

for i, name in ipairs(sections) do
    createSidebarButton(name, (i - 1) * 50 + 10)
end

-- Универсальные кнопки
local function createToggleButton(text, y, parent, stateGetter, toggleCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 20
    btn.Parent = parent
    btn.AutoButtonColor = false

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 6)
    uicorner.Parent = btn

    local function updateText()
        local state = stateGetter()
        local emoji = state and "✅ " or "❌ "
        btn.Text = emoji .. text
    end

    updateText()
    btn.MouseButton1Click:Connect(function()
        toggleCallback()
        updateText()
    end)
end

local function createButton(text, y, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 20
    btn.Parent = parent
    btn.AutoButtonColor = false
    btn.Text = text

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
end

-- ===========================
-- Player Tab
-- (твой код Jump Boost, Fly, Speed Boost, NoClip)
-- ===========================

--[тут вставь весь твой существующий код Player Tab без изменений]

-- ===========================
-- World Tab
-- (твой код WallHack, Create Part, AimBot)
-- ===========================

--[тут вставь весь твой существующий код World Tab без изменений]

-- ===========================
-- Other Tab
-- ===========================

local otherLabel = Instance.new("TextLabel")
otherLabel.Size = UDim2.new(1, -40, 0, 40)
otherLabel.Position = UDim2.new(0, 20, 0, 20)
otherLabel.BackgroundTransparency = 1
otherLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
otherLabel.Font = Enum.Font.SourceSans
otherLabel.TextSize = 20
otherLabel.Text = "Other cheats will come soon..."
otherLabel.Parent = otherTab

-- ===========================
-- 99 NTH Tab
-- ===========================

-- Изменение скорости бега
local runSpeed = 16
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 200, 0, 40)
speedBox.Position = UDim2.new(0, 20, 0, 10)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 120)
speedBox.BorderSizePixel = 0
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 20
speedBox.Text = tostring(runSpeed)
speedBox.Parent = nthTab

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedBox.Text)
        if val then
            runSpeed = val
            local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = runSpeed
            end
        else
            speedBox.Text = tostring(runSpeed)
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = runSpeed
end)

-- ESP сундуков
local chestEspEnabled = false
local chestEspBoxes = {}
local espColor = Color3.fromRGB(0, 255, 0)

createToggleButton("ESP Chests", 60, nthTab,
    function() return chestEspEnabled end,
    function()
        chestEspEnabled = not chestEspEnabled
        if chestEspEnabled then
            RunService:BindToRenderStep("ChestESP", 401, function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and string.find(string.lower(obj.Name), "chest") then
                        if obj.PrimaryPart == nil then
                            obj.PrimaryPart = obj:FindFirstChildWhichIsA("BasePart")
                        end
                        if obj.PrimaryPart and not chestEspBoxes[obj] then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Adornee = obj.PrimaryPart
                            box.AlwaysOnTop = true
                            box.Size = obj.PrimaryPart.Size + Vector3.new(1,1,1)
                            box.Transparency = 0.5
                            box.Color3 = espColor
                            box.Parent = player.PlayerGui
                            chestEspBoxes[obj] = box
                        end
                    end
                end
                for chest, box in pairs(chestEspBoxes) do
                    if not chest.Parent then
                        box:Destroy()
                        chestEspBoxes[chest] = nil
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("ChestESP")
            for _, box in pairs(chestEspBoxes) do
                box:Destroy()
            end
            chestEspBoxes = {}
        end
    end
)

-- Кнопки выбора цвета ESP
local colors = {Red=Color3.fromRGB(255,0,0), Green=Color3.fromRGB(0,255,0), Blue=Color3.fromRGB(0,128,255), Yellow=Color3.fromRGB(255,255,0)}
local yOffset = 110
for name, col in pairs(colors) do
    createButton("ESP Color: "..name, yOffset, nthTab, function()
        espColor = col
        for _, box in pairs(chestEspBoxes) do
            box.Color3 = espColor
        end
    end)
    yOffset = yOffset + 50
end

-- Увеличение голода
createButton("Increase Hunger", yOffset + 10, nthTab, function()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Hunger") then
        stats.Hunger.Value = stats.Hunger.Value + 10
    end
end)

-- ===========================
-- Клавиша Insert скрыть/показать
-- ===========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleGui()
    end
end)

frame.Visible = true
