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
	local running, folder, tags, itemConns, folderConns = false, nil, {}, {}, {}
	local function font()
		return FontMap[NoxLib.getSetting("Renderer", "ItemDrop", "font", "GothamBold")] or Enum.Font.GothamBold
	end
	local function getPart(d)
		if not d or not d.Parent then
			return nil
		end
		if d:IsA("BasePart") then
			return d
		end
		if d:IsA("Model") then
			if d.PrimaryPart then
				return d.PrimaryPart
			end
			local h = d:FindFirstChild("Handle")
			if h and h:IsA("BasePart") then
				return h
			end
			return d:FindFirstChildWhichIsA("BasePart", true)
		end
		if d:IsA("Attachment") then
			return d.Parent
		end
		return nil
	end
	local function getAmount(d)
		local a = d:GetAttribute("Amount")
		if a ~= nil then
			return tostring(a)
		end
		local v = d:FindFirstChild("Amount")
		if v and v:IsA("ValueBase") then
			return tostring(v.Value)
		end
		return "?"
	end
	local function remove(d)
		if itemConns[d] then
			for _, c in pairs(itemConns[d]) do
				if c and c.Disconnect then
					pcall(function()
						c:Disconnect()
					end)
				end
			end
			itemConns[d] = nil
		end
		if tags[d] then
			tags[d]:Destroy()
			tags[d] = nil
		end
	end
	local function update(d)
		local tag = tags[d]
		if not tag or not tag.Parent then
			return
		end
		local tx = tag:FindFirstChild("Text")
		if not tx then
			return
		end
		tx.Text = d.Name .. " x" .. getAmount(d)
		local f = font()
		if tx.Font ~= f then
			tx.Font = f
		end
		local p = getPart(d)
		if p and tag.Adornee ~= p then
			tag.Adornee = p
		end
	end
	local function create(d, attempt)
		attempt = attempt or 0
		if not running or not d or not d.Parent then
			return
		end
		local p = getPart(d)
		if not p then
			if attempt < 20 then
				task.delay(0.1, function()
					create(d, attempt + 1)
				end)
			end
			return
		end
		if tags[d] then
			update(d)
			return
		end
		local tag = Instance.new("BillboardGui")
		tag.Name = "NoxItemDrop"
		tag.Adornee = p
		tag.Size = UDim2.fromOffset(180, 26)
		tag.StudsOffset = Vector3.new(0, 1.5, 0)
		tag.AlwaysOnTop = true
		tag.Enabled = true
		tag.MaxDistance = 1000000
		tag.Parent = player:WaitForChild("PlayerGui")
		local tx = Instance.new("TextLabel", tag)
		tx.Name = "Text"
		tx.Size = UDim2.fromScale(1, 1)
		tx.BackgroundTransparency = 1
		tx.Text = d.Name .. " x" .. getAmount(d)
		tx.TextColor3 = Color3.new(1, 1, 1)
		tx.TextSize = 14
		tx.Font = font()
		tx.TextStrokeTransparency = 0.25
		tx.TextXAlignment = Enum.TextXAlignment.Center
		tx.TextYAlignment = Enum.TextYAlignment.Center
		tags[d] = tag
		itemConns[d] = {}
		itemConns[d][# itemConns[d] + 1] = d:GetAttributeChangedSignal("Amount"):Connect(function()
			update(d)
		end)
		local av = d:FindFirstChild("Amount")
		if av and av:IsA("ValueBase") then
			itemConns[d][# itemConns[d] + 1] = av.Changed:Connect(function()
				update(d)
			end)
		end
		itemConns[d][# itemConns[d] + 1] = d.ChildAdded:Connect(function(child)
			if child.Name == "Amount" and child:IsA("ValueBase") then
				itemConns[d][# itemConns[d] + 1] = child.Changed:Connect(function()
					update(d)
				end)
				update(d)
			end
			if not getPart(d) then
				task.defer(function()
					create(d, attempt)
				end)
			end
		end)
		itemConns[d][# itemConns[d] + 1] = d.AncestryChanged:Connect(function()
			if not d.Parent then
				remove(d)
			end
		end)
	end
	local function scan()
		if not folder or not folder.Parent then
			return
		end
		for _, d in ipairs(folder:GetChildren()) do
			create(d)
		end
	end
	local function disconnectFolder()
		for _, c in pairs(folderConns) do
			if c and c.Disconnect then
				pcall(function()
					c:Disconnect()
				end)
			end
		end
		table.clear(folderConns)
		folder = nil
	end
	local function connectFolder(f)
		if not running or not f then
			return
		end
		disconnectFolder()
		folder = f
		folderConns.added = f.ChildAdded:Connect(function(d)
			task.defer(function()
				create(d)
			end)
		end)
		folderConns.removed = f.ChildRemoved:Connect(function(d)
			remove(d)
		end)
		scan()
	end
	local function findFolder()
		local f = workspace:FindFirstChild("ItemDrops")
		if f then
			connectFolder(f)
		end
	end
	NoxLib.addButton("Renderer", {
		name = "ItemDrop",
		toggle = true,
		description = "Displays dropped item amounts.",
		settings = {
			{
				type = "dropdown",
				name = "Font",
				key = "font",
				default = "GothamBold",
				options = {
					"Gotham",
					"GothamBold",
					"SourceSans",
					"SourceSansBold",
					"Arial",
					"ArialBold",
					"Cartoon",
					"Code",
					"SciFi",
					"Fantasy",
					"BuilderSans",
					"BuilderSansMedium",
					"BuilderSansBold"
				},
				action = function()
					for d in pairs(tags) do
						update(d)
					end
				end
			}
		},
		action = function(enabled)
			running = enabled
			if not enabled then
				disconnectFolder()
				for d in pairs(tags) do
					remove(d)
				end
				return true
			end
			findFolder()
			folderConns.workspace = workspace.ChildAdded:Connect(function(child)
				if not running then
					return
				end
				if child.Name == "ItemDrops" then
					task.defer(function()
						connectFolder(child)
					end)
				end
			end)
			folderConns.workspaceRemoving = workspace.ChildRemoved:Connect(function(child)
				if child == folder then
					disconnectFolder()
					task.defer(function()
						if running then
							findFolder()
						end
					end)
				end
			end)
			task.spawn(function()
				while running do
					task.wait(1)
					if not running then
						break
					end
					if not folder or not folder.Parent then
						findFolder()
					else
						scan()
					end
					for d in pairs(tags) do
						if not d.Parent then
							remove(d)
						else
							update(d)
						end
					end
				end
			end)
			return true
		end
	})
end
return true
