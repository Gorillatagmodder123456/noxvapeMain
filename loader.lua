-- noxvape GitHub loader
-- Put this file anywhere you want to execute the project from.

local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeSRC/main/"
local source = game:HttpGet(BASE_URL .. "src/init.lua")
local chunk, err = loadstring(source)
assert(chunk, "noxvape bootstrap error: " .. tostring(err))
return chunk(BASE_URL)
