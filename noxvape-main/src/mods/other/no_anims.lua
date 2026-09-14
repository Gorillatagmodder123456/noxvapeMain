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
	local conn, thread, running = nil, nil, false
	local function apply(c)
		if not c then
			return
		end
		local h = c:FindFirstChildOfClass("Humanoid")
		local an = c:FindFirstChild("Animate")
		if h then
			local a = h:FindFirstChildOfClass("Animator")
			if a then
				for _, tr in ipairs(a:GetPlayingAnimationTracks()) do
					pcall(function()
						tr:Stop()
					end)
				end
			end
		end
		if an then
			an.Disabled = true
		end
	end
	NoxLib.addButton("Other", {
		name = "No Anims",
		toggle = true,
		description = "Stops animations.",
		action = function(enabled)
			running = enabled
			if conn then
				conn:Disconnect();
				conn = nil
			end
			if thread then
				task.cancel(thread)
				thread = nil
			end
			if not enabled then
				local c = player.Character
				if c then
					local an = c:FindFirstChild("Animate")
					if an then
						an.Disabled = false
					end
				end
				return true
			end
			apply(player.Character or player.CharacterAdded:Wait())
			thread = task.spawn(function()
				while running do
					local c = player.Character
					if c then
						local an = c:FindFirstChild("Animate")
						local h = c:FindFirstChildOfClass("Humanoid")
						if an and not an.Disabled then
							an.Disabled = true
						end
						if h then
							local a = h:FindFirstChildOfClass("Animator")
							if a then
								for _, tr in ipairs(a:GetPlayingAnimationTracks()) do
									pcall(function()
										tr:Stop()
									end)
								end
							end
						end
					end
					task.wait(0.5)
				end
			end)
			conn = player.CharacterAdded:Connect(function(c)
				if not running then
					return
				end
				task.spawn(function()
					c:WaitForChild("Humanoid", 5)
					c:WaitForChild("Animate", 5)
					task.wait(0.25)
					if running then
						apply(c)
					end
				end)
			end)
			return true
		end
	})
return true
