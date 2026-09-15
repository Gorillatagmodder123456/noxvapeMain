# noxvape

Modular Roblox GUI framework. One raw link loads everything.

## Quick start

Paste this into your executor:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USER/noxvape/main/main.lua"))()
```

Replace `YOUR_USER` with your GitHub username after uploading.

---

## File structure

```
noxvape/
├── main.lua                  ← executor entry point (only file you run)
├── lib/
│   └── NoxLib.lua            ← GUI framework (buttons, settings, keybinds, notifications)
├── backend/
│   └── Backend.lua           ← remotes, controller getters, inventory check
└── mods/
    ├── combat/
    │   ├── NoClickDelay.lua
    │   ├── AutoClicker.lua
    │   └── Sprint.lua
    ├── movement/
    │   └── InfJump.lua
    ├── renderer/
    │   ├── Transparent.lua
    │   ├── NameTags.lua
    │   └── FabricTextures.lua
    └── other/
        └── SpinBot.lua
```

---

## Adding a new mod

1. Create a file in the right `mods/` subfolder, e.g. `mods/combat/KillAura.lua`
2. Use this template:

```lua
-- mods/combat/KillAura.lua
local NoxLib = _G.NoxLib
local B      = _G.NoxBackend
local player = B.player

NoxLib.addButton("Combat", {
    name        = "Kill Aura",
    toggle      = true,
    description = "Attacks nearby players automatically.",
    settings    = {
        {
            type      = "slider",
            name      = "Range",
            key       = "range",
            default   = 10,
            min       = 1,
            max       = 50,
            onChanged = function(val) CachedRange = tonumber(val) or 10 end,
        },
        {
            type      = "checkbox",
            name      = "Wall Check",
            key       = "wallCheck",
            default   = true,
            onChanged = function(val) CachedWallCheck = val end,
        },
        {
            type      = "dropdown",
            name      = "Target",
            key       = "target",
            default   = "Closest",
            options   = { "Closest", "Lowest HP", "Random" },
            onChanged = function(val) CachedTarget = val end,
        },
    },
    action = function(enabled)
        -- your logic here
        return true
    end,
})
```

3. Add one line to `main.lua`:
```lua
load("mods/combat/KillAura.lua")
```

That's it. Push to GitHub and it loads automatically.

---

## Setting types

| type       | required fields                        | optional          |
|------------|----------------------------------------|-------------------|
| slider     | name, key, default, min, max           | onChanged         |
| checkbox   | name, key, default (bool)              | onChanged         |
| textbox    | name, key, default                     | placeholder, onChanged |
| dropdown   | name, key, default, options={...}      | onChanged         |

---

## NoxLib API

```lua
NoxLib.addCategory(name)          -- registers a tab
NoxLib.addButton(category, opts)  -- adds a button
NoxLib.notify(msg, type)          -- "enabled" | "warning" | "error"
NoxLib.notifyEnabled(msg)
NoxLib.notifyWarning(msg)
NoxLib.notifyError(msg)
NoxLib.getSetting(cat, feat, key, default)
NoxLib.setSetting(cat, feat, key, value)
NoxLib.Features.isEnabled(cat, name)
NoxLib.Features.enable(cat, name)
NoxLib.Features.disable(cat, name)
NoxLib.Features.forceOff(cat, name)
NoxLib.saveConfig()
NoxLib.setMenuVisible(bool)
NoxLib.init()                     -- call once after all addButton calls
```

## Backend API

```lua
local B = _G.NoxBackend
B.RemoteList          -- table of game remotes
B.getSwordController()
B.getSprintController()
B.hasItem(searchString)
B.sanitizeAssetId(raw)
B.player              -- Players.LocalPlayer
B.ActiveLoops         -- { name = thread } for cleanup
```
