--[[ Heli Wars SMART AIMBOT v10 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    AutoShoot = false,
    FOV = 200,
    MyTeam = "Green" -- Green / Yellow
}

local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local SG = Instance.new("ScreenGui",game:GetService("CoreGui"))
SG.Name = "SmartAim"

local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,320,0,320)
Main.Position = UDim2.new(0.5,-160,0.5,-160)
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
Title.Text = "🎯 Smart Aim v10"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

-- FOV Circle
local FOV = Instance.new("Frame",SG)
FOV.Size = UDim2.new(0,400,0,400)
FOV.Position = UDim2.new(0.5,-200,0.5,-200)
FOV.BackgroundTransparency = 1
FOV.BorderSizePixel = 2
FOV.BorderColor3 = Color3.fromRGB(255,255,255)
FOV.Visible = false
Instance.new("UICorner",FOV).CornerRadius = UDim.new(1,0)

-- Кнопки
local yPos = 45
local function Btn(text,cb)
    local b = Instance.new("TextButton",Main)
    b.Size = UDim2.new(1,-20,0,38)
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
        b.BackgroundColor3 = e and Color3.fromRGB(255,100,0) or Color3.fromRGB(40,40,55)
        b.Text = text..(e and " [ON]" or " [OFF]")
        cb(e)
    end)
    yPos = yPos + 42
    return b
end

Btn("🎯 Aimbot",function(v) 
    Settings.Aimbot = v
    FOV.Visible = v
    Notify("Aimbot",v and"ON"or"OFF")
end)

Btn("🔫 Auto Shoot",function(v) 
    Settings.AutoShoot = v
    Notify("AutoShoot",v and"ON"or"OFF")
end)

-- Выбор команды
local TeamBtn = Instance.new("TextButton",Main)
TeamBtn.Size = UDim2.new(1,-20,0,38)
TeamBtn.Position = UDim2.new(0,10,0,yPos)
TeamBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
TeamBtn.BorderSizePixel = 0
TeamBtn.Text = "My Team: Green"
TeamBtn.TextColor3 = Color3.fromRGB(255,255,255)
TeamBtn.TextSize = 13
TeamBtn.Font = Enum.Font.Gotham
Instance.new("UICorner",TeamBtn).CornerRadius = UDim.new(0,6)

local teamColors = {"Green","Yellow"}
local teamIndex = 1
TeamBtn.MouseButton1Click:Connect(function()
    teamIndex = teamIndex == 1 and 2 or 1
    Settings.MyTeam = teamColors[teamIndex]
    TeamBtn.Text = "My Team: "..Settings.MyTeam
    TeamBtn.BackgroundColor3 = Settings.MyTeam == "Green" and Color3.fromRGB(0,170,0) or Color3.fromRGB(200,200,0)
end)
yPos = yPos + 47

Btn("⚡ Speed Hack",function(v) Settings.SpeedHack = v end)

-- Перетаскивание
local drag,sP,sG = false,nil,nil
Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true sP=i.Position sG=Main.Position end end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then Main.Position=UDim2.new(sG.X.Scale,sG.X.Offset+i.Position.X-sP.X,sG.Y.Scale,sG.Y.Offset+i.Position.Y-sP.Y) end end)

-- ОПРЕДЕЛЕНИЕ ВРАГА ПО КОМАНДЕ
local function GetTeamColor(player)
    local char = player.Character
    if not char then return nil end
    
    -- Проверяем цвет Team
    local team = player.Team
    if team then
        local color = team.TeamColor.Color
        if color == Color3.fromRGB(0,255,0) or color == Color3.fromRGB(50,200,50) then return "Green" end
        if color == Color3.fromRGB(255,255,0) or color == Color3.fromRGB(200,200,0) then return "Yellow" end
    end
    
    -- Проверяем цвет частей тела
    local head = char:FindFirstChild("Head")
    if head and head.BrickColor then
        local bc = head.BrickColor.Name
        if bc:find("Green") then return "Green" end
        if bc:find("Yellow") or bc:find("Gold") then return "Yellow" end
    end
    
    -- Проверяем одежду
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.BrickColor.Name:find("Green") then return "Green" end
        if part:IsA("BasePart") and (part.BrickColor.Name:find("Yellow") or part.BrickColor.Name:find("Gold")) then return "Yellow" end
    end
    
    return nil
end

local function IsEnemy(player)
    local color = GetTeamColor(player)
    if not color then return true end -- Если не определили - считаем врагом
    return color ~= Settings.MyTeam
end

-- ДЕТЕКТОР ЦЕЛИ
local function GetBestTarget()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local best = nil
    local bestDist = math.huge
    local screenCenter = Camera.ViewportSize / 2
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if not IsEnemy(player) then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- Проверяем все части тела для точного наведения
        local targetPart = player.Character:FindFirstChild("HumanoidRootPart") or 
                          player.Character:FindFirstChild("UpperTorso") or
                          player.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        -- Учёт скорости
        local velocity = targetPart.Velocity
        local predictedPos = targetPart.Position + velocity * 0.15
        
        -- Проверка что цель на экране
        local screenPos, onScreen = Camera:WorldToScreenPoint(predictedPos)
        if not onScreen then continue end
        
        -- Проверка FOV
        local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if distFromCenter > Settings.FOV then continue end
        
        -- Проверка Raycast (видимость)
        local ray = Ray.new(Camera.CFrame.Position, (predictedPos - Camera.CFrame.Position).Unit * 2000)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        
        if hit and hit:IsDescendantOf(player.Character) then
            local realDist = (predictedPos - myRoot.Position).Magnitude
            if realDist < bestDist then
                bestDist = realDist
                best = {Player = player, Position = predictedPos, ScreenPos = screenPos}
            end
        end
    end
    
    return best
end

-- AIMBOT
local UserInput = game:GetService("VirtualInputManager")

RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end
    
    -- Обновляем FOV
    FOV.Size = UDim2.new(0,Settings.FOV*2,0,Settings.FOV*2)
    FOV.Position = UDim2.new(0.5,-Settings.FOV,0.5,-Settings.FOV)
    
    local target = GetBestTarget()
    if not target then return end
    
    local pos = target.ScreenPos
    local center = Camera.ViewportSize / 2
    
    -- Плавное наведение
    local moveX = (pos.X - center.X) * 0.35
    local moveY = (pos.Y - center.Y) * 0.35
    
    -- Ограничение
    moveX = math.clamp(moveX, -50, 50)
    moveY = math.clamp(moveY, -50, 50)
    
    UserInput:SendMouseMoveEvent(Vector2.new(moveX, moveY), false)
end)

-- AUTO SHOOT
RunService.Heartbeat:Connect(function()
    if not Settings.AutoShoot or not Settings.Aimbot then return end
    
    local target = GetBestTarget()
    if not target then return end
    
    -- Проверяем что цель в прицеле (близко к центру)
    local dist = (target.ScreenPos - Camera.ViewportSize/2).Magnitude
    if dist < 80 then
        -- Проверка оружия
        local canShoot = true
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount") or tool:FindFirstChild("Magazine")
                if ammo and ammo.Value ~= nil and ammo.Value <= 0 then canShoot = false end
            end
        end
        
        if canShoot then
            mouse1press()
        end
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
    pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
end)

Notify("🎯 Smart Aim v10","Выбери свою команду!",5)
Notify("Система","Зелёный FOV + автострельба",5)