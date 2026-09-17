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

	local conn, currentTarget, lastSearch = nil, nil, - math.huge
	NoxLib.addButton("Movement", {
		name = "PlayerAttach",
		toggle = true,
		description = "Smoothly follows the closest enemy from above. Discards targets below bed level.",
		settings = {
			{
				type = "slider",
				name = "Range",
				key = "range",
				default = 50,
				min = 5,
				max = 200,
				step = 1
			},
			{
				type = "slider",
				name = "Height",
				key = "height",
				default = 15,
				min = 5,
				max = 50,
				step = 1
			},
			{
				type = "slider",
				name = "Lerp Speed",
				key = "lerpSpeed",
				default = 8,
				min = 1,
				max = 30,
				step = 1
			}
		},
		action = function(enabled)
			if conn then
				conn:Disconnect();
				conn = nil
			end
			currentTarget = nil
			lastSearch = - math.huge
			if not enabled then
				return true
			end
			local function getRange()
				return getNumber("Movement", "PlayerAttach", "range", 50)
			end
			local function getHeight()
				return getNumber("Movement", "PlayerAttach", "height", 15)
			end
			local function getSpeed()
				return getNumber("Movement", "PlayerAttach", "lerpSpeed", 8)
			end
			local function getBedY()
				local bed = findBed()
				return bed and bed.Position.Y or nil
			end
			local function isBelowBed(root)
				if not root then
					return false
				end
				local by = getBedY()
				if not by then
					return false
				end
				return root.Position.Y < (by - 5)
			end
			local function valid(target)
				if not target or target == player then
					return false
				end
				if not target.Parent then
					return false
				end
				local ch = target.Character
				if not ch or not ch.Parent then
					return false
				end
				local h = ch:FindFirstChildOfClass("Humanoid")
				local r = ch:FindFirstChild("HumanoidRootPart")
				if not h or not r or not isHumanoidAlive(h) or not isEnemyPlayer(target) then
					return false
				end
				if isBelowBed(r) then
					return false
				end
				return true
			end
			local function closest()
				local c = player.Character
				if not c then
					return nil
				end
				local r = c:FindFirstChild("HumanoidRootPart")
				if not r then
					return nil
				end
				local max = getRange()
				local best, bestD = nil, math.huge
				for _, tar in ipairs(Players:GetPlayers()) do
					if tar ~= player and valid(tar) then
						local tr = tar.Character and tar.Character:FindFirstChild("HumanoidRootPart")
						if tr then
							local d = (tr.Position - r.Position).Magnitude
							if d <= max and d < bestD then
								bestD = d
								best = tar
							end
						end
					end
				end
				return best
			end
			local function hasRoof(tr, h, ignore)
				local p = RaycastParams.new()
				p.FilterType = Enum.RaycastFilterType.Exclude
				local fl = {}
				if ignore then
					fl[# fl + 1] = ignore
				end
				if tr.Parent then
					fl[# fl + 1] = tr.Parent
				end
				p.FilterDescendantsInstances = fl
				return not workspace:Raycast(tr.Position, Vector3.new(0, h + 2, 0), p)
			end
			conn = RunService.Heartbeat:Connect(function(dt)
				if Shared.FlyRunning then
					return
				end
				if os.clock() - Shared.TPDownLastTeleportTime < 0.15 then
					return
				end
				local c = player.Character
				local r = c and c:FindFirstChild("HumanoidRootPart")
				if not r then
					currentTarget = nil
					return
				end
				if not valid(currentTarget) then
					local now = os.clock()
					if now - lastSearch >= 0.25 then
						lastSearch = now
						currentTarget = closest()
					end
				end
				local tar = currentTarget
				if not valid(tar) then
					currentTarget = nil
					return
				end
				local tr = tar.Character and tar.Character:FindFirstChild("HumanoidRootPart")
				if not tr then
					currentTarget = nil
					return
				end
				local h = getHeight()
				if not hasRoof(tr, h, c) then
					return
				end
				local tp = tr.Position + Vector3.new(0, h, 0)
				local look = r.CFrame.LookVector
				local fl = Vector3.new(look.X, 0, look.Z)
				fl = fl.Magnitude < 0.001 and Vector3.new(0, 0, - 1) or fl.Unit
				local targetCF = CFrame.lookAt(tp, tp + fl, Vector3.new(0, 1, 0))
				r.CFrame = r.CFrame:Lerp(targetCF, math.clamp(dt * getSpeed(), 0, 1))
				r.AssemblyLinearVelocity = Vector3.zero
				r.AssemblyAngularVelocity = Vector3.zero
			end)
			return true
		end
	})
end
