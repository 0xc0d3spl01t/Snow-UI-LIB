local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

local function createTween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

local function createFrame(parent, properties)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    for prop, value in pairs(properties or {}) do
        frame[prop] = value
    end
    return frame
end

local function createTextLabel(parent, properties)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    for prop, value in pairs(properties or {}) do
        label[prop] = value
    end
    return label
end

local function createTextButton(parent, properties)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.new(1, 1, 1)
    for prop, value in pairs(properties or {}) do
        button[prop] = value
    end
    return button
end

local function createImageLabel(parent, properties)
    local image = Instance.new("ImageLabel")
    image.Parent = parent
    image.BackgroundTransparency = 1
    for prop, value in pairs(properties or {}) do
        image[prop] = value
    end
    return image
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.new(0.3, 0.3, 0.3)
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

function Library.new(title)
    local self = setmetatable({}, Library)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILibrary"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self.MainFrame = createFrame(self.ScreenGui, {
        Name = "MainFrame",
        Position = UDim2.new(0.5, -300, 0.5, -250),
        Size = UDim2.new(0, 600, 0, 500),
        BackgroundColor3 = Color3.new(0.08, 0.08, 0.1),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true
    })
    addCorner(self.MainFrame, 12)
    addStroke(self.MainFrame, Color3.new(0.2, 0.2, 0.25), 2)
    
    self.TitleBar = createFrame(self.MainFrame, {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(self.TitleBar, 12)
    
    self.TitleLabel = createTextLabel(self.TitleBar, {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Text = title or "UI Library",
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    self.CloseButton = createTextButton(self.TitleBar, {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        Text = "×",
        TextSize = 20,
        BackgroundColor3 = Color3.new(0.8, 0.2, 0.2),
        Font = Enum.Font.GothamBold
    })
    addCorner(self.CloseButton, 6)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        local tween = createTween(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        self.ScreenGui:Destroy()
    end)
    
    self.TabContainer = createFrame(self.MainFrame, {
        Name = "TabContainer",
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(0, 150, 1, -60),
        BackgroundColor3 = Color3.new(0.06, 0.06, 0.08),
        BorderSizePixel = 0
    })
    addCorner(self.TabContainer, 8)
    
    self.ContentContainer = createFrame(self.MainFrame, {
        Name = "ContentContainer",
        Position = UDim2.new(0, 170, 0, 50),
        Size = UDim2.new(1, -180, 1, -60),
        BackgroundColor3 = Color3.new(0.06, 0.06, 0.08),
        BorderSizePixel = 0
    })
    addCorner(self.ContentContainer, 8)
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = self.TabContainer
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 2)
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = self.TabContainer
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    local openTween = createTween(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 500)
    })
    
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    openTween:Play()
    openTween.Completed:Connect(function()
        self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    end)
    
    return self
end

function Library:CreateTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Elements = {}
    
    tab.Button = createTextButton(self.TabContainer, {
        Name = name,
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.12),
        Text = "  " .. name,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    addCorner(tab.Button, 6)
    
    tab.Content = createFrame(self.ContentContainer, {
        Name = name .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = tab.Content
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.3)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.ScrollFrame = scrollFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    local padding = Instance.new("UIPadding")
    padding.Parent = scrollFrame
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    tab.Button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            createTween(tab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.new(0.15, 0.15, 0.18)
            }):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            createTween(tab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.new(0.1, 0.1, 0.12)
            }):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function Library:SelectTab(tab)
    if self.CurrentTab then
        createTween(self.CurrentTab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.12)
        }):Play()
        self.CurrentTab.Content.Visible = false
    end
    
    self.CurrentTab = tab
    createTween(tab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    }):Play()
    tab.Content.Visible = true
end

function Library:CreateButton(tab, text, callback)
    local button = createTextButton(tab.ScrollFrame, {
        Name = "Button",
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        Text = text,
        TextSize = 14
    })
    addCorner(button, 6)
    addStroke(button, Color3.new(0.2, 0.2, 0.25))
    
    button.MouseButton1Click:Connect(function()
        createTween(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
        }):Play()
        wait(0.1)
        createTween(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0.12, 0.12, 0.15)
        }):Play()
        if callback then callback() end
    end)
    
    button.MouseEnter:Connect(function()
        createTween(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0.15, 0.15, 0.18)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.new(0.12, 0.12, 0.15)
        }):Play()
    end)
    
    return button
end

function Library:CreateToggle(tab, text, default, callback)
    local toggleFrame = createFrame(tab.ScrollFrame, {
        Name = "Toggle",
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(toggleFrame, 6)
    addStroke(toggleFrame, Color3.new(0.2, 0.2, 0.25))
    
    local label = createTextLabel(toggleFrame, {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleButton = createFrame(toggleFrame, {
        Position = UDim2.new(1, -45, 0.5, -10),
        Size = UDim2.new(0, 35, 0, 20),
        BackgroundColor3 = default and Color3.new(0.2, 0.4, 0.8) or Color3.new(0.3, 0.3, 0.35),
        BorderSizePixel = 0
    })
    addCorner(toggleButton, 10)
    
    local toggleCircle = createFrame(toggleButton, {
        Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    addCorner(toggleCircle, 8)
    
    local isToggled = default or false
    
    local function toggle()
        isToggled = not isToggled
        
        local bgColor = isToggled and Color3.new(0.2, 0.4, 0.8) or Color3.new(0.3, 0.3, 0.35)
        local circlePos = isToggled and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        
        createTween(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = bgColor
        }):Play()
        
        createTween(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = circlePos
        }):Play()
        
        if callback then callback(isToggled) end
    end
    
    local clickDetector = createTextButton(toggleFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    clickDetector.MouseButton1Click:Connect(toggle)
    
    return {
        Frame = toggleFrame,
        SetValue = function(value)
            if value ~= isToggled then
                toggle()
            end
        end,
        GetValue = function()
            return isToggled
        end
    }
end

function Library:CreateSlider(tab, text, min, max, default, callback)
    local sliderFrame = createFrame(tab.ScrollFrame, {
        Name = "Slider",
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(sliderFrame, 6)
    addStroke(sliderFrame, Color3.new(0.2, 0.2, 0.25))
    
    local label = createTextLabel(sliderFrame, {
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = createTextLabel(sliderFrame, {
        Position = UDim2.new(1, -60, 0, 5),
        Size = UDim2.new(0, 50, 0, 20),
        Text = tostring(default or min),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local sliderTrack = createFrame(sliderFrame, {
        Position = UDim2.new(0, 10, 1, -20),
        Size = UDim2.new(1, -20, 0, 6),
        BackgroundColor3 = Color3.new(0.2, 0.2, 0.25),
        BorderSizePixel = 0
    })
    addCorner(sliderTrack, 3)
    
    local sliderFill = createFrame(sliderTrack, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.new(0.2, 0.4, 0.8),
        BorderSizePixel = 0
    })
    addCorner(sliderFill, 3)
    
    local sliderHandle = createFrame(sliderTrack, {
        Position = UDim2.new(0, -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    addCorner(sliderHandle, 6)
    
    local currentValue = default or min
    local dragging = false
    
    local function updateSlider(value)
        currentValue = math.clamp(value, min, max)
        local percentage = (currentValue - min) / (max - min)
        
        createTween(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(percentage, 0, 1, 0)
        }):Play()
        
        createTween(sliderHandle, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Position = UDim2.new(percentage, -6, 0.5, -6)
        }):Play()
        
        valueLabel.Text = tostring(math.floor(currentValue))
        if callback then callback(currentValue) end
    end
    
    updateSlider(currentValue)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            local value = min + (max - min) * percentage
            updateSlider(value)
        end
    end)
    
    return {
        Frame = sliderFrame,
        SetValue = updateSlider,
        GetValue = function()
            return currentValue
        end
    }
end

function Library:CreateDropdown(tab, text, options, default, callback)
    local dropdownFrame = createFrame(tab.ScrollFrame, {
        Name = "Dropdown",
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(dropdownFrame, 6)
    addStroke(dropdownFrame, Color3.new(0.2, 0.2, 0.25))
    
    local label = createTextLabel(dropdownFrame, {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local selectedLabel = createTextLabel(dropdownFrame, {
        Position = UDim2.new(0, 120, 0, 0),
        Size = UDim2.new(1, -150, 1, 0),
        Text = default or (options[1] or "None"),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local arrow = createTextLabel(dropdownFrame, {
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Text = "▼",
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    local optionsList = createFrame(tab.ScrollFrame, {
        Name = "OptionsList",
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, -20, 0, 0),
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.12),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10
    })
    addCorner(optionsList, 6)
    addStroke(optionsList, Color3.new(0.2, 0.2, 0.25))
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Parent = optionsList
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local isOpen = false
    local currentValue = default or (options[1] or "None")
    
    for i, option in ipairs(options) do
        local optionButton = createTextButton(optionsList, {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.12),
            Text = "  " .. option,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        optionButton.MouseButton1Click:Connect(function()
            currentValue = option
            selectedLabel.Text = option
            isOpen = false
            optionsList.Visible = false
            
            createTween(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Rotation = 0
            }):Play()
            
            createTween(optionsList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, -20, 0, 0)
            }):Play()
            
            if callback then callback(option) end
        end)
        
        optionButton.MouseEnter:Connect(function()
            createTween(optionButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.new(0.15, 0.15, 0.18)
            }):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            createTween(optionButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.new(0.1, 0.1, 0.12)
            }):Play()
        end)
    end
    
    local clickDetector = createTextButton(dropdownFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    clickDetector.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsList.Visible = isOpen
        
        local arrowRotation = isOpen and 180 or 0
        local listSize = isOpen and UDim2.new(1, -20, 0, #options * 30) or UDim2.new(1, -20, 0, 0)
        
        createTween(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Rotation = arrowRotation
        }):Play()
        
        createTween(optionsList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = listSize
        }):Play()
    end)
    
    return {
        Frame = dropdownFrame,
        SetValue = function(value)
            if table.find(options, value) then
                currentValue = value
                selectedLabel.Text = value
            end
        end,
        GetValue = function()
            return currentValue
        end
    }
end

function Library:CreateTextBox(tab, text, placeholder, callback)
    local textboxFrame = createFrame(tab.ScrollFrame, {
        Name = "TextBox",
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(textboxFrame, 6)
    addStroke(textboxFrame, Color3.new(0.2, 0.2, 0.25))
    
    local label = createTextLabel(textboxFrame, {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 80, 1, 0),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textBox = Instance.new("TextBox")
    textBox.Parent = textboxFrame
    textBox.Position = UDim2.new(0, 100, 0, 5)
    textBox.Size = UDim2.new(1, -110, 1, -10)
    textBox.BackgroundColor3 = Color3.new(0.08, 0.08, 0.1)
    textBox.BorderSizePixel = 0
    textBox.Font = Enum.Font.Gotham
    textBox.TextColor3 = Color3.new(1, 1, 1)
    textBox.TextSize = 14
    textBox.PlaceholderText = placeholder or ""
    textBox.Text = ""
    addCorner(textBox, 4)
    
    textBox.FocusLost:Connect(function(enterPressed)
        if callback then callback(textBox.Text, enterPressed) end
    end)
    
    return {
        Frame = textboxFrame,
        TextBox = textBox,
        SetText = function(text)
            textBox.Text = text
        end,
        GetText = function()
            return textBox.Text
        end
    }
end

function Library:CreateLabel(tab, text)
    local label = createTextLabel(tab.ScrollFrame, {
        Name = "Label",
        Size = UDim2.new(1, -20, 0, 25),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    
    return label
end

function Library:CreateSeparator(tab)
    local separator = createFrame(tab.ScrollFrame, {
        Name = "Separator",
        Size = UDim2.new(1, -20, 0, 1),
        BackgroundColor3 = Color3.new(0.3, 0.3, 0.35),
        BorderSizePixel = 0
    })
    
    return separator
end

function Library:CreateKeybind(tab, text, defaultKey, callback)
    local keybindFrame = createFrame(tab.ScrollFrame, {
        Name = "Keybind",
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(keybindFrame, 6)
    addStroke(keybindFrame, Color3.new(0.2, 0.2, 0.25))
    
    local label = createTextLabel(keybindFrame, {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local keyLabel = createTextLabel(keybindFrame, {
        Position = UDim2.new(1, -80, 0, 5),
        Size = UDim2.new(0, 70, 0, 25),
        Text = defaultKey or "None",
        TextSize = 12,
        BackgroundColor3 = Color3.new(0.08, 0.08, 0.1),
        TextXAlignment = Enum.TextXAlignment.Center
    })
    addCorner(keyLabel, 4)
    
    local currentKey = defaultKey
    local listening = false
    
    local clickDetector = createTextButton(keybindFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    clickDetector.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keyLabel.Text = "..."
            keyLabel.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode.Name
                keyLabel.Text = currentKey
                keyLabel.BackgroundColor3 = Color3.new(0.08, 0.08, 0.1)
                listening = false
            end
        elseif not listening and currentKey and input.KeyCode.Name == currentKey then
            if callback then callback() end
        end
    end)
    
    return {
        Frame = keybindFrame,
        SetKey = function(key)
            currentKey = key
            keyLabel.Text = key
        end,
        GetKey = function()
            return currentKey
        end
    }
end

function Library:CreateColorPicker(tab, text, defaultColor, callback)
    local colorFrame = createFrame(tab.ScrollFrame, {
        Name = "ColorPicker",
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = Color3.new(0.12, 0.12, 0.15),
        BorderSizePixel = 0
    })
    addCorner(colorFrame, 6)
    addStroke(colorFrame, Color3.new(0.2, 0.2, 0.25))
    
    local label = createTextLabel(colorFrame, {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Text = text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local colorPreview = createFrame(colorFrame, {
        Position = UDim2.new(1, -35, 0, 7.5),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = defaultColor or Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    addCorner(colorPreview, 4)
    
    local currentColor = defaultColor or Color3.new(1, 1, 1)
    
    local colorPicker = createFrame(self.ScreenGui, {
        Name = "ColorPicker",
        Position = UDim2.new(0.5, -150, 0.5, -100),
        Size = UDim2.new(0, 300, 0, 200),
        BackgroundColor3 = Color3.new(0.08, 0.08, 0.1),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20
    })
    addCorner(colorPicker, 8)
    addStroke(colorPicker, Color3.new(0.2, 0.2, 0.25), 2)
    
    local rSlider = self:CreateSliderInternal(colorPicker, "R", 0, 255, math.floor(currentColor.R * 255), UDim2.new(0, 10, 0, 20))
    local gSlider = self:CreateSliderInternal(colorPicker, "G", 0, 255, math.floor(currentColor.G * 255), UDim2.new(0, 10, 0, 70))
    local bSlider = self:CreateSliderInternal(colorPicker, "B", 0, 255, math.floor(currentColor.B * 255), UDim2.new(0, 10, 0, 120))
    
    local function updateColor()
        currentColor = Color3.new(rSlider.value/255, gSlider.value/255, bSlider.value/255)
        colorPreview.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end
    
    rSlider.callback = updateColor
    gSlider.callback = updateColor
    bSlider.callback = updateColor
    
    local closeButton = createTextButton(colorPicker, {
        Position = UDim2.new(1, -30, 0, 5),
        Size = UDim2.new(0, 25, 0, 25),
        Text = "×",
        TextSize = 16,
        BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    })
    addCorner(closeButton, 4)
    
    closeButton.MouseButton1Click:Connect(function()
        colorPicker.Visible = false
    end)
    
    local clickDetector = createTextButton(colorFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    clickDetector.MouseButton1Click:Connect(function()
        colorPicker.Visible = not colorPicker.Visible
    end)
    
    return {
        Frame = colorFrame,
        SetColor = function(color)
            currentColor = color
            colorPreview.BackgroundColor3 = color
            rSlider.setValue(math.floor(color.R * 255))
            gSlider.setValue(math.floor(color.G * 255))
            bSlider.setValue(math.floor(color.B * 255))
        end,
        GetColor = function()
            return currentColor
        end
    }
end

function Library:CreateSliderInternal(parent, text, min, max, default, position)
    local sliderFrame = createFrame(parent, {
        Position = position,
        Size = UDim2.new(1, -20, 0, 40),
        BackgroundTransparency = 1
    })
    
    local label = createTextLabel(sliderFrame, {
        Size = UDim2.new(0, 20, 0, 20),
        Text = text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = createTextLabel(sliderFrame, {
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 35, 0, 20),
        Text = tostring(default),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local track = createFrame(sliderFrame, {
        Position = UDim2.new(0, 25, 0, 25),
        Size = UDim2.new(1, -70, 0, 4),
        BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
    })
    addCorner(track, 2)
    
    local fill = createFrame(track, {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    })
    addCorner(fill, 2)
    
    local handle = createFrame(track, {
        Position = UDim2.new((default - min) / (max - min), -4, 0.5, -4),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.new(1, 1, 1)
    })
    addCorner(handle, 4)
    
    local value = default
    local dragging = false
    
    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local percentage = (value - min) / (max - min)
        
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        handle.Position = UDim2.new(percentage, -4, 0.5, -4)
        valueLabel.Text = tostring(math.floor(value))
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local trackPos = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            local newValue = min + (max - min) * percentage
            updateSlider(newValue)
            if self.callback then self.callback() end
        end
    end)
    
    return {
        value = value,
        setValue = updateSlider,
        callback = nil
    }
end

function Library:CreateSection(tab, title)
    local sectionFrame = createFrame(tab.ScrollFrame, {
        Name = "Section",
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1
    })
    
    local titleLabel = createTextLabel(sectionFrame, {
        Position = UDim2.new(0, 0, 0, 5),
        Size = UDim2.new(1, 0, 0, 20),
        Text = title,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3.new(0.8, 0.8, 1)
    })
    
    local line = createFrame(sectionFrame, {
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
    })
    
    return sectionFrame
end

function Library:AddNotification(title, text, duration)
    local notification = createFrame(self.ScreenGui, {
        Name = "Notification",
        Position = UDim2.new(1, -320, 0, 20),
        Size = UDim2.new(0, 300, 0, 80),
        BackgroundColor3 = Color3.new(0.08, 0.08, 0.1),
        BorderSizePixel = 0,
        ZIndex = 100
    })
    addCorner(notification, 8)
    addStroke(notification, Color3.new(0.2, 0.2, 0.25), 2)
    
    local titleLabel = createTextLabel(notification, {
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Text = title,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local textLabel = createTextLabel(notification, {
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 35),
        Text = text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextColor3 = Color3.new(0.8, 0.8, 0.8)
    })
    
    local slideIn = createTween(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 0, 20)
    })
    
    notification.Position = UDim2.new(1, 0, 0, 20)
    slideIn:Play()
    
    wait(duration or 3)
    
    local slideOut = createTween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 0, 0, 20)
    })
    slideOut:Play()
    slideOut.Completed:Connect(function()
        notification:Destroy()
    end)
end

function Library:SetVisibility(visible)
    self.MainFrame.Visible = visible
end

function Library:Toggle()
    self.MainFrame.Visible = not self.MainFrame.Visible
end

function Library:Destroy()
    self.ScreenGui:Destroy()
end

return Library
