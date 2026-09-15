-- mods/renderer/NameTags.lua
local NoxLib  = _G.NoxLib
local B       = _G.NoxBackend
local Players = game:GetService("Players")
local player  = B.player

local Running         = false
local GlobalConns     = {}
local PlayerConns     = {}   -- player -> {RBXScriptConnection, ...}
local Tags            = {}   -- character -> BillboardGui

local FontMap = {
    Gotham="Gotham", GothamBold="GothamBold", SourceSans="SourceSans",
    SourceSansBold="SourceSansBold", Arial="Arial", ArialBold="ArialBold",
    Cartoon="Cartoon", Code="Code", SciFi="SciFi", Fantasy="Fantasy",
}
local function getFont()
    local key = NoxLib.getSetting("Renderer","Name Tags","font","GothamBold")
    return Enum.Font[FontMap[key] or "GothamBold"] or Enum.Font.GothamBold
end
local function useTeamColors()
    return NoxLib.getSetting("Renderer","Name Tags","teamColors",false) == true
end
local function tagColor(target)
    if useTeamColors() and target and target.Team then return target.Team.TeamColor.Color end
    return Color3.new(1,1,1)
end
local function resize(bb)
    if not bb or not bb.Parent then return end
    local ov = bb:FindFirstChild("Overlay")
    local tx = ov and ov:FindFirstChild("Name")
    if not tx then return end
    local w = math.max(tx.TextBounds.X + 18, 30)
    ov.Size = UDim2.fromOffset(w, 25)
    tx.Size = UDim2.fromOffset(tx.TextBounds.X + 2, 25)
end

local function createTag(target)
    if target == player then return end
    local char = target.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    if Tags[char] then Tags[char]:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name="NoxNameTag"; bb.Adornee=head
    bb.Size=UDim2.fromOffset(250,40); bb.StudsOffset=Vector3.new(0,2.8,0)
    bb.AlwaysOnTop=true; bb.ResetOnSpawn=false; bb.Parent=head
    local ov = Instance.new("Frame")
    ov.Name="Overlay"; ov.AnchorPoint=Vector2.new(0.5,0.5)
    ov.Position=UDim2.fromScale(0.5,0.5); ov.Size=UDim2.fromOffset(60,25)
    ov.BackgroundColor3=Color3.fromRGB(10,10,10); ov.BackgroundTransparency=0.15
    ov.BorderSizePixel=0; ov.Parent=bb
    local corner = Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,4); corner.Parent=ov
    local tx = Instance.new("TextLabel")
    tx.Name="Name"; tx.AnchorPoint=Vector2.new(0.5,0.5)
    tx.Position=UDim2.fromScale(0.5,0.5); tx.Size=UDim2.fromOffset(40,25)
    tx.BackgroundTransparency=1; tx.Text=target.DisplayName
    tx.TextSize=14; tx.Font=getFont()
    tx.TextColor3=tagColor(target)
    tx.TextStrokeTransparency=1; tx.TextXAlignment=Enum.TextXAlignment.Center
    tx.TextYAlignment=Enum.TextYAlignment.Center; tx.Parent=ov
    Tags[char] = bb
    task.defer(function() resize(bb) end)
    local c1 = target:GetPropertyChangedSignal("DisplayName"):Connect(function()
        if bb.Parent then tx.Text=target.DisplayName; resize(bb) end
    end)
    local c2 = target:GetPropertyChangedSignal("Team"):Connect(function()
        if bb.Parent then tx.TextColor3=tagColor(target) end
    end)
    PlayerConns[target] = {c1, c2}
end

local function clearAll()
    for _, bb in pairs(Tags) do pcall(function() bb:Destroy() end) end
    table.clear(Tags)
    for _, conns in pairs(PlayerConns) do
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    end
    table.clear(PlayerConns)
    for _, c in ipairs(GlobalConns) do pcall(function() c:Disconnect() end) end
    table.clear(GlobalConns)
end

NoxLib.addButton("Renderer", {
    name        = "Name Tags",
    toggle      = true,
    description = "Shows player display names above heads.",
    settings    = {
        {
            type      = "dropdown",
            name      = "Font",
            key       = "font",
            default   = "GothamBold",
            options   = {"Gotham","GothamBold","SourceSans","SourceSansBold","Arial","ArialBold","Cartoon","Code","SciFi","Fantasy"},
            onChanged = function()
                for _, bb in pairs(Tags) do
                    local tx = bb:FindFirstChild("Overlay") and bb.Overlay:FindFirstChild("Name")
                    if tx then tx.Font=getFont(); resize(bb) end
                end
            end,
        },
        {
            type      = "checkbox",
            name      = "Team Colors",
            key       = "teamColors",
            default   = false,
            onChanged = function()
                for char, bb in pairs(Tags) do
                    local tgt = Players:GetPlayerFromCharacter(char)
                    if tgt then
                        local tx = bb:FindFirstChild("Overlay") and bb.Overlay:FindFirstChild("Name")
                        if tx then tx.TextColor3 = tagColor(tgt) end
                    end
                end
            end,
        },
    },
    action = function(enabled)
        Running = enabled
        if not enabled then clearAll() return true end
        for _, tgt in ipairs(Players:GetPlayers()) do
            if tgt ~= player then
                createTag(tgt)
                local cc = tgt.CharacterAdded:Connect(function()
                    if Running and tgt ~= player then task.wait(); createTag(tgt) end
                end)
                PlayerConns[tgt] = PlayerConns[tgt] or {}
                table.insert(PlayerConns[tgt], cc)
            end
        end
        local paConn = Players.PlayerAdded:Connect(function(tgt)
            if not Running or tgt == player then return end
            createTag(tgt)
            local cc = tgt.CharacterAdded:Connect(function()
                if Running and tgt ~= player then task.wait(); createTag(tgt) end
            end)
            PlayerConns[tgt] = PlayerConns[tgt] or {}
            table.insert(PlayerConns[tgt], cc)
        end)
        table.insert(GlobalConns, paConn)
        return true
    end,
})
