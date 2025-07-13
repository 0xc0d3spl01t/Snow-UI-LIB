local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SmoothGUI = {}
SmoothGUI.__index = SmoothGUI

-- Modern Color Palette & Styling
local COLORS = {
    -- Glasmorphism Design
    Background = Color3.fromRGB(15, 15, 25),
    Glass = Color3.fromRGB(30, 30, 45),
    Surface = Color3.fromRGB(25, 25, 40),
    Accent = Color3.fromRGB(100, 200, 255),
    AccentHover = Color3.fromRGB(120, 220, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(170, 170, 190),
    TextMuted = Color3.fromRGB(120, 120, 140),
    Success = Color3.fromRGB(100, 220, 140),
    Warning = Color3.fromRGB(255, 200, 100),
    Danger = Color3.fromRGB(255, 120, 120),
    Border = Color3.fromRGB(60, 60, 80),
    Hover = Color3.fromRGB(40, 40, 60),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- Animation Settings
local ANIM = {
    Fast = 0.15,
    Normal = 0.25,
    Slow = 0.4,
    Style = Enum.EasingStyle.Quart,
    Direction = Enum.EasingDirection.Out
}

-- Utility Functions
local function tween(object, properties, duration, style, direction)
    return TweenService:Create(
        object,
        TweenInfo.new(duration or ANIM.Normal, style or ANIM.Style, direction or ANIM.Direction),
        properties
    ):Play()
end

local function createCorner(radius, parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = parent
    return corner
end

local function createPadding(parent, all)
    local padding = Instance.new("UIPadding")
    if type(all) == "number" then
        padding.PaddingTop = UDim.new(0, all)
        padding.PaddingBottom = UDim.new(0, all)
        padding.PaddingLeft = UDim.new(0, all)
        padding.PaddingRight = UDim.new(0, all)
    elseif type(all) == "table" then
        padding.PaddingTop = UDim.new(0, all[1] or 0)
        padding.PaddingRight = UDim.new(0, all[2] or all[1] or 0)
        padding.PaddingBottom = UDim.new(0, all[3] or all[1] or 0)
        padding.PaddingLeft = UDim.new(0, all[4] or all[2] or all[1] or 0)
    end
    padding.Parent = parent
    return padding
end

local function createGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2 or color1)
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

local function createShadow(parent, size, offset, blur)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = parent
    shadow.Size = UDim2.new(1, size or 40, 1, size or 40)
    shadow.Position = UDim2.new(0, -(size or 40)/2 + (offset or 0), 0, -(size or 40)/2 + (offset or 0))
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/Glow.png"
    shadow.ImageColor3 = COLORS.Shadow
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = -1
    return shadow
end

local function createBlur(parent, intensity)
    local blur = Instance.new("Frame")
    blur.Name = "BlurEffect"
    blur.Parent = parent
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = COLORS.Glass
    blur.BackgroundTransparency = 0.7
    blur.BorderSizePixel = 0
    blur.ZIndex = -1
    createCorner(12, blur)
    return blur
end

-- Main GUI Constructor
function SmoothGUI.new(title, size)
    local self = setmetatable({}, SmoothGUI)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SmoothGUI_v2"
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Background Blur Effect
    local backgroundBlur = Instance.new("Frame")
    backgroundBlur.Name = "BackgroundBlur"
    backgroundBlur.Parent = self.ScreenGui
    backgroundBlur.Size = UDim2.new(1, 0, 1, 0)
    backgroundBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backgroundBlur.BackgroundTransparency = 0.8
    backgroundBlur.BorderSizePixel = 0
    backgroundBlur.Visible = false
    
    -- Main Container
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainContainer"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Size = size or UDim2.new(0, 650, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    createCorner(16, self.MainFrame)
    createShadow(self.MainFrame, 60, 8)
    
    -- Glass Effect
    createBlur(self.MainFrame, 0.7)
    
    -- Border Glow
    local borderGlow = Instance.new("UIStroke")
    borderGlow.Color = COLORS.Accent
    borderGlow.Thickness = 1
    borderGlow.Transparency = 0.7
    borderGlow.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Parent = self.MainFrame
    self.TitleBar.Size = UDim2.new(1, 0, 0, 50)
    self.TitleBar.BackgroundColor3 = COLORS.Glass
    self.TitleBar.BackgroundTransparency = 0.3
    self.TitleBar.BorderSizePixel = 0
    createCorner(16, self.TitleBar)
    createGradient(self.TitleBar, COLORS.Accent, Color3.fromRGB(80, 160, 255), 45)
    
    -- Title Bar Bottom Fix
    local titleFix = Instance.new("Frame")
    titleFix.Parent = self.TitleBar
    titleFix.Size = UDim2.new(1, 0, 0, 16)
    titleFix.Position = UDim2.new(0, 0, 1, -16)
    titleFix.BackgroundColor3 = COLORS.Accent
    titleFix.BackgroundTransparency = 0.3
    titleFix.BorderSizePixel = 0
    createGradient(titleFix, COLORS.Accent, Color3.fromRGB(80, 160, 255), 45)
    
    -- Title Text with Icon
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "TitleText"
    self.TitleText.Parent = self.TitleBar
    self.TitleText.Size = UDim2.new(1, -120, 1, 0)
    self.TitleText.Position = UDim2.new(0, 20, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Text = "✨ " .. (title or "Smooth GUI v2.0")
    self.TitleText.TextColor3 = COLORS.Text
    self.TitleText.TextSize = 18
    self.TitleText.Font = Enum.Font.GothamBold
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.TextStrokeTransparency = 0.8
    self.TitleText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    
    -- Control Buttons Container
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Parent = self.TitleBar
    controlsFrame.Size = UDim2.new(0, 90, 0, 30)
    controlsFrame.Position = UDim2.new(1, -110, 0.5, -15)
    controlsFrame.BackgroundTransparency = 1
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.Parent = controlsFrame
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, 8)
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Parent = controlsFrame
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.BackgroundColor3 = COLORS.Warning
    self.MinimizeButton.BackgroundTransparency = 0.2
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Text = "━"
    self.MinimizeButton.TextColor3 = COLORS.Text
    self.MinimizeButton.TextSize = 14
    self.MinimizeButton.Font = Enum.Font.GothamBold
    createCorner(8, self.MinimizeButton)
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Parent = controlsFrame
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.BackgroundColor3 = COLORS.Danger
    self.CloseButton.BackgroundTransparency = 0.2
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "✕"
    self.CloseButton.TextColor3 = COLORS.Text
    self.CloseButton.TextSize = 14
    self.CloseButton.Font = Enum.Font.GothamBold
    createCorner(8, self.CloseButton)
    
    -- Content Container
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Parent = self.MainFrame
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -50)
    self.ContentFrame.Position = UDim2.new(0, 0, 0, 50)
    self.ContentFrame.BackgroundTransparency = 1
    
    -- Sidebar for Tabs
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.Parent = self.ContentFrame
    self.Sidebar.Size = UDim2.new(0, 180, 1, 0)
    self.Sidebar.BackgroundColor3 = COLORS.Surface
    self.Sidebar.BackgroundTransparency = 0.3
    self.Sidebar.BorderSizePixel = 0
    createBlur(self.Sidebar, 0.8)
    
    -- Sidebar Border
    local sidebarBorder = Instance.new("Frame")
    sidebarBorder.Name = "Border"
    sidebarBorder.Parent = self.Sidebar
    sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    sidebarBorder.Position = UDim2.new(1, 0, 0, 0)
    sidebarBorder.BackgroundColor3 = COLORS.Border
    sidebarBorder.BackgroundTransparency = 0.5
    sidebarBorder.BorderSizePixel = 0
    
    -- Tab Container
    self.TabContainer = Instance.new("ScrollingFrame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Parent = self.Sidebar
    self.TabContainer.Size = UDim2.new(1, 0, 1, 0)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.ScrollBarThickness = 4
    self.TabContainer.ScrollBarImageColor3 = COLORS.Accent
    self.TabContainer.ScrollBarImageTransparency = 0.3
    self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    createPadding(self.TabContainer, {15, 10, 15, 15})
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = self.TabContainer
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    
    -- Page Container
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Name = "PageContainer"
    self.PageContainer.Parent = self.ContentFrame
    self.PageContainer.Size = UDim2.new(1, -180, 1, 0)
    self.PageContainer.Position = UDim2.new(0, 180, 0, 0)
    self.PageContainer.BackgroundTransparency = 1
    
    -- Initialize
    self.tabs = {}
    self.currentTab = nil
    self.isMinimized = false
    self.originalSize = self.MainFrame.Size
    
    -- Auto-resize tab container
    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 30)
    end)
    
    -- Connect Events
    self:_connectEvents()
    
    -- Entry Animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.BackgroundTransparency = 1
    tween(self.MainFrame, {
        Size = self.originalSize,
        BackgroundTransparency = 0.1
    }, ANIM.Slow, Enum.EasingStyle.Back)
    
    return self
end

-- Create Tab
function SmoothGUI:CreateTab(name, icon)
    local tab = {
        name = name,
        icon = icon or "📄",
        elements = {},
        isActive = false
    }
    
    -- Tab Button
    tab.button = Instance.new("TextButton")
    tab.button.Name = name .. "Tab"
    tab.button.Parent = self.TabContainer
    tab.button.Size = UDim2.new(1, 0, 0, 45)
    tab.button.BackgroundColor3 = COLORS.Surface
    tab.button.BackgroundTransparency = 0.5
    tab.button.BorderSizePixel = 0
    tab.button.Text = ""
    createCorner(12, tab.button)
    
    -- Tab Content
    local tabContent = Instance.new("Frame")
    tabContent.Name = "Content"
    tabContent.Parent = tab.button
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    createPadding(tabContent, {0, 15, 0, 15})
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabContent
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 12)
    
    -- Tab Icon
    local tabIcon = Instance.new("TextLabel")
    tabIcon.Name = "Icon"
    tabIcon.Parent = tabContent
    tabIcon.Size = UDim2.new(0, 25, 0, 25)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Text = tab.icon
    tabIcon.TextColor3 = COLORS.TextSecondary
    tabIcon.TextSize = 18
    tabIcon.Font = Enum.Font.Gotham
    
    -- Tab Label
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.Parent = tabContent
    tabLabel.Size = UDim2.new(1, -37, 1, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = COLORS.TextSecondary
    tabLabel.TextSize = 14
    tabLabel.Font = Enum.Font.GothamSemibold
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Tab Page
    tab.page = Instance.new("ScrollingFrame")
    tab.page.Name = name .. "Page"
    tab.page.Parent = self.PageContainer
    tab.page.Size = UDim2.new(1, 0, 1, 0)
    tab.page.BackgroundTransparency = 1
    tab.page.BorderSizePixel = 0
    tab.page.ScrollBarThickness = 6
    tab.page.ScrollBarImageColor3 = COLORS.Accent
    tab.page.ScrollBarImageTransparency = 0.3
    tab.page.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.page.Visible = false
    createPadding(tab.page, 20)
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = tab.page
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 12)
    
    -- Auto-resize page
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
    end)
    
    -- Tab Interactions
    tab.button.MouseEnter:Connect(function()
        if not tab.isActive then
            tween(tab.button, {BackgroundTransparency = 0.3}, ANIM.Fast)
            tween(tabIcon, {TextColor3 = COLORS.Text}, ANIM.Fast)
            tween(tabLabel, {TextColor3 = COLORS.Text}, ANIM.Fast)
        end
    end)
    
    tab.button.MouseLeave:Connect(function()
        if not tab.isActive then
            tween(tab.button, {BackgroundTransparency = 0.5}, ANIM.Fast)
            tween(tabIcon, {TextColor3 = COLORS.TextSecondary}, ANIM.Fast)
            tween(tabLabel, {TextColor3 = COLORS.TextSecondary}, ANIM.Fast)
        end
    end)
    
    tab.button.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)
    
    -- Store references
    tab.icon_obj = tabIcon
    tab.label_obj = tabLabel
    
    table.insert(self.tabs, tab)
    
    -- Select first tab
    if #self.tabs == 1 then
        self:_selectTab(tab)
    end
    
    return tab
end

-- Create Toggle
function SmoothGUI:CreateToggle(tab, text, default, callback)
    local toggle = {
        enabled = default or false,
        callback = callback or function() end
    }
    
    local container = Instance.new("Frame")
    container.Name = "ToggleContainer"
    container.Parent = tab.page
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = COLORS.Glass
    container.BackgroundTransparency = 0.4
    container.BorderSizePixel = 0
    createCorner(12, container)
    createBlur(container, 0.8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    createPadding(container, {15, 20, 15, 20})
    
    -- Toggle Label
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(1, -70, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle Switch Background
    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBackground"
    switchBg.Parent = container
    switchBg.Size = UDim2.new(0, 50, 0, 24)
    switchBg.Position = UDim2.new(1, -50, 0.5, -12)
    switchBg.BackgroundColor3 = toggle.enabled and COLORS.Accent or COLORS.TextMuted
    switchBg.BackgroundTransparency = 0.2
    switchBg.BorderSizePixel = 0
    createCorner(12, switchBg)
    
    -- Toggle Knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = switchBg
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = toggle.enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = COLORS.Text
    knob.BorderSizePixel = 0
    createCorner(10, knob)
    createShadow(knob, 20, 2)
    
    -- Click Handler
    local clickArea = Instance.new("TextButton")
    clickArea.Parent = container
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    
    clickArea.MouseButton1Click:Connect(function()
        toggle.enabled = not toggle.enabled
        
        local bgColor = toggle.enabled and COLORS.Accent or COLORS.TextMuted
        local knobPos = toggle.enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        
        tween(switchBg, {BackgroundColor3 = bgColor}, ANIM.Fast)
        tween(knob, {Position = knobPos}, ANIM.Normal, Enum.EasingStyle.Back)
        
        toggle.callback(toggle.enabled)
    end)
    
    -- Hover Effects
    clickArea.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, ANIM.Fast)
        tween(stroke, {Transparency = 0.3}, ANIM.Fast)
    end)
    
    clickArea.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.4}, ANIM.Fast)
        tween(stroke, {Transparency = 0.6}, ANIM.Fast)
    end)
    
    table.insert(tab.elements, toggle)
    return toggle
end

-- Create Button
function SmoothGUI:CreateButton(tab, text, callback)
    local button = {
        callback = callback or function() end
    }
    
    local container = Instance.new("TextButton")
    container.Name = "ButtonContainer"
    container.Parent = tab.page
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundColor3 = COLORS.Accent
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Text = ""
    createCorner(12, container)
    createGradient(container, COLORS.Accent, COLORS.AccentHover, 45)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = container
    
    -- Button Text
    local buttonText = Instance.new("TextLabel")
    buttonText.Parent = container
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = text
    buttonText.TextColor3 = COLORS.Text
    buttonText.TextSize = 14
    buttonText.Font = Enum.Font.GothamSemibold
    buttonText.TextStrokeTransparency = 0.8
    
    container.MouseButton1Click:Connect(function()
        -- Click animation
        tween(container, {Size = UDim2.new(1, -4, 0, 41)}, ANIM.Fast)
        wait(ANIM.Fast)
        tween(container, {Size = UDim2.new(1, 0, 0, 45)}, ANIM.Fast)
        
        button.callback()
    end)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.05}, ANIM.Fast)
        tween(stroke, {Transparency = 0.2}, ANIM.Fast)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.1}, ANIM.Fast)
        tween(stroke, {Transparency = 0.5}, ANIM.Fast)
    end)
    
    table.insert(tab.elements, button)
    return button
end

-- Create Dropdown
function SmoothGUI:CreateDropdown(tab, text, options, default, callback)
    local dropdown = {
        options = options or {},
        selected = default or (options and options[1]) or "None",
        callback = callback or function() end,
        isOpen = false
    }
    
    local container = Instance.new("Frame")
    container.Name = "DropdownContainer"
    container.Parent = tab.page
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = COLORS.Glass
    container.BackgroundTransparency = 0.4
    container.BorderSizePixel = 0
    createCorner(12, container)
    createBlur(container, 0.8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    createPadding(container, {15, 20, 15, 20})
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Dropdown Button
    local dropButton = Instance.new("TextButton")
    dropButton.Parent = container
    dropButton.Size = UDim2.new(0.6, -10, 1, -10)
    dropButton.Position = UDim2.new(0.4, 0, 0, 5)
    dropButton.BackgroundColor3 = COLORS.Surface
    dropButton.BackgroundTransparency = 0.3
    dropButton.BorderSizePixel = 0
    dropButton.Text = dropdown.selected .. " ▼"
    dropButton.TextColor3 = COLORS.Text
    dropButton.TextSize = 12
    dropButton.Font = Enum.Font.Gotham
    createCorner(8, dropButton)
    
    -- Options List
    local optionsList = Instance.new("Frame")
    optionsList.Name = "OptionsList"
    optionsList.Parent = container
    optionsList.Size = UDim2.new(0.6, -10, 0, 0)
    optionsList.Position = UDim2.new(0.4, 0, 1, 5)
    optionsList.BackgroundColor3 = COLORS.Surface
    optionsList.BackgroundTransparency = 0.1
    optionsList.BorderSizePixel = 0
    optionsList.Visible = false
    optionsList.ZIndex = 10
    createCorner(8, optionsList)
    createBlur(optionsList, 0.9)
    
    local optionsStroke = Instance.new("UIStroke")
    optionsStroke.Color = COLORS.Border
    optionsStroke.Thickness = 1
    optionsStroke.Transparency = 0.4
    optionsStroke.Parent = optionsList
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = optionsList
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Create options
    for i, option in ipairs(dropdown.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option" .. i
        optionButton.Parent = optionsList
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = COLORS.Surface
        optionButton.BackgroundTransparency = 1
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = COLORS.Text
        optionButton.TextSize = 11
        optionButton.Font = Enum.Font.Gotham
        createPadding(optionButton, {0, 10, 0, 10})
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.selected = option
            dropButton.Text = option .. " ▼"
            dropdown.isOpen = false
            
            tween(optionsList, {Size = UDim2.new(0.6, -10, 0, 0)}, ANIM.Fast)
            wait(ANIM.Fast)
            optionsList.Visible = false
            
            dropdown.callback(option)
        end)
        
        optionButton.MouseEnter:Connect(function()
            tween(optionButton, {BackgroundTransparency = 0.7}, ANIM.Fast)
        end)
        
        optionButton.MouseLeave:Connect(function()
            tween(optionButton, {BackgroundTransparency = 1}, ANIM.Fast)
        end)
    end
    
    dropButton.MouseButton1Click:Connect(function()
        dropdown.isOpen = not dropdown.isOpen
        
        if dropdown.isOpen then
            optionsList.Visible = true
            local targetHeight = #dropdown.options * 30
            tween(optionsList, {Size = UDim2.new(0.6, -10, 0, targetHeight)}, ANIM.Normal)
            dropButton.Text = dropdown.selected .. " ▲"
        else
            tween(optionsList, {Size = UDim2.new(0.6, -10, 0, 0)}, ANIM.Normal)
            dropButton.Text = dropdown.selected .. " ▼"
            wait(ANIM.Normal)
            optionsList.Visible = false
        end
    end)
    
    dropButton.MouseEnter:Connect(function()
        tween(dropButton, {BackgroundTransparency = 0.1}, ANIM.Fast)
    end)
    
    dropButton.MouseLeave:Connect(function()
        tween(dropButton, {BackgroundTransparency = 0.3}, ANIM.Fast)
    end)
    
    table.insert(tab.elements, dropdown)
    return dropdown
end

-- Create Slider
function SmoothGUI:CreateSlider(tab, text, min, max, default, callback)
    local slider = {
        min = min or 0,
        max = max or 100,
        value = default or min or 0,
        callback = callback or function() end,
        dragging = false
    }
    
    local container = Instance.new("Frame")
    container.Name = "SliderContainer"
    container.Parent = tab.page
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = COLORS.Glass
    container.BackgroundTransparency = 0.4
    container.BorderSizePixel = 0
    createCorner(12, container)
    createBlur(container, 0.8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    createPadding(container, {15, 20, 15, 20})
    
    -- Header
    local header = Instance.new("Frame")
    header.Parent = container
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = header
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = header
    valueLabel.Size = UDim2.new(0, 60, 1, 0)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(slider.value)
    valueLabel.TextColor3 = COLORS.Accent
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Slider Track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Parent = container
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 1, -15)
    track.BackgroundColor3 = COLORS.Surface
    track.BackgroundTransparency = 0.3
    track.BorderSizePixel = 0
    createCorner(3, track)
    
    -- Slider Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = track
    fill.Size = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.BackgroundTransparency = 0.2
    fill.BorderSizePixel = 0
    createCorner(3, fill)
    createGradient(fill, COLORS.Accent, COLORS.AccentHover, 0)
    
    -- Slider Knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = track
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), -8, 0.5, -8)
    knob.BackgroundColor3 = COLORS.Text
    knob.BorderSizePixel = 0
    createCorner(8, knob)
    createShadow(knob, 20, 2)
    
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = COLORS.Accent
    knobStroke.Thickness = 2
    knobStroke.Transparency = 0.3
    knobStroke.Parent = knob
    
    -- Click Handler
    local clickArea = Instance.new("TextButton")
    clickArea.Parent = track
    clickArea.Size = UDim2.new(1, 0, 1, 20)
    clickArea.Position = UDim2.new(0, 0, 0, -10)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        slider.value = math.floor(slider.min + (slider.max - slider.min) * percentage)
        
        valueLabel.Text = tostring(slider.value)
        tween(fill, {Size = UDim2.new(percentage, 0, 1, 0)}, ANIM.Fast)
        tween(knob, {Position = UDim2.new(percentage, -8, 0.5, -8)}, ANIM.Fast)
        
        slider.callback(slider.value)
    end
    
    clickArea.MouseButton1Down:Connect(function()
        slider.dragging = true
        tween(knob, {Size = UDim2.new(0, 20, 0, 20)}, ANIM.Fast)
        tween(knobStroke, {Transparency = 0.1}, ANIM.Fast)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if slider.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and slider.dragging then
            slider.dragging = false
            tween(knob, {Size = UDim2.new(0, 16, 0, 16)}, ANIM.Fast)
            tween(knobStroke, {Transparency = 0.3}, ANIM.Fast)
        end
    end)
    
    clickArea.MouseButton1Click:Connect(function()
        updateSlider(UserInputService:GetMouseLocation())
    end)
    
    table.insert(tab.elements, slider)
    return slider
end

-- Create Input
function SmoothGUI:CreateInput(tab, text, placeholder, callback)
    local input = {
        value = "",
        callback = callback or function() end
    }
    
    local container = Instance.new("Frame")
    container.Name = "InputContainer"
    container.Parent = tab.page
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = COLORS.Glass
    container.BackgroundTransparency = 0.4
    container.BorderSizePixel = 0
    createCorner(12, container)
    createBlur(container, 0.8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = container
    
    createPadding(container, {15, 20, 15, 20})
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.Text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Input Box
    local inputBox = Instance.new("TextBox")
    inputBox.Parent = container
    inputBox.Size = UDim2.new(0.7, -10, 1, -10)
    inputBox.Position = UDim2.new(0.3, 0, 0, 5)
    inputBox.BackgroundColor3 = COLORS.Surface
    inputBox.BackgroundTransparency = 0.3
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or "Enter text..."
    inputBox.TextColor3 = COLORS.Text
    inputBox.PlaceholderColor3 = COLORS.TextMuted
    inputBox.TextSize = 12
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = false
    createCorner(8, inputBox)
    createPadding(inputBox, 10)
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = COLORS.Border
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.6
    inputStroke.Parent = inputBox
    
    inputBox.Focused:Connect(function()
        tween(inputStroke, {Color = COLORS.Accent, Transparency = 0.3}, ANIM.Fast)
        tween(inputBox, {BackgroundTransparency = 0.1}, ANIM.Fast)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        tween(inputStroke, {Color = COLORS.Border, Transparency = 0.6}, ANIM.Fast)
        tween(inputBox, {BackgroundTransparency = 0.3}, ANIM.Fast)
        
        input.value = inputBox.Text
        input.callback(input.value, enterPressed)
    end)
    
    table.insert(tab.elements, input)
    return input
end

-- Create Label
function SmoothGUI:CreateLabel(tab, text, size)
    local label = {}
    
    local container = Instance.new("TextLabel")
    container.Name = "LabelContainer"
    container.Parent = tab.page
    container.Size = UDim2.new(1, 0, 0, size or 30)
    container.BackgroundTransparency = 1
    container.Text = text
    container.TextColor3 = COLORS.Text
    container.TextSize = 14
    container.Font = Enum.Font.Gotham
    container.TextXAlignment = Enum.TextXAlignment.Left
    container.TextWrapped = true
    createPadding(container, {5, 10, 5, 10})
    
    label.SetText = function(newText)
        container.Text = newText
    end
    
    table.insert(tab.elements, label)
    return label
end

-- Private Methods
function SmoothGUI:_selectTab(tab)
    -- Deselect current tab
    if self.currentTab then
        self.currentTab.isActive = false
        tween(self.currentTab.button, {BackgroundTransparency = 0.5}, ANIM.Fast)
        tween(self.currentTab.icon_obj, {TextColor3 = COLORS.TextSecondary}, ANIM.Fast)
        tween(self.currentTab.label_obj, {TextColor3 = COLORS.TextSecondary}, ANIM.Fast)
        self.currentTab.page.Visible = false
    end
    
    -- Select new tab
    self.currentTab = tab
    tab.isActive = true
    tween(tab.button, {BackgroundTransparency = 0.1}, ANIM.Fast)
    tween(tab.icon_obj, {TextColor3 = COLORS.Accent}, ANIM.Fast)
    tween(tab.label_obj, {TextColor3 = COLORS.Text}, ANIM.Fast)
    tab.page.Visible = true
    
    -- Add accent border to active tab
    local activeStroke = tab.button:FindFirstChild("UIStroke")
    if not activeStroke then
        activeStroke = Instance.new("UIStroke")
        activeStroke.Color = COLORS.Accent
        activeStroke.Thickness = 1
        activeStroke.Transparency = 0.5
        activeStroke.Parent = tab.button
    end
end

function SmoothGUI:_connectEvents()
    -- Close button
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Minimize button
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Control button hover effects
    self.CloseButton.MouseEnter:Connect(function()
        tween(self.CloseButton, {BackgroundTransparency = 0.05}, ANIM.Fast)
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        tween(self.CloseButton, {BackgroundTransparency = 0.2}, ANIM.Fast)
    end)
    
    self.MinimizeButton.MouseEnter:Connect(function()
        tween(self.MinimizeButton, {BackgroundTransparency = 0.05}, ANIM.Fast)
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        tween(self.MinimizeButton, {BackgroundTransparency = 0.2}, ANIM.Fast)
    end)
end

-- Public Methods
function SmoothGUI:ToggleMinimize()
    self.isMinimized = not self.isMinimized
    
    if self.isMinimized then
        tween(self.MainFrame, {Size = UDim2.new(0, self.originalSize.X.Offset, 0, 50)}, ANIM.Normal)
        self.MinimizeButton.Text = "□"
    else
        tween(self.MainFrame, {Size = self.originalSize}, ANIM.Normal)
        self.MinimizeButton.Text = "━"
    end
end

function SmoothGUI:SetVisible(visible)
    self.ScreenGui.Enabled = visible
end

function SmoothGUI:Destroy()
    tween(self.MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, ANIM.Slow, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    wait(ANIM.Slow)
    self.ScreenGui:Destroy()
end

return SmoothGUI
