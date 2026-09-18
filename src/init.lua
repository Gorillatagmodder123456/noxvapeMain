print("[noxvape] INIT STARTED")

local BASE_URL = select(1, ...)

print("[noxvape] BASE_URL = " .. tostring(BASE_URL))

if type(BASE_URL) ~= "string" then
    error("[noxvape] BASE_URL is missing")
end

local NOXLIB_URL =
    "https://raw.githubusercontent.com/Gorillatagmodder123456/Noxvape/refs/heads/main/noxvape.lua"

print("[noxvape] downloading NoxLib")

local noxLibSource = game:HttpGet(NOXLIB_URL)

print("[noxvape] NoxLib downloaded")

local noxLibLoader, noxLibError = loadstring(
    noxLibSource,
    "@noxvape/NoxLib"
)

if not noxLibLoader then
    error(
        "[noxvape] NoxLib compile error: "
        .. tostring(noxLibError)
    )
end

print("[noxvape] executing NoxLib")

local noxLibSuccess, NoxLib = pcall(noxLibLoader)

if not noxLibSuccess then
    error(
        "[noxvape] NoxLib execution error: "
        .. tostring(NoxLib)
    )
end

print("[noxvape] NoxLib executed")

print("[noxvape] NoxLib type = " .. type(NoxLib))

if type(NoxLib) ~= "table" then
    error("[noxvape] NoxLib did not return a table")
end

print("[noxvape] NoxLib.init type = " .. type(NoxLib.init))

if type(NoxLib.init) ~= "function" then
    error("[noxvape] NoxLib.init() is missing")
end

print("[noxvape] calling NoxLib.init()")

local guiSuccess, guiError = pcall(function()
    NoxLib.init()
end)

if not guiSuccess then
    error(
        "[noxvape] NoxLib.init() error: "
        .. tostring(guiError)
    )
end

print("[noxvape] NoxLib.init() finished")

return NoxLib
