-- mods/other/SpinBot.lua
local NoxLib     = _G.NoxLib
local B          = _G.NoxBackend
local RunService = game:GetService("RunService")
local player     = B.player

NoxLib.addCategory("Other")

local Running    = false
local Conn       = nil
local CachedSpeed = 10

NoxLib.addButton("Other", {
    name        = "Spin Bot",
    toggle      = true,
    description = "Continuously rotates your character.",
    settings    = {
        {
            type      = "slider",
            name      = "Speed",
            key       = "speed",
            default   = 10,
            min       = 1,
            max       = 100,
            onChanged = function(val) CachedSpeed = tonumber(val) or 10 end,
        },
    },
    action = function(enabled)
        Running = enabled
        if Conn then Conn:Disconnect(); Conn = nil end
        if not enabled then return true end
        CachedSpeed = NoxLib.getSetting("Other", "Spin Bot", "speed", 10)
        Conn = RunService.RenderStepped:Connect(function(dt)
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(360 * CachedSpeed * dt), 0)
        end)
        return true
    end,
})
