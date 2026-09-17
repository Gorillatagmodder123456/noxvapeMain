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

do
	local conn, filledSize = nil, nil
	local function bounce()
		return getNumber("Movement", "AntiFall", "bounceForce", 250)
	end
	local function size()
		return getNumber("Movement", "AntiFall", "terrainSize", 512)
	end
	local function getY()
		local bed = findBed()
		if bed then
			return bed.Position.Y - 15
		end
		return (Shared.AntiFallReferenceY or 0) - 15
	end
	local function detectRef()
		local c = player.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if not r then
			return nil
		end
		local p = RaycastParams.new()
		p.FilterType = Enum.RaycastFilterType.Exclude
		p.FilterDescendantsInstances = {
			c
		}
		local res = workspace:Raycast(r.Position, Vector3.new(0, - 2000, 0), p)
		return res and res.Position.Y or r.Position.Y
	end
	local function fill(x, z)
		local y = getY()
		local s = size()
		local cf = CFrame.new(Vector3.new(x, y - Shared.ANTI_FALL_THICKNESS / 2, z))
		pcall(function()
			workspace.Terrain:FillBlock(cf, Vector3.new(s, Shared.ANTI_FALL_THICKNESS, s), Enum.Material.Water)
		end)
		Shared.AntiFallTerrainCenter = Vector3.new(x, y, z)
		filledSize = s
	end
	local function clear()
		if not Shared.AntiFallTerrainCenter then
			return
		end
		local s = filledSize or size()
		local cf = CFrame.new(Shared.AntiFallTerrainCenter - Vector3.new(0, Shared.ANTI_FALL_THICKNESS / 2, 0))
		pcall(function()
			workspace.Terrain:FillBlock(cf, Vector3.new(s, Shared.ANTI_FALL_THICKNESS, s), Enum.Material.Air)
		end)
		Shared.AntiFallTerrainCenter = nil
		filledSize = nil
	end
	local function update(force)
		if not Shared.AntiFallRunning then
			return
		end
		local c = player.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if not r then
			return
		end
		local pos = r.Position
		local s = size()
		local refresh = force
		if not refresh then
			if not Shared.AntiFallTerrainCenter then
				refresh = true
			else
				if (Vector2.new(pos.X, pos.Z) - Vector2.new(Shared.AntiFallTerrainCenter.X, Shared.AntiFallTerrainCenter.Z)).Magnitude > s * 0.30 then
					refresh = true
				end
				if math.abs(Shared.AntiFallTerrainCenter.Y - getY()) > 0.5 then
					refresh = true
				end
				if filledSize ~= s then
					refresh = true
				end
			end
		end
		if not refresh then
			return
		end
		clear()
		fill(pos.X, pos.Z)
	end
	NoxLib.addButton("Movement", {
		name = "AntiFall",
		toggle = true,
		description = "Uses the workspace 'bed' object as the barrier (15 studs below it) and bounces you back up.",
		settings = {
			{
				type = "slider",
				name = "Launch Force",
				key = "bounceForce",
				default = 250,
				min = 50,
				max = 800,
				step = 10
			},
			{
				type = "slider",
				name = "Terrain Size",
				key = "terrainSize",
				default = 512,
				min = 128,
				max = 2048,
				step = 64,
				action = function()
					if Shared.AntiFallRunning then
						update(true)
					end
				end
			}
		},
		action = function(enabled)
			Shared.AntiFallRunning = enabled
			if conn then
				conn:Disconnect();
				conn = nil
			end
			if not enabled then
				clear()
				Shared.AntiFallReferenceY = nil
				return true
			end
			Shared.AntiFallReferenceY = detectRef() or 0
			update(true)
			local last = 0
			conn = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if now - last >= 0.25 then
					last = now
					update(false)
				end
				local c = player.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				if not r then
					return
				end
				local by = getY()
				if r.Position.Y > by + 2 then
					return
				end
				local b = bounce()
				local v = r.AssemblyLinearVelocity
				r.AssemblyLinearVelocity = Vector3.new(v.X, b, v.Z)
				if r.Position.Y < by - 4 then
					r.CFrame = CFrame.new(r.Position.X, by + 5, r.Position.Z)
				end
			end)
			return true
		end
	})
end

-- ============================================================
-- OTHER
-- ============================================================
end
