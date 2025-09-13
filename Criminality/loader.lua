-- Load Orion UI Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/Source"))()

-- Create main window
local Window = OrionLib:MakeWindow({Name = "uniScript", HidePremium = true, SaveConfig = true, ConfigFolder = "uniScript"})

-- ===== UI Toggle Keybind (Alt) =====
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.LeftAlt then
            Window.Toggle() -- Show/hide Orion UI
        end
    end
end)

-- ===== Combat Tab =====
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- Infinite Sprint
local SprintEnabled = false
CombatTab:AddButton({Name = "Toggle Infinite Sprint", Callback = function()
    SprintEnabled = not SprintEnabled
    if SprintEnabled then
        local SprintTable = {}
        for _, tbl in getgc(true) do
            if typeof(tbl) == "table" and rawget(tbl, "S") then
                if typeof(rawget(tbl, "S")) == "number" then
                    table.insert(SprintTable, tbl)
                end
            end
        end
        game:GetService("RunService").Heartbeat:Connect(function()
            for _, tbl in ipairs(SprintTable) do
                rawset(tbl, "S", 100)
            end
        end)
    else
        SprintTable = {}
    end
end})

-- Right-Click Aimlock
local AimlockEnabled = false
local RS = game:GetService("RunService")
local RightClickHeld = false
local plrs = game:GetService("Players")
local LocalPlayer = plrs.LocalPlayer
local cam = workspace.CurrentCamera

CombatTab:AddToggle({Name = "Aimlock (Hold Right Click)", Default = false, Callback = function(state)
    AimlockEnabled = state
end})

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false
    end
end)

local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(plrs:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPos = player.Character.HumanoidRootPart.Position
            local predictedPos = targetPos + player.Character.HumanoidRootPart.Velocity * 0.15
            local screenPos, onScreen = cam:WorldToViewportPoint(predictedPos)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

RS.RenderStepped:Connect(function()
    if AimlockEnabled and RightClickHeld then
        local targetPlayer = getClosestPlayerToCursor()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = targetPlayer.Character.HumanoidRootPart.Position + targetPlayer.Character.HumanoidRootPart.Velocity * 0.15
            cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
        end
    end
end)

-- ===== Misc Tab =====
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- FOV Slider
MiscTab:AddSlider({Name = "Field of View", Min = 70, Max = 120, Default = 90, Increment = 1, Callback = function(value)
    cam.FieldOfView = value
end})

-- ESP Integration
local ESP = loadstring([[
-- Paste your full ESP code here
]])() -- Replace this comment with your full ESP code

MiscTab:AddToggle({Name = "Enable ESP", Default = false, Callback = function(state) ESP:Toggle(state) end})
MiscTab:AddToggle({Name = "Show Boxes", Default = false, Callback = function(state) ESP.Boxes = state end})
MiscTab:AddToggle({Name = "Show Names", Default = false, Callback = function(state) ESP.Names = state end})
MiscTab:AddToggle({Name = "Show Distance", Default = false, Callback = function(state) ESP.Distance = state end})
MiscTab:AddToggle({Name = "Show Health", Default = false, Callback = function(state) ESP.Health = state end})
MiscTab:AddToggle({Name = "Show Tools", Default = false, Callback = function(state) ESP.Tool = state end})

-- ===== UI Tab =====
local UITab = Window:MakeTab({Name = "UI", Icon = "rbxassetid://4483345998", PremiumOnly = false})
UITab:AddButton({Name = "Reset UI Position", Callback = function()
    Window:Restore()
end})
