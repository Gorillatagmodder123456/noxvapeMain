local BASE_URL = select(1, ...)
assert(type(BASE_URL) == "string" and BASE_URL ~= "", "[noxvape] Missing BASE_URL")

local HttpService = game:GetService("HttpService")

local Nox = {
    Lib = nil,
    BaseURL = BASE_URL,
    Mods = {},
    Categories = {},
    LoadedFiles = {},
}

local function fetch(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        error("[noxvape] HTTP request failed: " .. tostring(url) .. "\n" .. tostring(result))
    end
    return result
end

local function loadSource(source, chunkName)
    local fn, err = loadstring(source, chunkName)
    if not fn then
        error("[noxvape] Compile error in " .. tostring(chunkName) .. ": " .. tostring(err))
    end
    local ok, result = pcall(fn)
    if not ok then
        error("[noxvape] Runtime error in " .. tostring(chunkName) .. ": " .. tostring(result))
    end
    return result
end

-- NoxLib is now part of this repository. No second GitHub repository is required.
local libSource = fetch(BASE_URL .. "src/core/NoxLib.lua?t=" .. tostring(os.time()))
local NoxLib = loadSource(libSource, "@noxvape/src/core/NoxLib.lua")
assert(type(NoxLib) == "table", "[noxvape] src/core/NoxLib.lua must return the NoxLib table")
Nox.Lib = NoxLib

local function getDirectory(path)
    local apiURL = "https://api.github.com/repos/Gorillatagmodder123456/noxvapeMain/contents/" .. path
    local raw = fetch(apiURL)
    local ok, result = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok or type(result) ~= "table" then
        error("[noxvape] GitHub API returned invalid JSON for " .. path)
    end
    return result
end

local function sorted(items)
    table.sort(items, function(a, b)
        return tostring(a.path or a.name) < tostring(b.path or b.name)
    end)
    return items
end

local function loadDirectory(path)
    local items = sorted(getDirectory(path))

    for _, item in ipairs(items) do
        if item.type == "dir" then
            loadDirectory(item.path)
        elseif item.type == "file" and item.name:lower():sub(-4) == ".lua" then
            -- NoxLib is loaded separately; do not load it as a mod.
            if item.path ~= "src/core/NoxLib.lua" then
                local source = fetch(BASE_URL .. item.path .. "?t=" .. tostring(os.time()))
                local mod = loadSource(source, "@noxvape/" .. item.path)

                if type(mod) == "table" then
                    local category = mod.Category or mod.category
                    if type(category) == "string" and category ~= "" then
                        if not Nox.Categories[category] then
                            Nox.Categories[category] = true
                            if type(NoxLib.addCategory) == "function" then
                                pcall(NoxLib.addCategory, category)
                            end
                        end
                    end

                    table.insert(Nox.Mods, mod)
                    Nox.LoadedFiles[#Nox.LoadedFiles + 1] = item.path

                    if type(mod.Init) == "function" then
                        local ok, err = pcall(function()
                            mod:Init(Nox)
                        end)
                        if not ok then
                            warn("[noxvape] Mod Init failed: " .. item.path .. " - " .. tostring(err))
                        end
                    end
                else
                    warn("[noxvape] " .. item.path .. " did not return a mod table")
                end
            end
        end
    end
end

-- Discover every mod recursively. Folder names are not hard-coded categories;
-- the mod's Category field is what determines its GUI category.
loadDirectory("src/mods")

-- Initialize the GUI only after every mod has registered its buttons/settings.
if type(NoxLib.init) == "function" then
    local ok, err = pcall(function()
        NoxLib.init()
    end)
    assert(ok, "[noxvape] NoxLib.init() failed: " .. tostring(err))
end

return Nox
