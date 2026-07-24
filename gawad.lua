-- aGsx-BLACKOBLIVION | Squid Game X OP (Custom GUI)
-- Fully custom GUI with draggable main frame and toggle circle
-- Works on all executors, mobile-friendly

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Variables
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 50
local speedEnabled = false
local speedValue = 50
local jumpEnabled = false
local jumpValue = 50
local espEnabled = false
local fullbrightEnabled = false
local autoKillEnabled = false
local originalBrightness = Lighting.Brightness
local espObjects = {}
local flyConnection = nil
local autoKillConnection = nil

-- Create GUI container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SquidGameX_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ========== DRAGGABLE TOGGLE CIRCLE ==========
local ToggleCircle = Instance.new("ImageButton")
ToggleCircle.Size = UDim2.new(0, 50, 0, 50)
ToggleCircle.Position = UDim2.new(0.85, -25, 0.85, -25)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ToggleCircle.BackgroundTransparency = 0.3
ToggleCircle.BorderColor3 = Color3.fromRGB(0, 255, 0)
ToggleCircle.BorderSizePixel = 2
ToggleCircle.Draggable = true
ToggleCircle.Active = true
ToggleCircle.Visible = true
ToggleCircle.Parent = ScreenGui

-- Make it round
local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = ToggleCircle

-- Circle label
local CircleLabel = Instance.new("TextLabel")
CircleLabel.Size = UDim2.new(1, 0, 1, 0)
CircleLabel.Text = "▶"
CircleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleLabel.BackgroundTransparency = 1
CircleLabel.Font = Enum.Font.GothamBold
CircleLabel.TextSize = 24
CircleLabel.Parent = ToggleCircle

-- Pulse animation
local pulse = TweenService:Create(ToggleCircle, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.1})
pulse:Play()

-- Hide toggle circle initially? We'll show it, but main frame will be visible first.
-- Actually better to show main frame and hide toggle circle until main frame is closed.
ToggleCircle.Visible = false

-- ========== MAIN FRAME (draggable) ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.Text = "⚡ Squid Game X OP"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = TitleBar

-- Close button (X) – hides main frame and shows toggle circle
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleCircle.Visible = true
end)

-- Toggle circle click: show main frame, hide circle
ToggleCircle.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleCircle.Visible = false
end)

-- ========== SCROLLING FRAME FOR CONTENT ==========
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = ScrollFrame

local function addToggle(labelText, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -55, 0, 2)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(state)
    end)
    return { button = btn, state = state }
end

local function addButton(labelText, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, 2)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addSlider(labelText, min, max, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = labelText .. ": " .. tostring(default) .. (suffix or "")
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 16, 0, 16)
    drag.Position = UDim2.new(fill.Size.X.Scale - 0.5, 0, 0, -5)
    drag.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.BackgroundTransparency = 0.2
    drag.Parent = sliderBg

    local value = default
    local dragging = false

    drag.MouseButton1Down:Connect(function() dragging = true end)
    drag.MouseButton1Up:Connect(function() dragging = false end)
    drag.MouseLeave:Connect(function() dragging = false end)

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local ratio = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            value = min + ratio * (max - min)
            value = math.round(value / 1) * 1
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            drag.Position = UDim2.new(ratio - 0.5, 0, 0, -5)
            label.Text = labelText .. ": " .. tostring(value) .. (suffix or "")
            callback(value)
        end
    end)

    sliderBg.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local ratio = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            value = min + ratio * (max - min)
            value = math.round(value / 1) * 1
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            drag.Position = UDim2.new(ratio - 0.5, 0, 0, -5)
            label.Text = labelText .. ": " .. tostring(value) .. (suffix or "")
            callback(value)
        end
    end)

    return { value = value }
end

-- ========== FUNCTIONS ==========
local function setNoclip(state)
    noclipEnabled = state
    if not noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

local function toggleFly(state)
    flyEnabled = state
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1, 1, 1) * 100000
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1, 1, 1) * 100000
        bg.Parent = hrp
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled then
                bv:Destroy(); bg:Destroy(); flyConnection:Disconnect(); return
            end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            bv.Velocity = dir.Unit * flySpeed
            bg.CFrame = cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    end
end

local function applySpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedEnabled and speedValue or 16
    end
end

local function applyJump()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpEnabled and jumpValue or 50
    end
end

local function toggleESP(state)
    espEnabled = state
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local h = Instance.new("Highlight")
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.5
                h.Parent = player.Character
                table.insert(espObjects, h)
            end
        end
        Players.PlayerAdded:Connect(function(player)
            if espEnabled then
                player.CharacterAdded:Connect(function(char)
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                    h.Parent = char
                    table.insert(espObjects, h)
                end)
            end
        end)
    else
        for _, obj in pairs(espObjects) do
            obj:Destroy()
        end
        espObjects = {}
    end
end

local function toggleFullbright(state)
    fullbrightEnabled = state
    if fullbrightEnabled then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    end
end

local function killAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
end

local function toggleAutoKill(state)
    autoKillEnabled = state
    if autoKillEnabled then
        autoKillConnection = RunService.Heartbeat:Connect(function()
            if not autoKillEnabled then autoKillConnection:Disconnect(); return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then hum.Health = 0 end
                end
            end
        end)
    else
        if autoKillConnection then autoKillConnection:Disconnect(); autoKillConnection = nil end
    end
end

local function teleportToPart(partName)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find(partName:lower()) then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                return
            end
        end
    end
end

local function resetChar()
    LocalPlayer.Character = nil
    LocalPlayer.CharacterAdded:Wait()
end

-- Anti-AFK
local function antiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end
antiAFK()

-- Character added events
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    applySpeed()
    applyJump()
end)

-- Noclip loop (handled separately because it needs to run continuously)
local noclipLoop
local function startNoclip()
    if noclipLoop then noclipLoop:Disconnect() end
    noclipLoop = RunService.Heartbeat:Connect(function()
        if noclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)
end
startNoclip()

-- ========== BUILD GUI CONTENT ==========
-- Movement section
local moveLabel = Instance.new("TextLabel")
moveLabel.Size = UDim2.new(1, 0, 0, 25)
moveLabel.Text = "--- MOVEMENT ---"
moveLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
moveLabel.BackgroundTransparency = 1
moveLabel.Font = Enum.Font.GothamBold
moveLabel.TextSize = 14
moveLabel.Parent = Content

local noclipToggle = addToggle("Noclip", false, function(v) setNoclip(v) end)
local flyToggle = addToggle("Fly", false, function(v) toggleFly(v) end)
local flySlider = addSlider("Fly Speed", 10, 500, flySpeed, "", function(v) flySpeed = v end)
local speedToggle = addToggle("Speed Hack", false, function(v) speedEnabled = v; applySpeed() end)
local speedSlider = addSlider("Speed Value", 16, 250, speedValue, "", function(v) speedValue = v; if speedEnabled then applySpeed() end end)
local jumpToggle = addToggle("Jump Hack", false, function(v) jumpEnabled = v; applyJump() end)
local jumpSlider = addSlider("Jump Value", 50, 300, jumpValue, "", function(v) jumpValue = v; if jumpEnabled then applyJump() end end)

-- Teleport section
local teleLabel = Instance.new("TextLabel")
teleLabel.Size = UDim2.new(1, 0, 0, 25)
teleLabel.Text = "--- TELEPORT ---"
teleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
teleLabel.BackgroundTransparency = 1
teleLabel.Font = Enum.Font.GothamBold
teleLabel.TextSize = 14
teleLabel.Parent = Content

local tpButtons = {
    "Red Light Green Light (End)", "Jump Rope (End)", "Tug of War (Win)",
    "Honeycomb (End)", "Glass Bridge (End)", "Mingle (Safe)",
    "Frontman's Office", "VIP Room", "Piggy Bank"
}
for _, name in ipairs(tpButtons) do
    addButton(name, function()
        local search = name:match("(.*) %(") or name
        teleportToPart(search)
    end)
end
addButton("Reset Character", resetChar)

-- Combat section
local combatLabel = Instance.new("TextLabel")
combatLabel.Size = UDim2.new(1, 0, 0, 25)
combatLabel.Text = "--- COMBAT ---"
combatLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
combatLabel.BackgroundTransparency = 1
combatLabel.Font = Enum.Font.GothamBold
combatLabel.TextSize = 14
combatLabel.Parent = Content

addButton("Kill All Players", killAll)
local autoKillToggle = addToggle("Auto Kill (Loop)", false, function(v) toggleAutoKill(v) end)

-- Visuals section
local visLabel = Instance.new("TextLabel")
visLabel.Size = UDim2.new(1, 0, 0, 25)
visLabel.Text = "--- VISUALS ---"
visLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
visLabel.BackgroundTransparency = 1
visLabel.Font = Enum.Font.GothamBold
visLabel.TextSize = 14
visLabel.Parent = Content

local espToggle = addToggle("ESP Players", false, function(v) toggleESP(v) end)
local fullbrightToggle = addToggle("Fullbright", false, function(v) toggleFullbright(v) end)

-- Misc section
local miscLabel = Instance.new("TextLabel")
miscLabel.Size = UDim2.new(1, 0, 0, 25)
miscLabel.Text = "--- MISC ---"
miscLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
miscLabel.BackgroundTransparency = 1
miscLabel.Font = Enum.Font.GothamBold
miscLabel.TextSize = 14
miscLabel.Parent = Content

addButton("Rejoin Game", function()
    TeleportService:Teleport(game.PlaceId)
end)
addButton("Server Hop", function()
    local servers = {}
    local data = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
    local json = HttpService:JSONDecode(data)
    for _, v in pairs(json.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end)

-- Adjust canvas size after building
local function updateCanvas()
    local y = 0
    for _, child in pairs(Content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            y = y + child.Size.Y.Offset + 2
        end
    end
    Content.Size = UDim2.new(1, 0, 0, y + 10)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end
task.wait(0.1)
updateCanvas()

-- Notification
print("🔥 Squid Game X OP Loaded | aGsx-BLACKOBLIVION")