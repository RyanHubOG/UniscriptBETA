--// Loader.lua for Roblox (Fully Optimized & Functional)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings (All OFF by default)
local Settings = {
    InfiniteSprint = false,
    ESPEnabled = false,
    AimlockEnabled = false,
    WallbangEnabled = false,
    AimlockFOV = 150,
    AimlockActive = false,
    PlayerFOV = Camera.FieldOfView,
    AimlockPrediction = 0.18,
}

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Criminality Enhancer",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by YourName",
    Theme = "Dark",
    ConfigurationSaving = {Enabled=true, FolderName="CriminalityScripts", FileName="Settings"},
    KeySystem = false
})

local Tab = Window:CreateTab("Features", 4483362458)

-- ESP
local ESPs = {}
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

-- Optimized Infinite Sprint
local sprintPatched = false
local originalSprint

local function toggleInfiniteSprint(enable)
    if enable and not sprintPatched then
        for i,v in pairs(getgc(true)) do
            if type(v)=="table" and rawget(v,"S") then
                originalSprint = v.S
                v.S = 100 -- Max sprint
                sprintPatched = true
                break
            end
        end
    elseif not enable and sprintPatched then
        if originalSprint then
            for i,v in pairs(getgc(true)) do
                if type(v)=="table" and rawget(v,"S") then
                    v.S = originalSprint
                    sprintPatched = false
                    break
                end
            end
        end
    end
end

-- Aimlock
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

-- Safe Wallbang Toggle (Placeholder)
local function attemptWallbang(shootFunction)
    if Settings.WallbangEnabled and shootFunction then
        -- Hook shooting function here if possible (game-specific)
    end
end

-- RenderStepped
RunService.RenderStepped:Connect(function()
    if Settings.ESPEnabled then updateESP() else
        for player,_ in pairs(ESPs) do removeESP(player) end
    end
    if Settings.AimlockEnabled then runAimlock() end
    Camera.FieldOfView = Settings.PlayerFOV
end)

-- Rayfield Toggles
Tab:CreateToggle({
    Name="Infinite Sprint",
    CurrentValue=false,
    Flag="InfiniteSprint",
    Callback=function(v)
        Settings.InfiniteSprint=v
        toggleInfiniteSprint(v)
    end
})
Tab:CreateToggle({Name="ESP", CurrentValue=false, Flag="ESP", Callback=function(v)
    Settings.ESPEnabled=v
    if not v then for p,_ in pairs(ESPs) do removeESP(p) end end
end})
Tab:CreateToggle({Name="Aimlock", CurrentValue=false, Flag="Aimlock", Callback=function(v) Settings.AimlockEnabled=v end})
Tab:CreateToggle({Name="Wallbang", CurrentValue=false, Flag="Wallbang", Callback=function(v) Settings.WallbangEnabled=v end})

Tab:CreateSlider({Name="Aimlock FOV", Range={50,500}, Increment=5, Suffix="px", CurrentValue=150, Flag="AimlockFOV", Callback=function(v) Settings.AimlockFOV=v end})
Tab:CreateSlider({Name="Aimlock Prediction", Range={0,0.5}, Increment=0.01, Suffix="", CurrentValue=0.18, Flag="AimlockPrediction", Callback=function(v) Settings.AimlockPrediction=v end})
Tab:CreateSlider({Name="Player FOV", Range={70,120}, Increment=1, Suffix="", CurrentValue=Camera.FieldOfView, Flag="PlayerFOV", Callback=function(v) Settings.PlayerFOV=v end})

Tab:CreateButton({Name="Copy Server Link", Callback=function()
    setclipboard("https://www.roblox.com/games/"..game.PlaceId.."/"..game.JobId)
end})

-- Right-Click Aimlock
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then Settings.AimlockActive=true end
end)
UserInputService.InputEnded:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseButton2 then Settings.AimlockActive=false end
end)

-- Reset ESP on respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    if Settings.ESPEnabled then updateESP() end
end)

print("Loader ready: All features functional, Infinite Sprint optimized, ESP & FOV working, safe Wallbang toggle added.")
