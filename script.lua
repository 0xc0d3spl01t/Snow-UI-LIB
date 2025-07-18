--[[
    SleekUI Library
    A smooth, modern UI library for Roblox with transparency
    Features:
    - Rounded corners
    - Smooth animations
    - Floating particles
    - Tab system
    - Dropdowns
    - Animated buttons and toggles
    - Minimizable with Insert key
    - Semi-transparent elements for a modern look
    - Notification system with close button
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local SleekUI = {}
SleekUI.__index = SleekUI

-- Tween info presets (smoother animations)
local TWEEN_INFO = {
    SHORT = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    MEDIUM = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
    LONG = TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
    BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
}

-- Colors
local COLORS = {
    BACKGROUND = Color3.fromRGB(30, 30, 35),
    ACCENT = Color3.fromRGB(114, 137, 218),
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
    TEXT_SECONDARY = Color3.fromRGB(185, 185, 185),
    ELEMENT_BG = Color3.fromRGB(40, 40, 45),
    ELEMENT_HOVER = Color3.fromRGB(50, 50, 55),
    PARTICLE = Color3.fromRGB(255, 255, 255),
    SUCCESS = Color3.fromRGB(87, 212, 145),
    ERROR = Color3.fromRGB(240, 71, 71),
    WARNING = Color3.fromRGB(250, 166, 26),
    INFO = Color3.fromRGB(77, 172, 224)
}

-- Transparency settings
local TRANSPARENCY = {
    BACKGROUND = 0.15,    -- Main background transparency
    ELEMENT = 0.1,        -- UI elements transparency
    SECONDARY = 0.25      -- Secondary elements transparency
}

-- Notification system variables
local NotificationSystem = {
    Container = nil,
    Notifications = {},
    MaxNotifications = 5,
    Padding = 8,
    Width = 280,
    DefaultHeight = 80,
    DefaultDuration = 5
}

-- Utility functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    return instance
end

local function ApplyRounding(frame, radius)
    local uiCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius or 6)
    })
    uiCorner.Parent = frame
    return uiCorner
end

local function CreateParticle(parent)
    local size = math.random(2, 4)
    local particle = CreateInstance("Frame", {
        BackgroundColor3 = COLORS.PARTICLE,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(math.random(), 0, math.random(), 0),
        Size = UDim2.fromOffset(size, size),
        BorderSizePixel = 0,
        Parent = parent
    })
    
    ApplyRounding(particle, size)
    
    -- Random movement
    spawn(function()
        local speed = math.random(15, 40) / 100
        local direction = Vector2.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10).Unit
        
        while particle and particle.Parent do
            local pos = particle.Position
            local newX = pos.X.Scale + direction.X * speed * 0.01
            local newY = pos.Y.Scale + direction.Y * speed * 0.01
            
            -- Bounce off edges
            if newX <= 0 or newX >= 1 then
                direction = Vector2.new(-direction.X, direction.Y)
                newX = math.clamp(newX, 0, 1)
            end
            if newY <= 0 or newY >= 1 then
                direction = Vector2.new(direction.X, -direction.Y)
                newY = math.clamp(newY, 0, 1)
            end
            
            particle.Position = UDim2.new(newX, 0, newY, 0)
            wait(0.05)
        end
    end)
    
    return particle
end

-- Initialize Notification Container
local function InitializeNotificationSystem()
    if NotificationSystem.Container then return end
    
    NotificationSystem.Container = CreateInstance("ScreenGui", {
        Name = "SleekUINotifications",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local frame = CreateInstance("Frame", {
        Name = "NotificationsContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -NotificationSystem.Width - 20, 0, 20),
        Size = UDim2.new(0, NotificationSystem.Width, 1, -40),
        ClipsDescendants = false,
        Parent = NotificationSystem.Container
    })
    
    local listLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, NotificationSystem.Padding),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = frame
    })
end

-- Create notification
local function CreateNotification(title, message, notificationType, duration)
    InitializeNotificationSystem()
    
    local typeColor = COLORS[notificationType:upper()] or COLORS.INFO
    duration = duration or NotificationSystem.DefaultDuration
    local container = NotificationSystem.Container.NotificationsContainer
    
    -- Cap notifications count
    while #NotificationSystem.Notifications >= NotificationSystem.MaxNotifications do
        local oldestNotif = NotificationSystem.Notifications[1]
        if oldestNotif and oldestNotif.Parent then
            oldestNotif:Destroy()
        end
        table.remove(NotificationSystem.Notifications, 1)
    end
    
    -- Create notification frame
    local notificationFrame = CreateInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = COLORS.BACKGROUND,
        BackgroundTransparency = TRANSPARENCY.BACKGROUND - 0.05, -- Slightly less transparent than main UI
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 0, 0),
        Size = UDim2.new(1, 0, 0, NotificationSystem.DefaultHeight),
        Parent = container,
        LayoutOrder = #NotificationSystem.Notifications + 1
    })
    
    ApplyRounding(notificationFrame, 8)
    
    -- Accent bar
    local accentBar = CreateInstance("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = typeColor,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notificationFrame
    })
    
    local accentBarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = accentBar
    })
    
    -- Title
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -54, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = typeColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notificationFrame
    })
    
    -- Message
    local messageLabel = CreateInstance("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -24, 1, -38),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = COLORS.TEXT_PRIMARY,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notificationFrame
    })
    
    -- Progress bar
    local progressBar = CreateInstance("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = typeColor,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 4, 1, -2),
        Size = UDim2.new(1, -8, 0, 2),
        Parent = notificationFrame
    })
    
    ApplyRounding(progressBar, 2)
    
    -- Close button
    local closeButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = COLORS.TEXT_SECONDARY,
        TextSize = 20,
        Parent = notificationFrame
    })
    
    -- Close button hover effect
    closeButton.MouseEnter:Connect(function()
        TweenService:Create(
            closeButton,
            TWEEN_INFO.SHORT,
            {TextColor3 = COLORS.TEXT_PRIMARY}
        ):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(
            closeButton,
            TWEEN_INFO.SHORT,
            {TextColor3 = COLORS.TEXT_SECONDARY}
        ):Play()
    end)
    
    -- Close functionality
    local function closeNotification()
        local index = table.find(NotificationSystem.Notifications, notificationFrame)
        if index then
            table.remove(NotificationSystem.Notifications, index)
        end
        
        TweenService:Create(
            notificationFrame,
            TWEEN_INFO.SHORT,
            {Position = UDim2.new(1, 20, 0, 0)}
        ):Play()
        
        task.delay(0.2, function()
            notificationFrame:Destroy()
        end)
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    -- Animate progress bar
    local progressTween = TweenService:Create(
        progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    
    -- Add particles
    for i = 1, 3 do
        CreateParticle(notificationFrame)
    end
    
    -- Animate notification entry
    table.insert(NotificationSystem.Notifications, notificationFrame)
    
    TweenService:Create(
        notificationFrame,
        TWEEN_INFO.SHORT,
        {Position = UDim2.new(0, 0, 0, 0)}
    ):Play()
    
    progressTween:Play()
    progressTween.Completed:Connect(closeNotification)
    
    return notificationFrame
end

-- Create the library
function SleekUI.new(title)
    local gui = {}
    setmetatable(gui, SleekUI)
    
    -- Main GUI container
    gui.ScreenGui = CreateInstance("ScreenGui", {
        Name = "SleekUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Main frame
    gui.MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = COLORS.BACKGROUND,
        BackgroundTransparency = TRANSPARENCY.BACKGROUND,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -175),
        Size = UDim2.new(0, 600, 0, 350),
        Parent = gui.ScreenGui
    })
    ApplyRounding(gui.MainFrame, 8)
    
    -- Shadow effect
    local shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = gui.MainFrame
    })
    
    -- Top bar
    gui.TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        BackgroundColor3 = COLORS.ACCENT,
        BackgroundTransparency = TRANSPARENCY.ELEMENT,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = gui.MainFrame
    })
    
    local topCorner = ApplyRounding(gui.TopBar, 8)
    topCorner.CornerRadius = UDim.new(0, 8)
    
    -- Title
    gui.Title = CreateInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Sleek UI",
        TextColor3 = COLORS.TEXT_PRIMARY,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = gui.TopBar
    })
    
    -- Close button
    gui.CloseButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = COLORS.TEXT_PRIMARY,
        TextSize = 20,
        Parent = gui.TopBar
    })
    
    -- Minimize button
    gui.MinimizeButton = CreateInstance("TextButton", {
        Name = "MinimizeButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = COLORS.TEXT_PRIMARY,
        TextSize = 20,
        Parent = gui.TopBar
    })
    
    -- Tab container
    gui.TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        Parent = gui.MainFrame
    })
    
    -- Tab buttons
    gui.TabButtonsFrame = CreateInstance("Frame", {
        Name = "TabButtonsFrame",
        BackgroundColor3 = COLORS.ELEMENT_BG,
        BackgroundTransparency = TRANSPARENCY.ELEMENT,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 120, 1, -20),
        Parent = gui.TabContainer
    })
    ApplyRounding(gui.TabButtonsFrame, 6)
    
    -- Tab button container (scrolling)
    gui.TabButtonsList = CreateInstance("ScrollingFrame", {
        Name = "TabButtonsList",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = COLORS.ACCENT,
        Parent = gui.TabButtonsFrame
    })
    
    local tabListLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = gui.TabButtonsList
    })
    
    local tabListPadding = CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = gui.TabButtonsList
    })
    
    -- Content frame
    gui.ContentFrame = CreateInstance("Frame", {
        Name = "ContentFrame",
        BackgroundColor3 = COLORS.ELEMENT_BG,
        BackgroundTransparency = TRANSPARENCY.ELEMENT,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 10),
        Size = UDim2.new(1, -150, 1, -20),
        ClipsDescendants = true, -- Important for tab animations
        Parent = gui.TabContainer
    })
    ApplyRounding(gui.ContentFrame, 6)
    
    -- Initialize
    gui.Tabs = {}
    gui.CurrentTab = nil
    gui.Minimized = false
    gui.Visible = true
    gui.TabAnimationInProgress = false  -- Add a flag to track animation state
    gui.ActiveTab = nil -- Track currently active tab
    
    -- Add particles
    for i = 1, 20 do
        CreateParticle(gui.ContentFrame)
    end
    
    -- Close button functionality
    gui.CloseButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Minimize button functionality
    gui.MinimizeButton.MouseButton1Click:Connect(function()
        gui:ToggleMinimize()
    end)
    
    -- Make the window draggable
    local dragging = false
    local dragStart, startPos

    gui.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Toggle visibility with Insert key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            gui:ToggleVisibility()
        end
    end)
    
    return gui
end

-- Toggle minimize state
function SleekUI:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        TweenService:Create(
            self.MainFrame,
            TWEEN_INFO.MEDIUM,
            {Size = UDim2.new(0, 600, 0, 30)}
        ):Play()
        self.TabContainer.Visible = false
    else
        TweenService:Create(
            self.MainFrame,
            TWEEN_INFO.MEDIUM,
            {Size = UDim2.new(0, 600, 0, 350)}
        ):Play()
        self.TabContainer.Visible = true
    end
end

-- Toggle visibility
function SleekUI:ToggleVisibility()
    self.Visible = not self.Visible
    
    if self.Visible then
        self.MainFrame.Visible = true
        TweenService:Create(
            self.MainFrame,
            TWEEN_INFO.MEDIUM,
            {Position = UDim2.new(0.5, -300, 0.5, -175)}
        ):Play()
    else
        local tween = TweenService:Create(
            self.MainFrame,
            TWEEN_INFO.MEDIUM,
            {Position = UDim2.new(0.5, -300, -0.5, 0)}
        )
        tween.Completed:Connect(function()
            if not self.Visible then
                self.MainFrame.Visible = false
            end
        end)
        tween:Play()
    end
end

-- Send a notification
function SleekUI:Notify(title, message, notificationType, duration)
    notificationType = notificationType or "info"
    
    -- Validate notification type
    local validTypes = {
        success = true,
        error = true,
        warning = true,
        info = true
    }
    
    if not validTypes[notificationType:lower()] then
        notificationType = "info"
    end
    
    return CreateNotification(title, message, notificationType, duration)
end

-- Create a new tab
function SleekUI:AddTab(name, icon)
    local tabIndex = #self.Tabs + 1
    
    -- Tab button
    local tabButton = CreateInstance("TextButton", {
        Name = name .. "Button",
        BackgroundColor3 = COLORS.ELEMENT_HOVER,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0.9, 0, 0, 32),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = COLORS.TEXT_PRIMARY,
        TextSize = 14,
        LayoutOrder = tabIndex,
        Parent = self.TabButtonsList
    })
    ApplyRounding(tabButton, 6)
    
    -- Tab icon (if provided)
    if icon then
        local iconImage = CreateInstance("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = icon,
            Parent = tabButton
        })
        
        tabButton.TextXAlignment = Enum.TextXAlignment.Right
        tabButton.Size = UDim2.new(0.9, 0, 0, 32)
    end
    
    -- Tab content container - this is a direct frame that will hold the content
    local tabContainer = CreateInstance("Frame", {
        Name = name .. "Container",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,  -- Start hidden
        Parent = self.ContentFrame
    })
    
    -- Tab content frame (scrolling)
    local tabFrame = CreateInstance("ScrollingFrame", {
        Name = name .. "Tab",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = tabContainer
    })
    
    local contentLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabFrame
    })
    
    local contentPadding = CreateInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tabFrame
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local tab = {
        Button = tabButton,
        Container = tabContainer,
        Frame = tabFrame,
        Name = name,
        Index = tabIndex
    }
    
    table.insert(self.Tabs, tab)
    
    -- Tab selection
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tabIndex)
    end)
    
    -- Select this tab if it's the first one
    if #self.Tabs == 1 then
        self:SelectTab(1)
    end
    
    -- Update the canvas size
    self.TabButtonsList.CanvasSize = UDim2.new(0, 0, 0, #self.Tabs * 37)
    
    -- Tab functionality
    local tabMethods = {}
    
    -- Section
    function tabMethods:AddSection(sectionName)
        local section = CreateInstance("Frame", {
            Name = sectionName .. "Section",
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            BackgroundTransparency = TRANSPARENCY.SECONDARY,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36), -- Initial size, will grow
            LayoutOrder = #tabFrame:GetChildren(),
            Parent = tabFrame
        })
        ApplyRounding(section, 8)
        
        local sectionTitle = CreateInstance("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = sectionName,
            TextColor3 = COLORS.ACCENT,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })
        
        local sectionContent = CreateInstance("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 36),
            Size = UDim2.new(1, -20, 1, -44),
            Parent = section
        })
        
        local sectionLayout = CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = sectionContent
        })
        
        -- Auto-adjust section size based on content
        sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            section.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 46)
        end)
        
        local sectionMethods = {}
        
        -- Label
        function sectionMethods:AddLabel(text)
            local label = CreateInstance("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionContent
            })
            
            -- Animate text color from white to darker
            spawn(function()
                local tweenInfo = TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                TweenService:Create(
                    label,
                    tweenInfo,
                    {TextColor3 = COLORS.TEXT_SECONDARY}
                ):Play()
            end)
            
            local labelMethods = {}
            
            function labelMethods:Update(newText)
                label.TextColor3 = COLORS.TEXT_PRIMARY
                label.Text = newText
                
                -- Re-animate
                spawn(function()
                    local tweenInfo = TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    TweenService:Create(
                        label,
                        tweenInfo,
                        {TextColor3 = COLORS.TEXT_SECONDARY}
                    ):Play()
                end)
            end
            
            return labelMethods
        end
        
        -- Button
        function sectionMethods:AddButton(text, callback)
            local button = CreateInstance("TextButton", {
                Name = "Button",
                BackgroundColor3 = COLORS.ELEMENT_HOVER,
                BackgroundTransparency = TRANSPARENCY.ELEMENT,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 32),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                AutoButtonColor = false,
                Parent = sectionContent
            })
            ApplyRounding(button, 6)
            
            button.MouseEnter:Connect(function()
                TweenService:Create(
                    button,
                    TWEEN_INFO.SHORT,
                    {BackgroundColor3 = COLORS.ACCENT, BackgroundTransparency = TRANSPARENCY.ELEMENT * 0.5}
                ):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(
                    button,
                    TWEEN_INFO.SHORT,
                    {BackgroundColor3 = COLORS.ELEMENT_HOVER, BackgroundTransparency = TRANSPARENCY.ELEMENT}
                ):Play()
            end)
            
            button.MouseButton1Down:Connect(function()
                TweenService:Create(
                    button,
                    TWEEN_INFO.SHORT,
                    {Size = UDim2.new(0.98, 0, 0, 30)}
                ):Play()
            end)
            
            button.MouseButton1Up:Connect(function()
                TweenService:Create(
                    button,
                    TWEEN_INFO.SHORT,
                    {Size = UDim2.new(1, 0, 0, 32)}
                ):Play()
            end)
            
            button.MouseButton1Click:Connect(function()
                callback()
                
                -- Ripple effect
                local ripple = CreateInstance("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 0, 0, 0),
                    Parent = button
                })
                ApplyRounding(ripple, 100)
                
                TweenService:Create(
                    ripple,
                    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}
                ):Play()
                
                game.Debris:AddItem(ripple, 0.6)
            end)
            
            local buttonMethods = {}
            
            function buttonMethods:Update(newText)
                button.Text = newText
            end
            
            return buttonMethods
        end
        
        -- Toggle
        function sectionMethods:AddToggle(text, default, callback)
            local toggle = CreateInstance("Frame", {
                Name = "Toggle",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Parent = sectionContent
            })
            
            local label = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle
            })
            
            local toggleButton = CreateInstance("Frame", {
                BackgroundColor3 = default and COLORS.ACCENT or COLORS.ELEMENT_BG,
                BackgroundTransparency = TRANSPARENCY.ELEMENT,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -40, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20),
                Parent = toggle
            })
            ApplyRounding(toggleButton, 10)
            
            local thumb = CreateInstance("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Position = default and UDim2.new(0.5, 0, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = toggleButton
            })
            ApplyRounding(thumb, 8)
            
            local button = CreateInstance("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = toggle
            })
            
            local toggled = default
            
            local function updateToggle()
                toggled = not toggled
                
                TweenService:Create(
                    toggleButton,
                    TWEEN_INFO.SHORT,
                    {BackgroundColor3 = toggled and COLORS.ACCENT or COLORS.ELEMENT_BG}
                ):Play()
                
                TweenService:Create(
                    thumb,
                    TWEEN_INFO.MEDIUM,
                    {Position = toggled and UDim2.new(0.5, 0, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
                ):Play()
                
                callback(toggled)
            end
            
            button.MouseButton1Click:Connect(updateToggle)
            
            local toggleMethods = {}
            
            function toggleMethods:SetState(state)
                if toggled ~= state then
                    updateToggle()
                end
            end
            
            function toggleMethods:GetState()
                return toggled
            end
            
            return toggleMethods
        end
        
        -- Dropdown
        function sectionMethods:AddDropdown(text, options, default, callback)
            local dropdown = CreateInstance("Frame", {
                Name = "Dropdown",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 52),
                ClipsDescendants = true,
                Parent = sectionContent
            })
            
            local label = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown
            })
            
            local dropdownButton = CreateInstance("TextButton", {
                BackgroundColor3 = COLORS.ELEMENT_HOVER,
                BackgroundTransparency = TRANSPARENCY.ELEMENT,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 22),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = default or "Select Option",
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                Parent = dropdown
            })
            ApplyRounding(dropdownButton, 6)
            
            local icon = CreateInstance("ImageLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6031091004",
                ImageColor3 = COLORS.TEXT_PRIMARY,
                Parent = dropdownButton
            })
            
            local optionContainer = CreateInstance("Frame", {
                BackgroundColor3 = COLORS.ELEMENT_BG,
                BackgroundTransparency = TRANSPARENCY.ELEMENT,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 54),
                Size = UDim2.new(1, 0, 0, #options * 30),
                Visible = false,
                ZIndex = 5,
                Parent = dropdown
            })
            ApplyRounding(optionContainer, 6)
            
            local optionList = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optionContainer
            })
            
            local isOpen = false
            local selectedOption = default
            
            local dropdownMethods = {}
            
            local function toggleDropdown()
                isOpen = not isOpen
                
                if isOpen then
                    dropdown.Size = UDim2.new(1, 0, 0, 54 + #options * 30)
                    optionContainer.Visible = true
                    TweenService:Create(
                        icon,
                        TWEEN_INFO.SHORT,
                        {Rotation = 180}
                    ):Play()
                else
                    TweenService:Create(
                        icon,
                        TWEEN_INFO.SHORT,
                        {Rotation = 0}
                    ):Play()
                    
                    wait(0.15)
                    optionContainer.Visible = false
                    dropdown.Size = UDim2.new(1, 0, 0, 52)
                end
            end
            
            for i, option in ipairs(options) do
                local optionButton = CreateInstance("TextButton", {
                    BackgroundColor3 = COLORS.ELEMENT_BG,
                    BackgroundTransparency = 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = COLORS.TEXT_PRIMARY,
                    TextSize = 14,
                    ZIndex = 6,
                    Parent = optionContainer
                })
                ApplyRounding(optionButton, 4)
                
                optionButton.MouseEnter:Connect(function()
                    TweenService:Create(
                        optionButton,
                        TWEEN_INFO.SHORT,
                        {BackgroundColor3 = COLORS.ACCENT, BackgroundTransparency = 0.2}
                    ):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    TweenService:Create(
                        optionButton,
                        TWEEN_INFO.SHORT,
                        {BackgroundColor3 = COLORS.ELEMENT_BG, BackgroundTransparency = 0.2}
                    ):Play()
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    dropdownButton.Text = option
                    callback(option)
                    toggleDropdown()
                end)
            end
            
            dropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            function dropdownMethods:SetOptions(newOptions)
                -- Clear old options
                for _, child in pairs(optionContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add new options
                for i, option in ipairs(newOptions) do
                    local optionButton = CreateInstance("TextButton", {
                        BackgroundColor3 = COLORS.ELEMENT_BG,
                        BackgroundTransparency = 0.2,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = COLORS.TEXT_PRIMARY,
                        TextSize = 14,
                        ZIndex = 6,
                        Parent = optionContainer
                    })
                    ApplyRounding(optionButton, 4)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        dropdownButton.Text = option
                        callback(option)
                        toggleDropdown()
                    end)
                end
                
                optionContainer.Size = UDim2.new(1, 0, 0, #newOptions * 30)
            end
            
            function dropdownMethods:GetSelection()
                return selectedOption
            end
            
            function dropdownMethods:SetSelection(option)
                for _, opt in pairs(options) do
                    if opt == option then
                        selectedOption = option
                        dropdownButton.Text = option
                        callback(option)
                        return true
                    end
                end
                return false
            end
            
            return dropdownMethods
        end
        
        -- Slider (Fixed and improved)
        function sectionMethods:AddSlider(text, min, max, default, precision, callback)
            local slider = CreateInstance("Frame", {
                Name = "Slider",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 52),
                Parent = sectionContent
            })
            
            local label = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider
            })
            
            local valueLabel = CreateInstance("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 50, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(default or min),
                TextColor3 = COLORS.TEXT_PRIMARY,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider
            })
            
            -- Default value handling
            default = default or min
            default = math.clamp(default, min, max)
            
            local sliderBg = CreateInstance("Frame", {
                BackgroundColor3 = COLORS.ELEMENT_BG,
                BackgroundTransparency = TRANSPARENCY.ELEMENT,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 8),
                Parent = slider
            })
            ApplyRounding(sliderBg, 4)
            
            local initialScale = (default - min) / (max - min)
            
            local sliderFill = CreateInstance("Frame", {
                BackgroundColor3 = COLORS.ACCENT,
                BackgroundTransparency = TRANSPARENCY.ELEMENT * 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(initialScale, 0, 1, 0),
                Parent = sliderBg
            })
            ApplyRounding(sliderFill, 4)
            
            local sliderKnob = CreateInstance("Frame", {
                BackgroundColor3 = COLORS.TEXT_PRIMARY,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 2,
                Parent = sliderFill
            })
            ApplyRounding(sliderKnob, 8)
            
            local sliderBtn = CreateInstance("TextButton", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, -5),
                Size = UDim2.new(1, 0, 0, 20),
                Text = "",
                Parent = sliderBg
            })
            
            -- Value variables
            local value = default
            precision = precision or 0
            
            -- Function to update slider position and value
            local function updateSliderVisual(newValue)
                local newScale = (newValue - min) / (max - min)
                sliderFill.Size = UDim2.new(newScale, 0, 1, 0)
                valueLabel.Text = tostring(newValue)
            end
            
            -- Function to get value from X position
            local function getValueFromPosition(posX)
                local percentage = math.clamp((posX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local rawValue = min + ((max - min) * percentage)
                
                if precision == 0 then
                    return math.floor(rawValue)
                else
                    return math.floor(rawValue * (10 ^ precision)) / (10 ^ precision)
                end
            end
            
            -- Update slider on click or drag
            local isDragging = false
            
            sliderBtn.MouseButton1Down:Connect(function()
                isDragging = true
                local newValue = getValueFromPosition(Mouse.X)
                if newValue ~= value then
                    value = newValue
                    updateSliderVisual(value)
                    callback(value)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local newValue = getValueFromPosition(input.Position.X)
                    if newValue ~= value then
                        value = newValue
                        updateSliderVisual(value)
                        callback(value)
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            -- Animation effects for slider
            sliderBtn.MouseEnter:Connect(function()
                TweenService:Create(sliderFill, TWEEN_INFO.SHORT, 
                    {BackgroundTransparency = 0}):Play()
                TweenService:Create(sliderKnob, TWEEN_INFO.SHORT, 
                    {Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 0}):Play()
            end)
            
            sliderBtn.MouseLeave:Connect(function()
                if not isDragging then
                    TweenService:Create(sliderFill, TWEEN_INFO.SHORT, 
                        {BackgroundTransparency = TRANSPARENCY.ELEMENT * 0.5}):Play()
                    TweenService:Create(sliderKnob, TWEEN_INFO.SHORT, 
                        {Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 0.1}):Play()
                end
            end)
            
            -- Methods
            local sliderMethods = {}
            
            function sliderMethods:SetValue(newValue)
                newValue = math.clamp(newValue, min, max)
                
                if precision == 0 then
                    newValue = math.floor(newValue)
                else
                    newValue = math.floor(newValue * (10 ^ precision)) / (10 ^ precision)
                end
                
                value = newValue
                updateSliderVisual(value)
                callback(value)
            end
            
            function sliderMethods:GetValue()
                return value
            end
            
            -- Set initial value
            updateSliderVisual(value)
            
            return sliderMethods
        end
        
        return sectionMethods
    end
    
    return tabMethods
end

-- COMPLETELY FIXED Select Tab Function
function SleekUI:SelectTab(tabIndex)
    -- Prevent multiple animations from running at the same time
    if self.TabAnimationInProgress then
        return
    end
    
    -- Check if tab exists
    if not self.Tabs[tabIndex] then
        return
    end
    
    -- Get the tab we want to select
    local newTab = self.Tabs[tabIndex]
    
    -- If this tab is already selected, do nothing
    if self.ActiveTab and self.ActiveTab.Index == tabIndex then
        return
    end
    
    -- Set animation in progress flag
    self.TabAnimationInProgress = true
    
    -- HIDE ALL OTHER TABS FIRST - this is critical
    for _, tab in pairs(self.Tabs) do
        -- Skip the tab we're selecting
        if tab.Index ~= tabIndex then
            -- Immediately hide the tab
            tab.Container.Visible = false
            
            -- Reset button highlight
            TweenService:Create(
                tab.Button,
                TWEEN_INFO.SHORT,
                {BackgroundTransparency = 1}
            ):Play()
        end
    end
    
    -- Set up the new tab for animation
    newTab.Container.Position = UDim2.new(0.1, 0, 0, 0)
    newTab.Container.Visible = true
    
    -- Store reference to active tab
    self.ActiveTab = newTab
    
    -- Animate in the new tab
    local tabInTween = TweenService:Create(
        newTab.Container,
        TWEEN_INFO.SHORT,
        {Position = UDim2.new(0, 0, 0, 0)}
    )
    
    -- Highlight the button
    TweenService:Create(
        newTab.Button,
        TWEEN_INFO.SHORT,
        {BackgroundTransparency = 0}
    ):Play()
    
    -- Start animation and clean up when done
    tabInTween:Play()
    
    -- Animation completed
    delay(0.25, function()
        self.TabAnimationInProgress = false
    end)
end

-- Destroy the UI
function SleekUI:Destroy()
    local fadeOut = TweenService:Create(
        self.MainFrame, 
        TWEEN_INFO.MEDIUM, 
        {BackgroundTransparency = 1}
    )
    
    fadeOut.Completed:Connect(function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end)
    
    fadeOut:Play()
end

return SleekUI
