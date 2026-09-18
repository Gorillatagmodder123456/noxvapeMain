local Raycast = {
    Name = "Raycast"
}

function Raycast:Init(Nox)
    Nox.Raycast = {}

    function Nox.Raycast.cast(origin, direction, params)
        return Nox.Services.Workspace:Raycast(origin, direction, params)
    end
end

return Raycast
