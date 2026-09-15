-- mods/renderer/FabricTextures.lua
local NoxLib = _G.NoxLib

local Originals = {}
local Applying  = false

NoxLib.addButton("Renderer", {
    name        = "Fabric Textures",
    toggle      = true,
    description = "Replaces world blocks with flat grey SmoothPlastic (no cloth lag).",
    action      = function(enabled)
        if Applying then return false end
        Applying = true
        local map    = workspace:FindFirstChild("Map")
        local worlds = map and map:FindFirstChild("Worlds")
        if not worlds then Applying = false return true end
        task.spawn(function()
            local n = 0
            if enabled then
                for _, world in ipairs(worlds:GetChildren()) do
                    local blocks = world:FindFirstChild("Blocks")
                    if blocks then
                        for _, obj in ipairs(blocks:GetChildren()) do
                            if obj:IsA("BasePart") then
                                if not Originals[obj] then
                                    Originals[obj] = {
                                        Material        = obj.Material,
                                        MaterialVariant = obj.MaterialVariant,
                                        Color           = obj.Color,
                                    }
                                end
                                obj.Material        = Enum.Material.SmoothPlastic
                                obj.MaterialVariant = ""
                                obj.Color           = Color3.fromRGB(128,128,128)
                                n += 1
                                if n % 200 == 0 then task.wait() end
                            end
                        end
                    end
                end
            else
                for obj, orig in pairs(Originals) do
                    if obj and obj.Parent then
                        obj.Material        = orig.Material
                        obj.MaterialVariant = orig.MaterialVariant
                        obj.Color           = orig.Color
                        n += 1
                        if n % 200 == 0 then task.wait() end
                    end
                end
                table.clear(Originals)
            end
            Applying = false
        end)
        return true
    end,
})
