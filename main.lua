local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/"

local source = game:HttpGet(BASE_URL .. "src/init.lua")

local fn, err = loadstring(source, "@noxvape/src/init.lua")
assert(fn, "noxvape bootstrap error: " .. tostring(err))

local ok, result = pcall(fn, BASE_URL)
assert(ok, "noxvape init error: " .. tostring(result))

return result
