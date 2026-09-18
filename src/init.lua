local BASE_URL = ...

local HttpService = game:GetService("HttpService")

-- Load NoxLib
local NoxLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Gorillatagmodder123456/Noxvape/refs/heads/main/noxvape.lua"
))()

local Nox = {
    Lib = NoxLib,
    BaseURL = BASE_URL,
    Mods = {},
    Categories = {}
}

local function getFolder(path)
    local url = "https://api.github.com/repos/Gorillatagmodder123456/noxvapeMain/contents/" .. path

    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success then
        return result
    end

    warn("[noxvape] Failed to read folder:", path)
    return {}
end

local function loadDirectory(path)
    for _, item in ipairs(getFolder(path)) do

        if item.type == "dir" then
            loadDirectory(item.path)

        elseif item.type == "file" and item.name:sub(-4) == ".lua" then

            local source = game:HttpGet(BASE_URL .. item.path)

            local fn, err = loadstring(source, "@noxvape/" .. item.path)

            if fn then
                local ok, mod = pcall(fn)

                if ok and type(mod) == "table" then

                    if mod.Category and not Nox.Categories[mod.Category] then
                        Nox.Categories[mod.Category] = true
                        NoxLib.addCategory(mod.Category)
                    end

                    table.insert(Nox.Mods, mod)

                    if mod.Init then
                        pcall(function()
                            mod:Init(Nox)
                        end)
                    end
                else
                    warn("[noxvape] Error loading " .. item.path, mod)
                end
            else
                warn("[noxvape] Compile error in " .. item.path, err)
            end
        end
    end
end

-- Load every mod automatically
loadDirectory("src/mods")

return Nox
