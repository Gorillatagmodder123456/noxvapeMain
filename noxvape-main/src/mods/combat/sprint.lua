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
	NoxLib.addButton("Combat", {
		name = "Sprint",
		toggle = true,
		description = "Forces sprinting.",
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			local controller = getSprintController()
			if not controller then
				return false
			end
			if enabled then
				conn = RunService.Heartbeat:Connect(function()
					pcall(function()
						controller.blockSprint = false
						controller.attemptingSprint = true
						if not controller.sprinting then
							controller:startSprinting()
						end
					end)
				end)
			else
				pcall(function()
					controller.attemptingSprint = false
					controller:stopSprinting(true)
				end)
			end
			return true
		end
	})
end
return true
