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

	local thread, folder, points, running = nil, nil, {}, false
	local function getSetting(k, d)
		return getNumber("Renderer", "Breadcrumbs", k, d)
	end
	local function getColorB()
		return getColor("Renderer", "Breadcrumbs", "color", Color3.fromRGB(70, 180, 235))
	end
	local function updateAppearance()
		if not folder then
			return
		end
		local c = getColorB()
		for _, o in ipairs(folder:GetChildren()) do
			if o:IsA("Beam") then
				o.Color = ColorSequence.new(c)
				o.LightEmission = 0
				o.LightInfluence = 0
				o.Transparency = NumberSequence.new(0.22)
			end
		end
	end
	local function clear()
		if folder then
			folder:Destroy()
			folder = nil
		end
		table.clear(points)
	end
	local function addPoint(pos)
		if not folder then
			return
		end
		local a = Instance.new("Attachment")
		a.Name = "Point"
		a.WorldPosition = pos
		a.Parent = folder
		local prev = points[# points]
		if prev and prev.Parent then
			local beam = Instance.new("Beam")
			beam.Name = "Breadcrumb"
			beam.Attachment0 = prev
			beam.Attachment1 = a
			beam.FaceCamera = true
			local t = getSetting("thickness", 0.12)
			beam.Width0 = t
			beam.Width1 = t
			beam.LightEmission = 0
			beam.LightInfluence = 0
			beam.Transparency = NumberSequence.new(0.22)
			beam.Color = ColorSequence.new(getColorB())
			beam.Parent = folder
		end
		points[# points + 1] = a
		local lifetime = getSetting("lifetime", 5)
		task.delay(lifetime, function()
			if a and a.Parent then
				a:Destroy()
			end
			for i, p in ipairs(points) do
				if p == a then
					table.remove(points, i)
					break
				end
			end
		end)
	end
	local function start()
		clear()
		folder = Instance.new("Folder")
		folder.Name = "NoxBreadcrumbs"
		folder.Parent = workspace
		thread = task.spawn(function()
			while running do
				task.wait(0.05)
				if not running then
					break
				end
				local c = player.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				if r then
					local pos = r.Position - Vector3.new(0, 2.7, 0)
					local last = points[# points]
					if not (last and last.Parent and (last.WorldPosition - pos).Magnitude < 0.15) then
						addPoint(pos)
					end
				end
			end
		end)
	end
	local function stop()
		running = false
		if thread then
			task.cancel(thread)
			thread = nil
		end
		clear()
	end
	NoxLib.addButton("Renderer", {
		name = "Breadcrumbs",
		toggle = true,
		description = "Leaves a smooth colored line behind you.",
		settings = {
			{
				type = "colorpicker",
				name = "Color",
				key = "color",
				default = Color3.fromRGB(70, 180, 235),
				action = function()
					updateAppearance()
				end
			},
			{
				type = "slider",
				name = "Lifetime",
				key = "lifetime",
				default = 5,
				min = 0.5,
				max = 30,
				step = 0.1
			},
			{
				type = "slider",
				name = "Line Thickness",
				key = "thickness",
				default = 0.12,
				min = 0.01,
				max = 1,
				step = 0.01
			}
		},
		action = function(enabled)
			running = enabled
			if enabled then
				start()
			else
				stop()
			end
			return true
		end
	})
end
