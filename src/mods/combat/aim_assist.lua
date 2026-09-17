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

	local circle, stroke, locked, conn = nil, nil, nil, nil
	local function getFov()
		return getNumber("Combat", "Aim Assist", "fov", 100)
	end
	local function getColorA()
		return getColor("Combat", "Aim Assist", "color", Color3.fromRGB(255, 255, 255))
	end
	local function updateCircle()
		if not circle then
			return
		end
		local f = getFov()
		circle.Size = UDim2.fromOffset(f * 2, f * 2)
		if stroke then
			stroke.Color = getColorA()
		end
	end
	local function setupGui()
		if circle then
			return
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "NoxAimAssistFOV"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 999997
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.Parent = player:WaitForChild("PlayerGui")
		circle = Instance.new("Frame", sg)
		circle.Name = "FOV"
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Position = UDim2.fromScale(0.5, 0.5)
		circle.BackgroundTransparency = 1
		circle.BorderSizePixel = 0
		circle.Visible = false
		Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
		stroke = Instance.new("UIStroke", circle)
		stroke.Thickness = 1.5
		stroke.Color = getColorA()
		stroke.Transparency = 0.15
	end
	local function hasLOS(pos)
		local cam = workspace.CurrentCamera
		if not cam then
			return false
		end
		local o = cam.CFrame.Position
		local d = pos - o
		local dist = d.Magnitude
		if dist <= 0 then
			return true
		end
		local p = RaycastParams.new()
		p.FilterType = Enum.RaycastFilterType.Exclude
		local fl = {}
		if player.Character then
			fl[# fl + 1] = player.Character
		end
		p.FilterDescendantsInstances = fl
		local r = workspace:Raycast(o, d.Unit * dist, p)
		return not r or r.Distance >= dist - 1
	end
	local function stillValid(ch)
		if not ch or not ch.Parent then
			return nil, nil
		end
		local h = ch:FindFirstChildOfClass("Humanoid")
		local r = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head")
		if not h or not r or not isHumanoidAlive(h) then
			return nil, nil
		end
		local tp = Players:GetPlayerFromCharacter(ch)
		if tp and not isEnemyPlayer(tp) then
			return nil, nil
		end
		return ch, r
	end
	local function validate(ch)
		local c, r = stillValid(ch)
		if not c or not hasLOS(r.Position) then
			return nil, nil
		end
		return c, r
	end
	local function inFov(root, cam, f)
		local vp = cam.ViewportSize
		local ctr = Vector2.new(vp.X / 2, vp.Y / 2)
		local sp, on = cam:WorldToViewportPoint(root.Position)
		if not on or sp.Z <= 0 then
			return false
		end
		return (Vector2.new(sp.X, sp.Y) - ctr).Magnitude <= f
	end
	local function findTarget()
		local cam = workspace.CurrentCamera
		if not cam then
			return nil, nil
		end
		local fov = getFov()
		if getBool("Combat", "Aim Assist", "useKATarget", false) then
			local t = Shared.KATarget
			if not t then
				return nil, nil
			end
			local c, r = validate(t)
			if not c or not r or not inFov(r, cam, fov) then
				return nil, nil
			end
			return c, r
		end
		if locked then
			local c, r = validate(locked)
			if c then
				return c, r
			end
			locked = nil
		end
		local vp = cam.ViewportSize
		local ctr = Vector2.new(vp.X / 2, vp.Y / 2)
		local best, bestRoot, bestDist = nil, nil, math.huge
		for _, tar in ipairs(Players:GetPlayers()) do
			if tar ~= player and tar.Character and isEnemyPlayer(tar) then
				local c, r = validate(tar.Character)
				if c and r then
					local sp, on = cam:WorldToViewportPoint(r.Position)
					if on and sp.Z > 0 then
						local d = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
						if d <= fov and d < bestDist then
							best, bestRoot, bestDist = c, r, d
						end
					end
				end
			end
		end
		for _, e in ipairs(collectAllEntities()) do
			local c, r = validate(e.model)
			if c and r then
				local sp, on = cam:WorldToViewportPoint(r.Position)
				if on and sp.Z > 0 then
					local d = (Vector2.new(sp.X, sp.Y) - ctr).Magnitude
					if d <= fov and d < bestDist then
						best, bestRoot, bestDist = c, r, d
					end
				end
			end
		end
		if best then
			locked = best
		end
		return best, bestRoot
	end
	NoxLib.addButton("Combat", {
		name = "Aim Assist",
		toggle = true,
		description = "Smoothly aims camera at a target.",
		settings = {
			{
				type = "checkbox",
				name = "Use Kill Aura Target",
				key = "useKATarget",
				default = false
			},
			{
				type = "checkbox",
				name = "Require Right Click",
				key = "requireRMB",
				default = true
			},
			{
				type = "checkbox",
				name = "FOV Circle",
				key = "fovCircle",
				default = false,
				action = function()
					if circle then
						circle.Visible = getBool("Combat", "Aim Assist", "fovCircle", false)
					end
				end
			},
			{
				type = "slider",
				name = "FOV",
				key = "fov",
				default = 100,
				min = 20,
				max = 500,
				action = function()
					updateCircle()
				end
			},
			{
				type = "colorpicker",
				name = "Color",
				key = "color",
				default = Color3.fromRGB(255, 255, 255),
				action = function()
					updateCircle()
				end
			}
		},
		action = function(enabled)
			locked = nil
			if conn then
				conn:Disconnect();
				conn = nil
			end
			if not enabled then
				if circle then
					circle.Visible = false
				end
				return true
			end
			setupGui()
			updateCircle()
			if circle then
				circle.Visible = getBool("Combat", "Aim Assist", "fovCircle", false)
			end
			local lastSearch, cachedCh, cachedRoot, lastCircle = - math.huge, nil, nil, nil
			conn = RunService.RenderStepped:Connect(function(dt)
				local sc = getBool("Combat", "Aim Assist", "fovCircle", false)
				if sc ~= lastCircle then
					updateCircle()
					if circle then
						circle.Visible = sc
					end
					lastCircle = sc
				end
				if not getBool("Combat", "Aim Assist", "useKATarget", false) then
					if getBool("Combat", "Aim Assist", "requireRMB", true) and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
						locked = nil
						cachedCh, cachedRoot = nil, nil
						return
					end
				end
				local now = os.clock()
				if now - lastSearch >= 0.1 then
					lastSearch = now
					local c, r = findTarget()
					if c and r and r.Parent then
						local h = c:FindFirstChildOfClass("Humanoid")
						if h and isHumanoidAlive(h) then
							cachedCh, cachedRoot = c, r
						else
							cachedCh, cachedRoot = nil, nil
						end
					else
						cachedCh, cachedRoot = nil, nil
					end
				end
				if not cachedCh or not cachedRoot or not cachedRoot.Parent then
					cachedCh, cachedRoot = nil, nil
					return
				end
				local cam = workspace.CurrentCamera
				if not cam then
					return
				end
				local aim = cachedRoot.Position
				local head = cachedCh:FindFirstChild("Head")
				if head then
					aim = head.Position
				end
				local look = CFrame.new(cam.CFrame.Position, aim)
				cam.CFrame = cam.CFrame:Lerp(look, math.clamp(dt * 10, 0, 1))
			end)
			return true
		end
	})
end
