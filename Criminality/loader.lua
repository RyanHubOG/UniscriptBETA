-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local modifierEnabled = false
local loopConnection = nil

local espEnabled = false
local playerESP = {}
local Skeletons = {}

local aimlockEnabled = false
local fovEnabled = true
local fovRadius = 150
local fovCircle = nil
-- Find tables for infinite sprint
local function findTablesWithS()
    local tables = {}
    for _, tbl in getgc(true) do
        if typeof(tbl)=="table" and rawget(tbl,"S") then
            if typeof(rawget(tbl,"S"))=="number" then table.insert(tables,tbl) end
        end
    end
    return tables
end

-- Infinite Sprint
local function startModifier()
    if loopConnection then loopConnection:Disconnect() loopConnection=nil end
    if not modifierEnabled then return end
    local tables = findTablesWithS()
    loopConnection = RunService.Heartbeat:Connect(function()
        for _, tbl in pairs(tables) do
            rawset(tbl,"S",100)
        end
    end)
end

local function stopModifier()
    if loopConnection then loopConnection:Disconnect() loopConnection=nil end
end

-- World to viewport helper
local function worldToViewport(pos)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen, screenPoint.Z
end

-- FOV Circle
fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(0,255,0)
fovCircle.NumSides = 64
fovCircle.Visible = fovEnabled

RunService.RenderStepped:Connect(function()
    if fovEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        fovCircle.Position = mousePos
        fovCircle.Radius = fovRadius
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)
local function getClosestPlayerToCursor()
    local closestDist = math.huge
    local targetPlayer = nil
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local headPos = plr.Character.Head.Position
            local screenPos, onScreen = worldToViewport(headPos)
            if onScreen then
                local dist = (Vector2.new(screenPos.X,screenPos.Y)-mousePos).Magnitude
                if dist<closestDist and dist<=fovRadius then
                    closestDist = dist
                    targetPlayer = plr
                end
            end
        end
    end
    return targetPlayer
end

-- Right mouse aimlock
UserInputService.InputBegan:Connect(function(input)
    if aimlockEnabled and input.UserInputType==Enum.UserInputType.MouseButton2 then
        local target = getClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local mouse = LocalPlayer:GetMouse()
            mouse.Hit = CFrame.new(target.Character.Head.Position)
        end
    end
end)
-- Load Skeleton library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/ESPs/main/UniversalSkeleton.lua"))()

local function createSkeletonESP(plr)
    local skeleton = Library:NewSkeleton(plr,true)
    skeleton.Size = 50
    skeleton.Static = true
    table.insert(Skeletons, skeleton)

    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Text = ""
    text.Color = Color3.fromRGB(0,255,0)
    text.Size = 15
    text.Transparency = 1

    RunService.RenderStepped:Connect(function()
        if not espEnabled then text.Visible=false; return end
        if plr.Character and plr.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude)
                text.Position = Vector2.new(pos.X,pos.Y-50)
                text.Text = plr.Name.." ["..dist.." Studs]"
                text.Visible=true
            else text.Visible=false end
        else text.Visible=false end
    end)
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr~=LocalPlayer then createSkeletonESP(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    createSkeletonESP(plr)
end)
-- Create GUI
local GUI = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
GUI.Name = "uniScriptGUI"
GUI.ResetOnSpawn = false

local frame = Instance.new("Frame", GUI)
frame.Size = UDim2.new(0,350,0,400)
frame.Position = UDim2.new(0.5,-175,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "uniScript All-In-One"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextColor3 = Color3.new(1,1,1)

-- Tabs
local tabs = {"Combat","Misc","UI"}
local tabFrames = {}
for i,name in ipairs(tabs) do
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1/#tabs,0,0,30)
    btn.Position = UDim2.new((i-1)/#tabs,0,0.09,0)
    btn.Text = name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)

    local tabFrame = Instance.new("Frame", frame)
    tabFrame.Size = UDim2.new(1,-20,1,-80)
    tabFrame.Position = UDim2.new(0,10,0.15,0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = i==1
    tabFrames[name] = tabFrame

    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible=false end
        tabFrame.Visible=true
    end)
end
local miscFrame = tabFrames["Misc"]
local combatFrame = tabFrames["Combat"]
local uiFrame = tabFrames["UI"]

-- FOV Slider
local sliderFrame = Instance.new("Frame", miscFrame)
sliderFrame.Size = UDim2.new(0,300,0,20)
sliderFrame.Position = UDim2.new(0.05,0,0.25,0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
local sliderFill = Instance.new("Frame", sliderFrame)
sliderFill.Size = UDim2.new(fovRadius/300,0,1,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0,255,0)

local dragging = false
sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
end)
sliderFrame.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = math.clamp(mouseX - sliderFrame.AbsolutePosition.X,0,sliderFrame.AbsoluteSize.X)
        sliderFill.Size = UDim2.new(sliderX/sliderFrame.AbsoluteSize.X,0,1,0)
        fovRadius = sliderX/sliderFrame.AbsoluteSize.X*300
    end
end)

-- Copy Discord Button
local copyBtn = Instance.new("TextButton", uiFrame)
copyBtn.Size = UDim2.new(0,200,0,40)
copyBtn.Position = UDim2.new(0.1,0,0.1,0)
copyBtn.Text = "Copy Discord"
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://discord.gg/b6fKAnYqtU") end) end
    copyBtn.Text = "Copied!"
    task.delay(1.5,function() copyBtn.Text="Copy Discord" end)
end)

-- Draggable
local drag, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                               startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
frame.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true
        dragStart=input.Position
        startPos=frame.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then drag=false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and drag then update(input) end
end)

-- Open/Close Alt
local guiOpen = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode==Enum.KeyCode.LeftAlt then
        guiOpen = not guiOpen
        frame.Visible = guiOpen
    end
end)
