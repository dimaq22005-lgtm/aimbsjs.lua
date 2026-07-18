--[[ Heli Wars PVO v9.0 - AIMBOT FIX ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    Aimbot = false,
    AutoShoot = false,
    TeamCheck = true,
    Noclip = false,
    SpeedHack = false,
    AntiAFK = true
}

local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local SG = Instance.new("ScreenGui",game:GetService("CoreGui"))
SG.Name = "PVO"

local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,300,0,260)
Main.Position = UDim2.new(0.5,-150,0.5,-130)
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
Title.Text = "🎯 PVO System v9.0"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

-- Кнопки
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
        b.BackgroundColor3 = e and Color3.fromRGB(255,100,0) or Color3.fromRGB(40,40,55)
        b.Text = text..(e and " [ON]" or " [OFF]")
        cb(e)
    end)
    yPos = yPos + 45
end

Btn("🎯 Aimbot",function(v) Settings.Aimbot=v end)
Btn("🔫 Auto Shoot",function(v) Settings.AutoShoot=v end)
Btn("🛡️ Team Check",function(v) Settings.TeamCheck=v end)
Btn("⚡ Speed Hack",function(v) Settings.SpeedHack=v end)

-- Перетаскивание
local drag,sP,sG = false,nil,nil
Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true sP=i.Position sG=Main.Position end end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then Main.Position=UDim2.new(sG.X.Scale,sG.X.Offset+i.Position.X-sP.X,sG.Y.Scale,sG.Y.Offset+i.Position.Y-sP.Y) end end)

-- ДЕТЕКТОР ВРАГОВ
local function DetectEnemy()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local best = nil
    local bestDist = math.huge
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
        
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        local dist = (root.Position - myRoot.Position).Magnitude
        
        -- Проверка видимости (Raycast)
        local ray = Ray.new(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        
        if hit and hit:IsDescendantOf(p.Character) then
            if dist < bestDist then
                bestDist = dist
                best = {Player=p, Root=root, Position=root.Position}
            end
        end
    end
    
    return best
end

-- AIMBOT (ПВО система)
local UserInput = game:GetService("VirtualInputManager")
local RunS = game:GetService("RunService")

RunS.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end
    
    local target = DetectEnemy()
    if not target then return end
    
    local pos = Camera:WorldToScreenPoint(target.Position)
    
    -- Проверка что цель на экране
    if pos.Z <= 0 then return end
    
    local center = Camera.ViewportSize / 2
    local deltaX = pos.X - center.X
    local deltaY = pos.Y - center.Y
    
    -- Плавное наведение (как ПВО)
    local speed = 0.4
    local moveX = deltaX * speed
    local moveY = deltaY * speed
    
    -- Ограничение резких движений
    moveX = math.clamp(moveX, -40, 40)
    moveY = math.clamp(moveY, -40, 40)
    
    -- Двигаем мышь
    UserInput:SendMouseMoveEvent(Vector2.new(moveX, moveY), false)
end)

-- AUTO SHOOT
RunS.Heartbeat:Connect(function()
    if not Settings.AutoShoot or not Settings.Aimbot then return end
    
    local target = DetectEnemy()
    if not target then return end
    
    -- Проверка что цель в прицеле
    local pos = Camera:WorldToScreenPoint(target.Position)
    local center = Camera.ViewportSize / 2
    local dist = Vector2.new(pos.X - center.X, pos.Y - center.Y).Magnitude
    
    -- Стреляем только если цель близко к центру экрана
    if dist < 150 then
        -- Проверяем оружие
        local canShoot = true
        if LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount")
                if ammo and ammo.Value <= 0 then canShoot = false end
            end
        end
        
        if canShoot then
            mouse1press()
        end
    end
end)

-- SPEED HACK
RunS.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Settings.SpeedHack and 50 or 16 end
    end
end)

-- ANTI-AFK
local VU = game:GetService("VirtualUser")
RunS.Heartbeat:Connect(function()
    if Settings.AntiAFK then pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end
end)

Notify("🎯 PVO System v9.0","Aimbot + AutoShoot готов!",5)
Notify("Совет","Включай Aimbot + AutoShoot вместе",5)