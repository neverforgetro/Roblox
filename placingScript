local PosX, PosY, PosZ
local Grid = 2.5
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local Part = game.ReplicatedStorage["Placement System"].Part
local isMoving = false
local isRemoving = false

local function Snap(posy)
	PosX = math.floor(mouse.Hit.X / Grid + 1) * Grid -- Snaps
	PosY = math.floor(mouse.Hit.Y /Grid + 1) * Grid -- Snaps
	PosZ = math.floor(mouse.Hit.Z / Grid + 1) * Grid -- Snaps
end

local function Move()
	mouse.TargetFilter = newpart
	Snap()
	if isMoving then
		newpart:SetPrimaryPartCFrame(CFrame.new(PosX, mouse.Hit.p.Y + 2.5, PosZ))
	end
end

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E and not isMoving then
		script.Parent.ScreenGui.TextLabel.Text = "Press Q to cancel"
		script.Parent.ScreenGui.TextLabel.TextColor3 = Color3.new(0.745098, 0, 0.0117647)
		Part.Parent = game.Workspace["Placement Hub"]
		newpart = Part:Clone()
		newpart.Name = "newPart"
		newpart.Parent = game.Workspace["Placement Hub"].Copies
		newpart.Base.CanCollide = false
		newpart.Base.CanTouch = false
		newpart.Base.Transparency = 0.45
		newpart.Base.Reflectance = 0.5
		isMoving = true
		while isMoving do
			wait()
			Move()
		end
	end
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q and isMoving then
		isMoving = false
		newpart:Destroy()
		script.Parent.ScreenGui.TextLabel.Text = "Press E to place"
		script.Parent.ScreenGui.TextLabel.TextColor3 = Color3.new(0.0117647, 0.768627, 1)
	end
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F and not isMoving then
		print("Here")
		local target = mouse.Target
		if target then
			print(target.Parent.Name, target.Name)
			if target.Parent.Name == "newPart" then
				target.Parent:Destroy()
			end
		end
	end
end)


mouse.Button1Down:Connect(function()
	newpart.Base.CanCollide = true
	newpart.Base.CanTouch = true
	newpart.Base.Transparency = 0
	newpart.Base.Reflectance = 0
	isMoving = false
	script.Parent.ScreenGui.TextLabel.Text = "Press E to place"
	script.Parent.ScreenGui.TextLabel.TextColor3 = Color3.new(0.0117647, 0.768627, 1)
end)
