local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SmoothGUI = {}
SmoothGUI.__index = SmoothGUI

-- Animations & Styling
local ANIMATION_TIME = 0.3
local EASE_STYLE = Enum.EasingStyle.Quart
local EASE_DIRECTION = Enum.EasingDirection.Out

local COLORS = {
    Background = Color3.fromRGB(25, 25, 35),
    Surface = Color3.fromRGB(35, 35, 50),
    Primary = Color3.fromRGB(70, 130, 250),
    Secondary = Color3.fromRGB(120, 120, 140),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(70, 200, 120),
    Warning = Color3.fromRGB(255, 180, 70),
    Danger = Color3.fromRGB(255, 100, 100),
    Border = Color3.fromRGB(50, 50, 70),
    Hover = Color3.fromRGB(45, 45, 65)
}

-- Utility Functions
local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function createPadding(all)
    local padding = Instance.new("UIPadding")
    if type(all) == "number" then
        padding.PaddingTop = UDim.new(0, all)
        padding.PaddingBottom = UDim.new(0, all)
        padding.PaddingLeft = UDim.new(0, all)
        padding.PaddingRight = UDim.new(0, all)
    elseif type(all) == "table" then
        padding.PaddingTop = UDim.new(0, all.Top or all[1] or 0)
        padding.PaddingBottom = UDim.new(0, all.Bottom or all[3] or all[1] or 0)
        padding.PaddingLeft = UDim.new(0, all.Left or all[4] or all[2] or all[1] or 0)
        padding.PaddingRight = UDim.new(0, all.Right or all[2] or all[1] or 0)
    end
    return padding
end

local function animateProperty(object, property, targetValue, duration, style, direction)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or ANIMATION_TIME, style or EASE_STYLE, direction or EASE_DIRECTION),
        {[property] = targetValue}
    )
    tween:Play()
    return tween
end

local function animateMultiple(object, properties, duration, style, direction)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or ANIMATION_TIME, style or EASE_STYLE, direction or EASE_DIRECTION),
        properties
    )
    tween:Play()
    return tween
end

-- Main GUI Constructor
function SmoothGUI.new(title, size)
    local self = setmetatable({}, SmoothGUI)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SmoothGUI"
    self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Size = size or UDim2.new(0, 600, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    createCorner(12).Parent = self.MainFrame
    
    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = self.MainFrame
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/Glow.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = -1
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Parent = self.MainFrame
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = COLORS.Surface
    self.TitleBar.BorderSizePixel = 0
    createCorner(12).Parent = self.TitleBar
    
    -- Title corner fix
    local titleCornerFix = Instance.new("Frame")
    titleCornerFix.Name = "CornerFix"
    titleCornerFix.Parent = self.TitleBar
    titleCornerFix.Size = UDim2.new(1, 0, 0, 12)
    titleCornerFix.Position = UDim2.new(0, 0, 1, -12)
    titleCornerFix.BackgroundColor3 = COLORS.Surface
    titleCornerFix.BorderSizePixel = 0
    
    -- Title Text
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "TitleText"
    self.TitleText.Parent = self.TitleBar
    self.TitleText.Size = UDim2.new(1, -80, 1, 0)
    self.TitleText.Position = UDim2.new(0, 15, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Text = title or "Smooth GUI"
    self.TitleText.TextColor3 = COLORS.Text
    self.TitleText.TextSize = 16
    self.TitleText.Font = Enum.Font.GothamSemibold
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Parent = self.TitleBar
    self.CloseButton.Size = UDim2.new(0, 30, 0, 30)
    self.CloseButton.Position = UDim2.new(1, -35, 0, 5)
    self.CloseButton.BackgroundColor3 = COLORS.Danger
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = COLORS.Text
    self.CloseButton.TextSize = 18
    self.CloseButton.Font = Enum.Font.GothamBold
    createCorner(6).Parent = self.CloseButton
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Parent = self.TitleBar
    self.MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    self.MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
    self.MinimizeButton.BackgroundColor3 = COLORS.Warning
    self.MinimizeButton.BorderSizePixel = 0
    self.MinimizeButton.Text = "−"
    self.MinimizeButton.TextColor3 = COLORS.Text
    self.MinimizeButton.TextSize = 18
    self.MinimizeButton.Font = Enum.Font.GothamBold
    createCorner(6).Parent = self.MinimizeButton
    
    -- Content Area
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Parent = self.MainFrame
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    self.ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    self.ContentFrame.BackgroundTransparency = 1
    
    -- Tab System
    self.TabFrame = Instance.new("Frame")
    self.TabFrame.Name = "TabFrame"
    self.TabFrame.Parent = self.ContentFrame
    self.TabFrame.Size = UDim2.new(0, 150, 1, 0)
    self.TabFrame.Position = UDim2.new(0, 0, 0, 0)
    self.TabFrame.BackgroundColor3 = COLORS.Surface
    self.TabFrame.BorderSizePixel = 0
    
    local tabCorner = createCorner(0)
    tabCorner.Parent = self.TabFrame
    
    -- Tab corner fix
    local tabCornerFix = Instance.new("Frame")
    tabCornerFix.Name = "CornerFix"
    tabCornerFix.Parent = self.TabFrame
    tabCornerFix.Size = UDim2.new(0, 12, 1, 0)
    tabCornerFix.Position = UDim2.new(1, -12, 0, 0)
    tabCornerFix.BackgroundColor3 = COLORS.Surface
    tabCornerFix.BorderSizePixel = 0
    
    -- Tab List
    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Name = "TabList"
    self.TabList.Parent = self.TabFrame
    self.TabList.Size = UDim2.new(1, 0, 1, 0)
    self.TabList.Position = UDim2.new(0, 0, 0, 0)
    self.TabList.BackgroundTransparency = 1
    self.TabList.BorderSizePixel = 0
    self.TabList.ScrollBarThickness = 4
    self.TabList.ScrollBarImageColor3 = COLORS.Primary
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    createPadding(10).Parent = self.TabList
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Parent = self.TabList
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    
    -- Content Pages
    self.PageFrame = Instance.new("Frame")
    self.PageFrame.Name = "PageFrame"
    self.PageFrame.Parent = self.ContentFrame
    self.PageFrame.Size = UDim2.new(1, -150, 1, 0)
    self.PageFrame.Position = UDim2.new(0, 150, 0, 0)
    self.PageFrame.BackgroundTransparency = 1
    
    -- Initialize
    self.tabs = {}
    self.currentTab = nil
    self.isMinimized = false
    self.originalSize = self.MainFrame.Size
    
    -- Connect Events
    self:_connectEvents()
    
    -- Initial Animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    animateProperty(self.MainFrame, "Size", self.originalSize, 0.5, Enum.EasingStyle.Back)
    
    return self
end

-- Tab Creation
function SmoothGUI:CreateTab(name, icon)
    local tab = {
        name = name,
        icon = icon,
        elements = {}
    }
    
    -- Tab Button
    tab.button = Instance.new("TextButton")
    tab.button.Name = name .. "Tab"
    tab.button.Parent = self.TabList
    tab.button.Size = UDim2.new(1, 0, 0, 35)
    tab.button.BackgroundColor3 = COLORS.Background
    tab.button.BorderSizePixel = 0
    tab.button.Text = (icon and icon .. " " or "") .. name
    tab.button.TextColor3 = COLORS.TextSecondary
    tab.button.TextSize = 14
    tab.button.Font = Enum.Font.Gotham
    tab.button.TextXAlignment = Enum.TextXAlignment.Left
    createCorner(6).Parent = tab.button
    createPadding(10).Parent = tab.button
    
    -- Tab Page
    tab.page = Instance.new("ScrollingFrame")
    tab.page.Name = name .. "Page"
    tab.page.Parent = self.PageFrame
    tab.page.Size = UDim2.new(1, 0, 1, 0)
    tab.page.Position = UDim2.new(0, 0, 0, 0)
    tab.page.BackgroundTransparency = 1
    tab.page.BorderSizePixel = 0
    tab.page.ScrollBarThickness = 4
    tab.page.ScrollBarImageColor3 = COLORS.Primary
    tab.page.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.page.Visible = false
    createPadding(15).Parent = tab.page
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = tab.page
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    
    -- Auto-resize canvas
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 30)
    end)
    
    -- Tab Button Hover Effect
    tab.button.MouseEnter:Connect(function()
        if self.currentTab ~= tab then
            animateProperty(tab.button, "BackgroundColor3", COLORS.Hover)
        end
    end)
    
    tab.button.MouseLeave:Connect(function()
        if self.currentTab ~= tab then
            animateProperty(tab.button, "BackgroundColor3", COLORS.Background)
        end
    end)
    
    -- Tab Button Click
    tab.button.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)
    
    table.insert(self.tabs, tab)
    
    -- Auto-select first tab
    if #self.tabs == 1 then
        self:_selectTab(tab)
    end
    
    -- Update tab list canvas size
    self.TabList.CanvasSize = UDim2.new(0, 0, 0, #self.tabs * 40 + 20)
    
    return tab
end

-- Toggle Creation
function SmoothGUI:CreateToggle(tab, text, default, callback)
    local toggle = {
        enabled = default or false,
        callback = callback or function() end
    }
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Parent = tab.page
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = COLORS.Surface
    toggleFrame.BorderSizePixel = 0
    createCorner(8).Parent = toggleFrame
    createPadding(15).Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Parent = toggleFrame
    toggleLabel.Size = UDim2.new(1, -60, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = COLORS.Text
    toggleLabel.TextSize = 14
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Name = "Switch"
    toggleSwitch.Parent = toggleFrame
    toggleSwitch.Size = UDim2.new(0, 45, 0, 20)
    toggleSwitch.Position = UDim2.new(1, -45, 0.5, -10)
    toggleSwitch.BackgroundColor3 = toggle.enabled and COLORS.Primary or COLORS.Secondary
    toggleSwitch.BorderSizePixel = 0
    createCorner(10).Parent = toggleSwitch
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Parent = toggleSwitch
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = toggle.enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = COLORS.Text
    toggleKnob.BorderSizePixel = 0
    createCorner(8).Parent = toggleKnob
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = toggleFrame
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    
    toggleButton.MouseButton1Click:Connect(function()
        toggle.enabled = not toggle.enabled
        
        local switchColor = toggle.enabled and COLORS.Primary or COLORS.Secondary
        local knobPosition = toggle.enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        animateProperty(toggleSwitch, "BackgroundColor3", switchColor)
        animateProperty(toggleKnob, "Position", knobPosition)
        
        toggle.callback(toggle.enabled)
    end)
    
    -- Hover effect
    toggleButton.MouseEnter:Connect(function()
        animateProperty(toggleFrame, "BackgroundColor3", COLORS.Hover)
    end)
    
    toggleButton.MouseLeave:Connect(function()
        animateProperty(toggleFrame, "BackgroundColor3", COLORS.Surface)
    end)
    
    table.insert(tab.elements, toggle)
    return toggle
end

-- Button Creation
function SmoothGUI:CreateButton(tab, text, callback)
    local button = {
        callback = callback or function() end
    }
    
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button"
    buttonFrame.Parent = tab.page
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.BackgroundColor3 = COLORS.Primary
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Text = text
    buttonFrame.TextColor3 = COLORS.Text
    buttonFrame.TextSize = 14
    buttonFrame.Font = Enum.Font.GothamSemibold
    createCorner(8).Parent = buttonFrame
    
    buttonFrame.MouseButton1Click:Connect(function()
        -- Click animation
        animateProperty(buttonFrame, "Size", UDim2.new(1, -4, 0, 36), 0.1)
        wait(0.1)
        animateProperty(buttonFrame, "Size", UDim2.new(1, 0, 0, 40), 0.1)
        
        button.callback()
    end)
    
    -- Hover effect
    buttonFrame.MouseEnter:Connect(function()
        animateProperty(buttonFrame, "BackgroundColor3", Color3.fromRGB(90, 150, 255))
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        animateProperty(buttonFrame, "BackgroundColor3", COLORS.Primary)
    end)
    
    table.insert(tab.elements, button)
    return button
end

-- Dropdown Creation
function SmoothGUI:CreateDropdown(tab, text, options, default, callback)
    local dropdown = {
        options = options or {},
        selected = default or (options and options[1]) or "None",
        callback = callback or function() end,
        isOpen = false
    }
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Parent = tab.page
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundColor3 = COLORS.Surface
    dropdownFrame.BorderSizePixel = 0
    createCorner(8).Parent = dropdownFrame
    createPadding({15, 10}).Parent = dropdownFrame
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Parent = dropdownFrame
    dropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = text
    dropdownLabel.TextColor3 = COLORS.Text
    dropdownLabel.TextSize = 14
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Parent = dropdownFrame
    dropdownButton.Size = UDim2.new(0.5, -20, 1, -10)
    dropdownButton.Position = UDim2.new(0.5, 0, 0, 5)
    dropdownButton.BackgroundColor3 = COLORS.Background
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = dropdown.selected .. " ▼"
    dropdownButton.TextColor3 = COLORS.Text
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    createCorner(6).Parent = dropdownButton
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "DropdownList"
    dropdownList.Parent = dropdownFrame
    dropdownList.Size = UDim2.new(0.5, -20, 0, 0)
    dropdownList.Position = UDim2.new(0.5, 0, 1, 5)
    dropdownList.BackgroundColor3 = COLORS.Background
    dropdownList.BorderSizePixel = 1
    dropdownList.BorderColor3 = COLORS.Border
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    createCorner(6).Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Create option buttons
    for i, option in ipairs(dropdown.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option" .. i
        optionButton.Parent = dropdownList
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundColor3 = COLORS.Background
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = COLORS.Text
        optionButton.TextSize = 11
        optionButton.Font = Enum.Font.Gotham
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.selected = option
            dropdownButton.Text = option .. " ▼"
            dropdown.isOpen = false
            
            animateMultiple(dropdownList, {
                Size = UDim2.new(0.5, -20, 0, 0)
            })
            
            wait(ANIMATION_TIME)
            dropdownList.Visible = false
            
            dropdown.callback(option)
        end)
        
        optionButton.MouseEnter:Connect(function()
            animateProperty(optionButton, "BackgroundColor3", COLORS.Hover)
        end)
        
        optionButton.MouseLeave:Connect(function()
            animateProperty(optionButton, "BackgroundColor3", COLORS.Background)
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdown.isOpen = not dropdown.isOpen
        
        if dropdown.isOpen then
            dropdownList.Visible = true
            local targetHeight = #dropdown.options * 25
            animateMultiple(dropdownList, {
                Size = UDim2.new(0.5, -20, 0, targetHeight)
            })
            dropdownButton.Text = dropdown.selected .. " ▲"
        else
            animateMultiple(dropdownList, {
                Size = UDim2.new(0.5, -20, 0, 0)
            })
            dropdownButton.Text = dropdown.selected .. " ▼"
            
            wait(ANIMATION_TIME)
            dropdownList.Visible = false
        end
    end)
    
    -- Hover effect
    dropdownButton.MouseEnter:Connect(function()
        animateProperty(dropdownButton, "BackgroundColor3", COLORS.Hover)
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        animateProperty(dropdownButton, "BackgroundColor3", COLORS.Background)
    end)
    
    table.insert(tab.elements, dropdown)
    return dropdown
end

-- Slider Creation
function SmoothGUI:CreateSlider(tab, text, min, max, default, callback)
    local slider = {
        min = min or 0,
        max = max or 100,
        value = default or min or 0,
        callback = callback or function() end,
        dragging = false
    }
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider"
    sliderFrame.Parent = tab.page
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundColor3 = COLORS.Surface
    sliderFrame.BorderSizePixel = 0
    createCorner(8).Parent = sliderFrame
    createPadding(15).Parent = sliderFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = sliderFrame
    sliderLabel.Size = UDim2.new(1, -60, 0, 20)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = text
    sliderLabel.TextColor3 = COLORS.Text
    sliderLabel.TextSize = 14
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderValue = Instance.new("TextLabel")
    sliderValue.Parent = sliderFrame
    sliderValue.Size = UDim2.new(0, 60, 0, 20)
    sliderValue.Position = UDim2.new(1, -60, 0, 0)
    sliderValue.BackgroundTransparency = 1
    sliderValue.Text = tostring(slider.value)
    sliderValue.TextColor3 = COLORS.Primary
    sliderValue.TextSize = 14
    sliderValue.Font = Enum.Font.GothamSemibold
    sliderValue.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Parent = sliderFrame
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 1, -15)
    sliderTrack.BackgroundColor3 = COLORS.Background
    sliderTrack.BorderSizePixel = 0
    createCorner(2).Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Parent = sliderTrack
    sliderFill.Size = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = COLORS.Primary
    sliderFill.BorderSizePixel = 0
    createCorner(2).Parent = sliderFill
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Parent = sliderTrack
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = COLORS.Text
    sliderKnob.BorderSizePixel = 0
    createCorner(6).Parent = sliderKnob
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Parent = sliderTrack
    sliderButton.Size = UDim2.new(1, 0, 1, 20)
    sliderButton.Position = UDim2.new(0, 0, 0, -10)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    
    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        slider.value = math.floor(slider.min + (slider.max - slider.min) * percentage)
        
        sliderValue.Text = tostring(slider.value)
        animateProperty(sliderFill, "Size", UDim2.new(percentage, 0, 1, 0))
        animateProperty(sliderKnob, "Position", UDim2.new(percentage, -6, 0.5, -6))
        
        slider.callback(slider.value)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        slider.dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if slider.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slider.dragging = false
        end
    end)
    
    sliderButton.MouseButton1Click:Connect(function()
        updateSlider(UserInputService:GetMouseLocation())
    end)
    
    table.insert(tab.elements, slider)
    return slider
end

-- Input/Textbox Creation
function SmoothGUI:CreateInput(tab, text, placeholder, callback)
    local input = {
        value = "",
        callback = callback or function() end
    }
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "Input"
    inputFrame.Parent = tab.page
    inputFrame.Size = UDim2.new(1, 0, 0, 40)
    inputFrame.BackgroundColor3 = COLORS.Surface
    inputFrame.BorderSizePixel = 0
    createCorner(8).Parent = inputFrame
    createPadding({15, 10}).Parent = inputFrame
    
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Parent = inputFrame
    inputLabel.Size = UDim2.new(0.3, 0, 1, 0)
    inputLabel.Position = UDim2.new(0, 0, 0, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = text
    inputLabel.TextColor3 = COLORS.Text
    inputLabel.TextSize = 14
    inputLabel.Font = Enum.Font.Gotham
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Parent = inputFrame
    inputBox.Size = UDim2.new(0.7, -10, 1, -10)
    inputBox.Position = UDim2.new(0.3, 0, 0, 5)
    inputBox.BackgroundColor3 = COLORS.Background
    inputBox.BorderSizePixel = 1
    inputBox.BorderColor3 = COLORS.Border
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or "Enter text..."
    inputBox.TextColor3 = COLORS.Text
    inputBox.PlaceholderColor3 = COLORS.TextSecondary
    inputBox.TextSize = 12
    inputBox.Font = Enum.Font.Gotham
    inputBox.ClearTextOnFocus = false
    createCorner(6).Parent = inputBox
    createPadding(8).Parent = inputBox
    
    inputBox.FocusLost:Connect(function(enterPressed)
        input.value = inputBox.Text
        input.callback(input.value, enterPressed)
    end)
    
    inputBox.Focused:Connect(function()
        animateProperty(inputBox, "BorderColor3", COLORS.Primary)
    end)
    
    inputBox.FocusLost:Connect(function()
        animateProperty(inputBox, "BorderColor3", COLORS.Border)
    end)
    
    table.insert(tab.elements, input)
    return input
end

-- Label Creation
function SmoothGUI:CreateLabel(tab, text, size)
    local label = {}
    
    local labelFrame = Instance.new("TextLabel")
    labelFrame.Name = "Label"
    labelFrame.Parent = tab.page
    labelFrame.Size = UDim2.new(1, 0, 0, size or 25)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Text = text
    labelFrame.TextColor3 = COLORS.Text
    labelFrame.TextSize = 14
    labelFrame.Font = Enum.Font.Gotham
    labelFrame.TextXAlignment = Enum.TextXAlignment.Left
    labelFrame.TextWrapped = true
    createPadding(5).Parent = labelFrame
    
    label.SetText = function(newText)
        labelFrame.Text = newText
    end
    
    table.insert(tab.elements, label)
    return label
end

-- Private Methods
function SmoothGUI:_selectTab(tab)
    -- Deselect previous tab
    if self.currentTab then
        animateProperty(self.currentTab.button, "BackgroundColor3", COLORS.Background)
        animateProperty(self.currentTab.button, "TextColor3", COLORS.TextSecondary)
        self.currentTab.page.Visible = false
    end
    
    -- Select new tab
    self.currentTab = tab
    animateProperty(tab.button, "BackgroundColor3", COLORS.Primary)
    animateProperty(tab.button, "TextColor3", COLORS.Text)
    tab.page.Visible = true
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
    
    -- Button hover effects
    self.CloseButton.MouseEnter:Connect(function()
        animateProperty(self.CloseButton, "BackgroundColor3", Color3.fromRGB(255, 120, 120))
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        animateProperty(self.CloseButton, "BackgroundColor3", COLORS.Danger)
    end)
    
    self.MinimizeButton.MouseEnter:Connect(function()
        animateProperty(self.MinimizeButton, "BackgroundColor3", Color3.fromRGB(255, 200, 90))
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        animateProperty(self.MinimizeButton, "BackgroundColor3", COLORS.Warning)
    end)
end

-- Public Methods
function SmoothGUI:ToggleMinimize()
    self.isMinimized = not self.isMinimized
    
    if self.isMinimized then
        animateProperty(self.MainFrame, "Size", UDim2.new(0, self.originalSize.X.Offset, 0, 40))
        self.MinimizeButton.Text = "+"
    else
        animateProperty(self.MainFrame, "Size", self.originalSize)
        self.MinimizeButton.Text = "−"
    end
end

function SmoothGUI:SetVisible(visible)
    self.ScreenGui.Enabled = visible
end

function SmoothGUI:Destroy()
    animateProperty(self.MainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    wait(0.3)
    self.ScreenGui:Destroy()
end

return SmoothGUI
