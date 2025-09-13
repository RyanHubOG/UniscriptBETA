--// Combat Tab Functions
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Infinite Sprint
local modifierEnabled = false
local loopConnection = nil

local function findTablesWithS()
    local tables = {}
    for _, tbl in getgc(true) do
        if typeof(tbl) == "table" and rawget(tbl, "S") then
            if typeof(rawget(tbl, "S")) == "number" then
                table.insert(tables, tbl)
            end
        end
    end
    return tables
end

local function startModifier()
    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
    if not modifierEnabled then return end
    local tables = findTablesWithS()
    loopConnection = RunService.Heartbeat:Connect(function()
        for _, tbl in tables do
            rawset(tbl, "S", 100)
        end
    end)
end

local function stopModifier()
    if loopConnection then loopConnection:Disconnect() loopConnection = nil end
end

-- Aimlock
local aimlockEnabled = false
local holdingRightClick = false
local prediction = 0.12 -- adjust prediction strength

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRightClick = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRightClick = false
    end
end)

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local hrp = plr.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local mag = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimlockEnabled and holdingRightClick then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local vel = hrp.Velocity * prediction
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position + vel)
        end
    end
end)

--// Combat Tab Buttons (will be added to GUI later)
local function CombatTab(container)
    local sprintBtn = Instance.new("TextButton", container)
    sprintBtn.Size = UDim2.new(0,120,0,30)
    sprintBtn.Position = UDim2.new(0.05,0,0.1,0)
    sprintBtn.Text = "Inf Sprint: OFF"
    sprintBtn.MouseButton1Click:Connect(function()
        modifierEnabled = not modifierEnabled
        sprintBtn.Text = "Inf Sprint: "..(modifierEnabled and "ON" or "OFF")
        if modifierEnabled then startModifier() else stopModifier() end
    end)

    local aimBtn = Instance.new("TextButton", container)
    aimBtn.Size = UDim2.new(0,120,0,30)
    aimBtn.Position = UDim2.new(0.55,0,0.1,0)
    aimBtn.Text = "Aimlock: OFF"
    aimBtn.MouseButton1Click:Connect(function()
        aimlockEnabled = not aimlockEnabled
        aimBtn.Text = "Aimlock: "..(aimlockEnabled and "ON" or "OFF")
    end)
end
--// Misc Tab Functions

local espEnabled = false
local espConnection
local playerESP = {}
local fovEnabled = true
local fovRadius = 150

-- ESP Drawing
local function createBox()
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Visible = false
    return box
end

local function createName()
    local txt = Drawing.new("Text")
    txt.Size = 14
    txt.Center = true
    txt.Outline = true
    txt.Color = Color3.fromRGB(0,255,0)
    txt.Visible = false
    return txt
end

local function clearESP()
    for _, data in pairs(playerESP) do
        if data.box then data.box:Remove() end
        if data.name then data.name:Remove() end
    end
    playerESP = {}
end

local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not playerESP[plr] then
                playerESP[plr] = {
                    box = createBox(),
                    name = createName(),
                }
            end
            local hrp = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local size = math.clamp(2000 / pos.Z, 20, 150)
                playerESP[plr].box.Size = Vector2.new(size, size*1.5)
                playerESP[plr].box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                playerESP[plr].box.Visible = true

                playerESP[plr].name.Position = Vector2.new(pos.X, pos.Y - size/2 - 12)
                playerESP[plr].name.Text = plr.Name
                playerESP[plr].name.Visible = true
            else
                playerESP[plr].box.Visible = false
                playerESP[plr].name.Visible = false
            end
        elseif playerESP[plr] then
            playerESP[plr].box:Remove()
            playerESP[plr].name:Remove()
            playerESP[plr] = nil
        end
    end
end

local function startESP()
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(function()
        if espEnabled then
            updateESP()
        end
    end)
end

local function stopESP()
    if espConnection then espConnection:Disconnect() espConnection=nil end
    clearESP()
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Visible = fovEnabled
fovCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    fovCircle.Position = mouse
    fovCircle.Radius = fovRadius
    fovCircle.Visible = fovEnabled
end)

--// Misc Tab Buttons (to GUI later)
local function MiscTab(container)
    local espBtn = Instance.new("TextButton", container)
    espBtn.Size = UDim2.new(0,120,0,30)
    espBtn.Position = UDim2.new(0.05,0,0.1,0)
    espBtn.Text = "ESP: OFF"
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = "ESP: "..(espEnabled and "ON" or "OFF")
        if espEnabled then startESP() else stopESP() end
    end)

    local fovBtn = Instance.new("TextButton", container)
    fovBtn.Size = UDim2.new(0,120,0,30)
    fovBtn.Position = UDim2.new(0.55,0,0.1,0)
    fovBtn.Text = "FOV: "..(fovEnabled and "ON" or "OFF")
    fovBtn.MouseButton1Click:Connect(function()
        fovEnabled = not fovEnabled
        fovBtn.Text = "FOV: "..(fovEnabled and "ON" or "OFF")
    end)

    -- FOV Slider
    local slider = Instance.new("TextButton", container)
    slider.Size = UDim2.new(0,200,0,20)
    slider.Position = UDim2.new(0.05,0,0.25,0)
    slider.Text = "FOV Radius: "..math.floor(fovRadius)

    slider.MouseButton1Click:Connect(function()
        fovRadius = fovRadius + 25
        if fovRadius > 300 then fovRadius = 50 end
        slider.Text = "FOV Radius: "..math.floor(fovRadius)
    end)
end
--// UI Tab + Main GUI

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Main UI
local gui = Instance.new("ScreenGui")
gui.Name = "uniScript"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 260)
mainFrame.Position = UDim2.new(0.5, -175, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
makeDraggable(mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1,0,0,28)
title.BackgroundTransparency = 1
title.Text = "uniScript"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

-- Tab Buttons
local tabs = Instance.new("Frame", mainFrame)
tabs.Size = UDim2.new(1,0,0,30)
tabs.Position = UDim2.new(0,0,0.12,0)
tabs.BackgroundTransparency = 1

local pages = Instance.new("Frame", mainFrame)
pages.Size = UDim2.new(1,0,0.75,0)
pages.Position = UDim2.new(0,0,0.25,0)
pages.BackgroundTransparency = 1

local function newTab(name, order, callback)
    local btn = Instance.new("TextButton", tabs)
    btn.Size = UDim2.new(0.3,0,1,0)
    btn.Position = UDim2.new(0.35*(order-1),0,0,0)
    btn.Text = name
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,55)

    local page = Instance.new("Frame", pages)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(pages:GetChildren()) do
            child.Visible = false
        end
        page.Visible = true
    end)

    if callback then
        callback(page)
    end

    if order == 1 then
        page.Visible = true
    end
end

-- Tabs hookup
newTab("Combat", 1, CombatTab)
newTab("Misc", 2, MiscTab)

-- UI Tab
newTab("UI", 3, function(container)
    local copyBtn = Instance.new("TextButton", container)
    copyBtn.Size = UDim2.new(0,140,0,30)
    copyBtn.Position = UDim2.new(0.05,0,0.1,0)
    copyBtn.Text = "Copy Discord"
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://discord.gg/b6fKAnYqtU")
            copyBtn.Text = "Copied!"
            task.delay(1,function() copyBtn.Text = "Copy Discord" end)
        end
    end)

    local resetBtn = Instance.new("TextButton", container)
    resetBtn.Size = UDim2.new(0,140,0,30)
    resetBtn.Position = UDim2.new(0.55,0,0.1,0)
    resetBtn.Text = "Reset UI"
    resetBtn.MouseButton1Click:Connect(function()
        mainFrame.Position = UDim2.new(0.5, -175, 0.2, 0)
    end)
end)

-- Alt key toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.LeftAlt then
        gui.Enabled = not gui.Enabled
    end
end)
