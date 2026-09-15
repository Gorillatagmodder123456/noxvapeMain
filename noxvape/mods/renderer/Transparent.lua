-- mods/renderer/Transparent.lua
local NoxLib = _G.NoxLib
local B      = _G.NoxBackend
local player = B.player

NoxLib.addCategory("Renderer")

local Running   = false
local CharConn  = nil

local function apply(enable)
    local char = player.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "NoxCape" then
            obj.LocalTransparencyModifier = enable and 0.5 or 0
        elseif (obj:IsA("Decal") or obj:IsA("Texture"))
            and obj.Parent and obj.Parent.Name ~= "NoxCape" then
            obj.Transparency = enable and 0.5 or 0
        end
    end
end

NoxLib.addButton("Renderer", {
    name        = "Transparent",
    toggle      = true,
    description = "Makes your character semi-transparent.",
    action      = function(enabled)
        Running = enabled
        if CharConn then CharConn:Disconnect(); CharConn = nil end
        if enabled then
            apply(true)
            CharConn = player.CharacterAdded:Connect(function()
                task.wait()
                if Running then apply(true) end
            end)
        else
            apply(false)
        end
        return true
    end,
})
