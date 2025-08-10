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

-- Function to create and show the GUI
local function createAndShowGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- Create the ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EmoteGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Good practice
    screenGui.Parent = playerGui

    -- Create the main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 150)
    frame.Position = UDim2.new(1, -270, 0, 50) -- Right side of the screen
    frame.AnchorPoint = Vector2.new(0, 0) -- Anchor top-left corner for consistent positioning
    frame.BackgroundColor3 = Color3.fromRGB(0, 100, 0) -- Dark green
    frame.BorderSizePixel = 0
    frame.ZIndex = 1
    frame.Parent = screenGui

    -- Add a title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 60) -- Add some padding
    titleLabel.Position = UDim2.new(0, 10, 0, 10) -- Offset from frame edge
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Wanna add more emotes? Join our server!"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    titleLabel.TextWrapped = true
    titleLabel.Font = Enum.Font.SourceSansSemibold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center -- Center text
    titleLabel.ZIndex = 2
    titleLabel.Parent = frame

    -- Add the copy button
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0, 200, 0, 40)
    copyButton.Position = UDim2.new(0.5, -100, 0, 80) -- Center horizontally within the frame
    copyButton.Text = "Copy Discord Link"
    copyButton.TextColor3 = Color3.fromRGB(0, 0, 0) -- Black text
    copyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White background
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.TextSize = 16
    copyButton.AutoButtonColor = true -- Gives visual feedback on press
    copyButton.ZIndex = 2
    copyButton.Parent = frame

    -- Button click/touch event to copy the link
    copyButton.MouseButton1Click:Connect(function()
        local success, errorMessage = pcall(function()
            -- Check if SetClipboard is supported
            local StarterGui = game:GetService("StarterGui")
            StarterGui:SetCore("SetClipboard", "https://discord.gg/nSmx5U3f")
        end)

        if success then
            -- Provide feedback
            local originalText = copyButton.Text
            copyButton.Text = "Copied!"
            wait(1.5)
            copyButton.Text = originalText
        else
            warn("Failed to copy link to clipboard:", errorMessage)
            -- Optionally, show an error message in the GUI if copying fails
        end
    end)
end

-- Run the GUI creation in a new thread to prevent blocking
spawn(createAndShowGui)
