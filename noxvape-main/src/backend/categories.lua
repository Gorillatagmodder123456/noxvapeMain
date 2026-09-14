local NoxLib = ...
for _, category in ipairs({"Combat", "Movement", "Exploits", "Kits", "Renderer", "Other"}) do
    NoxLib.addCategory(category)
end
return true
