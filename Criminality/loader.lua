-- Wrap any function safely
local function safeCall(func, name)
    local success, err = pcall(func)
    if not success then
        warn("Error in "..name..": "..err)
    end
end

-- Example: ESP updater
table.insert(connections, RunService.RenderStepped:Connect(function()
    safeCall(function()
        for _,player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if Settings.ESPEnabled then
                    -- Your ESP creation/update logic here
                else
                    -- Remove ESP
                end
            end
        end
    end, "ESP Update")
end))

-- Example: Infinite Sprint updater
task.spawn(function()
    while task.wait(0.1) do
        safeCall(function()
            if SprintEnabled then
                for _, tbl in pairs(sprintTables) do
                    rawset(tbl, "S", 100)
                end
            end
        end, "Infinite Sprint")
    end
end)

-- Example: Aimlock run
RunService.RenderStepped:Connect(function()
    safeCall(function()
        if Settings.AimlockActive then
            -- Your Aimlock code here
        end
    end, "Aimlock Update")
end)

-- Toggle callbacks wrapped safely
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
