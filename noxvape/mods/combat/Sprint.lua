-- mods/combat/Sprint.lua
local NoxLib    = _G.NoxLib
local B         = _G.NoxBackend
local RunService = game:GetService("RunService")
local player    = B.player

local SprintRunning  = false
local SprintConn     = nil
local SprintCharConn = nil

NoxLib.addButton("Combat", {
    name        = "Sprint",
    toggle      = true,
    description = "Always sprints.",
    action      = function(enabled)
        SprintRunning = enabled
        if SprintConn     then SprintConn:Disconnect();     SprintConn     = nil end
        if SprintCharConn then SprintCharConn:Disconnect(); SprintCharConn = nil end

        local sc = B.getSprintController()
        if not enabled then
            if sc then sc.attemptingSprint = false; sc:stopSprinting(true) end
            return true
        end

        if sc then sc.attemptingSprint = true; sc:startSprinting() end

        -- Only re-applies when the controller drops the flag — not every frame
        SprintConn = RunService.Heartbeat:Connect(function()
            if not SprintRunning then return end
            local s = B.getSprintController()
            if s and not s.attemptingSprint then
                s.attemptingSprint = true; s:startSprinting()
            end
        end)

        SprintCharConn = player.CharacterAdded:Connect(function()
            task.wait(0.1)
            if SprintRunning then
                local s = B.getSprintController()
                if s then s.attemptingSprint = true; s:startSprinting() end
            end
        end)
        return true
    end,
})
