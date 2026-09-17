-- noxvape bootstrap
-- This file is the only project entrypoint. It loads the shared core and every mod from raw GitHub files.

local BASE_URL = ...
assert(type(BASE_URL) == "string" and BASE_URL ~= "", "noxvape init error: missing BASE_URL")

local function fetch(path)
    local source = game:HttpGet(BASE_URL .. path)
    local chunk, err = loadstring(source)
    assert(chunk, "noxvape load error [" .. path .. "]: " .. tostring(err))
    return chunk()
end

local ctx = fetch("src/core/context.lua")()

ctx.NoxLib.addCategory("Combat")
ctx.NoxLib.addCategory("Movement")
ctx.NoxLib.addCategory("Exploits")
ctx.NoxLib.addCategory("Kits")
ctx.NoxLib.addCategory("Renderer")
ctx.NoxLib.addCategory("Other")

local modules = {
    "renderer/name_tags.lua",
    "renderer/world_theme.lua",
    "renderer/breadcrumbs.lua",
    "renderer/chams.lua",
    "renderer/box_esp.lua",
    "renderer/item_drop.lua",
    "renderer/transparent.lua",
    "exploits/krystal_disabler.lua",
    "combat/kill_aura.lua",
    "combat/aim_assist.lua",
    "combat/auto_clicker.lua",
    "combat/no_click_delay.lua",
    "combat/sprint.lua",
    "movement/inf_jump.lua",
    "movement/speed.lua",
    "movement/fly.lua",
    "movement/player_attach.lua",
    "movement/spider.lua",
    "movement/tp_down.lua",
    "movement/anti_fall.lua",
    "other/spin_bot.lua",
    "other/no_anims.lua",
    "other/breaker.lua",
 }

for _, path in ipairs(modules) do
    local ok, err = pcall(function()
        local module = fetch(path)
        assert(type(module) == "function", "module did not return a function")
        module(ctx)
    end)

    if not ok then
        warn("[noxvape] failed to load " .. path .. ": " .. tostring(err))
    end
end

ctx.NoxLib.init()

return ctx
