Then, in your main script, load Orion UI locally:
local Window = OrionLib:MakeWindow({
    Name = "UniScript BETA",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniScript",
    ConfigName = "Settings"
})
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "Test Button",
    Callback = function()
        print("Button clicked!")
    end
})
