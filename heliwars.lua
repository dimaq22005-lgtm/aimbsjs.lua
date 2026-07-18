--[[
    Heli Wars Premium Script v3.0
    Developer: Top-Tier Scripter | 5+ Years Experience
    Executor: Delta Executor (Android/iOS)
    Optimized for Mobile | Silent Aim | Visuals | Misc
    
    Architecture: Event-Driven, Modular, Optimized
    Best Practices 2026: Heartbeat/Stepped only when needed, minimal table creation, pooled connections
--]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Drawing = Drawing or {}
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

--// Anti-Crash Protection
local success, err = pcall(function()
    -- Variable Initialization
    local Settings = {
        -- Silent Aim
        SilentAimEnabled = false,
        SilentAimSmoothness = 0.5,
        SilentAimFOV = 100,
        SilentAimFOVEnabled = true,
        SilentAimFOVColor = Color3.fromRGB(255, 255, 255),
        SilentAimAimPart = "Head",
        SilentAimPrediction = 0.1,
        SilentAimTeamCheck = true,
        SilentAimWallCheck = true,
        TriggerBotEnabled = false,
        
        -- Visuals
        ESPEnabled = false,
        ESPBoxes = true,
        ESPNames = true,
        ESPHealth = true,
        ESPDistance = true,
        ESPWeapon = true,
        ESPTeamColor = true,
        TracersEnabled = false,
        HeadDotsEnabled = false,
        SkeletonEnabled = false,
        ESPTransparency = 0.7,
        ESPColor = Color3.fromRGB(255, 0, 0),
        
        -- Aimbot
        AimbotEnabled = false,
        AimbotSmoothness = 0.3,
        AimbotFOV = 100,
        AimbotAimPart = "Head",
        AimbotVisible = false,
        
        -- Misc
        FlyEnabled = false,
        FlySpeed = 20,
        NoclipEnabled = false,
        VehicleNoclip = false,
        InfiniteJumpEnabled = false,
        SpeedHackEnabled = false,
        SpeedHackValue = 30,
        JumpPowerEnabled = false,
        JumpPowerValue = 70,
        AntiAFKEnabled = true,
        HitboxExpanderEnabled = false,
        HitboxSize = 2,
        NoRecoilEnabled = false,
        NoSpreadEnabled = false,
        AutoFarmEnabled = false,
        
        -- Settings
        MenuHidden = false,
        SaveSettings = true
    }
    
    -- Save/Load System
    local SaveFileName = "HeliWars_Settings.json"
    
    local function SaveSettings()
        if not Settings.SaveSettings then return end
        pcall(function()
            local data = HttpService:JSONEncode(Settings)
            writefile(SaveFileName, data)
        end)
    end
    
    local function LoadSettings()
        pcall(function()
            if isfile and isfile(SaveFileName) then
                local data = readfile(SaveFileName)
                local decoded = HttpService:JSONDecode(data)
                for k, v in pairs(decoded) do
                    if Settings[k] ~= nil then
                        Settings[k] = v
                    end
                end
            end
        end)
    end
    
    LoadSettings()
    
    --// Notification System
    local function Notify(title, message, duration)
        duration = duration or 3
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = message,
                Duration = duration,
            })
        end)
    end
    
    --// Drawing Library Compatibility Layer
    local function DrawCircle(pos, radius, color, filled, transparency)
        local circle = Drawing.new("Circle")
        circle.Position = pos
        circle.Radius = radius
        circle.Color = color
        circle.Filled = filled or false
        circle.Transparency = transparency or 1
        circle.Visible = true
        return circle
    end
    
    local function DrawLine(from, to, color, transparency)
        local line = Drawing.new("Line")
        line.From = from
        line.To = to
        line.Color = color
        line.Transparency = transparency or 1
        line.Visible = true
        return line
    end
    
    local function DrawText(text, pos, color, size, font, transparency)
        local txt = Drawing.new("Text")
        txt.Text = text
        txt.Position = pos
        txt.Color = color
        txt.Size = size or 18
        txt.Font = font or 2
        txt.Transparency = transparency or 1
        txt.Visible = true
        return txt
    end
    
    local function DrawSquare(pos, size, color, filled, transparency)
        local square = Drawing.new("Square")
        square.Position = pos
        square.Size = size
        square.Color = color
        square.Filled = filled or false
        square.Transparency = transparency or 1
        square.Visible = true
        return square
    end
    
    --// Main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HeliWarsPremium"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 8)
    UICorner2.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Heli Wars Premium"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    local HideButton = Instance.new("TextButton")
    HideButton.Size = UDim2.new(0, 30, 0, 30)
    HideButton.Position = UDim2.new(1, -35, 0, 2.5)
    HideButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    HideButton.BorderSizePixel = 0
    HideButton.Text = "-"
    HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HideButton.TextSize = 20
    HideButton.Font = Enum.Font.GothamBold
    HideButton.Parent = TopBar
    
    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 6)
    UICorner3.Parent = HideButton
    
    -- Tab Buttons Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local Tabs = {"Main", "Combat", "Visuals", "Misc", "Settings"}
    local TabButtons = {}
    local Pages = {}
    
    for i, tab in ipairs(Tabs) do
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.2, -4, 1, -5)
        Button.Position = UDim2.new((i-1)*0.2, 3, 0, 2.5)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Button.BorderSizePixel = 0
        Button.Text = tab
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.TextSize = 13
        Button.Font = Enum.Font.GothamBold
        Button.Parent = TabContainer
        
        local UICorner4 = Instance.new("UICorner")
        UICorner4.CornerRadius = UDim.new(0, 5)
        UICorner4.Parent = Button
        
        TabButtons[tab] = Button
        
        -- Page
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, -75)
        Page.Position = UDim2.new(0, 0, 0, 75)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Visible = (tab == "Main")
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = MainFrame
        
        Pages[tab] = Page
    end
    
    -- Function to create UI elements
    local function CreateToggle(page, text, default, callback)
        local Y = page.UIListLayout and #page:GetChildren() * 35 or 0
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -20, 0, 30)
        Button.Position = UDim2.new(0, 10, 0, 5 + Y)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.Parent = page
        
        local UICorner5 = Instance.new("UICorner")
        UICorner5.CornerRadius = UDim.new(0, 6)
        UICorner5.Parent = Button
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Button
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 45, 0, 20)
        ToggleIndicator.Position = UDim2.new(1, -55, 0.5, -10)
        ToggleIndicator.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 100)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Parent = Button
        
        local UICorner6 = Instance.new("UICorner")
        UICorner6.CornerRadius = UDim.new(1, 0)
        UICorner6.Parent = ToggleIndicator
        
        local ToggleDot = Instance.new("Frame")
        ToggleDot.Size = UDim2.new(0, 16, 0, 16)
        ToggleDot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDot.BorderSizePixel = 0
        ToggleDot.Parent = ToggleIndicator
        
        local UICorner7 = Instance.new("UICorner")
        UICorner7.CornerRadius = UDim.new(1, 0)
        UICorner7.Parent = ToggleDot
        
        Button.MouseButton1Click:Connect(function()
            default = not default
            ToggleIndicator.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 100)
            ToggleDot:TweenPosition(
                default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                "Out",
                "Quad",
                0.15
            )
            callback(default)
        end)
        
        page.CanvasSize = UDim2.new(0, 0, 0, Y + 45)
        return Button
    end
    
    -- Create UIListLayout for pages
    for _, page in pairs(Pages) do
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 5)
        UIListLayout.Parent = page
    end
    
    -- Tab switching
    for tab, button in pairs(TabButtons) do
        button.MouseButton1Click:Connect(function()
            for _, page in pairs(Pages) do
                page.Visible = false
            end
            Pages[tab].Visible = true
            
            for _, btn in pairs(TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end)
    end
    
    -- Set first tab active
    TabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    
    --// Main Page
    CreateToggle(Pages["Main"], "Silent Aim", Settings.SilentAimEnabled, function(val)
        Settings.SilentAimEnabled = val
        Notify("Silent Aim", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Main"], "Trigger Bot", Settings.TriggerBotEnabled, function(val)
        Settings.TriggerBotEnabled = val
        Notify("Trigger Bot", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Main"], "Aimbot", Settings.AimbotEnabled, function(val)
        Settings.AimbotEnabled = val
        Notify("Aimbot", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Main"], "ESP", Settings.ESPEnabled, function(val)
        Settings.ESPEnabled = val
        Notify("ESP", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Main"], "Auto Farm", Settings.AutoFarmEnabled, function(val)
        Settings.AutoFarmEnabled = val
        Notify("Auto Farm", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    --// Combat Page
    CreateToggle(Pages["Combat"], "Silent Aim", Settings.SilentAimEnabled, function(val)
        Settings.SilentAimEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "FOV Circle", Settings.SilentAimFOVEnabled, function(val)
        Settings.SilentAimFOVEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "Team Check", Settings.SilentAimTeamCheck, function(val)
        Settings.SilentAimTeamCheck = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "Wall Check", Settings.SilentAimWallCheck, function(val)
        Settings.SilentAimWallCheck = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "Trigger Bot", Settings.TriggerBotEnabled, function(val)
        Settings.TriggerBotEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "Aimbot", Settings.AimbotEnabled, function(val)
        Settings.AimbotEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "No Recoil", Settings.NoRecoilEnabled, function(val)
        Settings.NoRecoilEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "No Spread", Settings.NoSpreadEnabled, function(val)
        Settings.NoSpreadEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Combat"], "Hitbox Expander", Settings.HitboxExpanderEnabled, function(val)
        Settings.HitboxExpanderEnabled = val
        SaveSettings()
    end)
    
    --// Visuals Page
    CreateToggle(Pages["Visuals"], "ESP Enabled", Settings.ESPEnabled, function(val)
        Settings.ESPEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Boxes", Settings.ESPBoxes, function(val)
        Settings.ESPBoxes = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Names", Settings.ESPNames, function(val)
        Settings.ESPNames = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Health", Settings.ESPHealth, function(val)
        Settings.ESPHealth = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Distance", Settings.ESPDistance, function(val)
        Settings.ESPDistance = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Weapon", Settings.ESPWeapon, function(val)
        Settings.ESPWeapon = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Team Colors", Settings.ESPTeamColor, function(val)
        Settings.ESPTeamColor = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Tracers", Settings.TracersEnabled, function(val)
        Settings.TracersEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Head Dots", Settings.HeadDotsEnabled, function(val)
        Settings.HeadDotsEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Visuals"], "Skeleton", Settings.SkeletonEnabled, function(val)
        Settings.SkeletonEnabled = val
        SaveSettings()
    end)
    
    --// Misc Page
    CreateToggle(Pages["Misc"], "Fly", Settings.FlyEnabled, function(val)
        Settings.FlyEnabled = val
        Notify("Fly", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Misc"], "Noclip", Settings.NoclipEnabled, function(val)
        Settings.NoclipEnabled = val
        Notify("Noclip", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Misc"], "Infinite Jump", Settings.InfiniteJumpEnabled, function(val)
        Settings.InfiniteJumpEnabled = val
        Notify("Infinite Jump", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Misc"], "Speed Hack", Settings.SpeedHackEnabled, function(val)
        Settings.SpeedHackEnabled = val
        Notify("Speed Hack", val and "Enabled" or "Disabled")
        SaveSettings()
    end)
    
    CreateToggle(Pages["Misc"], "Anti-AFK", Settings.AntiAFKEnabled, function(val)
        Settings.AntiAFKEnabled = val
        SaveSettings()
    end)
    
    CreateToggle(Pages["Misc"], "Server Hop", false, function(val)
        if val then
            local servers = {}
            pcall(function()
                local Http = game:GetService("HttpService")
                local req = request or syn.request
                local data = req({
                    Url = "https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?limit=100"
                })
                local json = Http:JSONDecode(data.Body)
                for _, server in ipairs(json.data) do
                    if server.playing < server.maxPlayers then
                        table.insert(servers, server.id)
                    end
                end
                if #servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
                end
            end)
        end
    end)
    
    --// Settings Page
    CreateToggle(Pages["Settings"], "Save Settings", Settings.SaveSettings, function(val)
        Settings.SaveSettings = val
        SaveSettings()
    end)
    
    --// Hide/Show Button
    local MinimizedButton = Instance.new("TextButton")
    MinimizedButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizedButton.Position = UDim2.new(0, 10, 0, 10)
    MinimizedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    MinimizedButton.BorderSizePixel = 0
    MinimizedButton.Text = "HW"
    MinimizedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizedButton.TextSize = 16
    MinimizedButton.Font = Enum.Font.GothamBold
    MinimizedButton.Visible = false
    MinimizedButton.Parent = ScreenGui
    
    local UICorner8 = Instance.new("UICorner")
    UICorner8.CornerRadius = UDim.new(0, 8)
    UICorner8.Parent = MinimizedButton
    
    HideButton.MouseButton1Click:Connect(function()
        Settings.MenuHidden = true
        MainFrame.Visible = false
        MinimizedButton.Visible = true
    end)
    
    MinimizedButton.MouseButton1Click:Connect(function()
        Settings.MenuHidden = false
        MainFrame.Visible = true
        MinimizedButton.Visible = false
    end)
    
    -- Make GUI draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = fals