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
	local highlights, conn, playerConns = {}, nil, {}
	local running = false
	local function teamColors()
		return getBool("Renderer", "Chams", "teamColors", false)
	end
	local function baseColor()
		return getColor("Renderer", "Chams", "color", Color3.fromRGB(70, 180, 235))
	end
	local function color(t)
		if teamColors() and t and t.Team then
			return t.Team.TeamColor.Color
		end
		return baseColor()
	end
	local function transparency()
		local v = NoxLib.getSetting("Renderer", "Chams", "transparency", 0.5)
		return type(v) == "number" and math.clamp(v, 0, 1) or 0.5
	end
	local function depthMode()
		return getBool("Renderer", "Chams", "occluded", false) and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
	end
	local function valid(t)
		if not t or t == player or not t.Parent then
			return false
		end
		local c = t.Character
		return c and c.Parent and c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") ~= nil
	end
	local function create(t)
		if not valid(t) then
			return
		end
		local ch = t.Character
		local ex = highlights[t]
		if ex and ex.Parent then
			ex.Adornee = ch
			ex.Enabled = true
			return
		end
		local h = Instance.new("Highlight")
		h.Name = "NoxChams"
		h.Adornee = ch
		h.FillColor = color(t)
		h.FillTransparency = transparency()
		h.OutlineColor = color(t)
		h.OutlineTransparency = math.clamp(transparency() + 0.2, 0, 1)
		h.DepthMode = depthMode()
		h.Parent = workspace
		highlights[t] = h
	end
	local function detach(t)
		local h = highlights[t]
		if h then
			h.Enabled = false
			h.Adornee = nil
		end
	end
	local function remove(t)
		local h = highlights[t]
		if h then
			h.Enabled = false
			h.Adornee = nil
			h:Destroy()
			highlights[t] = nil
		end
	end
	local function update(t)
		local h = highlights[t]
		if not h or not h.Parent then
			return
		end
		if not valid(t) then
			detach(t);
			return
		end
		h.FillColor = color(t)
		h.FillTransparency = transparency()
		h.OutlineColor = color(t)
		h.OutlineTransparency = math.clamp(transparency() + 0.2, 0, 1)
		h.DepthMode = depthMode()
		h.Adornee = t.Character
		h.Enabled = true
	end
	local function updateAll()
		if not running then
			return
		end
		for _, t in ipairs(Players:GetPlayers()) do
			if t ~= player then
				update(t)
			end
		end
	end
	local function watchdog()
		for t, h in pairs(highlights) do
			if not h or not h.Parent then
				highlights[t] = nil
			elseif not valid(t) then
				detach(t)
			else
				local ch = t.Character
				if h.Adornee ~= ch then
					h.Adornee = ch
					h.Enabled = true
				end
			end
		end
	end
	local function cleanup()
		running = false
		if conn then
			conn:Disconnect();
			conn = nil
		end
		for _, c in ipairs(playerConns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		table.clear(playerConns)
		for t in pairs(highlights) do
			remove(t)
		end
	end
	NoxLib.addButton("Renderer", {
		name = "Chams",
		toggle = true,
		description = "Highlights players with a solid color.",
		settings = {
			{
				type = "checkbox",
				name = "Team Colors",
				key = "teamColors",
				default = false,
				action = updateAll
			},
			{
				type = "colorpicker",
				name = "Color",
				key = "color",
				default = Color3.fromRGB(70, 180, 235),
				action = updateAll
			},
			{
				type = "slider",
				name = "Transparency",
				key = "transparency",
				default = 0.5,
				min = 0,
				max = 1,
				step = 0.1,
				action = updateAll
			},
			{
				type = "checkbox",
				name = "Occluded",
				key = "occluded",
				default = false,
				action = updateAll
			}
		},
		action = function(enabled)
			cleanup()
			if not enabled then
				return true
			end
			running = true
			for _, t in ipairs(Players:GetPlayers()) do
				if t ~= player then
					create(t)
				end
			end
			conn = Players.PlayerAdded:Connect(function(t)
				if t == player then
					return
				end
				playerConns[# playerConns + 1] = t.CharacterAdded:Connect(function()
					task.wait(0.2)
					if running then
						create(t)
					end
				end)
				playerConns[# playerConns + 1] = t.CharacterRemoving:Connect(function()
					detach(t)
				end)
				if t.Character then
					create(t)
				end
			end)
			for _, t in ipairs(Players:GetPlayers()) do
				if t ~= player then
					playerConns[# playerConns + 1] = t.CharacterAdded:Connect(function()
						task.wait(0.2)
						if running then
							create(t)
						end
					end)
					playerConns[# playerConns + 1] = t.CharacterRemoving:Connect(function()
						detach(t)
					end)
				end
			end
			task.spawn(function()
				while running do
					task.wait(2)
					if running then
						watchdog()
					end
				end
			end)
			return true
		end
	})
end
return true
