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
end
