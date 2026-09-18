local Mod = {
    Name = "Example Movement",
    Category = "Movement",
    Description = "Template showing how a NoxLib movement module is structured."
}

function Mod:Init(Nox)
    self.Nox = Nox

    Nox.Lib.addButton(self.Category, {
        name = self.Name,
        toggle = true,
        description = self.Description,

        action = function(enabled)
            if enabled then
                self:Enable()
            else
                self:Disable()
            end
        end,

        settings = {
            {
                type = "slider",
                name = "Speed",
                key = "speed",
                default = 20,
                min = 1,
                max = 100
            }
        }
    })
end

function Mod:Enable()
    -- Put feature startup code here.
end

function Mod:Disable()
    -- Put feature cleanup code here.
end

function Mod:Destroy()
    self:Disable()
end

return Mod
