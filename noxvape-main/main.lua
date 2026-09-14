local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/noxvape-main/"
local source = game:HttpGet(BASE_URL .. "main.lua")
local fn, err = loadstring(source)

assert(fn, "noxvape bootstrap error: " .. tostring(err))

return fn(BASE_URL)
