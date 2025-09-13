--// Loader.lua for Roblox (UniScript BETA, 3 Tabs, Laggy Infinite Sprint, ESP, Aimlock, Wallbang, NoClip, Reach Punch, Visual FOV, Unload)

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
    MeleeAuraEnabled = false,
    MeleeReach = 10,
}

-- Globals
local ESPs = {}
local connections = {}

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local Window = Rayfield:CreateWindow({
    Name = "UniScript BETA",             
    LoadingTitle = "UniScript is loading...",  
    LoadingSubtitle = "by Ryan",         
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
-- ======= INFINITE SPRINT (Laggy but slightly optimized) ======
-- =========================

local function toggleInfiniteSprint(enable)
    Settings.InfiniteSprint = enable
end

table.insert(connections, RunService.RenderStepped:Connect(function()
    if Settings.InfiniteSprint then
        for i,v in pairs(getgc(true)) do
            if type(v)=="table" and rawget(v,"S") then
                v.S = 100
                break -- early exit to reduce lag
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
-- ======= AIMLOCK FOV CIRCLE ======
-- =========================
local DrawingService = Drawing
local FOVCircle = DrawingService.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255,0,0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = Settings.AimlockFOV
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = Settings.AimlockFOV
    FOVCircle.Visible = Settings.AimlockEnabled
end)

-- =========================
-- ======= MELEE AURA / REACH PUNCH ======
-- =========================

RunService.RenderStepped:Connect(function()
    if Settings.MeleeAuraEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= Settings.MeleeReach then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:TakeDamage(10) -- adjustable damage
                    end
                end
            end
        end
    end
end)

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
