-- Минимальная версия для Delta
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")

-- Настройки
local SilentAim = false
local TriggerBot = false
local ESP = false
local Fly = false
local Noclip = false
local SpeedHack = false
local AntiAFK = true
local AutoFarm = false

-- Уведомление
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Heli Wars",
    Text = "Скрипт загружен!",
    Duration = 5
})

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeliWars"
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 350)
Main.Position = UDim2.new(0.5, -140, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Heli Wars"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

-- Функция создания кнопок
local y = 40
local function AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = Main
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 65)
        btn.Text = text:gsub("%[.*%]", enabled and "[ON]" or "[OFF]")
        callback(enabled)
    end)
    
    y = y + 40
    return btn
end

AddButton("Silent Aim [OFF]", function(v) SilentAim = v end)
AddButton("Trigger Bot [OFF]", function(v) TriggerBot = v end)
AddButton("ESP [OFF]", function(v) ESP = v end)
AddButton("Fly [OFF]", function(v) Fly = v end)
AddButton("Noclip [OFF]", function(v) Noclip = v end)
AddButton("Speed Hack [OFF]", function(v) SpeedHack = v end)
AddButton("Auto Farm [OFF]", function(v) AutoFarm = v end)

-- Перетаскивание
local drag = false
local startPos = nil
local startGui = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        startPos = input.Position
        startGui = Main.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    drag = false
end)

UserInputService.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startPos
        Main.Position = UDim2.new(startGui.X.Scale, startGui.X.Offset + delta.X, startGui.Y.Scale, startGui.Y.Offset + delta.Y)
    end
end)

-- Silent Aim
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if self == Mouse and key == "Hit" and SilentAim then
        local closest = nil
        local closestDist = 200
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize / 2)).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = head.Position
                        end
                    end
                end
            end
        end
        
        if closest then
            return closest
        end
    end
    return oldIndex(self, key)
end)

-- Trigger Bot
local UserInput = game:GetService("VirtualInputManager")
RunService.Heartbeat:Connect(function()
    if TriggerBot and SilentAim then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize / 2)).Magnitude
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

-- Fly
local bodyGyro, bodyVel
RunService.Heartbeat:Connect(function()
    if Fly and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not bodyGyro then
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                bodyGyro.Parent = root
            end
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(400000, 400000, 400000)
                bodyVel.Parent = root
            end
            
            bodyGyro.CFrame = Camera.CFrame
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            
            bodyVel.Velocity = move.Magnitude > 0 and move.Unit * 30 or Vector3.zero
            
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end
        end
    else
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedHack and 40 or 16
        end
    end
end)

-- Anti-AFK
local VU = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if AntiAFK then
        pcall(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if not ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and root then
                local headPos, headOn = Camera:WorldToScreenPoint(head.Position)
                local rootPos, rootOn = Camera:WorldToScreenPoint(root.Position)
                
                if rootOn then
                    local color = plr.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, 40, 0, 60)
                    box.Position = UDim2.new(0, rootPos.X - 20, 0, rootPos.Y - 60)
                    box.BackgroundTransparency = 0.8
                    box.BorderSizePixel = 2
                    box.BorderColor3 = color
                    box.Parent = ScreenGui
                    game:GetService("Debris"):AddItem(box, 0.05)
                    
                    local name = Instance.new("TextLabel")
                    name.Size = UDim2.new(0, 100, 0, 20)
                    name.Position = UDim2.new(0, rootPos.X - 50, 0, rootPos.Y - 80)
                    name.BackgroundTransparency = 1
                    name.Text = plr.Name
                    name.TextColor3 = color
                    name.TextSize = 12
                    name.Font = Enum.Font.Gotham
                    name.Parent = ScreenGui
                    game:GetService("Debris"):AddItem(name, 0.05)
                end
            end
        end
    end
end)

-- Auto Farm
RunService.Heartbeat:Connect(function()
    if not AutoFarm or not LocalPlayer.Character then return end
    local best = nil
    local bestDist = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Team ~= LocalPlayer.Team then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = root
                end
            end
        end
    end
    
    if best then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(best.Position) end
    end
end)