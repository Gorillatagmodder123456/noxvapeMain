-- mods/combat/NoClickDelay.lua
local NoxLib  = _G.NoxLib
local B       = _G.NoxBackend

NoxLib.addCategory("Combat")

NoxLib.addButton("Combat", {
    name        = "No Click Delay",
    toggle      = true,
    description = "Removes the sword swing delay.",
    action      = function(enabled)
        local sc = B.getSwordController()
        if not sc then NoxLib.notify("SwordController not found!", "error") return false end
        if enabled then
            if not sc._originalIsClickingTooFast then
                sc._originalIsClickingTooFast = sc.isClickingTooFast
            end
            sc.isClickingTooFast = function() return false end
        else
            if sc._originalIsClickingTooFast then
                sc.isClickingTooFast = sc._originalIsClickingTooFast
                sc._originalIsClickingTooFast = nil
            end
        end
        return true
    end,
})
