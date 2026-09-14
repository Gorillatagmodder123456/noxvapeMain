local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/noxvape-main/main.lua"
local source = game:HttpGet(BASE_URL .. "src/init.lua")
local fn, err = loadstring(source)
assert(fn, "noxvape bootstrap error: " .. tostring(err))
return fn(BASE_URL)
