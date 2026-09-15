-- ============================================================
-- noxvape / main.lua
-- This is the only file you need to put in your executor.
-- It loads everything from GitHub raw links in the right order.
--
-- USAGE (executor):
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/noxvape/main/main.lua"))()
-- ============================================================

local BASE = "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/noxvape/main/"

local function load(path)
    local url = BASE .. path
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not ok then
        warn("[noxvape] Failed to load: " .. path .. "\n" .. tostring(result))
    end
    return result
end

-- 1. GUI framework
load("lib/NoxLib.lua")
local NoxLib = _G.NoxLib
if not NoxLib then
    warn("[noxvape] NoxLib failed to load — aborting.")
    return
end

-- 2. Backend (remotes, controllers, helpers)
load("backend/Backend.lua")

-- 3. Mods — add new files here to include them
--    Order within a category determines button order in the GUI.

-- Combat
load("mods/combat/NoClickDelay.lua")
load("mods/combat/AutoClicker.lua")
load("mods/combat/Sprint.lua")

-- Movement
load("mods/movement/InfJump.lua")

-- Renderer
load("mods/renderer/Transparent.lua")
load("mods/renderer/NameTags.lua")
load("mods/renderer/FabricTextures.lua")

-- Other
load("mods/other/SpinBot.lua")

-- 4. Build the GUI — must be called AFTER all addButton/addCategory calls
NoxLib.init()

print("[noxvape] Loaded successfully.")
