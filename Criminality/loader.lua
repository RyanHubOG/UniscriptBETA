--// UniScript BETA Loader (Full Optimized Version with Low-Lag Infinite Sprint)

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
-- SAFE RAYFIELD LOADING
-- =========================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)

if not success or not Rayfield then
    warn("Rayfield failed to load. UI will not appear.")
    return
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

-- =========================
-- AIMLOCK CENTERED
-- =========================
local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255,0,0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 100
    FOVCircle.Radius = Settings.AimlockFOV
    FOVCircle.Filled = false
end)

local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = ScreenCenter
        FOVCircle.Radius = Settings.AimlockFOV
        FOVCircle.Visible = Settings.AimlockEnabled
    end
end)

local function aimAtTarget(target)
    if target and target:FindFirstChild("Head") and target:FindFirstChild("HumanoidRootPart") then
        local cam = Camera
        local head = target.Head
        local root = target.HumanoidRootPart
        local predictedPos = head.Position + root.Velocity * Settings.AimlockPrediction
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
                local dist = (Vector2.new(screenPos.X,screenPos.Y)-ScreenCenter).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    if closest then aimAtTarget(closest.Character) end
end

UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Settings.AimlockActive = true end
end)

UserInputService.InputEnded:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Settings.AimlockActive = false end
end)

-- =========================
-- COMBAT TAB UI
-- =========================
CombatTab:CreateToggle({Name="Aimlock", CurrentValue=false, Flag="Aimlock", Callback=function(v) Settings.AimlockEnabled=v end})
CombatTab:CreateSlider({Name="Aimlock FOV", Range={50,500}, Increment=5, Suffix="px", CurrentValue=150, Flag="AimlockFOV", Callback=function(v) Settings.AimlockFOV=v if FOVCircle then FOVCircle.Radius=v end end})
CombatTab:CreateSlider({Name="Aimlock Prediction", Range={0,0.5}, Increment=0.01, Suffix="", CurrentValue=0.18, Flag="AimlockPrediction", Callback=function(v) Settings.AimlockPrediction=v end})
CombatTab:CreateToggle({Name="Wallbang", CurrentValue=false, Flag="Wallbang", Callback=function(v) Settings.WallbangEnabled=v end})
CombatTab:CreateToggle({Name="Melee Aura", CurrentValue=false, Flag="MeleeAura", Callback=function(v) Settings.MeleeAuraEnabled=v end})
CombatTab:CreateSlider({Name="Melee Reach", Range={1,30}, Increment=1, Suffix=" studs", CurrentValue=10, Flag="MeleeReach", Callback=function(v) Settings.MeleeReach=v end})

-- =========================
-- MISC TAB UI
-- =========================
MiscTab:CreateToggle({Name="NoClip", CurrentValue=false, Flag="NoClip", Callback=function(v) Settings.NoClipEnabled=v end})
MiscTab:CreateSlider({Name="Player FOV", Range={70,120}, Increment=1, Suffix="", CurrentValue=Camera.FieldOfView, Flag="PlayerFOV", Callback=function(v) Settings.PlayerFOV=v Camera.FieldOfView=v end})

-- =========================
-- EXTRAS TAB UI
-- =========================
ExtrasTab:CreateButton({Name="Copy Discord", Callback=function() setclipboard("https://discord.gg/dJEM47ZtGa") end})
ExtrasTab:CreateButton({Name="Unload Script", Callback=function()
    for _, conn in pairs(connections) do conn:Disconnect() end
    for player, _ in pairs(ESPs) do ESPs[player].Billboard:Destroy() end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed=16 end
    Camera.FieldOfView = 70
    if Window then Window:Unload() end
    print("UniScript fully unloaded!")
end})
