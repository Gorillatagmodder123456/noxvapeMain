print("[noxvape] MAIN STARTED")

local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/refs/heads/main/"

local URL = BASE_URL .. "src/init.lua"

print("[noxvape] downloading init.lua")

local source = game:HttpGet(URL)

print("[noxvape] init.lua downloaded")

local fn, err = loadstring(source, "@noxvape/src/init.lua")

if not fn then
    warn("[noxvape] loadstring failed: " .. tostring(err))
    return
end

print("[noxvape] executing init.lua")

local ok, result = pcall(fn, BASE_URL)

if not ok then
    warn("[noxvape] init.lua error: " .. tostring(result))
    return
end

print("[noxvape] DONE")

return result
