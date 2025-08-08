local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

local function createEmoteTool(toolInfo)
    local tool = Instance.new("Tool")
    tool.Name = toolInfo.name or "Emote"
    tool.RequiresHandle = false
    tool.Parent = Backpack
    tool.Equipped:Connect(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
            return
        end
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..tostring(toolInfo.Id)
        local track
        pcall(function()
            track = humanoid:LoadAnimation(anim)
        end)
        if track then
            track:Play()
        end
    end)
end

local waitForToolsTable
waitForToolsTable = coroutine.create(function()
    while not _G.tools do
        wait()
    end
    for _, toolInfo in ipairs(_G.tools) do
        createEmoteTool(toolInfo)
    end
end)
coroutine.resume(waitForToolsTable)
