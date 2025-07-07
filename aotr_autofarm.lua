--===[ AOTR AutoFarm by ChatGPT ]===--
-- Tested on Delta & Fluxus

--=== GUI INIT ===--
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "AOT Revolution | Delta Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AOTRDelta"
})

--=== Globals ===--
getgenv().AutoFarm = false
getgenv().SafeFarm = false
getgenv().AutoRefill = false
getgenv().AutoRetry = false
getgenv().EnableESP = false
getgenv().TitanTypeFilter = "All"

--=== Titan Finder ===--
function findNearestTitan()
    local nearest = nil
    local shortestDistance = math.huge
    local player = game.Players.LocalPlayer
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if not hrp then return nil end

    for _, titan in pairs(workspace:FindFirstChild("Titans"):GetChildren()) do
        if titan:FindFirstChild("HumanoidRootPart") then
            local name = titan.Name:lower()
            if getgenv().TitanTypeFilter == "Normal" and (name:find("shifter") or name:find("boss")) then continue end
            if getgenv().TitanTypeFilter == "Shifter" and not name:find("shifter") then continue end
            if getgenv().TitanTypeFilter == "Boss" and not name:find("boss") then continue end

            local distance = (titan.HumanoidRootPart.Position - hrp.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearest = titan
            end
        end
    end

    return nearest
end

--=== Auto Farm ===--
function farmTitan()
    while getgenv().AutoFarm do
        local titan = findNearestTitan()
        if titan then
            local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            hrp.CFrame = titan.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
            wait(0.2)
            mouse1click()
        else
            wait(1)
        end
    end
end

--=== Safe Farm (Hover Slash) ===--
function safeFarm()
    while getgenv().SafeFarm do
        local titan = findNearestTitan()
        if titan then
            local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            hrp.CFrame = titan.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
            wait(0.3)
            mouse1click()
        else
            wait(1)
        end
    end
end

--=== Auto Refill ===--
function autoRefill()
    while getgenv().AutoRefill do
        local backpack = game.Players.LocalPlayer.Backpack
        if backpack:FindFirstChild("GasCanister") then
            backpack.GasCanister:Activate()
        end
        if backpack:FindFirstChild("BladeRefill") then
            backpack.BladeRefill:Activate()
        end
        wait(5)
    end
end

--=== Auto Retry ===--
function autoRetry()
    while getgenv().AutoRetry do
        local gui = game:GetService("Players").LocalPlayer.PlayerGui
        if gui:FindFirstChild("RetryUI") then
            firesignal(gui.RetryUI.Retry.MouseButton1Click)
        end
        wait(3)
    end
end

--=== ESP System ===--
function createTitanESP()
    if not getgenv().EnableESP then return end
    for _, titan in pairs(workspace:FindFirstChild("Titans"):GetChildren()) do
        if titan:FindFirstChild("HumanoidRootPart") and not titan:FindFirstChild("ESP") then
            local name = titan.Name:lower()
            if getgenv().TitanTypeFilter == "Shifter" and not name:find("shifter") then return end
            if getgenv().TitanTypeFilter == "Boss" and not name:find("boss") then return end
            if getgenv().TitanTypeFilter == "Normal" and (name:find("shifter") or name:find("boss")) then return end

            local billboard = Instance.new("BillboardGui", titan)
            billboard.Name = "ESP"
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 5, 0)
            billboard.AlwaysOnTop = true

            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1, 0, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextScaled = true
            label.Text = "[TITAN]"

            coroutine.wrap(function()
                while billboard and billboard.Parent and getgenv().EnableESP do
                    local plr = game.Players.LocalPlayer
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = math.floor((titan.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
                        label.Text = "Titan [" .. dist .. "m]"
                    end
                    wait(0.5)
                end
            end)()
        end
    end
end

-- Run ESP Loop
spawn(function()
    while true do
        if getgenv().EnableESP then
            createTitanESP()
        end
        wait(3)
    end
end)

--=== GUI Tabs ===--

local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
MainTab:AddToggle({
    Name = "Auto Farm Titan",
    Default = false,
    Callback = function(v)
        getgenv().AutoFarm = v
        if v then farmTitan() end
    end
})
MainTab:AddToggle({
    Name = "Safe Farm (Gas Hover)",
    Default = false,
    Callback = function(v)
        getgenv().SafeFarm = v
        if v then safeFarm() end
    end
})
MainTab:AddToggle({
    Name = "Auto Refill Gear",
    Default = false,
    Callback = function(v)
        getgenv().AutoRefill = v
        if v then autoRefill() end
    end
})
MainTab:AddToggle({
    Name = "Auto Retry (loop game)",
    Default = false,
    Callback = function(v)
        getgenv().AutoRetry = v
        if v then autoRetry() end
    end
})

local VisualTab = Window:MakeTab({Name = "ESP & Visual", Icon = "rbxassetid://6034287525", PremiumOnly = false})
VisualTab:AddToggle({
    Name = "Enable Titan ESP",
    Default = false,
    Callback = function(v)
        getgenv().EnableESP = v
    end
})
VisualTab:AddDropdown({
    Name = "Titan Type Filter",
    Default = "All",
    Options = {"All", "Normal", "Shifter", "Boss"},
    Callback = function(v)
        getgenv().TitanTypeFilter = v
    end
})

local StatsTab = Window:MakeTab({Name = "Stats", Icon = "rbxassetid://6031075938", PremiumOnly = false})
StatsTab:AddParagraph("Progress Tracker", "Total Misi, XP, Gold, Item:")
StatsTab:AddButton({
    Name = "Refresh Stats",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local stats = plr:FindFirstChild("leaderstats")
        if stats then
            for i, v in pairs(stats:GetChildren()) do
                print(v.Name .. ": " .. tostring(v.Value))
            end
        end
    end
})

OrionLib:Init()
