# noxvape

Modular Roblox Lua project split from the original monolithic script. The project keeps NoxLib as the UI/backend dependency and moves shared game access/helpers into `src/core`, while each feature lives in its own mod file.

## Structure

```text
noxvape/
├── loader.lua
├── README.md
└── src/
    ├── init.lua
    ├── core/
    │   └── context.lua
    └── mods/
        ├── combat/
        ├── exploits/
        ├── movement/
        ├── other/
        └── renderer/
```

## Loading

`loader.lua` points at the GitHub repository root and downloads `src/init.lua`. `init.lua` then downloads the core context and every mod using the same raw base URL.

If you move the repository or branch, change only `BASE_URL` in `loader.lua`.

The mod list is generated in `src/init.lua`, so the top-level loader does not need to know about individual features.

## Adding a mod

1. Add a new file under the appropriate `src/mods/<category>/` folder.
2. Make it return `function(ctx) ... end`.
3. Add its path to the generated module list in `src/init.lua`.

For completely automatic discovery of new files, a later version can use the GitHub Contents/Tree API, but this version intentionally avoids a JSON API dependency so it works with simple executor `HttpGet` support.

## NoxLib

The project continues to load NoxLib from the existing raw URL used by the original script.
