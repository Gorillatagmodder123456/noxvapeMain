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
