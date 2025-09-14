-- Safe UI Module
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FemWareUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Example: Notification
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

-- Example: Drawing Text for ESP
local function createESPText(text, color)
    local txt = Drawing.new("Text")
    txt.Text = text
    txt.Size = 14
    txt.Color = color or Color3.new(1,1,1)
    txt.Center = true
    txt.Outline = true
    txt.Visible = false
    return txt
end

-- Example: Add toggle button
local function addToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 10)
    btn.Text = text.." [OFF]"
    btn.Parent = parent
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text..(state and " [ON]" or " [OFF]")
        callback(state)
    end)
end

-- Create a sample frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
mainFrame.Parent = screenGui

-- Add a toggle
addToggle(mainFrame, "Example Toggle", function(state)
    print("Toggle State:", state)
end)

-- Example ESP usage
local playerText = createESPText("PlayerName", Color3.fromRGB(255,0,0))
RunService.RenderStepped:Connect(function()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
        playerText.Position = Vector2.new(screenPos.X, screenPos.Y)
        playerText.Visible = onScreen
    else
        playerText.Visible = false
    end
end)
