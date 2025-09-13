--// UniScript BETA Loader (Safe Version)

-- Services (ensure none are nil)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Safe pcall wrapper for any feature
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
        Name = "UniScript BETA",
        LoadingTitle = "UniScript is loading...",
        LoadingSubtitle = "by Ryan",
        Theme = "Dark",
        ConfigurationSaving = {Enabled=true, FolderName="CriminalityScripts", FileName="Settings"},
        KeySystem = false
    })
end, "Rayfield Window")

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
-- SAFE RENDERSTEPPED CONNECTION EXAMPLE
-- =========================
RunService.RenderStepped:Connect(function()
    safeCall(function()
        -- Example: ESP / Aimlock code here
        if Settings.ESPEnabled then
            -- Update ESP safely
        end
        if Settings.AimlockActive then
            -- Aimlock code safely
        end
    end, "Main RenderStepped")
end)
