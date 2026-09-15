-- mods/movement/InfJump.lua
local NoxLib     = _G.NoxLib
local B          = _G.NoxBackend
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local player     = B.player

NoxLib.addCategory("Movement")

local Running        = false
local SpaceHeld      = false
local JumpConn       = nil
local BeganConn      = nil
local EndedConn      = nil
local CachedSpeed    = 35

NoxLib.addButton("Movement", {
    name        = "Inf Jump",
    toggle      = true,
    description = "Hold Space to float upward.",
    settings    = {
        {
            type      = "slider",
            name      = "Float Speed",
            key       = "floatSpeed",
            default   = 35,
            min       = 1,
            max       = 150,
            onChanged = function(val) CachedSpeed = tonumber(val) or 35 end,
        },
    },
    action = function(enabled)
        Running = enabled
        if JumpConn  then JumpConn:Disconnect();  JumpConn  = nil end
        if BeganConn then BeganConn:Disconnect(); BeganConn = nil end
        if EndedConn then EndedConn:Disconnect(); EndedConn = nil end
        SpaceHeld = false
        if not enabled then return true end

        CachedSpeed = NoxLib.getSetting("Movement", "Inf Jump", "floatSpeed", 35)

        BeganConn = UIS.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == Enum.KeyCode.Space then SpaceHeld = true end
        end)
        EndedConn = UIS.InputEnded:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.Space then SpaceHeld = false end
        end)
        JumpConn = RunService.Heartbeat:Connect(function()
            if not Running or not SpaceHeld then return end
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(v.X, CachedSpeed, v.Z)
        end)
        return true
    end,
})
