local NoxLib = ...

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer

local NetManaged = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
local GameEvents = ReplicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"]

local RemoteList = {
    SwordHit = NetManaged.SwordHit,
    ExtractFromDrill = NetManaged.ExtractFromDrill,
    MomentumUpdate = NetManaged.MomentumUpdate,
    MountZipline = NetManaged.MountZipline,
    SkyScytheSpin = NetManaged.SkyScytheSpin,
    SetInvItem = NetManaged.SetInvItem,
    ProjectileFire = NetManaged.ProjectileFire,
    UseVoidPortal = NetManaged.UseVoidPortal,
    StepOnVoidPortal = NetManaged.StepOnVoidPortal,
    UseStyxPortalFromClient = NetManaged.UseStyxPortalFromClient,
    HatterUseTeleport = NetManaged.HatterUseTeleport,
    UseAbility = GameEvents.useAbility
}

local Shared = {
    FlyRunning = false,
    KATarget = nil,
    KARoot = nil,
    TPDownLastTeleportTime = 0,
    AntiFallRunning = false,
    AntiFallTerrainCenter = nil,
    AntiFallReferenceY = nil,
    ANTI_FALL_THICKNESS = 8,
    SwordControllerCache = nil,
    SprintControllerCache = nil
}

local FontMap = {
    Gotham = Enum.Font.Gotham,
    GothamBold = Enum.Font.GothamBold,
    SourceSans = Enum.Font.SourceSans,
    SourceSansBold = Enum.Font.SourceSansBold,
    Arial = Enum.Font.Arial,
    ArialBold = Enum.Font.ArialBold,
    Cartoon = Enum.Font.Cartoon,
    Code = Enum.Font.Code,
    SciFi = Enum.Font.SciFi,
    Fantasy = Enum.Font.Fantasy,
    BuilderSans = Enum.Font.BuilderSans,
    BuilderSansMedium = Enum.Font.BuilderSansMedium,
    BuilderSansBold = Enum.Font.BuilderSansBold
}

local function getColor(cat, btn, key, default)
    local v = NoxLib.getSetting(cat, btn, key, default)
    return typeof(v) == "Color3" and v or default
end

local function getNumber(cat, btn, key, default)
    return tonumber(NoxLib.getSetting(cat, btn, key, default)) or default
end

local function getBool(cat, btn, key, default)
    return NoxLib.getSetting(cat, btn, key, default) == true
end

local function getSwordWeapon()
    local inv = ReplicatedStorage:FindFirstChild("Inventories")
    if not inv then return nil end
    local i = inv:FindFirstChild(player.Name)
    if not i then return nil end
    for _, item in ipairs(i:GetChildren()) do
        local n = string.lower(item.Name)
        if string.find(n, "sword", 1, true) or string.find(n, "blade", 1, true) or string.find(n, "dao", 1, true) then
            return item
        end
    end
    return nil
end

local function hasItem(search)
    local inventories = ReplicatedStorage:FindFirstChild("Inventories")
    if not inventories then return false end
    local playerInv = inventories:FindFirstChild(player.Name)
    if not playerInv then return false end
    search = string.lower(search)
    for _, item in ipairs(playerInv:GetChildren()) do
        if string.find(string.lower(item.Name), search, 1, true) then
            return true
        end
    end
    return false
end

local function getCharacterRoot(c)
    if not c then return nil end
    local r = c:FindFirstChild("HumanoidRootPart")
    if r and r:IsA("BasePart") then return r end
    return c.PrimaryPart
end

local function getCharacterHumanoid(c)
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isHumanoidAlive(h)
    if not h or h.Health <= 0 then return false end
    local ok, s = pcall(function() return h:GetState() end)
    return not (ok and s == Enum.HumanoidStateType.Dead)
end

local function isEnemyPlayer(t)
    if not t or t == player then return false end
    if player.Team and t.Team and player.Team == t.Team then return false end
    return true
end

local function getEntityRoot(m)
    if not m then return nil end
    local r = m:FindFirstChild("HumanoidRootPart")
    if r and r:IsA("BasePart") then return r end
    return m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
end

local function getKnitController(name)
    local c
    pcall(function()
        if shared and shared.KnitClient and shared.KnitClient.Controllers then
            c = shared.KnitClient.Controllers[name]
        end
    end)
    if c then return c end
    pcall(function()
        if _G and _G.KnitClient and _G.KnitClient.Controllers then
            c = _G.KnitClient.Controllers[name]
        end
    end)
    if c then return c end
    pcall(function()
        if getrenv then
            local e = getrenv()
            if e and e._G and e._G.KnitClient and e._G.KnitClient.Controllers then
                c = e._G.KnitClient.Controllers[name]
            end
        end
    end)
    if c then return c end
    if getgc then
        pcall(function()
            for _, v in ipairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "Name") == name then
                    c = v
                    break
                end
            end
        end)
    end
    return c
end

local function getSwordController()
    Shared.SwordControllerCache = Shared.SwordControllerCache or getKnitController("SwordController")
    return Shared.SwordControllerCache
end

local function getSprintController()
    Shared.SprintControllerCache = Shared.SprintControllerCache or getKnitController("SprintController")
    return Shared.SprintControllerCache
end

player.CharacterAdded:Connect(function()
    Shared.SwordControllerCache = nil
    Shared.SprintControllerCache = nil
end)

local function getMoveInput()
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.zero, false end
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    local fl = Vector3.new(look.X, 0, look.Z)
    local fr = Vector3.new(right.X, 0, right.Z)
    fl = fl.Magnitude > 0 and fl.Unit or fl
    fr = fr.Magnitude > 0 and fr.Unit or fr
    local d = Vector3.zero
    local h = false
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then d += fl; h = true end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then d -= fl; h = true end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then d += fr; h = true end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then d -= fr; h = true end
    return d.Magnitude > 0 and d.Unit or d, h
end

local entityCache = {data = {}, time = -math.huge}
local ENTITY_TTL = 0.5

local function collectAllEntities()
    local now = os.clock()
    if now - entityCache.time < ENTITY_TTL then return entityCache.data end
    local list, myChar, seen = {}, player.Character, {}
    local function check(m)
        if seen[m] or m == myChar or Players:GetPlayerFromCharacter(m) then return end
        seen[m] = true
        local h = m:FindFirstChildOfClass("Humanoid")
        if not h or not isHumanoidAlive(h) then return end
        local r = getEntityRoot(m)
        if r then list[#list + 1] = {model = m, humanoid = h, root = r} end
    end
    local function recurse(c, d)
        if d > 3 then return end
        for _, o in ipairs(c:GetChildren()) do
            if o:IsA("Model") then
                check(o)
            elseif o:IsA("Folder") or o:IsA("Configuration") then
                recurse(o, d + 1)
            end
        end
    end
    recurse(workspace, 0)
    entityCache.data, entityCache.time = list, now
    return list
end

local function getClosestTarget(includeEntities)
    local c = player.Character
    if not c then return nil, nil, math.huge end
    local r = getCharacterRoot(c)
    if not r then return nil, nil, math.huge end
    local closest, closestRoot, closestDist = nil, nil, math.huge
    for _, t in ipairs(Players:GetPlayers()) do
        if t ~= player and t.Character and isEnemyPlayer(t) then
            local h, tr = getCharacterHumanoid(t.Character), getCharacterRoot(t.Character)
            if h and tr and isHumanoidAlive(h) then
                local d = (tr.Position - r.Position).Magnitude
                if d < closestDist then closestDist, closest, closestRoot = d, t.Character, tr end
            end
        end
    end
    if includeEntities then
        for _, e in ipairs(collectAllEntities()) do
            if e.model.Parent and e.humanoid.Parent and e.root.Parent and isHumanoidAlive(e.humanoid) then
                local d = (e.root.Position - r.Position).Magnitude
                if d < closestDist then closestDist, closest, closestRoot = d, e.model, e.root end
            end
        end
    end
    return closest, closestRoot, closestDist
end

local bedCache
local function findBed()
    if bedCache and bedCache.Parent then return bedCache end
    local function search(c, d)
        if d > 4 then return nil end
        for _, x in ipairs(c:GetChildren()) do
            if x:IsA("BasePart") and string.lower(x.Name) == "bed" then return x end
            if x:IsA("Model") and string.lower(x.Name) == "bed" then
                local p = x.PrimaryPart or x:FindFirstChildWhichIsA("BasePart", true)
                if p then return p end
            end
            if x:IsA("Folder") or x:IsA("Model") then
                local r = search(x, d + 1)
                if r then return r end
            end
        end
    end
    bedCache = search(workspace, 0)
    return bedCache
end

return {
    NoxLib = NoxLib, Players = Players, RunService = RunService, UserInputService = UserInputService,
    ReplicatedStorage = ReplicatedStorage, Lighting = Lighting, GuiService = GuiService, player = player,
    NetManaged = NetManaged, GameEvents = GameEvents, RemoteList = RemoteList, Shared = Shared, FontMap = FontMap,
    getColor = getColor, getNumber = getNumber, getBool = getBool, getSwordWeapon = getSwordWeapon, hasItem = hasItem,
    getCharacterRoot = getCharacterRoot, getCharacterHumanoid = getCharacterHumanoid, isHumanoidAlive = isHumanoidAlive,
    isEnemyPlayer = isEnemyPlayer, getEntityRoot = getEntityRoot, getKnitController = getKnitController,
    getSwordController = getSwordController, getSprintController = getSprintController, getMoveInput = getMoveInput,
    collectAllEntities = collectAllEntities, getClosestTarget = getClosestTarget, findBed = findBed
}
