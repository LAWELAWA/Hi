-- aGsx-BLACKOBLIVION | Squid Game X OP (Mobile-Fixed GUI)
-- Paste this directly into your executor

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
ToggleCircle.Size = UDim2.new(0, 55, 0, 55)
ToggleCircle.Position = UDim2.new(0.85, -27, 0.9, -27)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ToggleCircle.BackgroundTransparency = 0.2
ToggleCircle.BorderColor3 = Color3.fromRGB(0, 255, 0)
ToggleCircle.BorderSizePixel = 2
ToggleCircle.Draggable = true
ToggleCircle.Active = true
ToggleCircle.Visible = true
ToggleCircle.ZIndex = 10
ToggleCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = ToggleCircle

local CircleLabel = Instance.new("TextLabel")
CircleLabel.Size = UDim2.new(1, 0, 1, 0)
CircleLabel.Text = "⚡"
CircleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleLabel.BackgroundTransparency = 1
CircleLabel.Font = Enum.Font.GothamBold
CircleLabel.TextSize = 28
CircleLabel.Parent = ToggleCircle

local pulse = TweenService:Create(ToggleCircle, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.05})
pulse:Play()

-- ========== MAIN FRAME ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.Text = "⚡ Squid Game X"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = TitleBar

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

-- Toggle circle click
ToggleCircle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleCircle.Visible = not MainFrame.Visible
end)

-- ========== SCROLLING FRAME ==========
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

-- Helper functions
local function addToggle(text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundTransparency = 1
    f.Parent = Content

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 180, 0, 30)
    l.Position = UDim2.new(0, 0, 0, 0)
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 50, 0, 25)
    b.Position = UDim2.new(1, -55, 0, 2)
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.BorderColor3 = Color3.fromRGB(0, 255, 0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = f

    local s = default
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = s and "ON" or "OFF"
        b.TextColor3 = s and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(s)
    end)
end

local function addButton(text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 35)
    f.BackgroundTransparency = 1
    f.Parent = Content

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Position = UDim2.new(0, 5, 0, 2)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(0, 255, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.BorderColor3 = Color3.fromRGB(0, 255, 0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = f
    b.MouseButton1Click:Connect(callback)
end

local function addSlider(text, min, max, default, suffix, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 45)
    f.BackgroundTransparency = 1
    f.Parent = Content

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.Position = UDim2.new(0, 0, 0, 0)
    l.Text = text .. ": " .. tostring(default) .. (suffix or "")
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.Parent = f

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 6)
    bg.Position = UDim2.new(0, 10, 0, 25)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bg.BorderSizePixel = 0
    bg.Parent = f

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 16, 0, 16)
    drag.Position = UDim2.new(fill.Size.X.Scale - 0.5, 0, 0, -5)
    drag.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    drag.BorderSizePixel = 0
    drag.Text = ""
    drag.BackgroundTransparency = 0.2
    drag.Parent = bg

    local val = default
    local dragging = false

    drag.MouseButton1Down:Connect(function() dragging = true end)
    drag.MouseButton1Up:Connect(function() dragging = false end)
    drag.MouseLeave:Connect(function() dragging = false end)

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position.X - bg.AbsolutePosition.X
            local ratio = math.clamp(pos / bg.AbsoluteSize.X, 0, 1)
            val = min + ratio * (max - min)
            val = math.round(val / 1) * 1
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            drag.Position = UDim2.new(ratio - 0.5, 0, 0, -5)
            l.Text = text .. ": " .. tostring(val) .. (suffix or "")
            callback(val)
        end
    end)

    bg.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local pos = input.Position.X - bg.AbsolutePosition.X
            local ratio = math.clamp(pos / bg.AbsoluteSize.X, 0, 1)
            val = min + ratio * (max - min)
            val = math.round(val / 1) * 1
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            drag.Position = UDim2.new(ratio - 0.5, 0, 0, -5)
            l.Text = text .. ": " .. tostring(val) .. (suffix or "")
            callback(val)
        end
    end)
end

-- ========== FUNCTIONS ==========
local function setNoclip(s)
    noclipEnabled = s
end

local function toggleFly(s)
    flyEnabled = s
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

local function toggleESP(s)
    espEnabled = s
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = Instance.new("Highlight")
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.5
                h.Parent = p.Character
                table.insert(espObjects, h)
            end
        end
    else
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
    end
end

local function toggleFullbright(s)
    fullbrightEnabled = s
    if fullbrightEnabled then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    end
end

local function killAll()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("Humanoid")
            if h then h.Health = 0 end
        end
    end
end

local function toggleAutoKill(s)
    autoKillEnabled = s
    if autoKillEnabled then
        autoKillConnection = RunService.Heartbeat:Connect(function()
            if not autoKillEnabled then autoKillConnection:Disconnect(); return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("Humanoid")
                    if h and h.Health > 0 then h.Health = 0 end
                end
            end
        end)
    else
        if autoKillConnection then autoKillConnection:Disconnect(); autoKillConnection = nil end
    end
end

local function tpPart(name)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find(name:lower()) then
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

-- Character events
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    applySpeed()
    applyJump()
end)

-- Noclip loop
local noclipLoop
local function startNoclip()
    if noclipLoop then noclipLoop:Disconnect() end
    noclipLoop = RunService.Heartbeat:Connect(function()
        if noclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end
    end)
end
startNoclip()

-- ========== BUILD GUI ==========
local function addSection(text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 25)
    l.Text = "--- " .. text .. " ---"
    l.TextColor3 = color or Color3.fromRGB(0, 255, 0)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.Parent = Content
end

addSection("MOVEMENT", Color3.fromRGB(0, 255, 0))
addToggle("Noclip", false, setNoclip)
addToggle("Fly", false, toggleFly)
addSlider("Fly Speed", 10, 500, flySpeed, "", function(v) flySpeed = v end)
addToggle("Speed Hack", false, function(v) speedEnabled = v; applySpeed() end)
addSlider("Speed Value", 16, 250, speedValue, "", function(v) speedValue = v; if speedEnabled then applySpeed() end end)
addToggle("Jump Hack", false, function(v) jumpEnabled = v; applyJump() end)
addSlider("Jump Value", 50, 300, jumpValue, "", function(v) jumpValue = v; if jumpEnabled then applyJump() end end)

addSection("TELEPORT", Color3.fromRGB(0, 255, 255))
local tps = {"Red Light Green Light", "Jump Rope", "Tug of War", "Honeycomb", "Glass Bridge", "Mingle", "Frontman Office", "VIP Room", "Piggy Bank"}
for _, name in ipairs(tps) do
    addButton(name, function() tpPart(name) end)
end
addButton("Reset Character", resetChar)

addSection("COMBAT", Color3.fromRGB(255, 0, 0))
addButton("Kill All Players", killAll)
addToggle("Auto Kill (Loop)", false, toggleAutoKill)

addSection("VISUALS", Color3.fromRGB(0, 255, 255))
addToggle("ESP Players", false, toggleESP)
addToggle("Fullbright", false, toggleFullbright)

addSection("MISC", Color3.fromRGB(255, 255, 0))
addButton("Rejoin Game", function() TeleportService:Teleport(game.PlaceId) end)
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

-- Update canvas
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

-- Show main frame initially
MainFrame.Visible = true
ToggleCircle.Visible = false

print("🔥 Squid Game X OP Loaded | aGsx-BLACKOBLIVION")