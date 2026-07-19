--[[
    Heli Wars - Advanced Silent Aim + Combat System v2.0
    Optimized for Delta Executor (Mobile)
    Focus: Vehicle tracking, team detection, stability
    No Drawing API - pure ScreenGui
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    -- Silent Aim
    SilentAimEnabled = false,
    FOV = 250,                  -- 40 to 360
    FOVVisible = true,
    MaxDistance = 1000,         -- Max studs
    Smoothness = 0.4,           -- 0.1 smooth, 1 instant
    Prediction = 0.15,          -- Velocity multiplier
    AimPart = "Head",           -- Head / UpperTorso / HumanoidRootPart / Auto
    TeamCheck = true,
    WallCheck = true,
    TriggerBot = false,
    VehiclePriority = true,     -- Shoot vehicle instead of player inside
    
    -- Misc
    Noclip = false,
    SpeedHack = false,
    AntiAFK = true
}

-- Utility: Notification
local function Notify(title, msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = msg,
            Duration = 3
        })
    end)
end

-- Utility: Team Detection
local function GetPlayerTeam(player)
    local char = player.Character
    if not char then return nil end
    
    -- Method 1: Roblox Team
    if player.Team then
        local color = player.Team.TeamColor.Color
        -- Desert Team (sand/beige)
        if color.r > 0.7 and color.g > 0.6 and color.b < 0.5 then return "Desert" end
        -- Green Team
        if color.g > 0.8 and color.r < 0.5 then return "Green" end
        -- Jungle Team (dark green)
        if color.g > 0.3 and color.g < 0.6 and color.r < 0.3 then return "Jungle" end
    end
    
    -- Method 2: Body parts color
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.BrickColor then
                local c = part.BrickColor.Color
                if c.r > 0.7 and c.g > 0.6 then return "Desert" end
                if c.g > 0.7 and c.r < 0.4 then return "Green" end
                if c.g > 0.2 and c.g < 0.5 and c.r < 0.3 then return "Jungle" end
            end
        end
    end
    
    return "Unknown"
end

-- Utility: Check if player is in vehicle
local function GetVehicle(player)
    local char = player.Character
    if not char then return nil end
    
    -- Check if sitting in VehicleSeat
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Sit then
        -- Find the seat they're sitting in
        for _, seat in ipairs(Workspace:GetDescendants()) do
            if seat:IsA("VehicleSeat") and seat.Occupant then
                local occupant = seat.Occupant.Parent
                if occupant == char then
                    return seat.Parent -- Return the vehicle model
                end
            end
        end
    end
    
    -- Check if character parent is a vehicle model
    if char.Parent and char.Parent ~= Workspace then
        local parent = char.Parent
        if parent:IsA("Model") and parent:FindFirstChildOfClass("VehicleSeat") then
            return parent
        end
    end
    
    return nil
end

-- Utility: Get best target part (handles vehicles)
local function GetTargetPart(player)
    local char = player.Character
    if not char then return nil end
    
    local vehicle = GetVehicle(player)
    
    if vehicle and Settings.VehiclePriority then
        -- Target the vehicle's primary part or largest part
        local target = vehicle.PrimaryPart
        if not target then
            -- Find largest part
            local maxSize = 0
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") and part.Size.Magnitude > maxSize then
                    maxSize = part.Size.Magnitude
                    target = part
                end
            end
        end
        
        -- If still no target, use player's root as fallback
        if not target then
            target = char:FindFirstChild("HumanoidRootPart")
        end
        
        return target, true -- true = is vehicle target
    end
    
    -- Standard aim parts for infantry
    local partName = Settings.AimPart
    if partName == "Auto" then
        -- Auto: prefer Head, fallback to Torso
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart"), false
    else
        return char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart"), false
    end
end

-- Utility: Wall Check (Raycast)
local function IsVisible(targetPos)
    if not Settings.WallCheck then return true end
    if not LocalPlayer.Character then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit * Settings.MaxDistance
    
    local ray = Ray.new(origin, direction)
    local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    
    -- If ray hits nothing or hits the target, it's visible
    if not hit then return true end
    
    -- Check if hit is part of the target's character or vehicle
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and hit:IsDescendantOf(player.Character) then
            return true
        end
        local vehicle = GetVehicle(player)
        if vehicle and hit:IsDescendantOf(vehicle) then
            return true
        end
    end
    
    return false
end

-- Core: Get Best Target
local function GetBestTarget()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local screenCenter = Camera.ViewportSize / 2
    local bestTarget = nil
    local bestScore = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        -- Team Check
        if Settings.TeamCheck then
            local myTeam = GetPlayerTeam(LocalPlayer)
            local theirTeam = GetPlayerTeam(player)
            if myTeam and theirTeam and myTeam == theirTeam then
                continue
            end
        end
        
        -- Health Check
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        -- Get target part
        local targetPart, isVehicle = GetTargetPart(player)
        if not targetPart then continue end
        
        -- Distance Check
        local distance = (targetPart.Position - myRoot.Position).Magnitude
        if distance > Settings.MaxDistance then continue end
        
        -- Prediction
        local velocity = targetPart.Velocity
        if isVehicle then
            -- Higher prediction for vehicles (they move faster)
            velocity = velocity * 1.5
        end
        local predictedPos = targetPart.Position + velocity * Settings.Prediction
        
        -- FOV Check
        local screenPos, onScreen = Camera:WorldToScreenPoint(predictedPos)
        if not onScreen then continue end
        
        local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distFromCenter > Settings.FOV then continue end
        
        -- Wall Check
        if not IsVisible(predictedPos) then continue end
        
        -- Score calculation (prioritize closer targets)
        local score = distance + distFromCenter * 0.5
        
        if score < bestScore then
            bestScore = score
            bestTarget = {
                Player = player,
                Part = targetPart,
                Position = predictedPos,
                IsVehicle = isVehicle,
                ScreenPos = screenPos,
                Distance = distance
            }
        end
    end
    
    return bestTarget
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeliWarsCombat"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 460)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Heli Wars Combat v2"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

-- FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, 500, 0, 500)
FOVCircle.Position = UDim2.new(0.5, -250, 0.5, -250)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 2
FOVCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

-- Scrollable content area
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ContentFrame.Parent = MainFrame

-- Button creation function
local yOffset = 10
local function CreateToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40, 40, 55)
    btn.BorderSizePixel = 0
    btn.Text = name .. (default and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(40, 40, 55)
        btn.Text = name .. (enabled and " [ON]" or " [OFF]")
        callback(enabled)
    end)
    
    yOffset = yOffset + 42
    return btn
end

local function CreateSlider(name, min, max, default, callback)
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yOffset)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.Parent = ContentFrame
    yOffset = yOffset + 22
    
    -- Slider button
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, -20, 0, 30)
    slider.Position = UDim2.new(0, 10, 0, yOffset)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = slider
    
    -- Fill bar
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition.X
            local sliderWidth = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = name .. ": " .. tostring(value)
            callback(value)
        end
    end)
    
    yOffset = yOffset + 35
    return slider
end

-- Create UI elements
CreateToggle("🎯 Silent Aim", false, function(v)
    Settings.SilentAimEnabled = v
    FOVCircle.Visible = v and Settings.FOVVisible
    Notify("Silent Aim", v and "Enabled" or "Disabled")
end)

CreateToggle("👁️ FOV Circle", true, function(v)
    Settings.FOVVisible = v
    FOVCircle.Visible = v and Settings.SilentAimEnabled
end)

CreateSlider("FOV Size", 40, 360, 250, function(v) Settings.FOV = v end)
CreateSlider("Max Distance", 200, 2000, 1000, function(v) Settings.MaxDistance = v end)
CreateSlider("Smoothness", 0.1, 1, 0.4, function(v) Settings.Smoothness = v end)
CreateSlider("Prediction", 0, 0.5, 0.15, function(v) Settings.Prediction = v end)

-- Aim Part dropdown
local aimParts = {"Head", "UpperTorso", "HumanoidRootPart", "Auto"}
local aimPartIdx = 1
local AimPartBtn = Instance.new("TextButton")
AimPartBtn.Size = UDim2.new(1, -20, 0, 38)
AimPartBtn.Position = UDim2.new(0, 10, 0, yOffset)
AimPartBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
AimPartBtn.BorderSizePixel = 0
AimPartBtn.Text = "Aim Part: Head"
AimPartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimPartBtn.TextSize = 13
AimPartBtn.Font = Enum.Font.Gotham
AimPartBtn.Parent = ContentFrame
Instance.new("UICorner", AimPartBtn).CornerRadius = UDim.new(0, 6)
AimPartBtn.MouseButton1Click:Connect(function()
    aimPartIdx = aimPartIdx % #aimParts + 1
    Settings.AimPart = aimParts[aimPartIdx]
    AimPartBtn.Text = "Aim Part: " .. Settings.AimPart
end)
yOffset = yOffset + 42

CreateToggle("🛡️ Team Check", true, function(v) Settings.TeamCheck = v end)
CreateToggle("🧱 Wall Check", true, function(v) Settings.WallCheck = v end)
CreateToggle("🔫 Trigger Bot", false, function(v) Settings.TriggerBot = v end)
CreateToggle("🚁 Vehicle Priority", true, function(v) Settings.VehiclePriority = v end)

yOffset = yOffset + 5

CreateToggle("👻 Noclip", false, function(v) Settings.Noclip = v end)
CreateToggle("⚡ Speed Hack", false, function(v) Settings.SpeedHack = v end)

-- Update content size
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)

-- Drag functionality
local dragMain, startPos, startGui = false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragMain = true
        startPos = input.Position
        startGui = MainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function() dragMain = false end)
UserInputService.InputChanged:Connect(function(input)
    if dragMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startPos
        MainFrame.Position = UDim2.new(startGui.X.Scale, startGui.X.Offset + delta.X, startGui.Y.Scale, startGui.Y.Offset + delta.Y)
    end
end)

-- Main Aimbot Loop
local UserInput = game:GetService("VirtualInputManager")

RunService.RenderStepped:Connect(function(deltaTime)
    -- Update FOV circle
    if Settings.FOVVisible and Settings.SilentAimEnabled then
        FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
    end
    
    if not Settings.SilentAimEnabled then return end
    
    local target = GetBestTarget()
    if not target then return end
    
    -- Calculate mouse movement
    local screenPos = Camera:WorldToScreenPoint(target.Position)
    local center = Camera.ViewportSize / 2
    
    local moveX = screenPos.X - center.X
    local moveY = screenPos.Y - center.Y
    
    -- Apply smoothness
    local smoothFactor = 1 - Settings.Smoothness
    moveX = moveX * smoothFactor
    moveY = moveY * smoothFactor
    
    -- Clamp for stability
    moveX = math.clamp(moveX, -60, 60)
    moveY = math.clamp(moveY, -60, 60)
    
    -- Move mouse
    UserInput:SendMouseMoveEvent(Vector2.new(moveX, moveY), false)
end)

-- Trigger Bot
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBot or not Settings.SilentAimEnabled then return end
    
    local target = GetBestTarget()
    if not target then return end
    
    -- Check if target is near center of screen
    local dist = (target.ScreenPos - Camera.ViewportSize / 2).Magnitude
    if dist < 50 then
        -- Check weapon ammo
        local canShoot = true
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount") or tool:FindFirstChild("Magazine")
                if ammo and ammo:IsA("IntValue") and ammo.Value <= 0 then
                    canShoot = false
                end
            end
        end
        
        if canShoot then
            mouse1press()
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not Settings.Noclip or not LocalPlayer.Character then return end
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.SpeedHack and 50 or 16
        end
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

Notify("Heli Wars Combat v2.0", "Silent Aim + Vehicle System", 5)
Notify("Features", "FOV | TeamCheck | WallCheck | Vehicle Priority", 5)