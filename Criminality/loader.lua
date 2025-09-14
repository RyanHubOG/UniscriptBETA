-- UniScript BETA using Orion UI
-- Make sure you have Orion.lua in the same folder

-- Load Orion UI
local OrionLib = loadstring(readfile("Orion.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local Settings = {
    InfiniteSprint = false,
    ESPEnabled = false,
    AimlockEnabled = false,
    WallbangEnabled = false,
    NoClipEnabled = false,
    PlayerFOV = Camera.FieldOfView,
    AimlockFOV = 150,
    AimlockPrediction = 0.18,
    MeleeAuraEnabled = false,
    MeleeReach = 10
}

-- Globals
local ESPs = {}
local sprintTables = {}
local SprintEnabled = false

-- =========================
-- UI Window
-- =========================
local Window = OrionLib:MakeWindow({
    Name = "Criminality Enhancer UniScript BETA",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniScript",
    ConfigName = "Settings"
})

-- Tabs
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483362458"})
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483362458"})
local ExtrasTab = Window:MakeTab({Name = "Extras", Icon = "rbxassetid://4483362458"})

-- =========================
-- Combat Tab Features
-- =========================
CombatTab:AddToggle({
    Name = "Aimlock",
    Default = false,
    Callback = function(value)
        Settings.AimlockEnabled = value
    end
})

CombatTab:AddSlider({
    Name = "Aimlock FOV",
    Min = 50,
    Max = 300,
    Default = Settings.AimlockFOV,
    Increment = 1,
    Callback = function(value)
        Settings.AimlockFOV = value
    end
})

CombatTab:AddSlider({
    Name = "Aimlock Prediction",
    Min = 0,
    Max = 1,
    Default = Settings.AimlockPrediction,
    Increment = 0.01,
    Callback = function(value)
        Settings.AimlockPrediction = value
    end
})

CombatTab:AddToggle({
    Name = "Wallbang",
    Default = false,
    Callback = function(value)
        Settings.WallbangEnabled = value
    end
})

CombatTab:AddToggle({
    Name = "Melee Aura",
    Default = false,
    Callback = function(value)
        Settings.MeleeAuraEnabled = value
    end
})

CombatTab:AddSlider({
    Name = "Melee Reach",
    Min = 1,
    Max = 30,
    Default = Settings.MeleeReach,
    Increment = 1,
    Callback = function(value)
        Settings.MeleeReach = value
    end
})

-- =========================
-- Misc Tab Features
-- =========================
MiscTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(value)
        Settings.NoClipEnabled = value
    end
})

MiscTab:AddToggle({
    Name = "Infinite Sprint",
    Default = false,
    Callback = function(value)
        SprintEnabled = value
    end
})

MiscTab:AddSlider({
    Name = "Player FOV",
    Min = 70,
    Max = 120,
    Default = Settings.PlayerFOV,
    Increment = 1,
    Callback = function(value)
        Settings.PlayerFOV = value
        Camera.FieldOfView = value
    end
})

MiscTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(value)
        Settings.ESPEnabled = value
    end
})

-- =========================
-- Extras Tab Features
-- =========================
ExtrasTab:AddButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("https://discord.gg/dJEM47ZtGa")
    end
})

ExtrasTab:AddButton({
    Name = "Unload Script",
    Callback = function()
        -- Disconnect loops, remove ESPs
        for _, v in pairs(ESPs) do
            if v.Billboard then v.Billboard:Destroy() end
        end
        Camera.FieldOfView = 70
        print("UniScript fully unloaded!")
        OrionLib:Destroy()
    end
})

-- =========================
-- Infinite Sprint (Laggy but functional)
-- =========================
local function getTargetTables()
    local found = {}
    for _, tbl in pairs(getgc(true)) do
        if typeof(tbl) == "table" and rawget(tbl,"S") and typeof(tbl.S)=="number" then
            table.insert(found, tbl)
        end
    end
    return found
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    sprintTables = getTargetTables()
end)

sprintTables = getTargetTables()

task.spawn(function()
    while task.wait(0.1) do
        if SprintEnabled then
            for _, tbl in pairs(sprintTables) do
                rawset(tbl,"S",100)
            end
        end
    end
end)

-- =========================
-- ESP (simplified)
-- =========================
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.ESPEnabled then
                if not ESPs[player] then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP"
                    billboard.Size = UDim2.new(0,120,0,50)
                    billboard.Adornee = player.Character.HumanoidRootPart
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0,2,0)
                    billboard.Parent = game:GetService("CoreGui")
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1,0,0.4,0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.new(0,1,0)
                    nameLabel.TextScaled = true
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.Text = player.Name
                    nameLabel.Parent = billboard
                    
                    ESPs[player] = {Billboard = billboard, Name = nameLabel}
                end
            else
                if ESPs[player] then
                    ESPs[player].Billboard:Destroy()
                    ESPs[player] = nil
                end
            end
        end
    end
end)

print("UniScript BETA loaded with Orion UI!")
