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
	local conn, original = nil, nil
	NoxLib.addButton("Movement", {
		name = "Speed",
		toggle = true,
		description = "Movement speed using AssemblyVelocity.",
		settings = {
			{
				type = "slider",
				name = "Speed",
				key = "vel",
				default = 23,
				min = 1,
				max = 100
			}
		},
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			local ch = player.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if not enabled then
				if h and original then
					h.WalkSpeed = original
					original = nil
				end
				return true
			end
			if h then
				original = h.WalkSpeed
			end
			conn = RunService.Heartbeat:Connect(function()
				if Shared.FlyRunning then
					return
				end
				local c2 = player.Character
				local root = c2 and c2:FindFirstChild("HumanoidRootPart")
				local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
				if not root or not h2 then
					return
				end
				local sp = getNumber("Movement", "Speed", "vel", 23)
				if h2.WalkSpeed ~= sp then
					h2.WalkSpeed = sp
				end
				local dir, has = getMoveInput()
				if not has then
					return
				end
				local v = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(dir.X * sp, v.Y, dir.Z * sp)
			end)
			return true
		end
	})
end
return true
