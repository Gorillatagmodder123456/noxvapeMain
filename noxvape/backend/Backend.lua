-- ============================================================
-- noxvape / backend / Backend.lua
-- Loaded by main.lua. Provides shared services:
--   RemoteList, getSwordController, getSprintController,
--   hasItem, sanitizeAssetId, ActiveLoops
-- Access via:  local B = _G.NoxBackend
-- ============================================================

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player           = Players.LocalPlayer

-- ─── Active loop registry ────────────────────────────────────────────────────
-- Mods register running task threads here so selfDestruct can cancel them all.
local ActiveLoops = {}

-- ─── Remote list ─────────────────────────────────────────────────────────────
local RemoteList = {}
pcall(function()
    RemoteList = {
        DrillEvent     = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.ExtractFromDrill,
        SetInvItem     = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.SetInvItem,
        MomentumUpdate = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.MomentumUpdate,
        SwordHitRemote = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.SwordHit,
        UseAbility     = ReplicatedStorage["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility,
        MountZipline   = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.MountZipline,
        SpinSkyScythe  = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged.SkyScytheSpin,
    }
end)

-- ─── Controller getters ──────────────────────────────────────────────────────
-- Both search Knit first (fast), then fall back to getgc (slow, one-time).
-- NEVER call these inside a Heartbeat/RenderStepped loop — cache the result.

local function getController(name)
    local KC = (shared and shared.KnitClient)
            or (_G and _G.KnitClient)
            or (getrenv and getrenv()._G and getrenv()._G.KnitClient)
    if KC and KC.Controllers and KC.Controllers[name] then
        return KC.Controllers[name]
    end
    if getgc then
        for _, v in ipairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "Name") == name then return v end
        end
    end
    return nil
end

local function getSwordController()  return getController("SwordController")  end
local function getSprintController() return getController("SprintController") end

-- ─── Inventory check ─────────────────────────────────────────────────────────
local function hasItem(search)
    local inv = ReplicatedStorage:FindFirstChild("Inventories")
    if not inv then return false end
    local pi = inv:FindFirstChild(player.Name)
    if not pi then return false end
    search = string.lower(search)
    for _, item in ipairs(pi:GetChildren()) do
        if string.find(string.lower(item.Name), search, 1, true) then return true end
    end
    return false
end

-- ─── Asset ID helper ─────────────────────────────────────────────────────────
local function sanitizeAssetId(raw)
    if type(raw) ~= "string" and type(raw) ~= "number" then return "" end
    local s = tostring(raw):gsub("%s+", "")
    if s:match("^%d+$") then return "rbxassetid://" .. s end
    if s:match("^rbxassetid://") then return s end
    return ""
end

-- ─── Export ──────────────────────────────────────────────────────────────────
local Backend = {
    RemoteList          = RemoteList,
    ActiveLoops         = ActiveLoops,
    getSwordController  = getSwordController,
    getSprintController = getSprintController,
    hasItem             = hasItem,
    sanitizeAssetId     = sanitizeAssetId,
    player              = player,
}

_G.NoxBackend = Backend
return Backend
