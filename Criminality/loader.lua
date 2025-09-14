local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(readfile("Rayfield.lua"))()
end)

if not success then
    warn("Rayfield failed to load: "..tostring(err))
    return
end

-- Now you can create your window
local Window = Rayfield:CreateWindow({
    Name = "UniScript BETA",
    LoadingTitle = "UniScript is loading...",
    LoadingSubtitle = "by Ryan",
    Theme = "Dark",
    ConfigurationSaving = {Enabled=true, FolderName="CriminalityScripts", FileName="Settings"},
    KeySystem = false
})
