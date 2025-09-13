--// Loader.lua with Auto-Reset on Death

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    InfiniteSprint = true,
    AimlockEnabled = false,
    ESPEnabled = true,
    AimlockFOV = 150,
}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local function createToggle(name, settingKey)
    local button = Instance.new("TextButton", Frame)
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, (#Frame:GetChildren()-1) * 35)
    button.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    
    button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        button.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    end)
end

createToggle("Infinite Sprint", "InfiniteSprint")
createToggle("ESP", "ESPEnabled")
createToggle("Aimlock", "AimlockEnabled")

-- ESP Table
local ESPBoxes = {}

local function resetESP()
    for _, box in pairs(ESPBoxes) do
        box:Remove()
    end
    ESPBoxes = {}
end

-- Function to reapply script features
local function applyFeatures()
    -- Infinite Sprint
    RunService.RenderStepped:Connect(function()
        if Settings.InfiniteSprint then
            pcall(function()
                for i,v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v,"S") then
                        v.S = 100
                    end
                end
            end)
        end
    end)

    -- ESP
    RunService.RenderStepped:Connect(function()
        if Settings.ESPEnabled then
            for i,v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local part = v.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if not ESPBoxes[v] then
                            local box = Drawing.new("Square")
                            box.Color = Color3.fromRGB(0, 255, 0)
                            box.Thickness = 2
                            box.Transparency = 1
                            box.Filled = false
                            ESPBoxes[v] = box
                        end
                        ESPBoxes[v].Position = Vector2.new(pos.X - 25, pos.Y - 50)
                        ESPBoxes[v].Size = Vector2.new(50,100)
                    else
                        if ESPBoxes[v] then ESPBoxes[v].Visible = false end
                    end
                end
            end
        else
            resetESP()
        end
    end)

    -- Aimlock
    RunService.RenderStepped:Connect(function()
        if Settings.AimlockEnabled then
            local closest
            local shortest = Settings.AimlockFOV
            for i,v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if distance < shortest then
                            shortest = distance
                            closest = v
                        end
                    end
                end
            end
            
            if closest and closest.Character then
                Mouse.Target = closest.Character.HumanoidRootPart
            end
        end
    end)
end

-- Initial apply
applyFeatures()

-- Reset features when character respawns
LocalPlayer.CharacterAdded:Connect(function()
    resetESP() -- clear ESP
    wait(0.5) -- small delay to let character load
    applyFeatures() -- reapply features
end)

print("Loader Enhanced: Infinite Sprint, ESP, Aimlock, GUI ready! Auto-reset on death enabled.")
