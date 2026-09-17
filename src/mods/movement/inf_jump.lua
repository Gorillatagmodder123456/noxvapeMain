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

	local held = false
	local att, vel, beganConn, endedConn, hb = nil, nil, nil, nil, nil
	local function ensure()
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		if not root then
			return false
		end
		if att and att.Parent ~= root then
			att:Destroy();
			att = nil
		end
		if vel and vel.Parent ~= root then
			vel:Destroy();
			vel = nil
		end
		if not att then
			att = Instance.new("Attachment")
			att.Name = "NoxInfJumpAtt"
			att.Parent = root
		end
		if not vel then
			vel = Instance.new("LinearVelocity")
			vel.Name = "NoxInfJumpVel"
			vel.Attachment0 = att
			vel.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
			vel.RelativeTo = Enum.ActuatorRelativeTo.World
			vel.LineDirection = Vector3.new(0, 1, 0)
			vel.LineVelocity = 0
			vel.MaxForce = 0
			vel.Parent = root
		end
		return true
	end
	local function destroy()
		if vel then
			vel:Destroy();
			vel = nil
		end
		if att then
			att:Destroy();
			att = nil
		end
	end
	NoxLib.addButton("Movement", {
		name = "Inf Jump",
		toggle = true,
		description = "Hold Space to float upward.",
		settings = {
			{
				type = "slider",
				name = "Float Speed",
				key = "floatSpeed",
				default = 35,
				min = 1,
				max = 150
			}
		},
		action = function(enabled)
			if beganConn then
				beganConn:Disconnect();
				beganConn = nil
			end
			if endedConn then
				endedConn:Disconnect();
				endedConn = nil
			end
			if hb then
				hb:Disconnect();
				hb = nil
			end
			held = false
			destroy()
			if not enabled then
				return true
			end
			ensure()
			beganConn = UserInputService.InputBegan:Connect(function(i)
				if i.KeyCode == Enum.KeyCode.Space then
					held = true
				end
			end)
			endedConn = UserInputService.InputEnded:Connect(function(i)
				if i.KeyCode == Enum.KeyCode.Space then
					held = false
				end
			end)
			hb = RunService.Heartbeat:Connect(function()
				if Shared.FlyRunning then
					if vel then
						vel.MaxForce = 0
					end
					return
				end
				if not ensure() then
					return
				end
				if held then
					vel.LineVelocity = getNumber("Movement", "Inf Jump", "floatSpeed", 35)
					vel.MaxForce = math.huge
				else
					vel.MaxForce = 0
				end
			end)
			return true
		end
	})
end
