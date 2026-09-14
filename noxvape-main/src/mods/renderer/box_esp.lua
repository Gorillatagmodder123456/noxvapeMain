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
	local running, gui, conn, boxes, playerConns = false, nil, nil, {}, {}
	local function boxColor(t)
		if getBool("Renderer", "Box ESP", "teamColors", false) and t and t.Team then
			return t.Team.TeamColor.Color
		end
		return getColor("Renderer", "Box ESP", "color", Color3.fromRGB(255, 255, 255))
	end
	local function thickness()
		return math.clamp(getNumber("Renderer", "Box ESP", "thickness", 1), 1, 5)
	end
	local function fillEnabled()
		return getBool("Renderer", "Box ESP", "fill", false)
	end
	local function fillAlpha()
		return math.clamp(getNumber("Renderer", "Box ESP", "fillAlpha", 0.7), 0, 1)
	end
	local function ensureGui()
		if gui and gui.Parent then
			return
		end
		gui = Instance.new("ScreenGui")
		gui.Name = "NoxBoxESP"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 999995
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = player:WaitForChild("PlayerGui")
	end
	local function create(t)
		if boxes[t] then
			return
		end
		local top = Instance.new("Frame", gui)
		top.BorderSizePixel = 0
		top.BackgroundColor3 = Color3.new(1, 1, 1)
		top.ZIndex = 2
		top.Visible = false
		local bottom = top:Clone();
		bottom.Parent = gui
		local left = top:Clone();
		left.Parent = gui
		local right = top:Clone();
		right.Parent = gui
		local fill = Instance.new("Frame", gui)
		fill.BorderSizePixel = 0
		fill.BackgroundColor3 = Color3.new(1, 1, 1)
		fill.BackgroundTransparency = 0.7
		fill.ZIndex = 1
		fill.Visible = false
		boxes[t] = {
			top = top,
			bottom = bottom,
			left = left,
			right = right,
			fill = fill
		}
	end
	local function destroy(t)
		local b = boxes[t]
		if not b then
			return
		end
		for _, p in pairs(b) do
			if p and p.Parent then
				p:Destroy()
			end
		end
		boxes[t] = nil
	end
	local function hide(b)
		if b.top.Visible then
			b.top.Visible = false
			b.bottom.Visible = false
			b.left.Visible = false
			b.right.Visible = false
			b.fill.Visible = false
		end
	end
	local function charSize(c)
		local h = c:FindFirstChildOfClass("Humanoid")
		local r = c:FindFirstChild("HumanoidRootPart")
		if not r then
			return Vector3.new(4, 5.5, 2)
		end
		local s = r.Size
		if h then
			if h.RigType == Enum.HumanoidRigType.R6 then
				s = Vector3.new(4, 5, 2)
			elseif h.RigType == Enum.HumanoidRigType.R15 then
				local ut, lt = c:FindFirstChild("UpperTorso"), c:FindFirstChild("LowerTorso")
				if ut and lt then
					s = s + ut.Size + lt.Size
				end
			end
		end
		local head = c:FindFirstChild("Head")
		if head then
			s = Vector3.new(s.X, s.Y + head.Size.Y / 2, s.Z)
		end
		return s
	end
	local function update(t, b)
		local c = t.Character
		if not c or not c.Parent then
			hide(b);
			return
		end
		local cam = workspace.CurrentCamera
		if not cam then
			hide(b);
			return
		end
		local r = c:FindFirstChild("HumanoidRootPart")
		if not r then
			hide(b);
			return
		end
		local s = charSize(c)
		local cf = CFrame.new(r.Position)
		local hx, hy, hz = s.X / 2, s.Y / 2, s.Z / 2
		local corners = {
			cf * Vector3.new(- hx, - hy, - hz),
			cf * Vector3.new(- hx, - hy, hz),
			cf * Vector3.new(- hx, hy, - hz),
			cf * Vector3.new(- hx, hy, hz),
			cf * Vector3.new(hx, - hy, - hz),
			cf * Vector3.new(hx, - hy, hz),
			cf * Vector3.new(hx, hy, - hz),
			cf * Vector3.new(hx, hy, hz)
		}
		local minX, minY, maxX, maxY = math.huge, math.huge, - math.huge, - math.huge
		local anyOn = false
		for _, cc in ipairs(corners) do
			local sp, on = cam:WorldToViewportPoint(cc)
			if on and sp.Z > 0 then
				anyOn = true
				if sp.X < minX then
					minX = sp.X
				end
				if sp.X > maxX then
					maxX = sp.X
				end
				if sp.Y < minY then
					minY = sp.Y
				end
				if sp.Y > maxY then
					maxY = sp.Y
				end
			end
		end
		if not anyOn or minX == math.huge then
			hide(b);
			return
		end
		local vp = cam.ViewportSize
		if minX > vp.X or minY > vp.Y or maxX < 0 or maxY < 0 then
			hide(b);
			return
		end
		local w, hgt = maxX - minX, maxY - minY
		if w < 1 or hgt < 1 then
			hide(b);
			return
		end
		local thick = thickness()
		local col = boxColor(t)
		b.top.Visible = true
		b.top.BackgroundColor3 = col
		b.top.Position = UDim2.fromOffset(minX, minY)
		b.top.Size = UDim2.fromOffset(w, thick)
		b.bottom.Visible = true
		b.bottom.BackgroundColor3 = col
		b.bottom.Position = UDim2.fromOffset(minX, maxY - thick)
		b.bottom.Size = UDim2.fromOffset(w, thick)
		b.left.Visible = true
		b.left.BackgroundColor3 = col
		b.left.Position = UDim2.fromOffset(minX, minY)
		b.left.Size = UDim2.fromOffset(thick, hgt)
		b.right.Visible = true
		b.right.BackgroundColor3 = col
		b.right.Position = UDim2.fromOffset(maxX - thick, minY)
		b.right.Size = UDim2.fromOffset(thick, hgt)
		if fillEnabled() then
			b.fill.Visible = true
			b.fill.BackgroundColor3 = col
			b.fill.BackgroundTransparency = fillAlpha()
			b.fill.Position = UDim2.fromOffset(minX, minY)
			b.fill.Size = UDim2.fromOffset(w, hgt)
		else
			b.fill.Visible = false
		end
	end
	local function track(t)
		if t == player then
			return
		end
		create(t)
		playerConns[# playerConns + 1] = t.CharacterAdded:Connect(function()
			task.wait(0.1)
			if running then
				create(t)
			end
		end)
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
		for t in pairs(boxes) do
			destroy(t)
		end
		if gui then
			gui:Destroy()
			gui = nil
		end
	end
	NoxLib.addButton("Renderer", {
		name = "Box ESP",
		toggle = true,
		description = "Draws 2D boxes around players.",
		settings = {
			{
				type = "checkbox",
				name = "Team Colors",
				key = "teamColors",
				default = false
			},
			{
				type = "colorpicker",
				name = "Color",
				key = "color",
				default = Color3.fromRGB(255, 255, 255)
			},
			{
				type = "slider",
				name = "Thickness",
				key = "thickness",
				default = 1,
				min = 1,
				max = 5,
				step = 1
			},
			{
				type = "checkbox",
				name = "Fill",
				key = "fill",
				default = false
			},
			{
				type = "slider",
				name = "Fill Transparency",
				key = "fillAlpha",
				default = 0.7,
				min = 0,
				max = 1,
				step = 0.05
			}
		},
		action = function(enabled)
			cleanup()
			if not enabled then
				return true
			end
			running = true
			ensureGui()
			for _, t in ipairs(Players:GetPlayers()) do
				track(t)
			end
			conn = Players.PlayerAdded:Connect(function(t)
				if t ~= player then
					track(t)
				end
			end)
			task.spawn(function()
				while running do
					RunService.Heartbeat:Wait()
					if not running then
						break
					end
					for t, b in pairs(boxes) do
						if not t.Parent then
							destroy(t)
						else
							update(t, b)
						end
					end
				end
			end)
			return true
		end
	})
end
return true
