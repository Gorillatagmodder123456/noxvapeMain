local Services = {
    Name = "Services"
}

function Services:Init(Nox)
    Nox.Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        Workspace = workspace,
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        Lighting = game:GetService("Lighting"),
        HttpService = game:GetService("HttpService")
    }

    Nox.Player = {
        LocalPlayer = Nox.Services.Players.LocalPlayer
    }
end

return Services
