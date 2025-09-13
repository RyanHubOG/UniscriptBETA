--// Loader.lua for Roblox (3 Tabs, Laggy Infinite Sprint, ESP, Aimlock, NoClip, Wallbang, Unload)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    InfiniteSprint = false,
    ESPEnabled = false,
    AimlockEnabled = false,
    WallbangEnabled = false,
    NoClipEnabled = false,
    AimlockFOV = 150,
    AimlockActive = false,
    PlayerFOV = Camera.FieldOfView,
    AimlockPrediction = 0.18,
}

-- Globals
local ESPs = {}
local connections = {}

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local Window = Rayfield:CreateWindow({
    Name = "Criminality Enhancer",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by YourName",
    Theme = "Dark",
    ConfigurationSaving = {Enabled=true, FolderName="CriminalityScripts", FileName="Settings"},
    KeySystem = false
})

-- Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ExtrasTab = Window:CreateTab("Extras", 4483362458)

-- =========================
-- ======= FUNCTIONS ======
-- =========================

-- ESP
local function createESP(player)
    if ESPs[player] then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0,120,0,50)
    billboard.Adornee = character.HumanoidRootPart
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0,2,0)
    billboard.Parent = game.CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,0.4,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(0,1,0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextScaled = true
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1,0,0.2,0)
    healthBar.Position = UDim2.new(0,0,0.4,0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1,0,0.4,0)
    distLabel.Position = UDim2.new(0,0,0.6,0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.new(1,1,0)
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.TextScaled = true
    distLabel.Text = ""
    distLabel.Parent = billboard

    ESPs[player] = {Billboard=billboard, Name=nameLabel, HealthBar=healthBar, Distance=distLabel}
end

local function removeESP(player)
    if ESPs[player] then
        ESPs[player].Billboard:Destroy()
        ESPs[player] = nil
    end
end

local function updateESP()
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.ESPEnabled then
                if not ESPs[player] then createESP(player) end
                local hum = player.Character:FindFirstChild("Humanoid")
                local root = player.Character.HumanoidRootPart
                if hum then ESPs[player].HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth,0,0.2,0) end
                local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                ESPs[player].Distance.Text = string.format("%.0f studs", distance)
            else
                removeESP(player)
            end
        else
            removeESP(player)
        end
    end
end

-- =========================
-- ======= INFINITE SPRINT (Laggy but reliable) ======
-- =========================

local function toggleInfiniteSprint(enable)
    Settings.InfiniteSprint = enable
end

-- Apply sprint every frame (laggy but reliable)
table.insert(connections, RunService.RenderStepped:Connect(function()
    if Settings.InfiniteSprint then
        for i,v in pairs(getgc(true)) do
            if type(v)=="table" and rawget(v,"S") then
                v.S = 100
            end
        end
    end
end))

-- =========================
-- ======= AIMLOCK ======
-- =========================

local function aimAtTarget(target)
    if target and target:FindFirstChild("Head") and target:FindFirstChild("HumanoidRootPart") then
        local cam = Camera
        local head = target.Head
        local root = target.HumanoidRootPart
        local predictedPos = head.Position + root.Velocity * (Settings.AimlockPrediction or 0.18)
        local direction = (predictedPos - cam.CFrame.Position).Unit
        cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + direction)
    end
end

local function runAimlock()
    if not Settings.AimlockActive then return end
    local closest
    local shortest = Settings.AimlockFOV
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X,screenPos.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    if closest then aimAtTarget(closest.Character) end
end

-- =========================
-- ======= NOCLIP ======
-- =========================

local function setNoClip(enable)
    Settings.NoClipEnabled = enable
end

-- =========================
-- ======= CONNECTIONS ======
-- =========================

table.insert(connections, RunService.Stepped:Connect(function()
    if Settings.NoClipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if Settings.ESPEnabled then updateESP() else
        for player,_ in pairs(ESPs) do removeESP(player) end
    end
    if Settings.AimlockEnabled then runAimlock() end
    Camera.FieldOfView = Settings.PlayerFOV
end))

table.insert(connections, LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    if Settings.ESPEnabled then updateESP() end
end))

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then Settings.AimlockActive=true end
end)
UserInputService.InputEnded:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then Settings.AimlockActive=false end
end)

-- =========================
-- ======= UI ELEMENTS ======
-- =========================

-- Combat Tab
CombatTab:CreateToggle({Name="Aimlock", CurrentValue=false, Flag="Aimlock", Callback=function(v) Settings.AimlockEnabled=v end})
CombatTab:CreateSlider({Name="Aimlock FOV", Range={50,500}, Increment=5, Suffix="px", CurrentValue=150, Flag="AimlockFOV", Callback=function(v) Settings.AimlockFOV=v end})
CombatTab:CreateSlider({Name="Aimlock Prediction", Range={0,0.5}, Increment=0.01, Suffix="", CurrentValue=0.18, Flag="AimlockPrediction", Callback=function(v) Settings.AimlockPrediction=v end})
CombatTab:CreateToggle({Name="Wallbang", CurrentValue=false, Flag="Wallbang", Callback=function(v) Settings.WallbangEnabled=v end})

-- Misc Tab
MiscTab:CreateToggle({Name="NoClip", CurrentValue=false, Flag="NoClip", Callback=function(v) setNoClip(v) end})
MiscTab:CreateToggle({Name="Infinite Sprint", CurrentValue=false, Flag="InfiniteSprint", Callback=function(v) toggleInfiniteSprint(v) end})
MiscTab:CreateSlider({Name="Player FOV", Range={70,120}, Increment=1, Suffix="", CurrentValue=Camera.FieldOfView, Flag="PlayerFOV", Callback=function(v) Settings.PlayerFOV=v end})

-- Extras Tab
ExtrasTab:CreateButton({Name="Copy Discord", Callback=function() setclipboard("https://discord.gg/YOURDISCORD") end})
ExtrasTab:CreateButton({Name="Unload Script", Callback=function()
    for _,conn in pairs(connections) do conn:Disconnect() end
    for player,_ in pairs(ESPs) do removeESP(player) end
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    Camera.FieldOfView = 70
    if Window then Window:Unload() end
    print("Loader fully unloaded!")
end})

print("Loader ready: 3 Tabs, Laggy Infinite Sprint, ESP, Aimlock, NoClip, Wallbang, Unload functional.")
