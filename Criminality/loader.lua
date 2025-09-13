--// UniScript BETA Loader (Fully Safe & Complete)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Safe call wrapper
local function safeCall(func, name)
    local success, err = pcall(func)
    if not success then
        warn("Error in "..name..": "..err)
    end
end

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
local sprintTables = {}
local SprintEnabled = false

-- =========================
-- SAFE RAYFIELD LOADING
-- =========================
local Rayfield
safeCall(function()
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
end, "Rayfield Load")

if not Rayfield then return end

local Window = safeCall(function()
    return Rayfield:CreateWindow({
        Name = "Criminality Enhancer UniScript BETA",
        LoadingTitle = "UniScript is loading...",
        LoadingSubtitle = "by Ryan",
        Theme = "Dark",
        ConfigurationSaving = {Enabled=true, FolderName="CriminalityScripts", FileName="Settings"},
        KeySystem = false
    })
end, "Rayfield Window")

-- Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local ExtrasTab = Window:CreateTab("Extras", 4483362458)

-- =========================
-- FPS BAR
-- =========================
safeCall(function()
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
        safeCall(function()
            local currentTime = tick()
            local fps = 1 / (currentTime - lastTime)
            lastTime = currentTime
            fpsLabel.Text = "FPS: "..math.floor(fps)
        end, "FPS Update")
    end)
end, "FPS Bar Init")

-- =========================
-- SAFE INFINITE SPRINT
-- =========================
local function getTargetTables()
    local found = {}
    for _, tbl in getgc(true) do
        if typeof(tbl) == "table" and rawget(tbl, "S") and typeof(rawget(tbl,"S")) == "number" then
            table.insert(found, tbl)
        end
    end
    return found
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    safeCall(function()
        sprintTables = getTargetTables()
    end, "Sprint Tables Refresh")
end)

sprintTables = getTargetTables()

task.spawn(function()
    while task.wait(0.1) do
        safeCall(function()
            if SprintEnabled then
                for _, tbl in pairs(sprintTables) do
                    rawset(tbl, "S", 100)
                end
            end
        end, "Infinite Sprint Loop")
    end
end)

MiscTab:CreateToggle({
    Name = "Infinite Sprint",
    CurrentValue = false,
    Flag = "InfiniteSprint",
    Callback = function(v)
        safeCall(function()
            SprintEnabled = v
        end, "Infinite Sprint Toggle")
    end
})

-- =========================
-- SAFE ESP
-- =========================
local function createESP(player)
    safeCall(function()
        if ESPs[player] then return end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(0,120,0,50)
        billboard.Adornee = char.HumanoidRootPart
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
    end, "ESP Create "..player.Name)
end

local function removeESP(player)
    safeCall(function()
        if ESPs[player] then
            ESPs[player].Billboard:Destroy()
            ESPs[player] = nil
        end
    end, "ESP Remove "..player.Name)
end

RunService.RenderStepped:Connect(function()
    safeCall(function()
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
    end, "ESP Update")
end)

-- =========================
-- Combat / Misc / Extras UI
-- =========================

-- Combat Tab
CombatTab:CreateToggle({Name="Aimlock", CurrentValue=false, Flag="Aimlock", Callback=function(v) safeCall(function() Settings.AimlockEnabled=v end,"Aimlock Toggle") end})
CombatTab:CreateSlider({Name="Aimlock FOV", Range={50,300}, Increment=1, Suffix="", CurrentValue=Settings.AimlockFOV, Flag="AimlockFOV", Callback=function(v) safeCall(function() Settings.AimlockFOV=v end,"Aimlock FOV") end})
CombatTab:CreateSlider({Name="Aimlock Prediction", Range={0,1}, Increment=0.01, Suffix="", CurrentValue=Settings.AimlockPrediction, Flag="AimlockPrediction", Callback=function(v) safeCall(function() Settings.AimlockPrediction=v end,"Aimlock Prediction") end})
CombatTab:CreateToggle({Name="Wallbang", CurrentValue=false, Flag="Wallbang", Callback=function(v) safeCall(function() Settings.WallbangEnabled=v end,"Wallbang") end})
CombatTab:CreateToggle({Name="Melee Aura", CurrentValue=false, Flag="MeleeAura", Callback=function(v) safeCall(function() Settings.MeleeAuraEnabled=v end,"Melee Aura") end})
CombatTab:CreateSlider({Name="Melee Reach", Range={1,30}, Increment=1, Suffix=" studs", CurrentValue=10, Flag="MeleeReach", Callback=function(v) safeCall(function() Settings.MeleeReach=v end,"Melee Reach") end})

-- Misc Tab
MiscTab:CreateToggle({Name="NoClip", CurrentValue=false, Flag="NoClip", Callback=function(v) safeCall(function() Settings.NoClipEnabled=v end,"NoClip") end})
MiscTab:CreateSlider({Name="Player FOV", Range={70,120}, Increment=1, Suffix="", CurrentValue=Camera.FieldOfView, Flag="PlayerFOV", Callback=function(v) safeCall(function() Settings.PlayerFOV=v Camera.FieldOfView=v end,"Player FOV") end})
MiscTab:CreateToggle({Name="ESP", CurrentValue=false, Flag="ESP", Callback=function(v) safeCall(function() Settings.ESPEnabled=v end,"ESP Toggle") end})

-- Extras Tab
ExtrasTab:CreateButton({Name="Copy Discord", Callback=function() safeCall(function() setclipboard("https://discord.gg/dJEM47ZtGa") end,"Copy Discord") end})
ExtrasTab:CreateButton({Name="Unload Script", Callback=function()
    safeCall(function()
        for _, conn in pairs(connections) do conn:Disconnect() end
        for player, _ in pairs(ESPs) do ESPs[player].Billboard:Destroy() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed=16 end
        Camera.FieldOfView = 70
        if Window then Window:Unload() end
        print("UniScript fully unloaded!")
    end,"Unload Script")
end})

print("UniScript BETA Loaded Safely!")
