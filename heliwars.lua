--[[
    Heli Wars Premium Script v3.1 - Delta Fix
    Optimized for Delta Executor (No Drawing API)
--]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

--// Настройки
local Settings = {
    SilentAimEnabled = false,
    SilentAimSmoothness = 0.5,
    SilentAimFOV = 100,
    SilentAimFOVEnabled = true,
    SilentAimAimPart = "Head",
    SilentAimPrediction = 0.1,
    SilentAimTeamCheck = true,
    SilentAimWallCheck = true,
    TriggerBotEnabled = false,
    AimbotEnabled = false,
    AimbotSmoothness = 0.3,
    AimbotFOV = 100,
    AimbotAimPart = "Head",
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPWeapon = true,
    ESPTeamColor = true,
    TracersEnabled = false,
    HeadDotsEnabled = false,
    FlyEnabled = false,
    FlySpeed = 20,
    NoclipEnabled = false,
    InfiniteJumpEnabled = false,
    SpeedHackEnabled = false,
    SpeedHackValue = 30,
    JumpPowerEnabled = false,
    JumpPowerValue = 70,
    AntiAFKEnabled = true,
    AutoFarmEnabled = false,
    MenuHidden = false
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

--// GUI (всё через ScreenGui, без Drawing API)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeliWarsPremium"
ScreenGui.Parent = game:GetService("CoreGui")

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
Title.Text = "Heli Wars Premium | Delta"
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

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 4)
UICorner2.Parent = HideButton

-- FOV Circle (делаем через Frame!)
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, 200, 0, 200)
FOVCircle.Position = UDim2.new(0.5, -100, 0.5, -100)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVRing = Instance.new("Frame")
FOVRing.Size = UDim2.new(1, 0, 1, 0)
FOVRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVRing.BackgroundTransparency = 0.8
FOVRing.BorderSizePixel = 2
FOVRing.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVRing.Parent = FOVCircle

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(1, 0)
UICorner3.Parent = FOVRing

-- Кнопки функций (компактный вид)
local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 55)
        callback(enabled)
    end)
    
    return btn
end

-- Создаём кнопки
CreateButton("Silent Aim [OFF]", 40, function(val)
    Settings.SilentAimEnabled = val
    Notify("Silent Aim", val and "ON" or "OFF")
end)

CreateButton("Trigger Bot [OFF]", 80, function(val)
    Settings.TriggerBotEnabled = val
    Notify("Trigger Bot", val and "ON" or "OFF")
end)

CreateButton("Aimbot [OFF]", 120, function(val)
    Settings.AimbotEnabled = val
    Notify("Aimbot", val and "ON" or "OFF")
end)

CreateButton("ESP [OFF]", 160, function(val)
    Settings.ESPEnabled = val
    Notify("ESP", val and "ON" or "OFF")
end)

CreateButton("FOV Circle [OFF]", 200, function(val)
    Settings.SilentAimFOVEnabled = val
    FOVCircle.Visible = val
end)

CreateButton("Fly [OFF]", 240, function(val)
    Settings.FlyEnabled = val
    Notify("Fly", val and "ON" or "OFF")
end)

CreateButton("Noclip [OFF]", 280, function(val)
    Settings.NoclipEnabled = val
    Notify("Noclip", val and "ON" or "OFF")
end)

CreateButton("Speed Hack [OFF]", 320, function(val)
    Settings.SpeedHackEnabled = val
    Notify("Speed Hack", val and "ON" or "OFF")
end)

CreateButton("Auto Farm [OFF]", 360, function(val)
    Settings.AutoFarmEnabled = val
    Notify("Auto Farm", val and "ON" or "OFF")
end)

-- Перетаскивание меню
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    dragging = false
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Hide/Show
local minimized = false
HideButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for i, child in ipairs(MainFrame:GetChildren()) do
        if child ~= TopBar then
            child.Visible = not minimized
        end
    end
    MainFrame.Size = minimized and UDim2.new(0, 300, 0, 30) or UDim2.new(0, 300, 0, 400)
end)

-- FOV Circle обновление
RunService.RenderStepped:Connect(function()
    if Settings.SilentAimFOVEnabled then
        local fov = Settings.SilentAimFOV
        FOVRing.Size = UDim2.new(0, fov * 2, 0, fov * 2)
        FOVRing.Position = UDim2.new(0.5, -fov, 0.5, -fov)
    end
end)

-- Silent Aim
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if self == Mouse and key == "Hit" and Settings.SilentAimEnabled then
        local target = nil
        local closestDist = Settings.SilentAimFOV
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if Settings.SilentAimTeamCheck and player.Team == LocalPlayer.Team then continue end
                
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

-- Trigger Bot
RunService.Heartbeat:Connect(function()
    if Settings.TriggerBotEnabled and Settings.SilentAimEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - (Camera.ViewportSize / 2)).Magnitude
                        if dist < Settings.SilentAimFOV then
                            mouse1press()
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Fly
local flyBodyGyro, flyBodyVelocity
RunService.Heartbeat:Connect(function()
    if Settings.FlyEnabled and LocalPlayer.Character then
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
            
            local moveDirection = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            
            flyBodyVelocity.Velocity = moveDirection.Magnitude > 0 and moveDirection.Unit * Settings.FlySpeed or Vector3.zero
            
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = true end
        end
    else
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Settings.NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.SpeedHackEnabled and Settings.SpeedHackValue or 16
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if Settings.AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            -- ESP обновление будет в RenderStepped
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not head or not humanoid or humanoid.Health <= 0 or not rootPart then continue end
        
        local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
        local rootPos, rootOnScreen = Camera:WorldToScreenPoint(rootPart.Position)
        
        if not rootOnScreen then continue end
        
        local isTeam = player.Team == LocalPlayer.Team
        local color = isTeam and Color3.fromRGB(0, 255, 0) : Color3.fromRGB(255, 0, 0)
        
        -- Box
        if Settings.ESPBoxes then
            local boxHeight = math.abs(rootPos.Y - headPos.Y)
            local boxWidth = boxHeight * 0.4
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
            box.Position = UDim2.new(0, headPos.X - boxWidth/2, 0, headPos.Y)
            box.BackgroundTransparency = 0.8
            box.BorderSizePixel = 2
            box.BorderColor3 = color
            box.Parent = ScreenGui
            game.Debris:AddItem(box, 0.1)
        end
        
        -- Name
        if Settings.ESPNames and headOnScreen then
            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(0, 100, 0, 20)
            name.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y - 25)
            name.BackgroundTransparency = 1
            name.Text = player.Name
            name.TextColor3 = color
            name.TextSize = 12
            name.Font = Enum.Font.Gotham
            name.Parent = ScreenGui
            game.Debris:AddItem(name, 0.1)
        end
        
        -- Distance
        if Settings.ESPDistance and LocalPlayer.Character then
            local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local distance = math.floor((rootPart.Position - localRoot.Position).Magnitude)
                local distLabel = Instance.new("TextLabel")
                distLabel.Size = UDim2.new(0, 100, 0, 20)
                distLabel.Position = UDim2.new(0, rootPos.X - 50, 0, rootPos.Y + 10)
                distLabel.BackgroundTransparency = 1
                distLabel.Text = distance .. "m"
                distLabel.TextColor3 = color
                distLabel.TextSize = 12
                distLabel.Font = Enum.Font.Gotham
                distLabel.Parent = ScreenGui
                game.Debris:AddItem(distLabel, 0.1)
            end
        end
        
        -- Tracers
        if Settings.TracersEnabled then
            local line = Instance.new("Frame")
            local screenCenter = Camera.ViewportSize / 2
            local startPos = Vector2.new(screenCenter.X, screenCenter.Y)
            local endPos = Vector2.new(rootPos.X, rootPos.Y)
            local length = (endPos - startPos).Magnitude
            local angle = math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X)
            
            line.Size = UDim2.new(0, length, 0, 1)
            line.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
            line.Rotation = math.deg(angle)
            line.BackgroundColor3 = color
            line.BorderSizePixel = 0
            line.Parent = ScreenGui
            game.Debris:AddItem(line, 0.1)
        end
    end
end)

-- Auto Farm
RunService.Heartbeat:Connect(function()
    if not Settings.AutoFarmEnabled then return end
    
    local nearestEnemy = nil
    local nearestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if rootPart and localRoot then
                local dist = (rootPart.Position - localRoot.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestEnemy = player
                end
            end
        end
    end
    
    if nearestEnemy and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:MoveTo(nearestEnemy.Character.HumanoidRootPart.Position)
        end
    end
end)

Notify("Heli Wars Premium", "Загружено! v3.1 Delta Fix", 5)
Notify("Функции", "Silent Aim | ESP | Fly | Noclip | Auto Farm", 5)

print("Heli Wars Premium v3.1 - Загружен!")