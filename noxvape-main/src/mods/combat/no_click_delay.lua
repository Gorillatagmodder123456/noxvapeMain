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
	local function apply(enabled)
		local controller = getSwordController()
		if not controller then
			NoxLib.notify("SwordController not found!", "error")
			return false
		end
		if enabled then
			if not controller._originalIsClickingTooFast then
				controller._originalIsClickingTooFast = controller.isClickingTooFast
			end
			controller.isClickingTooFast = function()
				return false
			end
		else
			if controller._originalIsClickingTooFast then
				controller.isClickingTooFast = controller._originalIsClickingTooFast
				controller._originalIsClickingTooFast = nil
			end
		end
		return true
	end
	NoxLib.addButton("Combat", {
		name = "No Click Delay",
		toggle = true,
		description = "Turns off sword delay.",
		action = apply
	})
end
return true
