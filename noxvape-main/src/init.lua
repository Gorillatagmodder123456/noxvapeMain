local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/noxvape-main/"

local function load(path, arg)
    local source = game:HttpGet(BASE_URL .. path)
    local fn, err = loadstring(source)

    assert(fn, "noxvape load error: " .. tostring(err))

    return fn(arg)
end

local NoxLib = load("NoxLib.lua")
local Core = load("src/backend/core.lua", NoxLib)

load("src/backend/categories.lua", NoxLib)

local modules = {
    "src/mods/yourmod.lua"
}

for _, path in ipairs(modules) do
    load(path, Core)
end

NoxLib.init()

return true
