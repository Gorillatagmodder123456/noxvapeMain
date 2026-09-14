local BASE_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPOSITORY/main/"
local source = game:HttpGet(BASE_URL .. "src/init.lua")
local fn, err = loadstring(source)
assert(fn, "noxvape bootstrap error: " .. tostring(err))
return fn(BASE_URL)
