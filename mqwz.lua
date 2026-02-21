local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Settings = {
    Enabled = false,
    FOV = 80,
    Smoothing = 0.15,  -- New: 0.1 = snappy, 0.5 = smooth
    TeamCheck = false,
    KillCheck = true,
    WallCheck = true,
    TargetPart = "Head"
}

-- Optimized FOV Circle (toggle visible, dynamic color)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.8
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Radius = Settings.FOV

-- Optimized GUI: Compact (150x240), modern dark theme, gradients, strokes, English labels, smoother drags/tweens
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OptimizedAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = gethui and gethui() or game:GetService("CoreGui")

-- Toggle Button: Smaller, hover effects, changed to X icon
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "Toggle"
ToggleButton.Size = UDim2.new(0, 42, 0, 42)
ToggleButton.Position = UDim2.new(0, 8, 0, 8)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.Image = "rbxassetid://1249929631"  -- X close icon
ToggleButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.ZIndex = 1000
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleButton

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
ToggleGradient.Rotation = 90
ToggleGradient.Parent = ToggleButton

-- Main Frame: Compact, draggable, minimizable
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 150, 0, 240)
MainFrame.Position = UDim2.new(0, 55, 0, 8)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false  -- Start hidden
MainFrame.ZIndex = 1001
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

-- Title with Minimize
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 32)
Title.Position = UDim2.new(0, 12, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Aimbot v2.0"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.ZIndex = 1002
Title.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(1, -36, 0, 8)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextScaled = true
MinimizeBtn.ZIndex = 1002
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -10, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.ZIndex = 1002
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Content ScrollingFrame for compact fit
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -42)
Scroll.Position = UDim2.new(0, 10, 0, 38)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 280)  -- Adjust as needed
Scroll.ZIndex = 1002
Scroll.Parent = MainFrame

local ScrollList = Instance.new("UIListLayout")
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
ScrollList.Padding = UDim.new(0, 4)
ScrollList.Parent = Scroll

-- Aimbot Toggle (top priority)
local AimbotBtn = Instance.new("TextButton")
AimbotBtn.Size = UDim2.new(1, -12, 0, 28)
AimbotBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimbotBtn.Text = "Aimbot: OFF"
AimbotBtn.Font = Enum.Font.GothamSemibold
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.TextScaled = true
AimbotBtn.LayoutOrder = 1
AimbotBtn.ZIndex = 1003
AimbotBtn.Parent = Scroll

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = AimbotBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(70, 70, 70)
BtnStroke.Thickness = 1
BtnStroke.Parent = AimbotBtn

-- FOV Section: Label + Slider compact
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0, 18)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: 80"
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FOVLabel.TextScaled = true
FOVLabel.LayoutOrder = 2
FOVLabel.ZIndex = 1003
FOVLabel.Parent = Scroll

local FOVSlider = Instance.new("Frame")
FOVSlider.Size = UDim2.new(1, 0, 0, 6)
FOVSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOVSlider.LayoutOrder = 3
FOVSlider.ZIndex = 1003
FOVSlider.Parent = Scroll

local FOVFill = Instance.new("Frame")
FOVFill.Size = UDim2.new(0.4, 0, 1, 0)
FOVFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FOVFill.ZIndex = 1004
FOVFill.Parent = FOVSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = FOVFill

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = FOVSlider

-- Smoothing Slider (new)
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(1, 0, 0, 18)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Smooth: 15%"
SmoothLabel.Font = Enum.Font.Gotham
SmoothLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SmoothLabel.TextScaled = true
SmoothLabel.LayoutOrder = 4
SmoothLabel.ZIndex = 1003
SmoothLabel.Parent = Scroll

local SmoothSlider = Instance.new("Frame")
SmoothSlider.Size = UDim2.new(1, 0, 0, 6)
SmoothSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SmoothSlider.LayoutOrder = 5
SmoothSlider.ZIndex = 1003
SmoothSlider.Parent = Scroll

local SmoothFill = Instance.new("Frame")
SmoothFill.Size = UDim2.new(0.15, 0, 1, 0)
SmoothFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
SmoothFill.ZIndex = 1004
SmoothFill.Parent = SmoothSlider

local SmoothCorner = Instance.new("UICorner")
SmoothCorner.CornerRadius = UDim.new(1, 0)
SmoothCorner.Parent = SmoothSlider

-- Check Toggles: Compact buttons
local function CreateToggle(name, layoutOrder)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -12, 0, 24)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = name .. ": OFF"
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextScaled = true
    Btn.LayoutOrder = layoutOrder
    Btn.ZIndex = 1003
    Btn.Parent = Scroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(65, 65, 65)
    Stroke.Thickness = 1
    Stroke.Parent = Btn
    
    return Btn
end

local TeamBtn = CreateToggle("Team Check", 6)
local KillBtn = CreateToggle("Kill Check", 7)
local WallBtn = CreateToggle("Wall Check", 8)

-- Target Dropdown: Compact
local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(1, -12, 0, 28)
TargetFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TargetFrame.LayoutOrder = 9
TargetFrame.ZIndex = 1003
TargetFrame.Parent = Scroll

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 6)
TargetCorner.Parent = TargetFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.7, 0, 1, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Head ▼"
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetLabel.TextScaled = true
TargetLabel.ZIndex = 1004
TargetLabel.Parent = TargetFrame

local DropdownList = Instance.new("Frame")
DropdownList.Size = UDim2.new(1, 0, 0, 0)
DropdownList.Position = UDim2.new(0, 0, 1, 2)
DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropdownList.Visible = false
DropdownList.ZIndex = 1005
DropdownList.Parent = TargetFrame

local DropListLayout = Instance.new("UIListLayout")
DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropListLayout.Padding = UDim.new(0, 0)
DropListLayout.Parent = DropdownList

local targetParts = {"Head", "HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso"}
local partButtons = {}

-- Keybind Info Label
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(1, -12, 0, 20)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Toggle: RIGHT SHIFT"
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
KeybindLabel.TextScaled = true
KeybindLabel.LayoutOrder = 10
KeybindLabel.ZIndex = 1003
KeybindLabel.Parent = Scroll

-- Functions
local function TweenBtn(btn, enabled)
    local color = enabled and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(45, 45, 45)
    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = color}):Play()
end

local function UpdateFOVLabel()
    FOVLabel.Text = "FOV: " .. math.floor(Settings.FOV)
    FOVCircle.Radius = Settings.FOV
end

local function UpdateSmoothLabel()
    SmoothLabel.Text = "Smooth: " .. math.floor(Settings.Smoothing * 100) .. "%"
end

local draggingFOV, draggingSmooth = false, false

-- Slider Drags (optimized, mobile-friendly)
local function SetupSlider(slider, fill, min, max, callback)
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFOV = (slider == FOVSlider)
            draggingSmooth = (slider == SmoothSlider)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFOV = draggingSmooth = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (draggingFOV and slider == FOVSlider or draggingSmooth and slider == SmoothSlider) and 
           (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = UserInputService:GetMouseLocation().X
            local rel = math.clamp((pos - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = min + (max - min) * rel
            if slider == FOVSlider then
                Settings.FOV = math.clamp(val, 20, 500)
                UpdateFOVLabel()
            else
                Settings.Smoothing = math.clamp(val, 0.05, 1)
                UpdateSmoothLabel()
            end
            callback(val)
        end
    end)
end

SetupSlider(FOVSlider, FOVFill, 20, 500, UpdateFOVLabel)
SetupSlider(SmoothSlider, SmoothFill, 0.05, 1, UpdateSmoothLabel)

-- Toggle Connections
local function ConnectToggle(btn, setting, text)
    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        btn.Text = text .. (Settings[setting] and ": ON" or ": OFF")
        TweenBtn(btn, Settings[setting])
    end)
end

ConnectToggle(AimbotBtn, "Enabled", "Aimbot")
ConnectToggle(TeamBtn, "TeamCheck", "Team Check")
ConnectToggle(KillBtn, "KillCheck", "Kill Check")
ConnectToggle(WallBtn, "WallCheck", "Wall Check")

-- Dropdown
TargetFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        DropdownList.Visible = not DropdownList.Visible
        DropdownList.Size = UDim2.new(1, 0, 0, #targetParts * 20)
    end
end)

for i, part in ipairs(targetParts) do
    local pBtn = Instance.new("TextButton")
    pBtn.Size = UDim2.new(1, 0, 0, 20)
    pBtn.BackgroundTransparency = 1
    pBtn.Text = part
    pBtn.Font = Enum.Font.Gotham
    pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    pBtn.TextScaled = true
    pBtn.ZIndex = 1006
    pBtn.Parent = DropdownList
    
    pBtn.MouseButton1Click:Connect(function()
        Settings.TargetPart = part
        TargetLabel.Text = part .. " ▼"
        DropdownList.Visible = false
    end)
end

-- UI Interactions: Hover/Tween
local hoverColor = Color3.fromRGB(55, 55, 55)
local function AddHover(btn)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play() end)
    btn.MouseLeave:Connect(function() 
        local baseColor = btn.BackgroundColor3 == Color3.fromRGB(0, 160, 0) and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(45, 45, 45)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play() 
    end)
end

for _, b in pairs({AimbotBtn, TeamBtn, KillBtn, WallBtn, TargetFrame}) do AddHover(b) end

-- ToggleButton: Show/Hide MainFrame + Rotate icon (removed rotation since X is symmetric)
local frameVisible = false
ToggleButton.MouseButton1Click:Connect(function()
    frameVisible = not frameVisible
    MainFrame.Visible = frameVisible
    -- Removed rotation tween as X doesn't change with rotation
    -- Instead, optional color change for feedback
    local color = frameVisible and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(200, 200, 200)
    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {ImageColor3 = color}):Play()
end)

AddHover(ToggleButton)

-- Minimize: Collapse Scroll
MinimizeBtn.MouseButton1Click:Connect(function()
    local targetSize = MainFrame.Size.Y.Offset > 50 and UDim2.new(0, 150, 0, 50) or UDim2.new(0, 150, 0, 240)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    Scroll.Visible = MainFrame.Size.Y.Offset > 100
end)

-- Close: Cleanup
CloseBtn.MouseButton1Click:Connect(function()
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

-- Keybind Toggle (RIGHT SHIFT - common for aimbots)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Settings.Enabled = not Settings.Enabled
        AimbotBtn.Text = "Aimbot: " .. (Settings.Enabled and "ON" or "OFF")
        TweenBtn(AimbotBtn, Settings.Enabled)
        -- Visual feedback
        FOVCircle.Visible = Settings.Enabled
        FOVCircle.Color = Settings.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    end
end)

-- FOV Circle Update (optimized)
local updateFOV = TweenInfo.new(0.1)
RunService.Heartbeat:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Main Aimbot Loop (optimized: only runs when enabled, better checks, prediction, raycast)
local connection
local function StartAimbot()
    if connection then connection:Disconnect() end
    connection = RunService.RenderStepped:Connect(function()
        if not Settings.Enabled then return end
        
        local closest, shortest = nil, Settings.FOV
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild(Settings.TargetPart) then continue end
            
            local target = player.Character[Settings.TargetPart]
            if Settings.KillCheck and (player.Character.Humanoid.Health <= 0) then continue end
            if Settings.TeamCheck and (player.Team == LocalPlayer.Team) then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if distance < shortest and onScreen then
                if Settings.WallCheck then
                    local rayOrigin = Camera.CFrame.Position
                    local rayDir = (target.Position - rayOrigin)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    local result = Workspace:Raycast(rayOrigin, rayDir, raycastParams)
                    if result and not result.Instance:IsDescendantOf(player.Character) then continue end
                end
                
                closest = target
                shortest = distance
            end
        end
        
        if closest then
            -- Prediction + Smoothing
            local predictTime = 0.13  -- Adjust for ping
            local velocity = closest.AssemblyLinearVelocity
            local predictedPos = closest.Position + velocity * predictTime
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPos)
            
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothing)
        end
    end)
end

StartAimbot()  -- Init connection (inactive until enabled)

print("Optimized Aimbot loaded! Toggle with RIGHT SHIFT | Drag toggle to show GUI.")
