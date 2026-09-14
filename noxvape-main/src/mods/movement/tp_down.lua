local Core = ...
local NoxLib = Core.NoxLib
local Players = Core.Players
local RunService = Core.RunService
local UserInputService = Core.UserInputService
local ReplicatedStorage = Core.ReplicatedStorage
local Lighting = Core.Lighting
local GuiService = Core.GuiService
local player = Core.player
local NetManaged = Core.NetManaged
local GameEvents = Core.GameEvents
local RemoteList = Core.RemoteList
local Shared = Core.Shared
local FontMap = Core.FontMap
local getColor = Core.getColor
local getNumber = Core.getNumber
local getBool = Core.getBool
local getSwordWeapon = Core.getSwordWeapon
local hasItem = Core.hasItem
local getCharacterRoot = Core.getCharacterRoot
local getCharacterHumanoid = Core.getCharacterHumanoid
local isHumanoidAlive = Core.isHumanoidAlive
local isEnemyPlayer = Core.isEnemyPlayer
local getEntityRoot = Core.getEntityRoot
local getKnitController = Core.getKnitController
local getSwordController = Core.getSwordController
local getSprintController = Core.getSprintController
local getMoveInput = Core.getMoveInput
local collectAllEntities = Core.collectAllEntities
local getClosestTarget = Core.getClosestTarget
local findBed = Core.findBed

do
	local conn, timer, maxTime, ui, timerLabel, progressFill = nil, 0, 2, nil, nil, nil
	local function barColor()
		return getColor("Movement", "TP Down", "barColor", Color3.fromRGB(55, 150, 200))
	end
	local function createUI()
		if ui then
			return
		end
		ui = Instance.new("ScreenGui")
		ui.Name = "NoxTPDownUI"
		ui.ResetOnSpawn = false
		ui.IgnoreGuiInset = true
		ui.DisplayOrder = 999999
		ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		ui.Parent = player:WaitForChild("PlayerGui")
		local cont = Instance.new("Frame", ui)
		cont.Name = "Container"
		cont.AnchorPoint = Vector2.new(0.5, 1)
		cont.Position = UDim2.new(0.5, 0, 1, - 110)
		cont.Size = UDim2.fromOffset(280, 60)
		cont.BackgroundColor3 = Color3.fromRGB(4, 5, 7)
		cont.BackgroundTransparency = 0.2
		cont.BorderSizePixel = 0
		Instance.new("UICorner", cont).CornerRadius = UDim.new(0, 8)
		timerLabel = Instance.new("TextLabel", cont)
		timerLabel.Name = "TimerLabel"
		timerLabel.Size = UDim2.new(1, 0, 0, 24)
		timerLabel.Position = UDim2.fromOffset(0, 4)
		timerLabel.BackgroundTransparency = 1
		timerLabel.Font = Enum.Font.BuilderSansBold
		timerLabel.TextSize = 20
		timerLabel.TextColor3 = Color3.fromRGB(235, 240, 245)
		timerLabel.Text = "2.0"
		local bg = Instance.new("Frame", cont)
		bg.Name = "BarBackground"
		bg.Position = UDim2.fromOffset(15, 36)
		bg.Size = UDim2.new(1, - 30, 0, 14)
		bg.BackgroundColor3 = Color3.fromRGB(7, 9, 12)
		bg.BorderSizePixel = 0
		Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 7)
		progressFill = Instance.new("Frame", bg)
		progressFill.Name = "Fill"
		progressFill.Size = UDim2.new(1, 0, 1, 0)
		progressFill.BackgroundColor3 = barColor()
		progressFill.BorderSizePixel = 0
		Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 7)
	end
	local function updateUI()
		if timerLabel then
			timerLabel.Text = string.format("%.1f", timer)
		end
		if progressFill then
			local p = maxTime > 0 and (timer / maxTime) or 0
			progressFill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
		end
	end
	local function groundPos()
		local c = player.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		local h = c and c:FindFirstChildOfClass("Humanoid")
		if not r or not h then
			return nil, true
		end
		local p = RaycastParams.new()
		p.FilterType = Enum.RaycastFilterType.Exclude
		p.FilterDescendantsInstances = {
			c
		}
		local onFloor = h.FloorMaterial ~= Enum.Material.Air
		local origin = r.Position
		for _ = 1, 4 do
			local res = workspace:Raycast(origin, Vector3.new(0, - 1000, 0), p)
			if not res then
				return nil, onFloor
			end
			local hit = Shared.AntiFallRunning and Shared.AntiFallTerrainCenter and res.Instance == workspace.Terrain and res.Material == Enum.Material.Water and math.abs(res.Position.Y - Shared.AntiFallTerrainCenter.Y) <= Shared.ANTI_FALL_THICKNESS + 2
			if hit then
				origin = res.Position - Vector3.new(0, Shared.ANTI_FALL_THICKNESS + 1, 0)
			else
				return res.Position, onFloor
			end
		end
		return nil, onFloor
	end
	NoxLib.addButton("Movement", {
		name = "TP Down",
		toggle = true,
		description = "TP to ground when timer hits zero.",
		settings = {
			{
				type = "slider",
				name = "Interval",
				key = "interval",
				default = 2,
				min = 0.1,
				max = 2,
				step = 0.1,
				action = function(v)
					maxTime = tonumber(v) or 2
					updateUI()
				end
			},
			{
				type = "colorpicker",
				name = "Bar Color",
				key = "barColor",
				default = Color3.fromRGB(55, 150, 200),
				action = function()
					if progressFill then
						progressFill.BackgroundColor3 = barColor()
					end
				end
			}
		},
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			if not enabled then
				if ui then
					ui:Destroy()
					ui = nil
					timerLabel = nil
					progressFill = nil
				end
				return true
			end
			createUI()
			maxTime = getNumber("Movement", "TP Down", "interval", 2)
			timer = maxTime
			updateUI()
			local lastTick = os.clock()
			local lastGround, cachedPos, cachedFloor = 0, nil, true
			conn = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if now - lastGround >= 0.1 then
					lastGround = now
					cachedPos, cachedFloor = groundPos()
				end
				local delta = now - lastTick
				lastTick = now
				if cachedFloor or not cachedPos then
					timer = maxTime
				else
					timer -= delta
				end
				if timer <= 0 then
					timer = maxTime
					local c = player.Character
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if r and cachedPos then
						Shared.TPDownLastTeleportTime = os.clock()
						local orig = r.CFrame
						r.CFrame = CFrame.new(cachedPos + Vector3.new(0, 3, 0))
						r.AssemblyLinearVelocity = Vector3.zero
						r.AssemblyAngularVelocity = Vector3.zero
						task.delay(0.1, function()
							if r and r.Parent then
								r.CFrame = orig
								r.AssemblyLinearVelocity = Vector3.zero
								r.AssemblyAngularVelocity = Vector3.zero
							end
						end)
					end
				end
				updateUI()
			end)
			return true
		end
	})
end
return true
