local Player = {
    Name = "Player"
}

function Player:Init(Nox)
    Nox.Player = Nox.Player or {}
    Nox.Player.LocalPlayer = Nox.Services.Players.LocalPlayer

    function Nox.Player.getCharacter()
        return Nox.Player.LocalPlayer.Character
    end

    function Nox.Player.getRoot()
        return Nox.Utils.getRoot(Nox.Player.getCharacter())
    end

    function Nox.Player.getHumanoid()
        return Nox.Utils.getHumanoid(Nox.Player.getCharacter())
    end
end

return Player
