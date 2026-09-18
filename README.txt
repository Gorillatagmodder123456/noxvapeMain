noxvapeMain modular loader

ENTRY POINT:
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gorillatagmodder123456/noxvapeMain/main/main.lua"))()

Structure:
main.lua
src/init.lua
src/core/NoxLib.lua
src/mods/**/*.lua

The loader recursively scans src/mods through the GitHub Contents API. Each mod
returns a table and may provide Category and Init. Categories are discovered at
runtime and registered automatically. NoxLib is loaded from src/core/NoxLib.lua,
so there is no runtime dependency on the separate Noxvape repository.

IMPORTANT:
The bundled NoxLib.lua is intentionally a guard placeholder because the exact
3516-line source could not be transferred from the web source into this archive.
Replace it with the exact contents of Noxvape/noxvape.lua before executing.
