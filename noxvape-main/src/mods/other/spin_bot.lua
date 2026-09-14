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
return true
