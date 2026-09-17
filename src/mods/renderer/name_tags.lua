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

	local tags = {}
	local running = false
	local conns = {}
	local function font()
		return FontMap[NoxLib.getSetting("Renderer", "Name Tags", "font", "GothamBold")] or Enum.Font.GothamBold
	end
	local function color(t)
		if getBool("Renderer", "Name Tags", "teamColors", false) and t and t.Team then
			return t.Team.TeamColor.Color
		end
		return getColor("Renderer", "Name Tags", "color", Color3.fromRGB(255, 255, 255))
	end
	local function remove(char)
		if tags[char] then
			tags[char]:Destroy()
			tags[char] = nil
		end
	end
	local function resize(tag)
		if not tag or not tag.Parent then
			return
		end
		local o = tag:FindFirstChild("Overlay")
		if not o then
			return
		end
		local tx = o:FindFirstChild("Name")
		if not tx then
			return
		end
		local w = tx.TextBounds.X
		if w <= 0 then
			return
		end
		o.Size = UDim2.fromOffset(math.max(w + 18, 30), 25)
		tx.Size = UDim2.fromOffset(w + 2, 25)
	end
	local function update(tag, t)
		if not tag or not tag.Parent or not t then
			return
		end
		local o = tag:FindFirstChild("Overlay")
		local tx = o and o:FindFirstChild("Name")
		if not tx then
			return
		end
		local f = font()
		if tx.Font ~= f then
			tx.Font = f
		end
		local c = color(t)
		if tx.TextColor3 ~= c then
			tx.TextColor3 = c
		end
		if tx.Text ~= t.DisplayName then
			tx.Text = t.DisplayName
		end
		resize(tag)
	end
	local function create(t)
		if t == player or not t.Character or not t.Character.Parent then
			return
		end
		local head = t.Character:FindFirstChild("Head")
		if not head then
			task.delay(0.2, function()
				if running and t.Character and not tags[t.Character] then
					create(t)
				end
			end)
			return
		end
		remove(t.Character)
		local bb = Instance.new("BillboardGui")
		bb.Name = "NoxNameTag"
		bb.Adornee = head
		bb.Size = UDim2.fromOffset(250, 40)
		bb.StudsOffset = Vector3.new(0, 2.8, 0)
		bb.AlwaysOnTop = true
		bb.ResetOnSpawn = false
		bb.Parent = head
		local o = Instance.new("Frame")
		o.Name = "Overlay"
		o.AnchorPoint = Vector2.new(0.5, 0.5)
		o.Position = UDim2.fromScale(0.5, 0.5)
		o.Size = UDim2.fromOffset(60, 25)
		o.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		o.BackgroundTransparency = 0.15
		o.BorderSizePixel = 0
		o.Parent = bb
		Instance.new("UICorner", o).CornerRadius = UDim.new(0, 4)
		local tx = Instance.new("TextLabel")
		tx.Name = "Name"
		tx.AnchorPoint = Vector2.new(0.5, 0.5)
		tx.Position = UDim2.fromScale(0.5, 0.5)
		tx.Size = UDim2.fromOffset(40, 25)
		tx.BackgroundTransparency = 1
		tx.Text = t.DisplayName
		tx.TextSize = 14
		tx.Font = font()
		tx.TextColor3 = color(t)
		tx.TextStrokeTransparency = 1
		tx.TextXAlignment = Enum.TextXAlignment.Center
		tx.TextYAlignment = Enum.TextYAlignment.Center
		tx.Parent = o
		tags[t.Character] = bb
		task.defer(function()
			resize(bb)
		end)
	end
	local function updateAll()
		if not running then
			return
		end
		for c, bb in pairs(tags) do
			if not c.Parent or not bb.Parent then
				tags[c] = nil
			else
				local t = Players:GetPlayerFromCharacter(c)
				if t then
					update(bb, t)
				end
			end
		end
	end
	local function cleanup()
		for i = 1, # conns do
			pcall(function()
				conns[i]:Disconnect()
			end)
		end
		table.clear(conns)
		for c in pairs(tags) do
			remove(c)
		end
	end
	NoxLib.addButton("Renderer", {
		name = "Name Tags",
		toggle = true,
		description = "Displays player names above their heads.",
		settings = {
			{
				type = "dropdown",
				name = "Font",
				key = "font",
				default = "GothamBold",
				options = {
					"Gotham",
					"GothamBold",
					"SourceSans",
					"SourceSansBold",
					"Arial",
					"ArialBold",
					"Cartoon",
					"Code",
					"SciFi",
					"Fantasy",
					"BuilderSans",
					"BuilderSansMedium",
					"BuilderSansBold"
				},
				action = function()
					updateAll()
				end
			},
			{
				type = "checkbox",
				name = "Team Colors",
				key = "teamColors",
				default = false,
				action = function()
					updateAll()
				end
			},
			{
				type = "colorpicker",
				name = "Color",
				key = "color",
				default = Color3.fromRGB(255, 255, 255),
				action = function()
					updateAll()
				end
			}
		},
		action = function(enabled)
			running = enabled
			cleanup()
			if not enabled then
				return true
			end
			for _, t in ipairs(Players:GetPlayers()) do
				if t ~= player then
					create(t)
				end
			end
			updateAll()
			conns[# conns + 1] = Players.PlayerAdded:Connect(function(t)
				if t == player then
					return
				end
				conns[# conns + 1] = t.CharacterAdded:Connect(function()
					task.wait(0.2)
					if running then
						create(t)
					end
				end)
				conns[# conns + 1] = t.CharacterRemoving:Connect(remove)
			end)
			for _, t in ipairs(Players:GetPlayers()) do
				if t ~= player then
					conns[# conns + 1] = t.CharacterAdded:Connect(function()
						task.wait(0.2)
						if running then
							create(t)
						end
					end)
					conns[# conns + 1] = t.CharacterRemoving:Connect(remove)
				end
			end
			conns[# conns + 1] = RunService.Heartbeat:Connect(function()
				if not running then
					return
				end
				conns._last = conns._last or 0
				if os.clock() - conns._last < 0.5 then
					return
				end
				conns._last = os.clock()
				for _, t in ipairs(Players:GetPlayers()) do
					if t ~= player and t.Character and t.Character.Parent then
						if not tags[t.Character] then
							create(t)
						else
							update(tags[t.Character], t)
						end
					end
				end
			end)
			return true
		end
	})
end
