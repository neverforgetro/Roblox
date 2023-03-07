-- Local Script
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


--Server Side 

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local questDataStore = DataStoreService:GetDataStore("questData")

local remoteEvent = game:GetService("ReplicatedStorage")["Quest System"]:WaitForChild("Schimbare")
local remoteEvent2 = game:GetService("ReplicatedStorage")["Quest System"]:WaitForChild("Adaugare")
local ShowQuestUI = game:GetService("ReplicatedStorage")["Quest System"].Events:WaitForChild("ShowQuestUI")

local function onPlayerAdded(player)
	
	local playerFolder = Instance.new("Folder", game.ReplicatedStorage["Quest System"].PlayersData)
	playerFolder.Name = player.Name
	
	local QuestProgress = Instance.new("IntValue")
	QuestProgress.Name = "QuestProgress"
	QuestProgress.Parent = playerFolder
	
	local QuestTargetName = Instance.new("StringValue")
	QuestTargetName.Name = "QuestTargetName"
	QuestTargetName.Parent = playerFolder
	
	local QuestTargetNumber = Instance.new("IntValue")
	QuestTargetNumber.Name = "QuestTargetNumber"
	QuestTargetNumber.Parent = playerFolder
	
	local QuestReward = Instance.new("IntValue")
	QuestReward.Name = "QuestReward"
	QuestReward.Parent = playerFolder
	
	local questData = questDataStore:GetAsync(player.Name)
	if questData then
		if questData.questTargetName == "NoQuest" then
			ShowQuestUI:FireClient(player, false)
		else
			ShowQuestUI:FireClient(player, true, "Quest", questData.questReward, "Kill "..questData.questTargetNumber.." "..questData.questTargetName.."", questData.questTargetNumber, questData.questProgress)
		end
		if questData.questProgress == nil then
			local questData = {
				questTargetName = "NoQuest", 
				questTargetNumber = 0, 
				questProgress = 0,
				questReward = 0
			}

			questDataStore:SetAsync(player, questData)
			QuestTargetNumber.Value = 0
			QuestTargetName.Value = "NoQuest"
			QuestProgress.Value = 0
			QuestReward.Value = 0
		else
			QuestProgress.Value = questData.questProgress
		end
		if questData.questTargetName == nil then
			local questData = {
				questTargetName = "NoQuest", 
				questTargetNumber = 0, 
				questProgress = 0,
				questReward = 0
			}

			questDataStore:SetAsync(player, questData)
			QuestTargetNumber.Value = 0
			QuestTargetName.Value = "NoQuest"
			QuestProgress.Value = 0
			QuestReward.Value = 0
		else
			QuestTargetName.Value = questData.questTargetName
		end
		if questData.questTargetNumber == nil then
			local questData = {
				questTargetName = "NoQuest", 
				questTargetNumber = 0, 
				questProgress = 0,
				questReward = 0
			}

			questDataStore:SetAsync(player, questData)
			QuestTargetNumber.Value = 0
			QuestTargetName.Value = "NoQuest"
			QuestProgress.Value = 0
			QuestReward.Value = 0
		else
			QuestTargetNumber.Value = questData.questTargetNumber
		end
		if questData.questReward == nil then
			local questData = {
				questTargetName = "NoQuest", 
				questTargetNumber = 0, 
				questProgress = 0,
				questReward = 0
			}

			questDataStore:SetAsync(player, questData)
			QuestTargetNumber.Value = 0
			QuestTargetName.Value = "NoQuest"
			QuestProgress.Value = 0
			QuestReward.Value = 0
		else
			QuestReward.Value = questData.questReward
		end
	end
end

local function onPlayerRemoving(player)
	local playersFolder = game.ReplicatedStorage["Quest System"].PlayersData:FindFirstChild(player.Name)
	
	local questTargetName1 = playersFolder:FindFirstChild("QuestTargetName").Value
	local questTargetNumber1 = playersFolder:FindFirstChild("QuestTargetNumber").Value
	local questProgress1 = playersFolder:FindFirstChild("QuestProgress").Value
	local questReward1 = playersFolder:FindFirstChild("QuestReward").Value
	local questData = {
		questTargetName = questTargetName1, 
		questTargetNumber = questTargetNumber1, 
		questProgress = questProgress1,
		questReward = questReward1
	}

	questDataStore:SetAsync(player.Name, questData)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(onPlayerRemoving)

local function schimbare(player, playersFolder, QuestProgress, QuestTargetName)
	
	playersFolder:FindFirstChild("QuestProgress").Value = QuestProgress
	
	local questTargetNumberValue = playersFolder:FindFirstChild("QuestTargetNumber").Value
	local questTargetNameValue = playersFolder:FindFirstChild("QuestTargetName").Value
	local questReward = playersFolder:FindFirstChild("QuestReward").Value
	
	if QuestProgress >= questTargetNumberValue then
		player.leaderstats.Cash.Value = player.leaderstats.Cash.Value + questReward
		
		playersFolder:FindFirstChild("QuestTargetName").Value = "NoQuest"
		playersFolder:FindFirstChild("QuestTargetNumber").Value = 0
		playersFolder:FindFirstChild("QuestProgress").Value = QuestProgress
		playersFolder:FindFirstChild("QuestReward").Value = 0
	end
end

function adaugare(player, playersFolder, questTarget,questNumber,questProgress,questReward)
	playersFolder:FindFirstChild("QuestTargetName").Value = questTarget
	playersFolder:FindFirstChild("QuestTargetNumber").Value = questNumber
	playersFolder:FindFirstChild("QuestProgress").Value = questProgress
	playersFolder:FindFirstChild("QuestReward").Value = questReward
end

remoteEvent.OnServerEvent:Connect(schimbare)
remoteEvent2.OnServerEvent:Connect(adaugare)


