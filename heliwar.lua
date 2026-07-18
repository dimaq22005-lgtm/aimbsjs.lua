--[[ Heli Wars v7.0 - VEHICLE AIMBOT ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    AimbotSmooth = 0.3,
    AimbotFOV = 500,
    TriggerBot = false,
    TeamCheck = true,
    TargetTeam = "Enemy",
    ESP = false,
    Noclip = false,
    SpeedHack = false,
    AntiAFK = true
}

local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local SG = Instance.new("ScreenGui",game:GetService("CoreGui"))
local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,320,0,380)
Main.Position = UDim2.new(0.5,-160,0.5,-190)
Main.BackgroundColor3 = Color3.fromRGB(20,20,30)
Main.BorderSizePixel = 0
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,10)

local Top = Instance.new("Frame",Main)
Top.Size = UDim2.new(1,0,0,35)
Top.BackgroundColor3 = Color3.fromRGB(30,30,45)
Top.BorderSizePixel = 0
Instance.new("UICorner",Top).CornerRadius = UDim.new(0,10)
Instance.new("TextLabel",Top).Text = "🚁 Heli Wars v7.0"
Instance.new("TextLabel",Top).TextColor3 = Color3.fromRGB(255,200,0)
Instance.new("TextLabel",Top).TextSize = 16
Instance.new("TextLabel",Top).Font = Enum.Font.GothamBold
Instance.new("TextLabel",Top).Size = UDim2.new(1,0,1,0)
Instance.new("TextLabel",Top).BackgroundTransparency = 1

-- Кнопки
local yPos = 45
local function Btn(text,cb)
    local b = Instance.new("TextButton",Main)
    b.Size = UDim2.new(1,-20,0,36)
    b.Position = UDim2.new(0,10,0,yPos)
    b.BackgroundColor3 = Color3.fromRGB(40,40,55)
    b.BorderSizePixel = 0
    b.Text = text.." [OFF]"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextSize = 13
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    local e = false
    b.MouseButton1Click:Connect(function()
        e = not e
        b.BackgroundColor3 = e and Color3.fromRGB(255,150,0) or Color3.fromRGB(40,40,55)
        b.Text = text..(e and " [ON]" or " [OFF]")
        cb(e)
    end)
    yPos = yPos + 40
end

-- Target Team
local tOpts = {"Enemy","Friend","All"}
local tIdx = 1
local tBtn = Instance.new("TextButton",Main)
tBtn.Size = UDim2.new(1,-20,0,36)
tBtn.Position = UDim2.new(0,10,0,yPos)
tBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
tBtn.BorderSizePixel = 0
tBtn.Text = "Target: Enemy"
tBtn.TextColor3 = Color3.fromRGB(255,255,255)
tBtn.TextSize = 13
tBtn.Font = Enum.Font.Gotham
Instance.new("UICorner",tBtn).CornerRadius = UDim.new(0,6)
tBtn.MouseButton1Click:Connect(function()
    tIdx = tIdx%3+1
    Settings.TargetTeam = tOpts[tIdx]
    tBtn.Text = "Target: "..Settings.TargetTeam
end)
yPos = yPos + 45

Btn("🎯 Aimbot",function(v) Settings.Aimbot=v end)
Btn("🔫 Trigger Bot",function(v) Settings.TriggerBot=v end)
Btn("🛡️ Team Check",function(v) Settings.TeamCheck=v end)
Btn("👁️ ESP",function(v) Settings.ESP=v end)
Btn("👻 Noclip",function(v) Settings.Noclip=v end)
Btn("⚡ Speed Hack",function(v) Settings.SpeedHack=v end)

-- Перетаскивание
local drag,sP,sG
Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true sP=i.Position sG=Main.Position end end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then Main.Position=UDim2.new(sG.X.Scale,sG.X.Offset+i.Position.X-sP.X,sG.Y.Scale,sG.Y.Offset+i.Position.Y-sP.Y) end end)

-- ПОЛУЧЕНИЕ ЦЕЛИ (игроки + вертолёты)
local function GetTarget()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local best = nil
    local bestDist = Settings.AimbotFOV
    local center = Camera.ViewportSize/2
    
    -- Проверяем игроков
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        
        if Settings.TeamCheck then
            if Settings.TargetTeam == "Enemy" and p.Team == LocalPlayer.Team then continue end
            if Settings.TargetTeam == "Friend" and p.Team ~= LocalPlayer.Team then continue end
        end
        
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- Целимся в RootPart (центр персонажа/вертолёта)
        local target = p.Character:FindFirstChild("HumanoidRootPart")
        if not target then continue end
        
        local pos, onScreen = Camera:WorldToScreenPoint(target.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = {Position = target.Position, Player = p}
        end
    end
    
    -- Проверяем технику (вертолёты, машины)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character then
            -- Ищем seat или vehicle seat
            local seat = v:FindFirstChildOfClass("VehicleSeat") or v:FindFirstChild("Seat")
            if seat and seat.Occupant then
                local occupant = seat.Occupant.Parent
                if occupant and occupant ~= LocalPlayer.Character then
                    local player = Players:GetPlayerFromCharacter(occupant)
                    if player then
                        if Settings.TeamCheck then
                            if Settings.TargetTeam == "Enemy" and player.Team == LocalPlayer.Team then continue end
                            if Settings.TargetTeam == "Friend" and player.Team ~= LocalPlayer.Team then continue end
                        end
                    end
                    
                    local root = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or seat
                    local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = {Position = root.Position, Player = player}
                        end
                    end
                end
            end
        end
    end
    
    return best
end

-- AIMBOT
local UserInput = game:GetService("VirtualInputManager")
RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end
    local target = GetTarget()
    if target then
        local pos = Camera:WorldToScreenPoint(target.Position)
        local center = Camera.ViewportSize/2
        local move = Vector2.new(pos.X-center.X, pos.Y-center.Y)
        move = move * (1 - Settings.AimbotSmooth)
        UserInput:SendMouseMoveEvent(move, false)
    end
end)

-- TRIGGER BOT (проверка перезарядки)
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBot or not Settings.Aimbot then return end
    local target = GetTarget()
    if not target then return end
    
    -- Проверяем что оружие заряжено
    local canShoot = true
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            -- Проверяем Ammo/Reload
            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount")
            if ammo and ammo.Value <= 0 then canShoot = false end
            
            -- Проверяем Reloading
            local reloading = tool:FindFirstChild("Reloading")
            if reloading and reloading.Value then canShoot = false end
        end
    end
    
    if canShoot then
        mouse1press()
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if not Settings.ESP then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if not onScreen then continue end
        
        local color = p.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
        if not Settings.TeamCheck then color = Color3.fromRGB(255,255,255) end
        
        local box = Instance.new("Frame",SG)
        box.Size = UDim2.new(0,50,0,50)
        box.Position = UDim2.new(0,pos.X-25,0,pos.Y-50)
        box.BackgroundTransparency = 0.8
        box.BorderSizePixel = 2
        box.BorderColor3 = color
        game:GetService("Debris"):AddItem(box,0.03)
        
        local name = Instance.new("TextLabel",SG)
        name.Size = UDim2.new(0,100,0,18)
        name.Position = UDim2.new(0,pos.X-50,0,pos.Y-70)
        name.BackgroundTransparency = 1
        name.Text = p.Name
        name.TextColor3 = color
        name.TextSize = 12
        name.Font = Enum.Font.GothamBold
        game:GetService("Debris"):AddItem(name,0.03)
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

Notify("🚁 Heli Wars v7.0","Aimbot для вертолётов!",5)
Notify("Используй","Aimbot + Trigger Bot",5)