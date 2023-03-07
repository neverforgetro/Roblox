local folder = game.Workspace.QuestMap.Dummies -- create a folder named "Dummies" in Workspace to store the clones
local dummyTemplate = game.ReplicatedStorage["Quest System"].Dummy -- create a template for the dummy instance
local spawnPos = Vector3.new(2085.125, 347.422, -1515.218) -- set the spawn position for the dummies
local spawnRadius = 30 -- set the radius for the random spawn position
local ServerScriptService = game:GetService("ServerScriptService")
local remoteEvent = game:GetService("ReplicatedStorage")["Quest System"]:WaitForChild("Schimbare")
local connections = {} -- table to store connections for each humanoid


-- Clone 5 dummy instances and place them in the "Dummies" folder
for i = 1, 6 do
	local dummy = dummyTemplate:Clone()
	dummy.Name = "Dummy"
	dummy.Parent = folder
	local randomPos = spawnPos + Vector3.new(math.random(-spawnRadius, spawnRadius), 0, math.random(-spawnRadius, spawnRadius))
	dummy:SetPrimaryPartCFrame(CFrame.new(randomPos))
end
-- Function to respawn a humanoid when it dies
local function respawn(humanoid)
	if connections[humanoid] then -- disconnect previous connection if it exists
		connections[humanoid]:Disconnect()
		connections[humanoid] = nil
	end

	local creatorValue = humanoid.creator
	local victim = humanoid.Parent.Name
	if creatorValue then
		local Killer = Game.Players:FindFirstChild(tostring(creatorValue.value))
		local playersFolder = game.ReplicatedStorage["Quest System"].PlayersData:FindFirstChild(Killer.Name)
		if Killer then
			local QuestTargetName = playersFolder:FindFirstChild("QuestTargetName").Value
			local QuestTargetNumber = playersFolder:FindFirstChild("QuestTargetNumber").Value
			local QuestProgress = playersFolder:FindFirstChild("QuestProgress").Value
			
			if victim == QuestTargetName then
				
				QuestProgressValue = QuestProgress + 1
				playersFolder:FindFirstChild("QuestProgress").Value = QuestProgressValue
				remoteEvent:FireServer(playersFolder, QuestProgressValue)
				script.Parent.Screen.QuestFrame.CurrentCount.Text = QuestProgressValue
				
				
				if QuestProgressValue >= QuestTargetNumber then
					QuestProgress = 0
					playersFolder:FindFirstChild("QuestTargetName").Value = "NoQuest"
					playersFolder:FindFirstChild("QuestTargetNumber").Value = 0
					playersFolder:FindFirstChild("QuestProgress").Value = QuestProgress
					playersFolder:FindFirstChild("QuestReward").Value = 0
					script.Parent.Screen.QuestFrame.Visible = false
					script.Parent.Screen.QuestFrame.CurrentCount.Text = 0
					
				end
			end
			
		end
	end

	local dummy = dummyTemplate:Clone()
	dummy.Parent = folder
	local randomPos = spawnPos + Vector3.new(math.random(-spawnRadius, spawnRadius), 0, math.random(-spawnRadius, spawnRadius))
	dummy:SetPrimaryPartCFrame(CFrame.new(randomPos))
	humanoid:Destroy()

	-- connect the Died event for the new humanoid
	local newHumanoid = dummy:FindFirstChildOfClass("Humanoid")
	if newHumanoid then
		connections[newHumanoid] = newHumanoid.Died:Connect(function()
			respawn(newHumanoid)
		end)
	end
end

-- Connect the Died event of each Humanoid to the respawn function
for _, dummy in pairs(folder:GetChildren()) do
	if dummy:IsA("Model") and dummy.Name:find("Dummy") then
		local humanoid = dummy:FindFirstChildOfClass("Humanoid")
		if humanoid then
			connections[humanoid] = humanoid.Died:Connect(function()
				respawn(humanoid)
			end)
		end
	end
end

-- continuously check for new dummies and connect the Died event to the respawn function
while true do
	for _, dummy in pairs(folder:GetChildren()) do
		if dummy:IsA("Model") and dummy.Name:find("Dummy") then
			local humanoid = dummy:FindFirstChildOfClass("Humanoid")
			if humanoid and not connections[humanoid] then
				connections[humanoid] = humanoid.Died:Connect(function()
					respawn(humanoid)
				end)
			end
		end
	end
	wait(1) -- wait for 1 second before checking again
end
