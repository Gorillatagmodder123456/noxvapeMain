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

	local conn = nil
	NoxLib.addButton("Other", {
		name = "Spin Bot",
		toggle = true,
		description = "Continuously spins your character.",
		settings = {
			{
				type = "slider",
				name = "Spin Speed",
				key = "speed",
				default = 10,
				min = 1,
				max = 100
			}
		},
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			if enabled then
				conn = RunService.RenderStepped:Connect(function(dt)
					local c = player.Character
					local r = c and c:FindFirstChild("HumanoidRootPart")
					if not r then
						return
					end
					local s = getNumber("Other", "Spin Bot", "speed", 10)
					r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(360 * s * dt), 0)
				end)
			end
			return true
		end
	})
end
