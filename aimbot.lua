--[[ Heli Wars v8.0 - AIMBOT ONLY ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    AimbotSmooth = 0.4,
    AimbotFOV = 400,
    TriggerBot = false,
    TeamCheck = true,
    Noclip = false,
    SpeedHack = false,
    AntiAFK = true
}

local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local SG = Instance.new("ScreenGui",game:GetService("CoreGui"))
local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,300,0,300)
Main.Position = UDim2.new(0.5,-150,0.5,-150)
Main.BackgroundColor3 = Color3.fromRGB(20,20,30)
Main.BorderSizePixel = 0
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,10)

local Top = Instance.new("Frame",Main)
Top.Size = UDim2.new(1,0,0,35)
Top.BackgroundColor3 = Color3.fromRGB(30,30,45)
Top.BorderSizePixel = 0
Instance.new("UICorner",Top).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel",Top)
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Aimbot v8.0"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

local yPos = 45
local function Btn(text,cb)
    local b = Instance.new("TextButton",Main)
    b.Size = UDim2.new(1,-20,0,40)
    b.Position = UDim2.new(0,10,0,yPos)
    b.BackgroundColor3 = Color3.fromRGB(40,40,55)
    b.BorderSizePixel = 0
    b.Text = text.." [OFF]"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextSize = 14
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local e = false
    b.MouseButton1Click:Connect(function()
        e = not e
        b.BackgroundColor3 = e and Color3.fromRGB(255,150,0) or Color3.fromRGB(40,40,55)
        b.Text = text..(e and " [ON]" or " [OFF]")
        cb(e)
    end)
    yPos = yPos + 45
    return b
end

Btn("🎯 Aimbot",function(v) Settings.Aimbot=v Notify("Aimbot",v and"ON"or"OFF") end)
Btn("🔫 Trigger Bot",function(v) Settings.TriggerBot=v Notify("Trigger Bot",v and"ON"or"OFF") end)
Btn("🛡️ Team Check",function(v) Settings.TeamCheck=v Notify("Team Check",v and"ON"or"OFF") end)
Btn("👻 Noclip",function(v) Settings.Noclip=v Notify("Noclip",v and"ON"or"OFF") end)
Btn("⚡ Speed Hack",function(v) Settings.SpeedHack=v Notify("Speed Hack",v and"ON"or"OFF") end)

-- Перетаскивание
local drag,sP,sG = false,nil,nil
Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true sP=i.Position sG=Main.Position end end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-sP Main.Position=UDim2.new(sG.X.Scale,sG.X.Offset+d.X,sG.Y.Scale,sG.Y.Offset+d.Y) end end)

-- ПОЛУЧЕНИЕ ЦЕЛИ (ТОЛЬКО ИГРОКИ)
local function GetTarget()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local best = nil
    local bestDist = Settings.AimbotFOV
    local center = Camera.ViewportSize/2
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        
        -- Team Check
        if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
        
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- Целимся в HumanoidRootPart (центр игрока)
        local target = p.Character:FindFirstChild("HumanoidRootPart")
        if not target then continue end
        
        -- Учёт скорости для Prediction
        local aimPos = target.Position + target.Velocity * 0.13
        
        local pos, onScreen = Camera:WorldToScreenPoint(aimPos)
        if not onScreen then continue end
        
        local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = {Position = aimPos, Player = p}
        end
    end
    
    return best
end

-- AIMBOT
local UserInput = game:GetService("VirtualInputManager")
local lastTarget = nil

RunService.RenderStepped:Connect(function(dt)
    if not Settings.Aimbot then 
        lastTarget = nil
        return 
    end
    
    local target = GetTarget()
    if target then
        lastTarget = target
        
        local pos = Camera:WorldToScreenPoint(target.Position)
        local center = Camera.ViewportSize/2
        
        -- Плавное движение к цели
        local move = Vector2.new(pos.X - center.X, pos.Y - center.Y)
        local smooth = Settings.AimbotSmooth
        
        -- Экспоненциальное сглаживание
        move = move * (1 - smooth * 0.9)
        
        -- Отправляем движение мыши
        UserInput:SendMouseMoveEvent(move.X, move.Y, false)
    end
end)

-- TRIGGER BOT
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBot or not Settings.Aimbot then return end
    
    local target = GetTarget()
    if not target then return end
    
    -- Проверка оружия
    local canShoot = true
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount") or tool:FindFirstChild("Magazine")
            if ammo and ammo.Value <= 0 then canShoot = false end
        end
    end
    
    if canShoot then
        mouse1press()
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if not Settings.Noclip or not LocalPlayer.Character then return end
    for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- SPEED HACK
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Settings.SpeedHack and 50 or 16 end
    end
end)

-- ANTI-AFK
local VU = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if Settings.AntiAFK then pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end
end)

Notify("🎯 Aimbot v8.0","Только игроки! Без ESP",5)
Notify("Совет","Aimbot + Trigger Bot = WIN",5)