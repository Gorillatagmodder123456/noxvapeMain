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

	local conn, orient, att, origAuto, origStates = nil, nil, nil, nil, nil
	local function destroyOrient()
		if orient then
			orient:Destroy();
			orient = nil
		end
		if att then
			att:Destroy();
			att = nil
		end
	end
	local function setup(root)
		if not root then
			return false
		end
		if att and att.Parent ~= root then
			destroyOrient()
		end
		if orient and orient.Parent ~= root then
			destroyOrient()
		end
		if not att then
			att = Instance.new("Attachment")
			att.Name = "NoxFlyAttachment"
			att.Parent = root
		end
		if not orient then
			orient = Instance.new("AlignOrientation")
			orient.Name = "NoxFlyOrientation"
			orient.Mode = Enum.OrientationAlignmentMode.OneAttachment
			orient.Attachment0 = att
			orient.RigidityEnabled = true
			orient.MaxTorque = math.huge
			orient.Responsiveness = 200
			orient.Parent = root
		end
		return true
	end
	local function restore(h)
		if not h then
			return
		end
		if origStates then
			for s, v in pairs(origStates) do
				pcall(function()
					h:SetStateEnabled(s, v)
				end)
			end
			origStates = nil
		end
		if origAuto ~= nil then
			pcall(function()
				h.AutoRotate = origAuto
			end)
			origAuto = nil
		end
		pcall(function()
			h:ChangeState(Enum.HumanoidStateType.Running)
		end)
	end
	NoxLib.addButton("Movement", {
		name = "Fly",
		toggle = true,
		description = "Fly while keeping your body upright.",
		settings = {
			{
				type = "slider",
				name = "Vertical Speed",
				key = "verticalSpeed",
				default = 50,
				min = 1,
				max = 100
			},
			{
				type = "slider",
				name = "Horizontal Speed",
				key = "horizontalSpeed",
				default = 23,
				min = 1,
				max = 100
			}
		},
		action = function(enabled)
			Shared.FlyRunning = enabled
			if conn then
				conn:Disconnect();
				conn = nil
			end
			destroyOrient()
			local ch = player.Character
			local h = ch and ch:FindFirstChildOfClass("Humanoid")
			if not enabled then
				restore(h)
				local root = ch and ch:FindFirstChild("HumanoidRootPart")
				if root then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end
				return true
			end
			if h then
				origAuto = h.AutoRotate
				origStates = {}
				for _, s in ipairs({
					Enum.HumanoidStateType.FallingDown,
					Enum.HumanoidStateType.Ragdoll,
					Enum.HumanoidStateType.PlatformStanding
				}) do
					local ok, v = pcall(function()
						return h:GetStateEnabled(s)
					end)
					if ok then
						origStates[s] = v
					end
					pcall(function()
						h:SetStateEnabled(s, false)
					end)
				end
				h.AutoRotate = false
				pcall(function()
					h:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			end
			conn = RunService.Heartbeat:Connect(function()
				local c = player.Character
				local root = c and c:FindFirstChild("HumanoidRootPart")
				local hum = c and c:FindFirstChildOfClass("Humanoid")
				if not root or not hum then
					return
				end
				if hum.AutoRotate then
					hum.AutoRotate = false
				end
				pcall(function()
					hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
				end)
				setup(root)
				local cam = workspace.CurrentCamera
				if not cam then
					return
				end
				local hSp = getNumber("Movement", "Fly", "horizontalSpeed", 23)
				local vSp = getNumber("Movement", "Fly", "verticalSpeed", 50)
				local look = cam.CFrame.LookVector
				local right = cam.CFrame.RightVector
				local fl = Vector3.new(look.X, 0, look.Z)
				local fr = Vector3.new(right.X, 0, right.Z)
				fl = fl.Magnitude < 0.001 and Vector3.new(0, 0, - 1) or fl.Unit
				fr = fr.Magnitude < 0.001 and Vector3.new(1, 0, 0) or fr.Unit
				local d = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then
					d += fl
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					d -= fl
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					d += fr
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					d -= fr
				end
				if d.Magnitude > 0 then
					d = d.Unit
				end
				local vert = 0
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					vert += 1
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
					vert -= 1
				end
				root.AssemblyLinearVelocity = Vector3.new(d.X * hSp, vert * vSp, d.Z * hSp)
				root.AssemblyAngularVelocity = Vector3.zero
				local yaw = math.atan2(fl.X, - fl.Z)
				local upright = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
				if orient then
					orient.CFrame = upright
				end
			end)
			return true
		end
	})
end
