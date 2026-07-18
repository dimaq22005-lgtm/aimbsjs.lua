--[[ Heli Wars FIX v1.0 - STABLE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    SilentAim = false,
    TriggerBot = false,
    ESP = false,
    Noclip = false,
    SpeedHack = false,
    AutoFarm = false,
    AntiAFK = true
}

-- Уведомление
local function Notify(t,m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3})
    end)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui",game:GetService("CoreGui"))
ScreenGui.Name = "HeliWars"

local Main = Instance.new("Frame",ScreenGui)
Main.Size = UDim2.new(0,300,0,300)
Main.Position = UDim2.new(0.5,-150,0.5,-150)
Main.BackgroundColor3 = Color3.fromRGB(25,25,35)
Main.BorderSizePixel = 0
Instance.new("UICorner",Main).CornerRadius = UDim.new(0,8)

local TopBar = Instance.new("Frame",Main)
TopBar.Size = UDim2.new(1,0,0,30)
TopBar.BackgroundColor3 = Color3.fromRGB(35,35,50)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel",TopBar)
Title.Size = UDim2.new(1,0,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Heli Wars FIX"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка
local function Button(text,y,callback)
    local btn = Instance.new("TextButton",Main)
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
    btn.BorderSizePixel = 0
    btn.Text = text.." [OFF]"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0,170,255) or Color3.fromRGB(40,40,55)
        btn.Text = text..(enabled and " [ON]" or " [OFF]")
        callback(enabled)
    end)
end

-- Создаём кнопки
Button("Silent Aim",40,function(v) Settings.SilentAim = v Notify("Silent Aim",v and"ON"or"OFF") end)
Button("Trigger Bot",85,function(v) Settings.TriggerBot = v Notify("Trigger Bot",v and"ON"or"OFF") end)
Button("ESP",130,function(v) Settings.ESP = v Notify("ESP",v and"ON"or"OFF") end)
Button("Noclip",175,function(v) Settings.Noclip = v Notify("Noclip",v and"ON"or"OFF") end)
Button("Speed Hack",220,function(v) Settings.SpeedHack = v Notify("Speed Hack",v and"ON"or"OFF") end)
Button("Auto Farm",265,function(v) Settings.AutoFarm = v Notify("Auto Farm",v and"ON"or"OFF") end)

-- Перетаскивание
local drag,startPos,startGui = false,nil,nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        startPos = i.Position
        startGui = Main.Position
    end
end)
UserInputService.InputEnded:Connect(function() drag = false end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - startPos
        Main.Position = UDim2.new(startGui.X.Scale,startGui.X.Offset+d.X,startGui.Y.Scale,startGui.Y.Offset+d.Y)
    end
end)

-- Silent Aim (БЕЗ hookmetamethod!)
local function GetTarget()
    local best, bestDist = nil, 200
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X,pos.Y) - (Camera.ViewportSize/2)).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = head
                    end
                end
            end
        end
    end
    return best
end

-- Прицеливание через mousemoverel
local UserInput = game:GetService("VirtualInputManager")
RunService.RenderStepped:Connect(function()
    if Settings.SilentAim then
        local target = GetTarget()
        if target then
            local pos = Camera:WorldToScreenPoint(target.Position)
            local center = Camera.ViewportSize / 2
            local move = Vector2.new(pos.X - center.X, pos.Y - center.Y)
            UserInput:SendMouseMoveEvent(move, game:GetService("RunService"):IsStudio() and true or false)
        end
    end
end)

-- Trigger Bot
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBot or not Settings.SilentAim then return end
    if GetTarget() then
        mouse1press()
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not Settings.Noclip or not LocalPlayer.Character then return end
    for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Settings.SpeedHack and 40 or 16 end
    end
end)

-- Anti-AFK
local VU = game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if Settings.AntiAFK then
        pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if not Settings.ESP then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local head = p.Character:FindFirstChild("Head")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local root = p.Character:FindFirstChild("HumanoidRootPart")
        if not head or not hum or hum.Health <= 0 or not root then continue end
        
        local hp, ho = Camera:WorldToScreenPoint(head.Position + Vector3.new(0,0.5,0))
        local rp, ro = Camera:WorldToScreenPoint(root.Position)
        if not ro then continue end
        
        local color = p.Team == LocalPlayer.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
        local bh = math.abs(rp.Y - hp.Y)
        
        local box = Instance.new("Frame",ScreenGui)
        box.Size = UDim2.new(0,bh*0.4,0,bh)
        box.Position = UDim2.new(0,hp.X-bh*0.2,0,hp.Y)
        box.BackgroundTransparency = 0.8
        box.BorderSizePixel = 2
        box.BorderColor3 = color
        game:GetService("Debris"):AddItem(box,0.05)
        
        local name = Instance.new("TextLabel",ScreenGui)
        name.Size = UDim2.new(0,100,0,20)
        name.Position = UDim2.new(0,hp.X-50,0,hp.Y-25)
        name.BackgroundTransparency = 1
        name.Text = p.Name
        name.TextColor3 = color
        name.TextSize = 12
        name.Font = Enum.Font.Gotham
        game:GetService("Debris"):AddItem(name,0.05)
    end
end)

-- Auto Farm
RunService.Heartbeat:Connect(function()
    if not Settings.AutoFarm or not LocalPlayer.Character then return end
    local best, bestDist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team ~= LocalPlayer.Team then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
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

Notify("Heli Wars FIX","Без зависаний! v1.0",5)