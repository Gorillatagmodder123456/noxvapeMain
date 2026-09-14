# Backend

`core.lua` is the shared runtime layer. It owns Roblox services, the game's remote references, shared state, controller lookup, target/entity helpers, movement input, inventory helpers, and bed lookup.

Mods should not duplicate those lookups. Each mod receives the Core table as `...` and aliases whatever it needs at the top of the file.

`categories.lua` registers the NoxLib categories before mods are loaded.
