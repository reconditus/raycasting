local players = game:GetService("Players")
--useful definitions
local localplayer = players.LocalPlayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local localhumanoidroot = character:WaitForChild("HumanoidRootPart")
-- these definitions are compeltely useless only used for debugging in arabic game remove if trying to port
local clientpos = workspace.Misc.Client_LucasZoomEcho:GetChildren()
local serverpos = workspace.Misc.Client_LucasZoomEcho:GetChildren()
-- this blacklist table is completely useless because its made for the arabic game.
local blacklist = {}

for _, obj in ipairs(character:GetDescendants()) do
    if obj:IsA("BasePart") then
        table.insert(blacklist, obj)
    end
end

for _, part in ipairs(serverpos) do
    if part:IsA("BasePart") then
        table.insert(blacklist, part)
    end
end

for _, part in ipairs(clientpos) do
    if part:IsA("BasePart") then
        table.insert(blacklist, part)
    end
end

local bots = game:GetService("Workspace").Bots
local botroot = bots:GetChildren() --table including all bots
-- this creates the higlight for the raycast target (botRootParts[6])
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(255, 80, 80)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.Parent = workspace

--looks through the bots folder and finds humanoidrootparts for the bots
local botRootParts = {}
for _, bot in pairs(botroot) do
    local hrp = bot:FindFirstChild("HumanoidRootPart", true)
    if hrp and hrp:IsA("BasePart") then
        table.insert(botRootParts, hrp)
    end
end
-- this is a static selector for raycasting (only scans 1 raycast at this)
local target = botRootParts[6]
--[[ defines the origin and destination for the raycast
since we dont have direction yet, but it is required for a raycast, we use the formula direction = destination - origin
the origin is offset 
]]
local origin = localhumanoidroot.Position
local destination = target.Position

local direction = destination - origin
print(" ") --blank print statements to help me separate each raycast result in the console
-- this is the blacklisting for the raycasting
local raycastparams = RaycastParams.new()
raycastparams.FilterType = Enum.RaycastFilterType.Blacklist
-- this blacklisting uses the table "blacklist," if you're only blacklisting a file then you will need braces.
raycastparams.FilterDescendantsInstances = blacklist
raycastparams.IgnoreWater = true
--fires raycast from the location of the origin in the direction of the bots humanoidrootpart with the parameters.
local raycastResult = workspace:Raycast(origin, direction, raycastparams)

--highlight raycast target
if raycastResult then
    local botModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")

    if botModel and botModel:IsDescendantOf(bots) then
        highlight.Adornee = botModel
        highlight.Enabled = true
    else
        highlight.Enabled = false
        highlight.Adornee = nil
    end
else
    highlight.Enabled = false
    highlight.Adornee = nil
end

--raycast result printing
local targetDistance = (destination - origin).Magnitude -- this is the distance between the target and the origin, this is different from raycastResult.Distance because raycastResult.Distance shows the distance between where the raycast landed.
print(direction, destination, origin)
if raycastResult then
    print("Position:", raycastResult.Position)
    warn("Distance of raycast result:", raycastResult.Distance)
    warn("Distance of Target", targetDistance)
    if raycastResult.Instance:IsDescendantOf(target.Parent) then -- if the raycast result is the descendant of the targets parent then its a hit (descendants include the arms, legs, head)
        warn("hit")
    else
        warn("miss, hit:", raycastResult.Instance, "isSelf?", raycastResult.Instance:IsDescendantOf(character)) -- isself is useless because of the blacklisting, this was made for debugging purposes.
    end
    print("Material:", raycastResult.Material)
    print("Normal:", raycastResult.Normal)
else
    warn("No raycast result!") -- this will never show up if the bot still exists
end
print(" ")
