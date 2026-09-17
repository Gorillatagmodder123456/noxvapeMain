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

	local conn, airborneSince = nil, nil
	NoxLib.addButton("Movement", {
		name = "Spider",
		toggle = true,
		description = "Climb up walls while moving into them.",
		settings = {
			{
				type = "slider",
				name = "Climb Speed",
				key = "climbSpeed",
				default = 25,
				min = 5,
				max = 100
			},
			{
				type = "slider",
				name = "Wall Reach",
				key = "reach",
				default = 3,
				min = 1,
				max = 8,
				step = 0.5
			}
		},
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			airborneSince = nil
			if not enabled then
				return true
			end
			conn = RunService.Heartbeat:Connect(function()
				if Shared.FlyRunning then
					return
				end
				local c = player.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				local h = c and c:FindFirstChildOfClass("Humanoid")
				if not r or not h or h.Health <= 0 then
					airborneSince = nil
					return
				end
				local now = os.clock()
				if h.FloorMaterial ~= Enum.Material.Air then
					airborneSince = nil
					return
				end
				if not airborneSince then
					airborneSince = now
					return
				end
				if now - airborneSince < 0.05 then
					return
				end
				local st = h:GetState()
				if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.PlatformStanding then
					return
				end
				local dir, has = getMoveInput()
				if not has or dir.Magnitude < 0.01 then
					return
				end
				local reach = getNumber("Movement", "Spider", "reach", 3)
				local p = RaycastParams.new()
				p.FilterType = Enum.RaycastFilterType.Exclude
				p.FilterDescendantsInstances = {
					c
				}
				local origin = r.Position + Vector3.new(0, 1.5, 0)
				local fd = Vector3.new(dir.X, 0, dir.Z)
				if fd.Magnitude < 0.01 then
					return
				end
				fd = fd.Unit
				local res = workspace:Raycast(origin, fd * reach, p)
				if not res or math.abs(res.Normal.Y) > 0.5 or res.Distance < 0.05 then
					return
				end
				local cs = getNumber("Movement", "Spider", "climbSpeed", 25)
				local v = r.AssemblyLinearVelocity
				if v.Y >= cs then
					return
				end
				r.AssemblyLinearVelocity = Vector3.new(v.X, cs, v.Z)
			end)
			return true
		end
	})
end
