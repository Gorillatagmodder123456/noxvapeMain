local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/"
local INIT_URL = BASE_URL .. "src/init.lua?t=" .. tostring(os.time())

local ok, source = pcall(function()
    return game:HttpGet(INIT_URL)
end)
assert(ok, "[noxvape] Failed to download src/init.lua: " .. tostring(source))

local fn, err = loadstring(source, "@noxvape/src/init.lua")
assert(fn, "[noxvape] init.lua compile error: " .. tostring(err))

local ran, result = pcall(fn, BASE_URL)
assert(ran, "[noxvape] init.lua error: " .. tostring(result))

return result
