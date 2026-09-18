local Targeting = {
    Name = "Targeting"
}

function Targeting:Init(Nox)
    Nox.Targeting = {}

    function Nox.Targeting.getPlayers()
        return Nox.Services.Players:GetPlayers()
    end

    function Nox.Targeting.isAlive(player)
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        return humanoid ~= nil and humanoid.Health > 0
    end

    function Nox.Targeting.getClosest(maxDistance)
        local localRoot = Nox.Player.getRoot()
        if not localRoot then return nil end

        local closest, closestDistance

        for _, player in ipairs(Nox.Services.Players:GetPlayers()) do
            if player ~= Nox.Player.LocalPlayer and Nox.Targeting.isAlive(player) then
                local root = Nox.Utils.getRoot(player.Character)
                if root then
                    local distance = (root.Position - localRoot.Position).Magnitude
                    if (not maxDistance or distance <= maxDistance)
                        and (not closestDistance or distance < closestDistance) then
                        closest = player
                        closestDistance = distance
                    end
                end
            end
        end

        return closest, closestDistance
    end
end

return Targeting
