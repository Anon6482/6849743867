local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local lockTarget = nil
local lockActive = false

-- Find the player whose torso is closest to the mouse
local function getClosestTorsoToMouse()
	local closestTorso = nil
	local smallestDistance = math.huge

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Torso") then
			local torso = otherPlayer.Character:FindFirstChild("Torso")
			local screenPos, onScreen = camera:WorldToViewportPoint(torso.Position)

			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
				if dist < smallestDistance then
					smallestDistance = dist
					closestTorso = torso
				end
			end
		end
	end

	return closestTorso
end

-- Toggle lock-on with Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Q then
		if lockActive then
			lockTarget = nil
			lockActive = false
		else
			local target = getClosestTorsoToMouse()
			if target then
				lockTarget = target
				lockActive = true
			end
		end
	end
end)

-- Continuously update camera
RunService.RenderStepped:Connect(function()
	if lockActive and lockTarget and lockTarget.Parent then
		camera.CFrame = CFrame.new(camera.CFrame.Position, lockTarget.Position)
	else
		lockTarget = nil
		lockActive = false
	end
end)
