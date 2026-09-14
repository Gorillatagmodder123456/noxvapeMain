local source = game:HttpGet("https://raw.githubusercontent.com/Gorillatagmodder123456/Noxvape/refs/heads/main/noxvape.lua")
local fn, err = loadstring(source)
assert(fn, "NoxLib load error: " .. tostring(err))
return fn()
