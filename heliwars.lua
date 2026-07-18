--[[ Heli Wars MOBILE v3.4 - STABLE ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Settings = {SilentAimEnabled=false,TriggerBotEnabled=false,ESPEnabled=false,FlyEnabled=false,FlySpeed=30,NoclipEnabled=false,SpeedHackEnabled=false,AutoFarmEnabled=false,AntiAFKEnabled=true}

local function Notify(t,m) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

-- GUI
local ScreenGui = Instance.new("ScreenGui",game:GetService("CoreGui"))
local Main = Instance.new("Frame",ScreenGui)
Main.Size=UDim2.new(0,300,0,380) Main.Position=UDim2.new(0.5,-150,0.5,-190)
Main.BackgroundColor3=Color3.fromRGB(25,25,35) Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,8)

local TopBar=Instance.new("Frame",Main)
TopBar.Size=UDim2.new(1,0,0,30) TopBar.BackgroundColor3=Color3.fromRGB(35,35,50) TopBar.BorderSizePixel=0

local Title=Instance.new("TextLabel",TopBar)
Title.Size=UDim2.new(1,-10,1,0) Title.Position=UDim2.new(0,10,0,0)
Title.BackgroundTransparency=1 Title.Text="Heli Wars v3.4" Title.TextColor3=Color3.fromRGB(255,255,255) Title.TextSize=14 Title.Font=Enum.Font.GothamBold Title.TextXAlignment=Enum.TextXAlignment.Left

-- Кнопки
local function Btn(t,y,cb)
    local b=Instance.new("TextButton",Main) b.Size=UDim2.new(1,-20,0,38) b.Position=UDim2.new(0,10,0,y) b.BackgroundColor3=Color3.fromRGB(40,40,55) b.BorderSizePixel=0 b.Text=t.." [OFF]" b.TextColor3=Color3.fromRGB(255,255,255) b.TextSize=14 b.Font=Enum.Font.Gotham
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local en=false b.MouseButton1Click:Connect(function() en=not en b.BackgroundColor3=en and Color3.fromRGB(0,170,255)or Color3.fromRGB(40,40,55) b.Text=t..(en and" [ON]"or" [OFF]") cb(en) end) return b
end

-- Fly переменные
local flyInput,flyUp,flyDown=false,false,false
local gyro,vel=nil,nil

-- Fly GUI (скрыто по умолчанию)
local Joystick=Instance.new("Frame",ScreenGui)
Joystick.Size=UDim2.new(0,140,0,140) Joystick.Position=UDim2.new(0.08,0,0.68,0)
Joystick.BackgroundColor3=Color3.fromRGB(255,255,255) Joystick.BackgroundTransparency=0.88 Joystick.BorderSizePixel=0 Joystick.Visible=false
Instance.new("UICorner",Joystick).CornerRadius=UDim.new(1,0)

local Stick=Instance.new("Frame",Joystick)
Stick.Size=UDim2.new(0,55,0,55) Stick.Position=UDim2.new(0.5,-27,0.5,-27)
Stick.BackgroundColor3=Color3.fromRGB(0,170,255) Stick.BackgroundTransparency=0.35 Stick.BorderSizePixel=0
Instance.new("UICorner",Stick).CornerRadius=UDim.new(1,0)

local UpBtn=Instance.new("TextButton",ScreenGui)
UpBtn.Size=UDim2.new(0,55,0,55) UpBtn.Position=UDim2.new(0.32,0,0.63,0)
UpBtn.BackgroundColor3=Color3.fromRGB(0,170,255) UpBtn.BackgroundTransparency=0.55 UpBtn.BorderSizePixel=0 UpBtn.Text="▲" UpBtn.TextColor3=Color3.fromRGB(255,255,255) UpBtn.TextSize=22 UpBtn.Font=Enum.Font.GothamBold UpBtn.Visible=false
Instance.new("UICorner",UpBtn).CornerRadius=UDim.new(1,0)

local DownBtn=Instance.new("TextButton",ScreenGui)
DownBtn.Size=UDim2.new(0,55,0,55) DownBtn.Position=UDim2.new(0.32,0,0.78,0)
DownBtn.BackgroundColor3=Color3.fromRGB(0,170,255) DownBtn.BackgroundTransparency=0.55 DownBtn.BorderSizePixel=0 DownBtn.Text="▼" DownBtn.TextColor3=Color3.fromRGB(255,255,255) DownBtn.TextSize=22 DownBtn.Font=Enum.Font.GothamBold DownBtn.Visible=false
Instance.new("UICorner",DownBtn).CornerRadius=UDim.new(1,0)

-- Джойстик управление
Joystick.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then flyInput=true end end)
Joystick.InputEnded:Connect(function() flyInput=false Stick:TweenPosition(UDim2.new(0.5,-27,0.5,-27),"Out","Sine",0.1) end)
Joystick.InputChanged:Connect(function(i)
    if flyInput and i.UserInputType==Enum.UserInputType.Touch then
        local c=Joystick.AbsolutePosition+Joystick.AbsoluteSize/2
        local d=i.Position-c
        local m=Joystick.AbsoluteSize.X/2-Stick.AbsoluteSize.X/2
        if d.Magnitude>m then d=d.Unit*m end
        Stick.Position=UDim2.new(0,d.X+Joystick.AbsoluteSize.X/2-Stick.AbsoluteSize.X/2,0,d.Y+Joystick.AbsoluteSize.Y/2-Stick.AbsoluteSize.Y/2)
    end
end)
UpBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then flyUp=true end end)
UpBtn.InputEnded:Connect(function() flyUp=false end)
DownBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then flyDown=true end end)
DownBtn.InputEnded:Connect(function() flyDown=false end)

-- Кнопки меню
Btn("Silent Aim",40,function(v) Settings.SilentAimEnabled=v end)
Btn("Trigger Bot",83,function(v) Settings.TriggerBotEnabled=v end)
Btn("ESP",126,function(v) Settings.ESPEnabled=v end)
Btn("FLY (джойстик)",169,function(v)
    Settings.FlyEnabled=v
    Joystick.Visible=v UpBtn.Visible=v DownBtn.Visible=v
    if not v then
        if gyro then gyro:Destroy() gyro=nil end
        if vel then vel:Destroy() vel=nil end
        if LocalPlayer.Character then
            local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.PlatformStand=false end
        end
    end
end)
Btn("Noclip",212,function(v) Settings.NoclipEnabled=v end)
Btn("Speed Hack",255,function(v) Settings.SpeedHackEnabled=v end)
Btn("Auto Farm",298,function(v) Settings.AutoFarmEnabled=v end)

-- Перетаскивание меню
local drag,dS,sP=false,nil,nil
TopBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true dS=i.Position sP=Main.Position end end)
UserInputService.InputEnded:Connect(function() drag=false end)
UserInputService.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-dS Main.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y) end end)

-- Fly система (работает только когда ВКЛЮЧЕН)
RunService.Heartbeat:Connect(function()
    if not Settings.FlyEnabled then return end
    if not LocalPlayer.Character then return end
    local root=LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if not gyro then gyro=Instance.new("BodyGyro",root) gyro.MaxTorque=Vector3.new(400000,400000,400000) end
    if not vel then vel=Instance.new("BodyVelocity",root) vel.MaxForce=Vector3.new(400000,400000,400000) end
    
    gyro.CFrame=Camera.CFrame
    local move=Vector3.zero
    
    if flyInput then
        local jc=Joystick.AbsolutePosition+Joystick.AbsoluteSize/2
        local sc=Stick.AbsolutePosition+Stick.AbsoluteSize/2
        local d=sc-jc
        local mx=Joystick.AbsoluteSize.X/2
        if d.Magnitude>5 then
            local n=d/mx
            move=Camera.CFrame.RightVector*n.X+Camera.CFrame.LookVector*(-n.Y)
        end
    end
    if flyUp then move=move+Vector3.new(0,1,0) end
    if flyDown then move=move+Vector3.new(0,-1,0) end
    
    vel.Velocity=move.Magnitude>0 and move.Unit*Settings.FlySpeed or Vector3.zero
    
    local hum=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand=true end
end)

-- Silent Aim
local oldIndex=hookmetamethod(game,"__index",function(s,k)
    if s==Mouse and k=="Hit" and Settings.SilentAimEnabled then
        local t,cd=nil,200
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character and p.Team~=LocalPlayer.Team then
                local h=p.Character:FindFirstChild("Head")
                if h then
                    local sp,on=Camera:WorldToScreenPoint(h.Position)
                    if on then
                        local d=(Vector2.new(sp.X,sp.Y)-(Camera.ViewportSize/2)).Magnitude
                        if d<cd then cd=d t=h.Position end
                    end
                end
            end
        end
        if t then return t end
    end
    return oldIndex(s,k)
end)

-- Trigger Bot
RunService.Heartbeat:Connect(function()
    if not Settings.TriggerBotEnabled or not Settings.SilentAimEnabled then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local h=p.Character:FindFirstChild("Head")
            if h then
                local sp,on=Camera:WorldToScreenPoint(h.Position)
                if on and(Vector2.new(sp.X,sp.Y)-(Camera.ViewportSize/2)).Magnitude<200 then
                    mouse1press() break
                end
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not Settings.NoclipEnabled or not LocalPlayer.Character then return end
    for _,p in ipairs(LocalPlayer.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=Settings.SpeedHackEnabled and 40 or 16 end
    end
end)

-- Anti-AFK
local VU=game:GetService("VirtualUser")
RunService.Heartbeat:Connect(function()
    if Settings.AntiAFKEnabled then pcall(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer or not p.Character then continue end
        local hd=p.Character:FindFirstChild("Head")
        local hm=p.Character:FindFirstChildOfClass("Humanoid")
        local rt=p.Character:FindFirstChild("HumanoidRootPart")
        if not hd or not hm or hm.Health<=0 or not rt then continue end
        local hp,ho=Camera:WorldToScreenPoint(hd.Position+Vector3.new(0,0.5,0))
        local rp,ro=Camera:WorldToScreenPoint(rt.Position)
        if not ro then continue end
        local c=p.Team==LocalPlayer.Team and Color3.fromRGB(0,255,0)or Color3.fromRGB(255,0,0)
        local bh=math.abs(rp.Y-hp.Y)
        local bx=Instance.new("Frame",ScreenGui) bx.Size=UDim2.new(0,bh*0.4,0,bh) bx.Position=UDim2.new(0,hp.X-bh*0.2,0,hp.Y) bx.BackgroundTransparency=0.8 bx.BorderSizePixel=2 bx.BorderColor3=c game:GetService("Debris"):AddItem(bx,0.05)
        local nm=Instance.new("TextLabel",ScreenGui) nm.Size=UDim2.new(0,100,0,20) nm.Position=UDim2.new(0,hp.X-50,0,hp.Y-25) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=c nm.TextSize=12 nm.Font=Enum.Font.Gotham game:GetService("Debris"):AddItem(nm,0.05)
    end
end)

-- Auto Farm
RunService.Heartbeat:Connect(function()
    if not Settings.AutoFarmEnabled or not LocalPlayer.Character then return end
    local ne,nd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Team~=LocalPlayer.Team then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            local lr=LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r and lr then
                local d=(r.Position-lr.Position).Magnitude
                if d<nd then nd=d ne=p end
            end
        end
    end
    if ne then
        local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:MoveTo(ne.Character.HumanoidRootPart.Position) end
    end
end)

Notify("Heli Wars v3.4","Все функции OFF по умолчанию")