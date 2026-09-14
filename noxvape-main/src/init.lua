
local BASE_URL = "https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/noxvape-main/"
local HttpService = game:GetService("HttpService")

local function load(path, arg)
    local source = game:HttpGet(BASE_URL .. path)
    local fn, err = loadstring(source)

    assert(fn, "noxvape load error: " .. tostring(err))

    return fn(arg)
end

local function getDirectory(path)
    local url = "https://api.github.com/repos/Gorillatagmodder123456/noxvapeMain/contents/noxvape-main/" .. path .. "?ref=main"

    local response = game:HttpGet(url)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    assert(ok, "noxvape: GitHub API returned invalid JSON")

    assert(type(data) == "table", "noxvape: invalid GitHub directory response")

    return data
end

local function collectLuaFiles(path, result)
    result = result or {}

    for _, entry in ipairs(getDirectory(path)) do
        if entry.type == "dir" then
            collectLuaFiles(entry.path:gsub("^noxvape%-main/", ""), result)
        elseif entry.type == "file" and entry.name:sub(-4) == ".lua" and entry.name ~= "init.lua" then
            result[#result + 1] = entry.path:gsub("^noxvape%-main/", "")
        end
    end

    return result
end

local NoxLib = load("NoxLib.lua")
local Core = load("src/backend/core.lua", NoxLib)

load("src/backend/categories.lua", NoxLib)

local modules = collectLuaFiles("src/mods")
table.sort(modules)

for _, path in ipairs(modules) do
    load(path, Core)
end

NoxLib.init()

return true

