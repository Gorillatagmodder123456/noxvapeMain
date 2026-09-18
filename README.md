# noxvapeMain

Modular Roblox Lua project designed around NoxLib.

## Execute

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/main.lua"))()
```

## Add a mod

Create a file anywhere under:

`src/mods/`

For example:

`src/mods/Movement/MyMod.lua`

Return a table:

```lua
local Mod = {
    Name = "My Mod",
    Category = "Movement",
    Description = "My description"
}

function Mod:Init(Nox)
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
end

function Mod:Disable()
end

return Mod
```

No module list needs to be edited. `src/init.lua` recursively discovers `.lua` files through the GitHub Contents API.

## Remove a mod

Delete its `.lua` file from `src/mods/`.

## Backend

Shared APIs are under `src/backend/`.

- Services
- Utils
- Player
- Targeting
- Raycast

More can be added later.

## Important

The GitHub API must be reachable through the executor's HTTP implementation and return valid JSON. If your executor blocks `api.github.com`, automatic discovery cannot work with this approach; in that case use a manifest or a GitHub raw file containing the module list.
