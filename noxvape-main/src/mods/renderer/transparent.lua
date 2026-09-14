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
	local running, thread, originals = false, nil, {}
	local function apply()
		local c = player.Character
		if not c then
			return
		end
		local col = getColor("Renderer", "Transparent", "color", Color3.fromRGB(255, 255, 255))
		local alpha = math.clamp(getNumber("Renderer", "Transparent", "alpha", 0.5), 0, 1)
		for _, o in ipairs(c:GetDescendants()) do
			if o:IsA("BasePart") and o.Name ~= "NoxCape" and o.Name ~= "HumanoidRootPart" then
				if not originals[o] then
					originals[o] = {
						Color = o.Color,
						Transparency = o.Transparency
					}
				end
				pcall(function()
					o.Color = col
					o.Transparency = alpha
				end)
			elseif (o:IsA("Decal") or o:IsA("Texture")) and o.Parent and o.Parent.Name ~= "NoxCape" then
				pcall(function()
					o.Transparency = alpha
				end)
			end
		end
	end
	local function restore()
		for p, orig in pairs(originals) do
			if p and p.Parent then
				pcall(function()
					p.Color = orig.Color
					p.Transparency = orig.Transparency
				end)
			end
		end
		originals = {}
		local c = player.Character
		if c then
			for _, o in ipairs(c:GetDescendants()) do
				if o:IsA("Decal") or o:IsA("Texture") then
					pcall(function()
						o.Transparency = 0
					end)
				end
			end
		end
	end
	NoxLib.addButton("Renderer", {
		name = "Transparent",
		toggle = true,
		description = "Turns player transparent with a custom color.",
		settings = {
			{
				type = "colorpicker",
				name = "Color",
				key = "color",
				default = Color3.fromRGB(255, 255, 255),
				action = function()
					if running then
						apply()
					end
				end
			},
			{
				type = "slider",
				name = "Transparency",
				key = "alpha",
				default = 0.5,
				min = 0,
				max = 1,
				step = 0.05,
				action = function()
					if running then
						apply()
					end
				end
			}
		},
		action = function(enabled)
			running = enabled
			if thread then
				task.cancel(thread)
				thread = nil
			end
			if enabled then
				apply()
				thread = task.spawn(function()
					while running do
						task.wait(0.25)
						if not running then
							break
						end
						apply()
					end
				end)
			else
				restore()
			end
			return true
		end
	})
end
return true
