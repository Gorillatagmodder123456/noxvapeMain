return function(ctx)
local NoxLib = ctx.NoxLib
local Players = ctx.Players
local RunService = ctx.RunService
local UserInputService = ctx.UserInputService
local ReplicatedStorage = ctx.ReplicatedStorage
local Lighting = ctx.Lighting
local GuiService = ctx.GuiService
local player = ctx.player
local NetManaged = ctx.NetManaged
local GameEvents = ctx.GameEvents
local RemoteList = ctx.RemoteList
local Shared = ctx.Shared
local FontMap = ctx.FontMap
local getColor = ctx.getColor
local getNumber = ctx.getNumber
local getBool = ctx.getBool
local getSwordWeapon = ctx.getSwordWeapon
local getCharacterRoot = ctx.getCharacterRoot
local getCharacterHumanoid = ctx.getCharacterHumanoid
local isHumanoidAlive = ctx.isHumanoidAlive
local isEnemyPlayer = ctx.isEnemyPlayer
local getEntityRoot = ctx.getEntityRoot
local getKnitController = ctx.getKnitController
local getSwordController = ctx.getSwordController
local getSprintController = ctx.getSprintController
local getMoveInput = ctx.getMoveInput
local collectAllEntities = ctx.collectAllEntities
local getClosestTarget = ctx.getClosestTarget
local findBed = ctx.findBed

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
