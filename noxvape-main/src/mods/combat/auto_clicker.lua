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
return true
