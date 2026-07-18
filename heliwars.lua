--[[
    Heli Wars Premium Script v3.2 - MOBILE FLY
    Delta Executor (Android/iOS)
    Fly управляется джойстиком на экране!
--]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")

--// Настройки
local Settings = {
    SilentAimEnabled = false,
    TriggerBotEnabled = false,
    AimbotEnabled = false,
    ESPEnabled = false,
    FlyEnabled = false,
    FlySpeed = 30,
    NoclipEnabled = false,
    SpeedHackEnabled = false,
    AutoFarmEnabled = false,
    AntiAFKEnabled = true
}

--// Уведомления
local function Notify(title, message, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 3,
        })
    end)
end

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeliWarsMobile"
ScreenGui.Parent = game:GetService("CoreGui")

-- Главное меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Heli Wars | MOBILE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 25, 0, 25)
HideButton.Position = UDim2.new(1, -30, 0, 2.5)
HideButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
HideButton.BorderSizePixel = 0
HideButton.Text = "-"
HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideButton.TextSize = 18
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = TopBar

-- Кнопки функций
local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 55)
        btn.Text = text:gsub("%[.*%]", enabled and "[ON]" or "[OFF]")
        callback(enabled)
    end)
    
    return btn
end

CreateButton("Silent Aim [OFF]", 40, function(v) Settings.SilentAimEnabled = v; Notify("Silent Aim", v and "ON" or "OFF") end)
CreateButton("Trigger Bot [OFF]", 85, function(v) Settings.TriggerBotEnabled = v; Notify("Trigger Bot", v and "ON" or "OFF") end)
CreateButton("Aimbot [OFF]", 130, function(v) Settings.AimbotEnabled = v; Notify("Aimbot", v and "ON" or "OFF") end)
CreateButton("ESP [OFF]", 175, function(v) Settings.ESPEnabled = v; Notify("ESP", v and "ON" or "OFF") end)
CreateButton("FLY (джойстик) [OFF]", 220, function(v) Settings.FlyEnabled = v; FlyToggle(v); Notify("Fly", v and "ON (экранный джойстик)" or "OFF") end)
CreateButton("Noclip [OFF]", 265, function(v) Settings.NoclipEnabled = v; Notify("Noclip", v and "ON" or "OFF") end)
CreateButton("Speed Hack [OFF]", 310, function(v) Settings.SpeedHackEnabled = v; Notify("Speed Hack", v and "ON" or "OFF") end)
CreateButton("Auto Farm [OFF]", 355, function(v) Settings.AutoFarmEnabled = v; Notify("Auto Farm", v and "ON" or "OFF") end)

-- Перетаскивание меню
local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    dragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Hide/Show кнопка
local minimized = false
HideButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child ~= TopBar then
            child.Visible = not minimized
        end
    end
    MainFrame.Size = minimized and UDim2.new(0, 300, 0, 30) or UDim2.new(0, 300, 0, 400)
end)

-- =============================================
-- 📱 МОБИЛЬНЫЙ FLY ДЖОЙСТИК
-- =============================================
local FlyJoystick = Instance.new("Frame")
FlyJoystick.Size = UDim2.new(0, 150, 0, 150)
FlyJoystick.Position = UDim2.new(0.15, 0, 0.7, 0)
FlyJoystick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyJoystick.BackgroundTransparency = 0.85
FlyJoystick.BorderSizePixel = 0
FlyJoystick.Visible = false
FlyJoystick.Parent = ScreenGui

local FlyJoystickCorner = Instance.new("UICorner")
FlyJoystickCorner.CornerRadius = UDim.new(1, 0)
FlyJoystickCorner.Parent = FlyJoystick

local FlyStick = Instance.new("Frame")
FlyStick.Size = UDim2.new(0, 60, 0, 60)
FlyStick.Position = UDim2.new(0.5, -30, 0.5, -30)
FlyStick.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FlyStick.BackgroundTransparency = 0.3
FlyStick.BorderSizePixel = 0
FlyStick.Parent = FlyJoystick

local FlyStickCorner = Instance.new("UICorner")
FlyStickCorner.CornerRadius = UDim.new(1, 0)
FlyStickCorner.Parent = FlyStick

-- Надпись на джойстике
local FlyLabel = Instance.new("TextLabel")
FlyLabel.Size = UDim2.new(1, 0, 0, 20)
FlyLabel.Position = UDim2.new(0, 0, 0, -25)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Text = "FLY"
FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLabel.TextSize = 14
FlyLabel.Font = Enum.Font.GothamBold
FlyLabel.Parent = FlyJoystick

-- Переменные джойстика
local flyInputActive = false
local flyInputConnection = nil
local flyMoveConnection = nil
local flyBodyGyro = nil
local flyBodyVelocity = nil

local function FlyToggle(enabled)
    Settings.FlyEnabled = enabled
    FlyJoystick.Visible = enabled
    
    if not enabled then
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
        if flyInputConnection then flyInputConnection:Disconnect(); flyInputConnection = nil end
        if flyMoveConnection then flyMoveConnection:Disconnect(); flyMoveConnection = nil end
        
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    else
        -- Активируем управление джойстиком
        flyInputConnection = FlyJoystick.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                flyInputActive = true
            end
        end)
        
        FlyJoystick.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                flyInputActive = false
                FlyStick:TweenPosition(UDim2.new(0.5, -30, 0.5, -30), "Out", "Sine", 0.1)
            end
        end)
        
        flyMoveConnection = FlyJoystick.InputChanged:Connect(function(input)
            if flyInputActive and input.UserInputType == Enum.UserInputType.Touch then
                local joystickCenter = FlyJoystick.AbsolutePosition + FlyJoystick.AbsoluteSize / 2
                local touchPos = input.Position
                local delta = touchPos - joystickCenter
                local maxRadius = FlyJoystick.AbsoluteSize.X / 2 - FlyStick.AbsoluteSize.X / 2
                
                if delta.Magnitude > maxRadius then
                    delta = delta.Unit * maxRadius
                end
                
                FlyStick.Position = UDim2.new(0, delta.X + FlyJoystick.AbsoluteSize.X/2 - FlyStick.AbsoluteSize.X/2, 0, delta.Y + FlyJoystick.AbsoluteSize.Y/2 - FlyStick.AbsoluteSize.Y/2)
            end
        end)
    end
end

-- Fly система с джойстиком
RunService.Heartbeat:Connect(function()
    if Settings.FlyEnabled and LocalPlayer.Character and flyInputActive then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            if not flyBodyGyro then
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                flyBodyGyro.Parent = rootPart
            end
            if not flyBodyVelocity then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
                flyBodyVelocity.Parent = rootPart
            end
            
            flyBodyGyro.CFrame = Camera.CFrame
            
            -- Направление от центра джойстика
            local joystickCenter = FlyJoystick.AbsolutePosition + FlyJoystick.AbsoluteSize / 2
            local stickCenter = FlyStick.AbsolutePosition + FlyStick.AbsoluteSize / 2
            local delta = stickCenter - joystickCenter
            local maxRadius = FlyJoystick.AbsoluteSize.X / 2
            
            local moveDirection = Vector3.zero
            if delta.Magnitude > 5 then
                local normalizedDelta = delta / maxRadius
                moveDirection = Camera.CFrame.RightVector * normalizedDelta.X + Camera.CFrame.LookVector * (-normalizedDelta.Y)
            end
            
            flyBodyVelocity.Velocity = moveDirection.Magnitude > 0 and moveDirection.Unit * Settings.FlySpeed or Vector3.zero
            
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = true end
        end
    elseif Settings.FlyEnabled and LocalPlayer.Character and not flyInputActive then
        if flyBodyVelocity then
            flyBodyVelocity.Velocity = Vector3.zero
        end
    elseif not Settings.FlyEnabled then
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    end
end)

-- Кнопки вверх/вниз для Fly (по бокам от джойстика)
local FlyUpButton = Instance.new("TextButton")
FlyUpButton.Size = UDim2.new(0, 50, 0, 50)
FlyUpButton.Position = UDim2.new(0.35, 0, 0.65, 0)
FlyUpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FlyUpButton.BackgroundTransparency = 0.5
FlyUpButton.BorderSizePixel = 0
FlyUpButton.Text = "⬆"
FlyUpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyUpButton.TextSize = 24
FlyUpButton.Font = Enum.Font.GothamBold
FlyUpButton.Visible = false
FlyUpButton.Parent = ScreenGui

local FlyUpCorner = Instance.new("UICorner")
FlyUpCorner.CornerRadius = UDim.new(1, 0)
FlyUpCorner.Parent = FlyUpButton

local FlyDownButton = Instance.new("TextButton")
FlyDownButton.Size = UDim2.new(0, 50, 0, 50)
FlyDownButton.Position = UDim2.new(0.35, 0, 0.8, 0)
FlyDownButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FlyDownButton.BackgroundTransparency = 0.5
FlyDownButton.BorderSizePixel = 0
FlyDownButton.Text = "⬇"
FlyDownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyDownButton.TextSize = 24
FlyDownButton.Font = Enum.Font.GothamBold
FlyDownButton.Visible = false
FlyDownButton.Parent = ScreenGui

local FlyDownCorner = Instance.new("UICorner")
FlyDownCorner.CornerRadius = UDim.new(1, 0)
FlyDownCorner.Parent = FlyDownButton

-- Подключаем кнопки вверх/вниз к Fly системе
local flyUpActive = false
local flyDownActive = false

FlyUpButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        flyUpActive = true
    end
end)
FlyUpButton.InputEnded:Connect(function(input)
    flyUpActive = false
end)

FlyDownButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        flyDownActive = true
    end
end)
FlyDownButton.InputEnded:Connect(function(input)
    flyDownActive = false
end)

-- Обновляем видимость кнопок вверх/вниз вместе с джойстиком
local function UpdateFlyButtons()
    FlyUpButton.Visible = Settings.FlyEnabled
    FlyDownButton.Visible = Settings.FlyEnabled
end

-- Переопределяем FlyToggle для включения кнопок
local oldFlyToggle = FlyToggle
FlyToggle = function(enabled)
    oldFlyToggle(enabled)
    UpdateFlyButtons()
end

-- Добавляем вертикальное движение в Fly систему
local oldHeartbeat = RunService.Heartbeat
RunService.Heartbeat:Connect(function()
    if Settings.FlyEnabled and LocalPlayer.Character and flyBodyVelocity then
        local verticalMove = 0
        if flyUpActive then verticalMove = verticalMove + 1 end
        if flyDownActive then verticalMove = verticalMove - 1 end
        
        if verticalMove ~= 0 then
            flyBodyVelocity.Velocity = flyBodyVelocity.Velocity + Vector3.new(0, verticalMove * Settings.FlySpeed, 0)
        end
    end
end)

-- =============================================
-- SILENT AIM
-- =============================================
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if self == Mouse and key == "Hit" and Settings.SilentAimEnabled then
        local target = nil
        local closestDist = 200
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if player.Team == LocalPlayer.Team then continue end
                
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - (Camera.ViewportSize / 2)).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            target = head.Position
                        end
                    end
                end
            end
        end
        
        if target then
            return target
        end
    end
    return oldIndex(self, key)
end)

-- =============================================
-- TRIGGER BOT
-- =============================================
RunService.Heartbeat:Connect(function()
    if Settings.TriggerBotEnabled and Settings.SilentAimEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - (Camera.ViewportSize / 2)).Magnitude
                        if dist < 200 then
                            mouse1press()
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- =============================================
-- NOCLIP
-- =============================================
RunService.Stepped:Connect(function()
    if Settings.NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- =============================================
-- SPEED HACK
-- =============================================
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.SpeedHackEnabled and 40 or 16
        end
    end
end)

-- =============================================
-- ANTI-AFK
-- =============================================
local VirtualUser = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if Settings.AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- =============================================
-- ESP
-- =============================================
RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not head or not humanoid or humanoid.Health <= 0 or not rootPart then continue end
        
        local headPos = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos = Camera:WorldToScreenPoint(rootPart.Position)
        
        if not rootPos.Z then continue end
        
        local isTeam = player.Team == LocalPlayer.Team
        local color = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        local boxHeight = math.abs(rootPos.Y - headPos.Y)
        local boxWidth = boxHeight * 0.4
        
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
        box.Position = UDim2.new(0, headPos.X - boxWidth/2, 0, headPos.Y)
        box.BackgroundTransparency = 0.8
        box.BorderSizePixel = 2
        box.BorderColor3 = color
        box.Parent = ScreenGui
        game:GetService("Debris"):AddItem(box, 0.05)
        
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0, 100, 0, 20)
        name.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y - 25)
        name.BackgroundTransparency = 1
        name.Text = player.Name
        name.TextColor3 = color
        name.TextSize = 12
        name.Font = Enum.Font.Gotham
        name.Parent = ScreenGui
        game:GetService("Debris"):AddItem(name, 0.05)
    end
end)

-- =============================================
-- AUTO FARM
-- =============================================
RunService.Heartbeat:Connect(function()
    if not Settings.AutoFarmEnabled or not LocalPlayer.Character then return end
    
    local nearestEnemy = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = LocalPlayer.Character:FindFirstChild("H