-- // Emote Tool Executor Script (Simplified GUI Interactions) \\
-- // Designed for KRNL, Synapse X, etc. \\

-- Wait for the critical game services and player components to load
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- TweenService removed as hover effect is simplified
local StarterGui = game:GetService("StarterGui")

-- It's crucial to wait for the LocalPlayer and PlayerGui
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") -- This ensures the GUI target exists

-- Function to create emote tools
local function createEmoteTool(toolInfo)
    -- Basic check, though tool creation might depend on game specifics
    if not toolInfo.Id then return end

    local tool = Instance.new("Tool")
    tool.Name = toolInfo.name or "Emote"
    tool.RequiresHandle = false

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
        anim.AnimationId = "rbxassetid://" .. tostring(toolInfo.Id)
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
        -- Optional: Reset to default animation
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://0" -- T-Pose or default anim ID
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

    -- Parent the tool to the backpack
    pcall(function()
        tool.Parent = LocalPlayer:WaitForChild("Backpack")
    end)
end

-- Function to wait for and process the _G.tools table
local function waitForAndCreateTools()
    -- Wait for _G.tools to be defined (likely by another executor script or manually)
    if not _G.tools then
        warn("[Executor Script] Waiting for _G.tools table...")
    end
    while not _G.tools do
        wait() -- Yield until _G.tools exists
    end

    if type(_G.tools) ~= "table" then
        warn("[Executor Script] _G.tools is not a table!")
        return
    end

    -- Iterate through the tools table and create them
    for _, toolInfo in ipairs(_G.tools) do
        if type(toolInfo) == "table" and toolInfo.Id then
            spawn(function() -- Use spawn to prevent one bad tool from stopping the loop
                createEmoteTool(toolInfo)
            end)
        else
            warn("[Executor Script] Invalid tool info found:", toolInfo)
        end
    end
    print("[Executor Script] Finished creating emote tools from _G.tools.")
end

-- Function to create the executor-style GUI
local function createExecutorGui()
    -- Create the ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ExecutorEmoteGui"
    screenGui.ResetOnSpawn = false
    -- Parent directly to PlayerGui, standard for executors
    pcall(function()
        screenGui.Parent = PlayerGui
    end)
    if not screenGui.Parent then
        warn("[Executor Script] Failed to parent ScreenGui!")
        return
    end

    -- Main Window Frame
    local windowFrame = Instance.new("Frame")
    windowFrame.Size = UDim2.new(0, 300, 0, 200)
    windowFrame.Position = UDim2.new(1, -320, 0, 50)
    windowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark background
    windowFrame.BorderSizePixel = 0
    windowFrame.Active = true -- Allows dragging
    windowFrame.Draggable = true -- Make it draggable
    windowFrame.Parent = screenGui

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Slightly lighter dark
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -25, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Emote Executor"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextWrapped = false
    titleLabel.Font = Enum.Font.SourceSansSemibold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Content Area Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -25)
    contentFrame.Position = UDim2.new(0, 0, 0, 25)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = windowFrame

    -- Message Label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 20)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = "Wanna add more emotes?\nJoin our server!"
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextWrapped = true
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextSize = 16
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = contentFrame

    -- Copy Button (Simplified Style)
    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyLinkButton"
    copyButton.Size = UDim2.new(0, 200, 0, 40)
    copyButton.Position = UDim2.new(0.5, -100, 0, 100)
    copyButton.Text = "Copy Discord Link"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70) -- Slightly lighter base
    copyButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
    copyButton.Font = Enum.Font.SourceSansSemibold
    copyButton.TextSize = 15
    copyButton.AutoButtonColor = true -- Roblox's built-in click effect
    copyButton.Parent = contentFrame

    -- Unified function for copying the link and feedback
    local function handleCopy()
        local success, err = pcall(function()
            -- Primary method for most executors
            setclipboard("https://discord.gg/nSmx5U3f")
        end)

        if not success then
            warn("[Executor Script] setclipboard failed, trying SetCore:", err)
            -- Fallback method
            pcall(function()
                StarterGui:SetCore("SetClipboard", "https://discord.gg/UpEb4KaqNp")
            end)
        end

        -- Visual feedback
        local originalText = copyButton.Text
        local originalColor = copyButton.TextColor3
        copyButton.Text = "Copied!"
        copyButton.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green feedback

        -- Revert after delay using spawn for safety
        spawn(function()
            wait(1.5)
            pcall(function() -- In case GUI was destroyed
                if copyButton and copyButton.Parent then
                    copyButton.Text = originalText
                    copyButton.TextColor3 = originalColor
                end
            end)
        end)
    end

    -- Connect the unified function to both PC and Mobile click events
    copyButton.MouseButton1Click:Connect(handleCopy) -- PC Click
    copyButton.TouchTap:Connect(handleCopy)         -- Mobile Tap

    print("[Executor Script] GUI created successfully.")
end

-- Main Execution Flow
print("[Executor Script] Script started. Waiting for prerequisites...")

-- Run the GUI creation and tool creation in parallel
spawn(function()
    createExecutorGui()
end)

spawn(function()
    waitForAndCreateTools()
end)

print("[Executor Script] Initialization complete. Waiting for _G.tools and player setup.")
