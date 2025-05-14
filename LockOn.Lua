local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local lockTarget = nil
local lockActive = false

-- Get the screen distance from mouse to target
local function getClosestRootPartToMouse()
	local closest = nil
	local minDist = math.huge

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local char = otherPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
				local root = char.HumanoidRootPart
				local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)

				if onScreen then
					local mousePos = Vector2.new(mouse.X, mouse.Y)
					local rootPos2D = Vector2.new(screenPos.X, screenPos.Y)
					local dist = (mousePos - rootPos2D).Magnitude

					if dist < minDist then
						minDist = dist
						closest = root
					end
				end
			end
		end
	end

	return closest
end

-- Toggle lock-on with Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Q then
		if lockActive then
			lockTarget = nil
			lockActive = false
		else
			local target = getClosestRootPartToMouse()
			if target then
				lockTarget = target
				lockActive = true
			end
		end
	end
end)

-- Continuously aim camera at locked target
RunService.RenderStepped:Connect(function()
	if lockActive and lockTarget and lockTarget.Parent then
		camera.CFrame = CFrame.new(camera.CFrame.Position, lockTarget.Position)
	else
		lockTarget = nil
		lockActive = false
	end
end)
