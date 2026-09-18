local Mod = {
    Name = "Example Combat",
    Category = "Combat",
    Description = "Template showing how a NoxLib combat module is structured."
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
        end
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
