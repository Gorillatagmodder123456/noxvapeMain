local Utils = {
    Name = "Utils"
}

function Utils:Init(Nox)
    Nox.Utils = {}

    function Nox.Utils.safeDisconnect(connection)
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
        return nil
    end

    function Nox.Utils.getCharacter(player)
        return player and player.Character
    end

    function Nox.Utils.getRoot(character)
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    end

    function Nox.Utils.getHumanoid(character)
        return character and character:FindFirstChildOfClass("Humanoid")
    end
end

return Utils
