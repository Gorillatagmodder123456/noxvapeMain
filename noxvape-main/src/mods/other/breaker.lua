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

    NoxLib.addButton("Other", {
        name = "Breaker",
        toggle = true,
        description = "Breaks blocks around you",
        settings = {
			{
				type = "checkbox",
				name = "Ores",
				key = "ores",
				default = false,
				action = function()
					
				end
			},
            {
				type = "checkbox",
				name = "Fast Break",
				key = "fastbreak",
				default = false,
				action = function()
					
				end
			},
            {
				type = "checkbox",
				name = "Show Block",
				key = "showblock",
				default = false,
				action = function()
					
				end
			},
        },
    })
end
return true
