local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/"

local source = game:HttpGet(BASE_URL .. "src/init.lua")

local fn, err = loadstring(source)

assert(fn, "Failed to load src/init.lua: " .. tostring(err))

return fn(BASE_URL)
