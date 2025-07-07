local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AOTR_GUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 420)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "AOTR AUTO FARM GUI"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 0.5
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local y = 40
local toggles = {}

local function addToggle(name, default, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 0, y)
	button.Text = name .. (default and " (ON)" or " (OFF)")
	button.BackgroundColor3 = default and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 14

	local state = default
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = name .. (state and " (ON)" or " (OFF)")
		button.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
		callback(state)
	end)

	toggles[name] = function() return state end
	y = y + 40
	return button
end

-- === TOGGLES ===
addToggle("Auto Farm", true, function() end)
addToggle("Safe Farm", true, function() end)
addToggle("Auto Refill", false, function() end)
addToggle("Auto Retry", false, function() end)
addToggle("ESP Titan", false, function() end)
addToggle("Filter: Shifter Titan", false, function() end)
addToggle("Filter: Normal Titan", true, function() end)

-- === STATS ===
local stat = Instance.new("TextLabel", frame)
stat.Size = UDim2.new(1, -20, 0, 60)
stat.Position = UDim2.new(0, 10, 0, y + 10)
stat.Text = "Gold: 9999\nXP: 999\nItems: 12x Blade\nSerum: 1"
stat.TextColor3 = Color3.new(1,1,1)
stat.TextSize = 14
stat.BackgroundTransparency = 0.5
stat.BackgroundColor3 = Color3.fromRGB(25,25,25)
stat.Font = Enum.Font.SourceSans
stat.TextWrapped = true
stat.TextYAlignment = Enum.TextYAlignment.Top

-- === ESP LOGIC ===
function createESP(target)
	if target:FindFirstChild("Head") and not target:FindFirstChild("ESPBox") then
		local box = Instance.new("BillboardGui", target)
		box.Name = "ESPBox"
		box.AlwaysOnTop = true
		box.Size = UDim2.new(4, 0, 4, 0)
		box.Adornee = target.Head

		local frame = Instance.new("Frame", box)
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(1, 0, 0)
		frame.BackgroundTransparency = 0.3
		frame.BorderSizePixel = 0
	end
end

-- === MAIN AUTOFARM LOOP ===
task.spawn(function()
	while true do
		task.wait(0.5)
		if toggles["Auto Farm"]() then
			local chars = workspace:GetDescendants()
			for _, titan in pairs(chars) do
				if titan:FindFirstChild("Humanoid") and titan:FindFirstChild("Torso") and titan.Name:lower():find("titan") then
					local isShifter = titan.Name:lower():find("shifter")
					if (toggles["Filter: Shifter Titan"]() and not isShifter) or (toggles["Filter: Normal Titan"]() and isShifter) then
						continue
					end

					-- ESP
					if toggles["ESP Titan"]() then
						createESP(titan)
					end

					-- Safe fly
					if toggles["Safe Farm"]() then
						local char = LocalPlayer.Character
						if char and char:FindFirstChild("HumanoidRootPart") then
							local targetPos = titan.Torso.Position + Vector3.new(0, 25, 0)
							char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
							-- Simulasi serang
							firetouchinterest(char:FindFirstChild("RightHand") or char:FindFirstChild("LeftHand"), titan.Torso, 0)
							firetouchinterest(char:FindFirstChild("RightHand") or char:FindFirstChild("LeftHand"), titan.Torso, 1)
						end
					end
				end
			end
		end

		if toggles["Auto Refill"]() then
			local station = workspace:FindFirstChild("RefillStation") or workspace:FindFirstChild("GasStation")
			if station then
				LocalPlayer.Character:MoveTo(station.Position)
			end
		end

		if toggles["Auto Retry"]() then
			local m = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RetryMission")
			if m then pcall(function() m:FireServer() end) end
		end
	end
end)
