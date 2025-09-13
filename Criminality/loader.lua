--// UniScript BETA Loader (Reliable & Optimized)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

-- =========================
-- RELIABLE RAYFIELD LOADING
-- =========================
local Rayfield
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/Rayfield.lua"))()
end)

if success and result then
    Rayfield = result
else
    if pcall(function() readfile("Rayfield.lua") end) then
        Rayfield = loadstring(readfile("Rayfield.lua"))()
    else
        warn("Rayfield failed to load. Make sure the URL works or 'Rayfield.lua' exists locally.")
        return
    end
end

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
-- FPS BAR
-- =========================
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0,100,0,25)
fpsLabel.Position = UDim2.new(0,10,0,10)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.ResetOnSpawn = false
fpsLabel.Parent = LocalPlayer:WaitForChild("PlayerGui")

local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    local fps = 1 / (currentTime - lastTime)
    lastTime = currentTime
    fpsLabel.Text = "FPS: "..math.floor(fps)
end)

-- =========================
-- ESP
-- =========================
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
    billboard.Parent = game:GetService("CoreGui")

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

table.insert(connections, RunService.RenderStepped:Connect(function()
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.ESPEnabled then
                if not ESPs[player] then createESP(player) end
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then ESPs[player].HealthBar.Size = UDim2.new(hum.Health / hum.MaxHealth,0,0.2,0) end
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if ESPs[player] then ESPs[player].Distance.Text = string.format("%.0f studs", distance) end
            else
                removeESP(player)
            end
        else
            removeESP(player)
        end
    end
end))

-- =========================
-- INFINITE SPRINT (Optimized getgc method)
-- =========================
local sprintTables = {}
local SprintEnabled = false

local function getTargetTables()
    local found = {}
    for _, tbl in getgc(true) do
        if typeof(tbl) == "table" and rawget(tbl, "S") then
            if typeof(rawget(tbl, "S")) == "number" then    
                table.insert(found, tbl)
            end
        end
    end
    return found
end

task.spawn(function()
    while task.wait(0.1) do
        if SprintEnabled then
            for _, tbl in pairs(sprintTables) do
                rawset(tbl, "S", 100)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    sprintTables = getTargetTables()
end)

sprintTables = getTargetTables()

-- Hook up UI toggle
MiscTab:CreateToggle({
    Name = "Infinite Sprint",
    CurrentValue = false,
    Flag = "InfiniteSprint",
    Callback = function(v)
        SprintEnabled = v
    end
})
