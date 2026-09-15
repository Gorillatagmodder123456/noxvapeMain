-- mods/combat/AutoClicker.lua
local NoxLib = _G.NoxLib
local B      = _G.NoxBackend
local UIS    = game:GetService("UserInputService")

local AutoClickerRunning     = false
local AutoClickerThread      = nil
local AutoClickerCPS         = 8
local AutoClickerMouseDown   = false   -- live-updated by checkbox onChanged

NoxLib.addButton("Combat", {
    name        = "Auto Clicker",
    toggle      = true,
    description = "Automatically swings your sword.",
    settings    = {
        {
            type      = "slider",
            name      = "CPS",
            key       = "cps",
            default   = 8,
            min       = 1,
            max       = 20,
            onChanged = function(val) AutoClickerCPS = tonumber(val) or 8 end,
        },
        {
            type      = "checkbox",
            name      = "Mouse Down Only",
            key       = "mouseDownOnly",
            default   = false,
            -- Updates live — no retoggle needed
            onChanged = function(val) AutoClickerMouseDown = val end,
        },
    },
    action = function(enabled)
        AutoClickerRunning = enabled
        if AutoClickerThread then
            task.cancel(AutoClickerThread)
            AutoClickerThread = nil
        end
        if not enabled then return true end

        -- Resolve controller ONCE here — never call B.getSwordController inside the loop
        local sc = B.getSwordController()
        if not sc or not sc.swingSwordAtMouse then
            NoxLib.notify("SwordController not found!", "error")
            return false
        end

        AutoClickerCPS    = NoxLib.getSetting("Combat", "Auto Clicker", "cps", 8)
        AutoClickerMouseDown = NoxLib.getSetting("Combat", "Auto Clicker", "mouseDownOnly", false)

        AutoClickerThread = task.spawn(function()
            while AutoClickerRunning do
                local interval = 1 / math.max(AutoClickerCPS, 1)
                if AutoClickerMouseDown and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    task.wait(0.05)
                    continue
                end
                pcall(function() sc:swingSwordAtMouse() end)
                task.wait(interval)
            end
        end)
        return true
    end,
})
