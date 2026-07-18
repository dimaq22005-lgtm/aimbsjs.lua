--[[ Heli Wars SILENT AIM v12 - NO FREEZE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Teams = {"Desert Team", "Green Team", "Jungle Team"}

local Settings = {
    SilentAim = false,
    MyTeam = "Green Team",
    TargetTeam = "Desert Team",
    FOV = 250,
    Noclip = false,
    SpeedHack = false
}

local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local SG = Instance.new("ScreenGui",game:GetService("CoreGui"))
SG.Name = "SilentAim"

local Main = Instance.new("Frame",SG)
Main.Size = UDim2.new(0,320,0,340)
Main.Position = UDim2.new(0.5,-160,0.5,-170)
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
Title.Text = "🎯 Silent Aim v12"
Title.TextColor3 = Color3.fromRGB(255,200,0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold

-- FOV Circle
local FOV = Instance.new("Frame",SG)
FOV.Size = UDim2.new(0,500,0,500)
FOV.Position = UDim2.new(0.5,-250,0.5,-250)
FOV.BackgroundTransparency = 1
FOV.BorderSizePixel = 2
FOV.BorderColor3 = Color3.fromRGB(255,255,255)
FOV.Visible = false
Instance.new("UICorner",FOV).CornerRadius = UDim.new(1,0)

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
        b.BackgroundColor3 = e and Color3.fromRGB(255,100,0) or Color3.fromRGB(40,40,55)
        b.Text = text..(e and " [ON]" or " [OFF]")
        cb(e)
    end)
    yPos = yPos + 40
end

Btn("🎯 Silent Aim",function(v) Settings.SilentAim=v FOV.Visible=v end)
Btn("👻 Noclip",function(v) Settings.Noclip=v end)
Btn("⚡ Speed Hack",function(v) Settings.SpeedHack=v end)

-- Выбор своей команды
local MyTeamBtn = Instance.new("TextButton",Main)
MyTeamBtn.Size = UDim2.new(1,-20,0,36)
MyTeamBtn.Position = UDim2.new(0,10,0,yPos)
MyTeamBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
MyTeamBtn.BorderSizePixel = 0
MyTeamBtn.Text = "My: Green Team"
MyTeamBtn.TextColor3 = Color3.fromRGB(255,255,255)
MyTeamBtn.TextSize = 13
MyTeamBtn.Font = Enum.Font.Gotham
Instance.new("UICorner",MyTeamBtn).CornerRadius = UDim.new(0,6)
yPos = yPos + 40

local myIdx = 2
MyTeamBtn.MouseButton1Click:Connect(function()
    myIdx = myIdx%3+1
    Settings.MyTeam = Teams[myIdx]
    MyTeamBtn.Text = "My: "..Settings.MyTeam
end)

-- Выбор кого убивать
local TargetBtn = Instance.new("TextButton",Main)
TargetBtn.Size = UDim2.new(1,-20,0,36)
TargetBtn.Position = UDim2.new(0,10,0,yPos)
TargetBtn.BackgroundColor3 = Color3.fromRGB(210,180,140)
TargetBtn.BorderSizePixel = 0
TargetBtn.Text = "Target: Desert Team"
TargetBtn.TextColor3 = Color3.fromRGB(255,255,255)
TargetBtn.TextSize = 13
TargetBtn.Font = Enum.Font.Gotham
Instance.new("UICorner",TargetBtn).CornerRadius = UDim.new(0,6)
yPos = yPos + 45

local targetIdx = 1
TargetBtn.MouseButton1Click:Connect(function()
    targetIdx = targetIdx%3+1
    Settings.TargetTeam = Teams[targetIdx]
    TargetBtn.Text = "Target: "..Settings.TargetTeam
end)

-- Перетаскивание
local drag,sP,sG = false,nil,nil
Top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true sP=i.Position sG=Main.Position end end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then Main.Position=UDim2.new(sG.X.Scale,sG.X.Offset+i.Position.X-sP.X,sG.Y.Scale,sG.Y.Offset+i.Position.Y-sP.Y) end end)

-- ОПРЕДЕЛЕНИЕ КОМАНДЫ
local function GetPlayerTeam(player)
    local char = player.Character
    if not char then return nil end
    
    if player.Team then
        local tc = player.Team.TeamColor.Color
        if tc.r > 0.7 and tc.g > 0.6 and tc.b < 0.5 then return "Desert Team" end
        if tc.g > 0.8 and tc.r < 0.5 then return "Green Team" end
        if tc.g < 0.5 and tc.r < 0.3 and tc.b < 0.3 then return "Jungle Team" end
    end
    
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.BrickColor then
            local color = part.BrickColor.Color
            if color.r > 0.7 and color.g > 0.6 then return "Desert Team" end
            if color.g > 0.8 then return "Green Team" end
            if color.g < 0.5 and color.r < 0.3 then return "Jungle Team" end
        end
    end
    
    return nil
end

-- ПОЛУЧЕНИЕ ЦЕЛИ
local function GetTarget()
    local center = Camera.ViewportSize / 2
    local best = nil
    local bestDist = Settings.FOV
    
    for _,player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        
        local team = GetPlayerTeam(player)
        if not team then continue end
        if team == Settings.MyTeam then continue end
        if team ~= Settings.TargetTeam then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then continue end
        
        local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = head
        end
    end
    
    return best
end

-- SILENT AIM (без hookmetamethod - через принудительное наведение)
local UserInput = game:GetService("VirtualInputManager")
local RunS = game:GetService("RunService")

RunS.RenderStepped:Connect(function()
    if not Settings.SilentAim then return end
    
    -- Обновляем FOV
    FOV.Size = UDim2.new(0,Settings.FOV*2,0,Settings.FOV*2)
    FOV.Position = UDim2.new(0.5,-Settings.FOV,0.5,-Settings.FOV)
    
    local target = GetTarget()
    if not target then return end
    
    local pos = Camera:WorldToScreenPoint(target.Position)
    local center = Camera.ViewportSize / 2
    
    -- Мгновенное наведение на цель
    local moveX = pos.X - center.X
    local moveY = pos.Y - center.Y
    
    UserInput:SendMouseMoveEvent(Vector2.new(moveX, moveY), false)
end)

-- NOCLIP
RunS.Stepped:Connect(function()
    if not Settings.Noclip or not LocalPlayer.Character then return end
    for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
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
    pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
end)

Notify("🎯 Silent Aim v12","Без зависаний!",5)