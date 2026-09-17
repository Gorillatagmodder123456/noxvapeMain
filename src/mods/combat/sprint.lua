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

-- ============================================================
-- MOVEMENT
-- ============================================================
end
