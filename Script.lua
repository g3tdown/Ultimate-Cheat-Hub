local oldGui = game.CoreGui:FindFirstChild("CheatMenu")
if oldGui then oldGui:Destroy() end


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

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 140, 1, -40)
leftPanel.Position = UDim2.new(0, 0, 0, 40)
leftPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = frame

local sections = {"Player", "World", "Other"}
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

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 6)
    uicorner.Parent = btn

    btn.Text = text

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
end

-- ===========================
-- Player Tab
-- ===========================

-- Jump Boost
local jumpBoostEnabled = false
local jumpPowerDefault = 50
local jumpPowerBoost = 100

local function updateJumpPower()
    local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.JumpPower = jumpBoostEnabled and jumpPowerBoost or jumpPowerDefault
    end
end

createToggleButton("Jump Boost", 10, playerTab,
    function() return jumpBoostEnabled end,
    function()
        jumpBoostEnabled = not jumpBoostEnabled
        updateJumpPower()
    end
)

-- Fly
local flying = false
local flightSpeed = 50
local bodyVelocity, bodyGyro

createToggleButton("Fly", 60, playerTab,
    function() return flying end,
    function()
        flying = not flying
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if flying then
            if rootPart then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVelocity.Velocity = Vector3.new(0,0,0)
                bodyVelocity.Parent = rootPart

                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bodyGyro.CFrame = rootPart.CFrame
                bodyGyro.Parent = rootPart

                humanoid.PlatformStand = true

                RunService:BindToRenderStep("Fly", 201, function()
                    if not flying or not rootPart then return end
                    local direction = Vector3.new(0,0,0)

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + workspace.CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - workspace.CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - workspace.CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + workspace.CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        direction = direction + Vector3.new(0,1,0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        direction = direction - Vector3.new(0,1,0)
                    end

                    if direction.Magnitude > 0 then
                        direction = direction.Unit * flightSpeed
                    end

                    bodyVelocity.Velocity = direction
                    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                end)
            end
        else
            RunService:UnbindFromRenderStep("Fly")
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            if bodyGyro then
                bodyGyro:Destroy()
                bodyGyro = nil
            end
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
)

-- Speed Boost
local speedBoostEnabled = false
local speedDefault = 16
local speedBoostValue = 50

local function updateSpeed()
    local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedBoostEnabled and speedBoostValue or speedDefault
    end
end

createToggleButton("Speed Boost", 110, playerTab,
    function() return speedBoostEnabled end,
    function()
        speedBoostEnabled = not speedBoostEnabled
        updateSpeed()
    end
)

-- NoClip
local noclipEnabled = false
local noclipConnection

local function setNoClip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

createToggleButton("NoClip", 160, playerTab,
    function() return noclipEnabled end,
    function()
        noclipEnabled = not noclipEnabled
        setNoClip(noclipEnabled)
    end
)

-- Aimbot
local aimbotEnabled = false
local aimbotFOV = 80
local aimbotSensitivity = 0.3

local function getClosestTarget()
    local closest = nil
    local closestDist = math.huge
    local camera = workspace.CurrentCamera
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = Vector2.new(mouse.X, mouse.Y)
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (targetPos - mousePos).Magnitude
                    if dist < aimbotFOV and dist < closestDist then
                        closestDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local aimbotConnection

createToggleButton("Aimbot", 210, playerTab,
    function() return aimbotEnabled end,
    function()
        aimbotEnabled = not aimbotEnabled
        if aimbotEnabled then
            aimbotConnection = RunService.RenderStepped:Connect(function()
                local target = getClosestTarget()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    local camera = workspace.CurrentCamera
                    local headPos = target.Character.Head.Position
                    local direction = (headPos - camera.CFrame.Position).Unit
                    local targetCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
                    -- Плавный поворот камеры к цели
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimbotSensitivity)
                end
            end)
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
        end
    end
)

-- Box ESP
local espEnabled = false
local espBoxes = {}

local function createBox(part)
    local adornment = Instance.new("BoxHandleAdornment")
    adornment.Adornee = part
    adornment.AlwaysOnTop = true
    adornment.ZIndex = 10
    adornment.Size = part.Size
    adornment.Color3 = Color3.new(1, 0, 0)
    adornment.Transparency = 0.5
    adornment.Parent = game.CoreGui  -- <<<< ИЗМЕНЕНО: Кладем в CoreGui, не в PlayerGui
    return adornment
end

local function updateESP()
    for plr, box in pairs(espBoxes) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Adornee = plr.Character.HumanoidRootPart
            box.Size = plr.Character.HumanoidRootPart.Size
            box.Transparency = 0.5
        else
            box:Destroy()
            espBoxes[plr] = nil
        end
    end
end

local function toggleESP(state)
    if state then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not espBoxes[plr] then
                    espBoxes[plr] = createBox(plr.Character.HumanoidRootPart)
                end
            end
        end
        game:GetService("RunService").RenderStepped:Connect(updateESP)
        Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function(character)
                wait(1)
                if espEnabled and character:FindFirstChild("HumanoidRootPart") then
                    espBoxes[plr] = createBox(character.HumanoidRootPart)
                end
            end)
        end)
    else
        for _, box in pairs(espBoxes) do
            box:Destroy()
        end
        espBoxes = {}
    end
end

createToggleButton("Box ESP", 260, playerTab,
    function() return espEnabled end,
    function()
        espEnabled = not espEnabled
        toggleESP(espEnabled)
    end
)

-- Auto Respawn
local autoRespawnEnabled = false

createToggleButton("Auto Respawn", 310, otherTab,
    function() return autoRespawnEnabled end,
    function()
        autoRespawnEnabled = not autoRespawnEnabled
    end
)

local function respawnPlayer()
    if player.Character then
        player.Character:BreakJoints()
    end
end

-- Check for death and respawn
spawn(function()
    while true do
        wait(1)
        if autoRespawnEnabled then
            if player.Character then
                local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
                if humanoid and humanoid.Health <= 0 then
                    respawnPlayer()
                end
            end
        end
    end
end)

-- Обработка смены персонажа
local function onCharacterAdded(char)
    updateJumpPower()
    updateSpeed()
    setNoClip(noclipEnabled)
end

player.CharacterAdded:Connect(onCharacterAdded)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleGui()
        end
    end
end)
