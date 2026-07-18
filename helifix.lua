--[[ Heli Wars PRO v6.0 - AIMBOT + ESP FIX ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ
local Settings = {
    Aimbot = false,
    AimbotSmooth = 0.5,
    AimbotFOV = 300,
    AimbotPart = "Head",
    TriggerBot = false,
    TeamCheck = true,
    TargetTeam = "Enemy", -- Enemy / Friend / All
    ESP = false,
    Noclip = false,
    SpeedHack = false,
    AutoFarm = false,
    AntiAFK = true
}

-- Уведомления
local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local SG = Instance.new("ScreenGui",game:GetService("CoreGui"))
SG.Name = "HeliPro"

local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,320,0,420)
Main.Position = UDim2.new(0.5,-160,0.5,-210)
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
Title.Text = "🚁 Heli Wars PRO"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

-- Функция кнопок
local yPos = 45
local function AddButton(text, callback)
    local btn = Instance.new("TextButton",Main)
    btn.Size = UDim2.new(1,-20,0,36)
    btn.Position = UDim2.new(0,10,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.BorderSizePixel = 0
    btn.Text = text.." [OFF]"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    
    local en = false
    btn.MouseButton1Click:Connect(function()
        en = not en
        btn.BackgroundColor3 = en and Color3.fromRGB(255,150,0) or Color3.fromRGB(40,40,55)
        btn.Text = text..(en and " [ON]" or " [OFF]")
        callback(en)
    end)
    yPos = yPos + 40
    return btn
end

-- Циклическая кнопка Target Team
local targetOptions = {"Enemy","Friend","All"}
local targetIndex = 1
local TargetBtn = Instance.new("TextButton",Main)
TargetBtn.Size = UDim2.new(1,-20,0,36)
TargetBtn.Position = UDim2.new(0,10,0,yPos)
TargetBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
TargetBtn.BorderSizePixel = 0
TargetBtn.Text = "Target: Enemy"
TargetBtn.TextColor3 = Color3.fromRGB(255,255,255)
TargetBtn.TextSize = 13
TargetBtn.Font = Enum.Font.Gotham
Instance.new("UICorner",TargetBtn).CornerRadius = UDim.new(0,6)

TargetBtn.MouseButton1Click:Connect(function()
    targetIndex = targetIndex % 3 + 1
    Settings.TargetTeam = targetOptions[targetIndex]
    TargetBtn.Text = "Target: "..Settings.TargetTeam
    local colors = {Enemy=Color3.fromRGB(255,80,80),Friend=Color3.fromRGB(80,255,80),All=Color3.fromRGB(80,80,255)}
    TargetBtn.BackgroundColor3 = colors[Settings.TargetTeam]
end)
yPos = yPos + 45

-- Кнопки
AddButton("🎯 Aimbot",function(v) Settings.Aimbot=v Notify("Aimbot",v and"ON"or"OFF") end)
AddButton("🔫 Trigger Bot",function(v) Settings.TriggerBot=v Notify("Trigger Bot",v and"ON"or"OFF") end)
AddButton("🛡️ Team Check",function(v) Settings.TeamCheck=v Notify("Team Check",v and"ON"or"OFF") end)
AddButton("👁️ ESP",function(v) Settings.ESP=v Notify("ESP",v and"ON"or"OFF") end)
AddButton("👻 Noclip",function(v) Settings.Noclip=v Notify("Noclip",v and"ON"or"OFF") end)
AddButton("⚡ Speed Hack",function(v) Settings.SpeedHack=v Notify("Speed Hack",v and"ON"or"OFF") end)
AddButton("🤖 Auto Farm",function(v) Settings.AutoFarm=v Notify("Auto Farm",v and"ON"or"OFF") end)

-- Перетаскивание
local drag,sP,sG = false,nil,nil
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag=true sP=i.Position sG=Main.Position
    end
end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i)
    if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
        local d=i.Position-sP Main.Position=UDim2.new(sG.X.Scale,sG.X.Offset+d.X,sG.Y.Scale,sG.Y.Offset+d.Y)
    end
end)

-- ПОЛУЧЕНИЕ ЦЕЛИ
local function GetTarget()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local best, bestDist = nil, Settings.AimbotFOV
    local screenCenter = Camera.ViewportSize / 2
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        
        -- Team Check
        if Settings.TeamCheck then
            if Settings.TargetTeam == "Enemy" and p.Team == LocalPlayer.Team then continue end
            if Settings.TargetTeam == "Friend" and p.Team ~= LocalPlayer.Team then continue end
        end
        
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- Выбираем часть тела
        local aimPart = nil
        if Settings.AimbotPart == "Head" then
            aimPart = p.Character:FindFirstChild("Head")
        elseif Settings.AimbotPart == "UpperTorso" then
            aimPart = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart")
        else
            aimPart = p.Character:FindFirstChild("HumanoidRootPart")
        end
        
        if not aimPart then continue end
        
        -- Учёт скорости (Prediction)
        local aimPos = aimPart.Position
        local rootVel = p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart.Velocity or Vector3.zero
        aimPos = aimPos + rootVel * 0.15
        
        local screenPos, onScreen = Camera:WorldToScreenPoint(aimPos)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X,screenPos.Y) - screenCenter).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = {Player=p, Position=aimPos, ScreenPos=screenPos, Part=aimPart, Distance=(aimPart.Position-myRoot.Position).Magnitude}
        end
    end
    
    return best
end

-- AIMBOT (плавное наведение)
local UserInput = game:GetService("VirtualInputManager")
RunService.RenderStepped:Connect(function(deltaTime)
    if not Settings.Aimbot then return end
    
    local target = GetTarget()
    if target then
        local screenPos = Camera:WorldToScreenPoint(target.Position)
        local center = Camera.ViewportSize / 2
        local move = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
        
        -- Плавность
        local smooth = Settings.AimbotSmooth
        move = move * (1 - smooth)
        
        UserInput:SendMouseMoveEvent(move, false)
    end
end)

-- TRIGGER BOT
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBot or not Settings.Aimbot then return end
    local target = GetTarget()
    if target then
        mouse1press()
    end
end)

-- ESP (ИСПРАВЛЕННЫЙ)
RunService.RenderStepped:Connect(function()
    if not Settings.ESP then return end
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not root then continue end
        
        -- Используем HumanoidRootPart для ESP (точнее чем голова)
        local rootPos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if not onScreen then continue end
        
        -- Определяем цвет
        local color
        if Settings.TeamCheck then
            color = p.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
        else
            color = Color3.fromRGB(255,255,255)
        end
        
        -- Размер бокса зависит от дистанции
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 50
        local boxSize = math.clamp(3000/dist, 20, 80)
        
        -- Бокс
        local box = Instance.new("Frame",SG)
        box.Size = UDim2.new(0,boxSize,0,boxSize*1.5)
        box.Position = UDim2.new(0,rootPos.X-boxSize/2,0,rootPos.Y-boxSize*1.5)
        box.BackgroundColor3 = color
        box.BackgroundTransparency = 0.75
        box.BorderSizePixel = 2
        box.BorderColor3 = color
        game:GetService("Debris"):AddItem(box,0.03)
        
        -- Имя
        local name = Instance.new("TextLabel",SG)
        name.Size = UDim2.new(0,120,0,18)
        name.Position = UDim2.new(0,rootPos.X-60,0,rootPos.Y-boxSize*1.5-20)
        name.BackgroundTransparency = 1
        name.Text = p.Name
        name.TextColor3 = color
        name.TextSize = 12
        name.Font = Enum.Font.GothamBold
        game:GetService("Debris"):AddItem(name,0.03)
        
        -- Дистанция
        local distLabel = Instance.new("TextLabel",SG)
        distLabel.Size = UDim2.new(0,100,0,18)
        distLabel.Position = UDim2.new(0,rootPos.X-50,0,rootPos.Y+5)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = math.floor(dist).."m"
        distLabel.TextColor3 = Color3.fromRGB(255,255,255)
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.Gotham
        game:GetService("Debris"):AddItem(distLabel,0.03)
        
        -- Линия (Tracer)
        local center = Camera.ViewportSize/2
        local tracer = Instance.new("Frame",SG)
        local length = (Vector2.new(rootPos.X,rootPos.Y) - center).Magnitude
        local angle = math.deg(math.atan2(rootPos.Y-center.Y, rootPos.X-center.X))
        tracer.Size = UDim2.new(0,length,0,1)
        tracer.Position = UDim2.new(0,center.X,0,center.Y)
        tracer.Rotation = angle
        tracer.BackgroundColor3 = color
        tracer.BorderSizePixel = 0
        game:GetService("Debris"):AddItem(tracer,0.03)
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
    if Settings.AntiAFK then
        pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
    end
end)

-- AUTO FARM
RunService.Heartbeat:Connect(function()
    if not Settings.AutoFarm or not LocalPlayer.Character then return end
    local target = GetTarget()
    if target then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(target.Position) end
    end
end)

Notify("🚁 Heli Wars PRO","Aimbot + ESP + Team Select",5)
Notify("Управление","Кнопки в меню",5)