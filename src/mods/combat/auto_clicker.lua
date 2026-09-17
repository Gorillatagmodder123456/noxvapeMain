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

	local thread = nil
	local running = false
	local function guiBlocks(g)
		if not g or not g.Parent or not g.Visible then
			return false
		end
		if g.AbsoluteSize.X <= 0 or g.AbsoluteSize.Y <= 0 then
			return false
		end
		if g:IsA("GuiButton") or g:IsA("TextBox") then
			return true
		end
		if g.Active then
			return true
		end
		if g:IsA("ImageLabel") or g:IsA("ImageButton") then
			if g.Image ~= "" and g.ImageTransparency < 0.9 then
				return true
			end
		elseif g:IsA("Frame") or g:IsA("ScrollingFrame") then
			if g.BackgroundTransparency < 0.9 then
				return true
			end
		end
		return false
	end
	local function mouseOverGui()
		local pg = player:FindFirstChild("PlayerGui")
		if not pg then
			return false
		end
		local m = UserInputService:GetMouseLocation()
		local inset = GuiService:GetGuiInset()
		for _, g in ipairs(pg:GetGuiObjectsAtPosition(m.X, m.Y)) do
			if guiBlocks(g) then
				return true
			end
		end
		for _, g in ipairs(pg:GetGuiObjectsAtPosition(m.X + inset.X, m.Y + inset.Y)) do
			if guiBlocks(g) then
				return true
			end
		end
		return false
	end
	NoxLib.addButton("Combat", {
		name = "Auto Clicker",
		toggle = true,
		description = "Automatically swings your sword.",
		settings = {
			{
				type = "slider",
				name = "CPS",
				key = "cps",
				default = 8,
				min = 1,
				max = 50
			},
			{
				type = "checkbox",
				name = "Mouse Down Only",
				key = "mouseDownOnly",
				default = false
			}
		},
		action = function(enabled)
			running = enabled
			if thread then
				task.cancel(thread)
				thread = nil
			end
			if not enabled then
				return true
			end
			thread = task.spawn(function()
				local controller = getSwordController()
				local cps, mouseOnly, nextCheck = 8, false, 0
				while running do
					local now = os.clock()
					if now >= nextCheck then
						cps = getNumber("Combat", "Auto Clicker", "cps", 8)
						mouseOnly = getBool("Combat", "Auto Clicker", "mouseDownOnly", false)
						nextCheck = now + 0.10
					end
					if not controller or not controller.swingSwordAtMouse then
						controller = getSwordController()
					end
					if controller and controller.swingSwordAtMouse then
						local click = not mouseOnly or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
						if click and not mouseOverGui() then
							pcall(function()
								controller:swingSwordAtMouse()
							end)
						end
					end
					task.wait(1 / math.max(cps, 1))
				end
			end)
			return true
		end
	})
end
