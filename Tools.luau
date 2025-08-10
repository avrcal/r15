local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

local function createEmoteTool(toolInfo)
    local tool = Instance.new("Tool")
    tool.Name = toolInfo.name or "Emote"
    tool.RequiresHandle = false
    tool.Parent = Backpack

    local activeTrack = nil

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
            activeTrack = track
        end
    end)

    tool.Unequipped:Connect(function()
        if activeTrack then
            pcall(function()
                activeTrack:Stop()
            end)
            activeTrack = nil
        end
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://0"
                local track
                pcall(function()
                    track = humanoid:LoadAnimation(anim)
                end)
                if track then
                    track:Play()
                end
            end
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

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Create the main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(1, -270, 0, 50) -- Right side of the screen
frame.BackgroundColor3 = Color3.fromRGB(0, 100, 0) -- Dark green
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Add a title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Wanna add more emotes? Join our server!"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
titleLabel.TextWrapped = true
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.TextSize = 18
titleLabel.Parent = frame

-- Add the copy button
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 200, 0, 40)
copyButton.Position = UDim2.new(0, 25, 0, 80)
copyButton.Text = "Copy Discord Link"
copyButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
copyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White background
copyButton.Font = Enum.Font.SourceSansBold
copyButton.TextSize = 16
copyButton.Parent = frame

-- Button click event to copy the link
copyButton.MouseButton1Click:Connect(function()
    -- Copy the link to clipboard (Roblox supports this through SetClipboard)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SetClipboard", "https://discord.gg/nSmx5U3f")
    end)

    -- Optional: Show feedback
    copyButton.Text = "Copied!"
    wait(1.5)
    copyButton.Text = "Copy Discord Link"
end)
