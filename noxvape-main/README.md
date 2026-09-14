# noxvape Modular

This is the modularized version of the uploaded Roblox Lua project. The original script is split into a small bootstrap, backend/core services, and individual feature modules.

## Structure

```text
noxvape-Modular/
├── main.lua
├── NoxLib.lua
├── README.md
└── src/
    ├── init.lua
    ├── backend/
    │   ├── core.lua
    │   └── categories.lua
    └── mods/
        ├── combat/
        ├── exploits/
        ├── movement/
        ├── other/
        └── renderer/
```

## First setup

1. Upload this folder to a GitHub repository.
2. Open `main.lua`.
3. Replace `YOUR_USERNAME/YOUR_REPOSITORY` with the repository owner/name.
4. Keep the repository branch as `main`, or change `/main/` in `main.lua` and `src/init.lua` if you use another branch.
5. Your one-line loader becomes:
   `loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPOSITORY/main/main.lua"))()`

## Loader

After uploading, the only script you need to run is `main.lua` through its GitHub raw URL. `main.lua` pulls `src/init.lua`, which pulls the backend and every mod.

## Adding a mod

Create a Lua file under the appropriate `src/mods/` category. The module receives the shared `Core` table as `...`, so common services and helpers are already available. Add the new module path to the `modules` table in `src/init.lua`.

## NoxLib

`NoxLib.lua` is a tiny adapter that loads the existing NoxLib from the current Noxvape repository. If you move NoxLib later, only that file needs to be changed.
