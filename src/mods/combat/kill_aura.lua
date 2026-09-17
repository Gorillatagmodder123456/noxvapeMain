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

	local TargetHUD = {
		Enabled = false,
		Frame = nil,
		ScreenGui = nil,
		Avatar = nil,
		NameLabel = nil,
		HealthFill = nil,
		HPText = nil,
		Stroke = nil,
		CurrentTarget = nil,
		LastThumbnailKey = nil
	}
	local TargetBox, TargetBoxAdornee
	local conn = nil
	local function createHUD()
		if TargetHUD.ScreenGui then
			return
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "NoxTargetHUD"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 999998
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.Parent = player:WaitForChild("PlayerGui")
		TargetHUD.ScreenGui = sg
		local f = Instance.new("Frame", sg)
		f.Name = "HUD"
		f.Size = UDim2.fromOffset(210, 64)
		f.BackgroundColor3 = Color3.fromRGB(4, 5, 7)
		f.BackgroundTransparency = 0.12
		f.BorderSizePixel = 0
		f.Visible = false
		TargetHUD.Frame = f
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", f)
		stroke.Color = Color3.fromRGB(255, 50, 50)
		stroke.Thickness = 1.5
		TargetHUD.Stroke = stroke
		local av = Instance.new("ImageLabel", f)
		av.Name = "Avatar"
		av.Size = UDim2.fromOffset(40, 40)
		av.Position = UDim2.fromOffset(8, 8)
		av.BackgroundColor3 = Color3.fromRGB(7, 9, 12)
		av.BorderSizePixel = 0
		av.Image = ""
		av.ScaleType = Enum.ScaleType.Crop
		TargetHUD.Avatar = av
		Instance.new("UICorner", av).CornerRadius = UDim.new(0, 4)
		local nl = Instance.new("TextLabel", f)
		nl.Name = "NameLabel"
		nl.Size = UDim2.new(1, - 58, 0, 18)
		nl.Position = UDim2.fromOffset(54, 6)
		nl.BackgroundTransparency = 1
		nl.Font = Enum.Font.BuilderSansBold
		nl.TextSize = 14
		nl.TextColor3 = Color3.fromRGB(235, 240, 245)
		nl.TextXAlignment = Enum.TextXAlignment.Left
		nl.TextTruncate = Enum.TextTruncate.AtEnd
		nl.Text = ""
		TargetHUD.NameLabel = nl
		local hp = Instance.new("TextLabel", f)
		hp.Name = "HPText"
		hp.Size = UDim2.new(1, - 58, 0, 12)
		hp.Position = UDim2.fromOffset(54, 24)
		hp.BackgroundTransparency = 1
		hp.Font = Enum.Font.BuilderSansBold
		hp.TextSize = 11
		hp.TextColor3 = Color3.fromRGB(235, 240, 245)
		hp.TextXAlignment = Enum.TextXAlignment.Left
		hp.TextYAlignment = Enum.TextYAlignment.Center
		hp.Text = ""
		TargetHUD.HPText = hp
		local hb = Instance.new("Frame", f)
		hb.Name = "HealthBg"
		hb.Size = UDim2.new(1, - 66, 0, 12)
		hb.Position = UDim2.fromOffset(54, 42)
		hb.BackgroundColor3 = Color3.fromRGB(7, 9, 12)
		hb.BorderSizePixel = 0
		Instance.new("UICorner", hb).CornerRadius = UDim.new(0, 6)
		local hf = Instance.new("Frame", hb)
		hf.Name = "HealthFill"
		hf.Size = UDim2.new(1, 0, 1, 0)
		hf.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		hf.BorderSizePixel = 0
		TargetHUD.HealthFill = hf
		Instance.new("UICorner", hf).CornerRadius = UDim.new(0, 6)
		RunService.RenderStepped:Connect(function()
			if not TargetHUD.Enabled or not TargetHUD.CurrentTarget then
				if TargetHUD.Frame and TargetHUD.Frame.Visible then
					TargetHUD.Frame.Visible = false
				end
				return
			end
			local tar = TargetHUD.CurrentTarget
			local isP = typeof(tar) == "Instance" and tar:IsA("Player")
			local ch = isP and tar.Character or tar
			if not ch or not ch.Parent then
				TargetHUD.CurrentTarget = nil
				TargetHUD.Frame.Visible = false
				return
			end
			local h = ch:FindFirstChildOfClass("Humanoid")
			if not h or h.Health <= 0 then
				TargetHUD.CurrentTarget = nil
				TargetHUD.Frame.Visible = false
				return
			end
			TargetHUD.Frame.Visible = true
			local m = UserInputService:GetMouseLocation() + GuiService:GetGuiInset()
			TargetHUD.Frame.Position = UDim2.fromOffset(m.X + 20, m.Y + 20)
			local c = getColor("Combat", "Kill Aura", "targetColor", Color3.fromRGB(255, 50, 50))
			if TargetHUD.Stroke then
				TargetHUD.Stroke.Color = c
			end
			if TargetHUD.HealthFill then
				TargetHUD.HealthFill.BackgroundColor3 = c
			end
			if isP then
				TargetHUD.NameLabel.Text = tar.DisplayName
				local key = "p_" .. tar.UserId
				if TargetHUD.LastThumbnailKey ~= key then
					TargetHUD.LastThumbnailKey = key
					task.spawn(function()
						local ok, u = pcall(function()
							return Players:GetUserThumbnailAsync(tar.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
						end)
						if ok and u and TargetHUD.LastThumbnailKey == key then
							TargetHUD.Avatar.Image = u
						end
					end)
				end
			else
				TargetHUD.NameLabel.Text = ch.Name
				local key = "e_" .. ch.Name
				if TargetHUD.LastThumbnailKey ~= key then
					TargetHUD.LastThumbnailKey = key
					TargetHUD.Avatar.Image = "rbxassetid://6034287638"
				end
			end
			local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
			TargetHUD.HealthFill.Size = UDim2.new(pct, 0, 1, 0)
			TargetHUD.HPText.Text = string.format("HP: %d / %d", math.floor(h.Health + 0.5), math.floor(math.max(h.MaxHealth, 1) + 0.5))
		end)
	end
	local function getShowTarget()
		return getBool("Combat", "Kill Aura", "showTarget", false)
	end
	local function getTBColor()
		return getColor("Combat", "Kill Aura", "targetColor", Color3.fromRGB(255, 50, 50))
	end
	local function destroyTB()
		if TargetBox then
			TargetBox.Adornee = nil
			TargetBox:Destroy()
			TargetBox = nil
		end
		TargetBoxAdornee = nil
	end
	local function setTB(target)
		if not getShowTarget() then
			destroyTB();
			return
		end
		local ad
		if typeof(target) == "Instance" and target:IsA("Player") then
			ad = target.Character
		elseif typeof(target) == "Instance" and (target:IsA("Model") or target:IsA("BasePart")) then
			ad = target
		end
		if not ad or not ad.Parent then
			destroyTB();
			return
		end
		local part, size
		if ad:IsA("Model") then
			part = ad.PrimaryPart or ad:FindFirstChild("HumanoidRootPart") or ad:FindFirstChildWhichIsA("BasePart", true)
			local ok, ex = pcall(function()
				return ad:GetExtentsSize()
			end)
			size = ok and typeof(ex) == "Vector3" and ex or Vector3.new(4, 5.5, 2)
		else
			part = ad
			size = ad.Size
		end
		if not part or not part.Parent then
			destroyTB();
			return
		end
		if TargetBox and TargetBoxAdornee == part and TargetBox.Parent then
			TargetBox.Color3 = getTBColor()
			TargetBox.Size = size
			return
		end
		destroyTB()
		TargetBoxAdornee = part
		TargetBox = Instance.new("BoxHandleAdornment")
		TargetBox.Name = "NoxTargetBox"
		TargetBox.Adornee = part
		TargetBox.AlwaysOnTop = true
		TargetBox.ZIndex = 5
		TargetBox.Transparency = 0.55
		TargetBox.Color3 = getTBColor()
		TargetBox.Size = size
		TargetBox.Parent = player:WaitForChild("PlayerGui")
	end
	NoxLib.addButton("Combat", {
		name = "Kill Aura",
		toggle = true,
		description = "Attacks the closest enemy player or entity.",
		settings = {
			{
				type = "slider",
				name = "Range",
				key = "range",
				default = 15,
				min = 1,
				max = 100
			},
			{
				type = "slider",
				name = "Delay",
				key = "delay",
				default = 0.25,
				min = 0.05,
				max = 2,
				step = 0.01
			},
			{
				type = "checkbox",
				name = "Mouse Down Only",
				key = "mouseDownOnly",
				default = false
			},
			{
				type = "checkbox",
				name = "Entities",
				key = "entities",
				default = false,
				action = function()
					NoxLib.notify("Detected " .. # collectAllEntities() .. " entities", "enabled")
				end
			},
			{
				type = "checkbox",
				name = "Target HUD",
				key = "targetHud",
				default = false
			},
			{
				type = "checkbox",
				name = "Show Target",
				key = "showTarget",
				default = false,
				action = function()
					if getShowTarget() then
						setTB(TargetHUD.CurrentTarget)
					else
						destroyTB()
					end
				end
			},
			{
				type = "colorpicker",
				name = "Target Color",
				key = "targetColor",
				default = Color3.fromRGB(255, 50, 50),
				action = function()
					if TargetBox then
						TargetBox.Color3 = getTBColor()
					end
					if TargetHUD.Stroke then
						TargetHUD.Stroke.Color = getTBColor()
					end
					if TargetHUD.HealthFill then
						TargetHUD.HealthFill.BackgroundColor3 = getTBColor()
					end
				end
			}
		},
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			if not enabled then
				TargetHUD.Enabled = false
				TargetHUD.CurrentTarget = nil
				if TargetHUD.Frame then
					TargetHUD.Frame.Visible = false
				end
				destroyTB()
				Shared.KATarget = nil
				Shared.KARoot = nil
				return true
			end
			createHUD()
			local lastAttack, lastSettingsCheck, lastTargetSearch, lastWeaponCheck = 0, 0, - math.huge, 0
			local cDelay, cRange, cMouse, cEntities, cHud, cShow = 0.25, 15, false, false, false, false
			local cachedTarget, cachedRoot, cachedDist = nil, nil, math.huge
			local cachedWeapon = nil
			local lastDestroyed = true
			conn = RunService.Heartbeat:Connect(function()
				local now = os.clock()
				if now - lastSettingsCheck >= 0.10 then
					cMouse = getBool("Combat", "Kill Aura", "mouseDownOnly", false)
					cDelay = getNumber("Combat", "Kill Aura", "delay", 0.25)
					cRange = getNumber("Combat", "Kill Aura", "range", 15)
					cEntities = getBool("Combat", "Kill Aura", "entities", false)
					cHud = getBool("Combat", "Kill Aura", "targetHud", false)
					cShow = getBool("Combat", "Kill Aura", "showTarget", false)
					TargetHUD.Enabled = cHud
					lastSettingsCheck = now
				end
				if now - lastTargetSearch >= 0.1 then
					lastTargetSearch = now
					local tt, tr, d = getClosestTarget(cEntities)
					if tt and tr then
						local h = getCharacterHumanoid(tt)
						if h and isHumanoidAlive(h) and tr.Parent then
							cachedTarget, cachedRoot, cachedDist = tt, tr, d
						else
							cachedTarget, cachedRoot, cachedDist = nil, nil, math.huge
						end
					else
						cachedTarget, cachedRoot, cachedDist = nil, nil, math.huge
					end
				end
				local target, tRoot, dist = cachedTarget, cachedRoot, cachedDist
				if target and tRoot and not tRoot.Parent then
					target, tRoot, dist = nil, nil, math.huge
					cachedTarget, cachedRoot, cachedDist = nil, nil, math.huge
				end
				local inRange = (target and tRoot and dist and dist <= cRange) and target or nil
				Shared.KATarget = inRange
				Shared.KARoot = inRange and tRoot or nil
				local show = true
				if cMouse then
					show = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				end
				if TargetHUD.Enabled and show then
					if inRange then
						local tp = Players:GetPlayerFromCharacter(inRange)
						TargetHUD.CurrentTarget = tp or inRange
					else
						TargetHUD.CurrentTarget = nil
					end
				else
					TargetHUD.CurrentTarget = nil
					if TargetHUD.Frame then
						TargetHUD.Frame.Visible = false
					end
				end
				if cShow and show and inRange then
					setTB(inRange)
					lastDestroyed = false
				elseif not lastDestroyed then
					destroyTB()
					lastDestroyed = true
				end
				if cMouse and not show then
					return
				end
				if not target or not tRoot or dist > cRange then
					return
				end
				local tp = Players:GetPlayerFromCharacter(target)
				if tp and not isEnemyPlayer(tp) then
					return
				end
				local th = getCharacterHumanoid(target)
				if not isHumanoidAlive(th) then
					return
				end
				if now - lastAttack < cDelay then
					return
				end
				local lc = player.Character
				local root = lc and getCharacterRoot(lc)
				local cam = workspace.CurrentCamera
				if now - lastWeaponCheck >= 0.20 or not cachedWeapon or not cachedWeapon.Parent then
					cachedWeapon = getSwordWeapon()
					lastWeaponCheck = now
				end
				if not root or not cam or not cachedWeapon or not RemoteList.SwordHit then
					return
				end
				local dir = tRoot.Position - cam.CFrame.Position
				local mag = dir.Magnitude
				if mag <= 0 then
					return
				end
				local ok = pcall(function()
					RemoteList.SwordHit:FireServer({
						chargedAttack = {
							chargeRatio = 0
						},
						entityInstance = target,
						validate = {
							targetPosition = {
								value = tRoot.Position
							},
							raycast = {
								cameraPosition = {
									value = cam.CFrame.Position
								},
								cursorDirection = {
									value = dir / mag
								}
							},
							selfPosition = {
								value = root.Position
							}
						},
						weapon = cachedWeapon
					})
				end)
				if ok then
					lastAttack = now
				end
			end)
			return true
		end
	})
end
