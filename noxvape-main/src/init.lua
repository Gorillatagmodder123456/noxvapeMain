local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/noxvape-main/"
local HttpService = game:GetService("HttpService")

local function load(path, arg)
    local source = game:HttpGet(BASE_URL .. path)
    local fn, err = loadstring(source)
    assert(fn, "noxvape load error: " .. tostring(err))
    return fn(arg)
end

-- Hard-coded modules (no GitHub API)
local modules = {
    -- combat
    "src/mods/combat/aim_assist.lua",
    "src/mods/combat/auto_clicker.lua",
    "src/mods/combat/kill_aura.lua",
    "src/mods/combat/no_click_delay.lua",
    "src/mods/combat/sprint.lua",

    -- exploits
    "src/mods/exploits/krystal_disabler.lua",

    -- movement
    "src/mods/movement/antifall.lua",
    "src/mods/movement/fly.lua",
    "src/mods/movement/inf_jump.lua",
    "src/mods/movement/player_attach.lua",
    "src/mods/movement/speed.lua",
    "src/mods/movement/spider.lua",
    "src/mods/movement/tp_down.lua",

    -- other
    "src/mods/other/breaker.lua",
    "src/mods/other/no_anims.lua",
    "src/mods/other/spin_bot.lua",

    -- renderer
    "src/mods/renderer/box_esp.lua",
    "src/mods/renderer/breadcrumbs.lua",
    "src/mods/renderer/chams.lua",
    "src/mods/renderer/item_drop.lua",
    "src/mods/renderer/name_tags.lua",
    "src/mods/renderer/transparent.lua",
    "src/mods/renderer/world_theme.lua",
}

local NoxLib = load("NoxLib.lua")
local Core = load("src/backend/core.lua", NoxLib)

load("src/backend/categories.lua", NoxLib)

table.sort(modules)

for _, path in ipairs(modules) do
    load(path, Core)
end

NoxLib.init()

return true
