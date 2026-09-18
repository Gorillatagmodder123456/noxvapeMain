local BASE_URL = select(1, ...)

assert(
    type(BASE_URL) == "string",
    "[noxvape] BASE_URL was not provided"
)

local HttpService = game:GetService("HttpService")

print("[noxvape] init.lua started")
print("[noxvape] BASE_URL: " .. BASE_URL)

--// NoxLib

print("[noxvape] loading NoxLib")

local NOXLIB_URL =
    "https://raw.githubusercontent.com/Gorillatagmodder123456/Noxvape/refs/heads/main/noxvape.lua"

local noxLibSource = game:HttpGet(NOXLIB_URL)

local noxLibLoader, noxLibError = loadstring(
    noxLibSource,
    "@noxvape/NoxLib"
)

assert(
    noxLibLoader,
    "[noxvape] NoxLib compile error: " .. tostring(noxLibError)
)

local noxLibSuccess, NoxLib = pcall(noxLibLoader)

assert(
    noxLibSuccess,
    "[noxvape] NoxLib execution error: " .. tostring(NoxLib)
)

assert(
    type(NoxLib) == "table",
    "[noxvape] NoxLib did not return a table"
)

print("[noxvape] NoxLib loaded")

--// Nox project object

local Nox = {
    Lib = NoxLib,
    BaseURL = BASE_URL,
    Mods = {},
    Categories = {}
}

--// GitHub API

local GITHUB_API =
    "https://api.github.com/repos/Gorillatagmodder123456/noxvapeMain/contents/"

local function getDirectory(path)
    local url = GITHUB_API .. path

    local success, result = pcall(function()
        local response = game:HttpGet(url)

        return HttpService:JSONDecode(response)
    end)

    if not success then
        warn(
            "[noxvape] Failed to read directory "
            .. tostring(path)
            .. ": "
            .. tostring(result)
        )

        return {}
    end

    if type(result) ~= "table" then
        warn(
            "[noxvape] Invalid GitHub response for "
            .. tostring(path)
        )

        return {}
    end

    return result
end

--// Load a single Lua module

local function loadModule(path)
    print("[noxvape] downloading " .. path)

    local success, source = pcall(function()
        return game:HttpGet(BASE_URL .. path)
    end)

    if not success then
        warn(
            "[noxvape] Failed to download "
            .. tostring(path)
            .. ": "
            .. tostring(source)
        )

        return
    end

    local fn, compileError = loadstring(
        source,
        "@noxvape/" .. path
    )

    if not fn then
        warn(
            "[noxvape] Compile error in "
            .. tostring(path)
            .. ": "
            .. tostring(compileError)
        )

        return
    end

    local moduleSuccess, module = pcall(fn)

    if not moduleSuccess then
        warn(
            "[noxvape] Runtime error in "
            .. tostring(path)
            .. ": "
            .. tostring(module)
        )

        return
    end

    if type(module) ~= "table" then
        warn(
            "[noxvape] "
            .. tostring(path)
            .. " did not return a table"
        )

        return
    end

    --// Register category

    if type(module.Category) == "string"
        and module.Category ~= ""
    then
        if not Nox.Categories[module.Category] then
            Nox.Categories[module.Category] = true

            if type(NoxLib.addCategory) == "function" then
                local categorySuccess, categoryError = pcall(function()
                    NoxLib.addCategory(module.Category)
                end)

                if not categorySuccess then
                    warn(
                        "[noxvape] Failed to create category "
                        .. module.Category
                        .. ": "
                        .. tostring(categoryError)
                    )
                end
            end

            print(
                "[noxvape] category: "
                .. module.Category
            )
        end
    end

    table.insert(Nox.Mods, module)

    --// Initialize module

    if type(module.Init) == "function" then
        local initSuccess, initError = pcall(function()
            module:Init(Nox)
        end)

        if not initSuccess then
            warn(
                "[noxvape] Init error in "
                .. tostring(path)
                .. ": "
                .. tostring(initError)
            )
        end
    end

    print("[noxvape] loaded " .. tostring(path))
end

--// Recursively scan directories

local function loadDirectory(path)
    print("[noxvape] scanning " .. path)

    local entries = getDirectory(path)

    for _, entry in ipairs(entries) do
        if entry.type == "dir" then

            loadDirectory(entry.path)

        elseif entry.type == "file" then

            local name = entry.name

            if type(name) == "string"
                and name:sub(-4) == ".lua"
            then
                loadModule(entry.path)
            end
        end
    end
end

--// Load every mod inside src/mods

loadDirectory("src/mods")

print(
    "[noxvape] loaded "
    .. tostring(#Nox.Mods)
    .. " modules"
)

--// Initialize the GUI

print("[noxvape] initializing GUI")

assert(
    type(NoxLib.init) == "function",
    "[noxvape] NoxLib.init() does not exist"
)

local guiSuccess, guiError = pcall(function()
    NoxLib.init()
end)

assert(
    guiSuccess,
    "[noxvape] GUI initialization failed: "
    .. tostring(guiError)
)

print("[noxvape] GUI initialized")

return Nox
