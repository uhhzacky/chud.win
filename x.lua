local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local Library = {}
Library.__index = Library

local Theme = {
    Background = Color3.fromRGB(8, 12, 14),
    Surface = Color3.fromRGB(12, 18, 20),
    Surface2 = Color3.fromRGB(15, 24, 27),
    Surface3 = Color3.fromRGB(20, 33, 36),
    Stroke = Color3.fromRGB(54, 84, 84),
    StrokeSoft = Color3.fromRGB(34, 56, 56),
    Accent = Color3.fromRGB(111, 255, 214),
    AccentDark = Color3.fromRGB(62, 211, 168),
    AccentSoft = Color3.fromRGB(26, 72, 65),
    Text = Color3.fromRGB(236, 255, 248),
    TextDim = Color3.fromRGB(161, 187, 181),
    Danger = Color3.fromRGB(255, 110, 130),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local Defaults = {
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    Animation = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    FastAnimation = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    SlowAnimation = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local Utility = {}

function Utility.Tween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

function Utility.Corner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = instance
    return c
end

function Utility.Stroke(instance, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = instance
    return s
end

function Utility.Padding(instance, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or left or 0)
    p.PaddingTop = UDim.new(0, top or left or 0)
    p.PaddingBottom = UDim.new(0, bottom or top or left or 0)
    p.Parent = instance
    return p
end

function Utility.List(instance, padding, fillDirection)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 0)
    l.FillDirection = fillDirection or Enum.FillDirection.Vertical
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = instance
    return l
end

function Utility.Gradient(instance, colors, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colors)
    g.Rotation = rotation or 0
    g.Parent = instance
    return g
end

function Utility.MakeShadow(parent, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = transparency or 0.42
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Size = UDim2.new(1, 42, 1, 42)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.ZIndex = math.max((parent.ZIndex or 1) - 1, 0)
    shadow.Parent = parent
    return shadow
end

function Utility.TextBounds(text, size, font, width)
    local bounds = TextService:GetTextSize(text, size, font, Vector2.new(width or 9999, 9999))
    return bounds
end

function Utility.Ripple(button)
    button.ClipsDescendants = true
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.fromOffset(0, 0)
        ripple.ZIndex = button.ZIndex + 5
        Utility.Corner(ripple, 999)
        ripple.Parent = button

        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2
        Utility.Tween(ripple, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(maxSize, maxSize),
            BackgroundTransparency = 1
        })
        task.delay(0.48, function()
            ripple:Destroy()
        end)
    end)
end

function Utility.Hover(frame, background, stroke)
    local normalBG = frame.BackgroundColor3
    local normalStroke = stroke and stroke.Color
    frame.MouseEnter:Connect(function()
        Utility.Tween(frame, Defaults.FastAnimation, {BackgroundColor3 = background or frame.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.04)})
        if stroke then Utility.Tween(stroke, Defaults.FastAnimation, {Color = Theme.Accent}) end
    end)
    frame.MouseLeave:Connect(function()
        Utility.Tween(frame, Defaults.FastAnimation, {BackgroundColor3 = normalBG})
        if stroke and normalStroke then Utility.Tween(stroke, Defaults.FastAnimation, {Color = normalStroke}) end
    end)
end

local function create(className, properties)
    local instance = Instance.new(className)
    for i,v in pairs(properties or {}) do
        instance[i] = v
    end
    return instance
end

local function safeCallback(callback, ...)
    if callback then
        local args = table.pack(...)
        task.spawn(function()
            local ok, err = pcall(callback, table.unpack(args, 1, args.n))
            if not ok then
                warn("MintUI callback error:", err)
            end
        end)
    end
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local KeybindPicker = {}
KeybindPicker.__index = KeybindPicker

function Library:CreateWindow(options)
    options = options or {}

    local self = setmetatable({}, Window)
    self.Title = options.Title or "Mint UI"
    self.Subtitle = options.Subtitle or "modern ui library"
    self.Size = options.Size or UDim2.fromOffset(920, 620)
    self.Theme = Theme
    self.Flags = {}
    self.Tabs = {}
    self.ActiveTab = nil
    self.Keybinds = {}
    self.Connections = {}
    self.Minimized = false
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl

    local screenGui = create("ScreenGui", {
        Name = options.GuiName or "MintUILibrary",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = gethui and gethui() or CoreGui
    })
    self.ScreenGui = screenGui

    local root = create("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = self.Size,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = screenGui
    })
    Utility.Corner(root, 18)
    Utility.Stroke(root, Theme.Stroke, 1)
    Utility.MakeShadow(root, 0.3)
    self.Root = root

    local accentGlow = create("Frame", {
        Name = "AccentGlow",
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 120),
        Parent = root
    })
    Utility.Corner(accentGlow, 18)
    Utility.Gradient(accentGlow, {
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(1, Theme.AccentDark)
    }, 0)

    local mainStroke = root:FindFirstChildOfClass("UIStroke")

    local topBar = create("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 0, 68),
        Position = UDim2.fromOffset(12, 12),
        Parent = root
    })

    local titleHolder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -180, 1, 0),
        Parent = topBar
    })

    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 4),
        Size = UDim2.new(1, 0, 0, 28),
        Font = Defaults.FontBold,
        Text = self.Title,
        TextColor3 = Theme.Text,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleHolder
    })

    local subtitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 31),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Defaults.FontMedium,
        Text = self.Subtitle,
        TextColor3 = Theme.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleHolder
    })

    local watermark = create("TextLabel", {
        Name = "Watermark",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 8),
        Size = UDim2.fromOffset(230, 24),
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = 0.12,
        Font = Defaults.FontMedium,
        Text = options.Watermark or "mint // modern smooth ui",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = root
    })
    Utility.Corner(watermark, 999)
    Utility.Stroke(watermark, Theme.StrokeSoft, 1, 0.1)

    local controls = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(160, 40),
        Parent = topBar
    })
    local controlsLayout = Utility.List(controls, 8, Enum.FillDirection.Horizontal)
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function makeTopButton(text)
        local b = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Surface2,
            Size = UDim2.fromOffset(34, 34),
            Font = Defaults.FontBold,
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Parent = controls
        })
        Utility.Corner(b, 10)
        local s = Utility.Stroke(b, Theme.StrokeSoft, 1)
        Utility.Ripple(b)
        Utility.Hover(b, Theme.Surface3, s)
        return b
    end

    local keybindButton = makeTopButton("⌨")
    local minimizeButton = makeTopButton("—")
    local closeButton = makeTopButton("✕")

    local body = create("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 88),
        Size = UDim2.new(1, -24, 1, -100),
        Parent = root
    })

    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 220, 1, 0),
        Parent = body
    })
    Utility.Corner(sidebar, 16)
    Utility.Stroke(sidebar, Theme.StrokeSoft, 1)
    Utility.Padding(sidebar, 12, 12, 12, 12)

    local search = create("TextBox", {
        Name = "SearchBox",
        PlaceholderText = "Search tabs / sections",
        Text = "",
        ClearTextOnFocus = false,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface2,
        Font = Defaults.FontMedium,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        TextSize = 14,
        Parent = sidebar
    })
    Utility.Corner(search, 12)
    Utility.Stroke(search, Theme.StrokeSoft, 1)
    Utility.Padding(search, 14, 14, 0, 0)

    local tabListHolder = create("ScrollingFrame", {
        Name = "TabListHolder",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        Parent = sidebar
    })
    local tabList = Utility.List(tabListHolder, 8)

    local content = create("Frame", {
        Name = "Content",
        BackgroundColor3 = Theme.Surface,
        Position = UDim2.fromOffset(232, 0),
        Size = UDim2.new(1, -232, 1, 0),
        Parent = body
    })
    Utility.Corner(content, 16)
    Utility.Stroke(content, Theme.StrokeSoft, 1)

    local contentPadding = Utility.Padding(content, 14, 14, 14, 14)
    local tabPages = create("Folder", {Name = "TabPages", Parent = content})

    local keybindOverlay = create("Frame", {
        Name = "KeybindOverlay",
        Visible = false,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.35,
        Size = UDim2.fromScale(1,1),
        Parent = screenGui
    })

    local keybindPanel = create("Frame", {
        Name = "KeybindPanel",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(360, 380),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = keybindOverlay
    })
    Utility.Corner(keybindPanel, 18)
    Utility.Stroke(keybindPanel, Theme.Stroke, 1)
    Utility.MakeShadow(keybindPanel, 0.36)

    local kbTitle = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 14),
        Size = UDim2.new(1, -36, 0, 28),
        Font = Defaults.FontBold,
        Text = "Keybinds",
        TextColor3 = Theme.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindPanel
    })

    local kbSub = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(18, 38),
        Size = UDim2.new(1, -36, 0, 18),
        Font = Defaults.FontMedium,
        Text = "toggle / hold actions in one clean panel",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindPanel
    })

    local kbList = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 68),
        Size = UDim2.new(1, -32, 1, -84),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        Parent = keybindPanel
    })
    Utility.List(kbList, 8)

    self.KeybindOverlay = keybindOverlay
    self.KeybindPanelList = kbList

    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    function self:SetWatermark(text)
        watermark.Text = text
    end

    function self:Notify(text)
        local note = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20),
            Size = UDim2.fromOffset(0, 48),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Surface2,
            Font = Defaults.FontMedium,
            Text = "   " .. text .. "   ",
            TextColor3 = Theme.Text,
            TextSize = 14,
            Parent = screenGui
        })
        Utility.Corner(note, 12)
        Utility.Stroke(note, Theme.StrokeSoft, 1)
        Utility.Padding(note, 12, 12, 0, 0)
        note.TextTransparency = 1
        note.BackgroundTransparency = 1
        Utility.Tween(note, Defaults.Animation, {BackgroundTransparency = 0.04, TextTransparency = 0})
        task.delay(2.6, function()
            Utility.Tween(note, Defaults.Animation, {BackgroundTransparency = 1, TextTransparency = 1})
            task.delay(0.26, function() note:Destroy() end)
        end)
    end

    function self:ToggleVisible(state)
        local target = state
        if target == nil then target = not root.Visible end
        root.Visible = target
        watermark.Visible = target
    end

    function self:OpenKeybindUI()
        keybindOverlay.Visible = true
        keybindPanel.Size = UDim2.fromOffset(320, 340)
        keybindPanel.BackgroundTransparency = 1
        Utility.Tween(keybindPanel, Defaults.SlowAnimation, {
            Size = UDim2.fromOffset(360, 380),
            BackgroundTransparency = 0
        })
    end

    function self:CloseKeybindUI()
        Utility.Tween(keybindPanel, Defaults.FastAnimation, {
            Size = UDim2.fromOffset(330, 350),
            BackgroundTransparency = 1
        })
        task.delay(0.14, function()
            keybindOverlay.Visible = false
        end)
    end

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    minimizeButton.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        local targetSize = self.Minimized and UDim2.fromOffset(self.Size.X.Offset, 84) or self.Size
        Utility.Tween(root, Defaults.SlowAnimation, {Size = targetSize})
        body.Visible = not self.Minimized
    end)

    keybindButton.MouseButton1Click:Connect(function()
        if keybindOverlay.Visible then
            self:CloseKeybindUI()
        else
            self:OpenKeybindUI()
        end
    end)

    keybindOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local absPos = keybindPanel.AbsolutePosition
            local absSize = keybindPanel.AbsoluteSize
            local m = UserInputService:GetMouseLocation()
            if not (m.X >= absPos.X and m.X <= absPos.X + absSize.X and m.Y >= absPos.Y and m.Y <= absPos.Y + absSize.Y) then
                self:CloseKeybindUI()
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:ToggleVisible()
            return
        end

        for _, bind in ipairs(self.Keybinds) do
            if bind.Value == input.KeyCode and bind.Enabled then
                if bind.Mode == "Toggle" then
                    bind.State = not bind.State
                    bind:SetVisualState(bind.State)
                    safeCallback(bind.Callback, bind.State, bind.Value, bind.Mode)
                elseif bind.Mode == "Hold" then
                    bind.State = true
                    bind:SetVisualState(true)
                    safeCallback(bind.Callback, true, bind.Value, bind.Mode)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end
        for _, bind in ipairs(self.Keybinds) do
            if bind.Value == input.KeyCode and bind.Enabled and bind.Mode == "Hold" then
                bind.State = false
                bind:SetVisualState(false)
                safeCallback(bind.Callback, false, bind.Value, bind.Mode)
            end
        end
    end)

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(search.Text)
        for _, tab in ipairs(self.Tabs) do
            local visible = query == "" or string.find(string.lower(tab.Name), query, 1, true) ~= nil
            if not visible then
                for _, section in ipairs(tab.Sections) do
                    if string.find(string.lower(section.Name), query, 1, true) then
                        visible = true
                        break
                    end
                end
            end
            tab.Button.Visible = visible
        end
    end)

    function self:RegisterKeybind(bind)
        table.insert(self.Keybinds, bind)
        local item = create("Frame", {
            BackgroundColor3 = Theme.Surface2,
            Size = UDim2.new(1, 0, 0, 52),
            Parent = kbList
        })
        Utility.Corner(item, 12)
        Utility.Stroke(item, Theme.StrokeSoft, 1)

        local name = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 7),
            Size = UDim2.new(1, -120, 0, 20),
            Font = Defaults.FontMedium,
            Text = bind.Title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = item
        })

        local meta = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 25),
            Size = UDim2.new(1, -120, 0, 18),
            Font = Defaults.Font,
            Text = string.format("%s mode", string.lower(bind.Mode)),
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = item
        })

        local value = create("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(90, 30),
            BackgroundColor3 = Theme.Surface3,
            Font = Defaults.FontBold,
            Text = bind.Value.Name,
            TextColor3 = Theme.Accent,
            TextSize = 13,
            Parent = item
        })
        Utility.Corner(value, 10)
        Utility.Stroke(value, Theme.StrokeSoft, 1)

        bind.VisualMeta = meta
        bind.VisualValue = value
        return bind
    end

    function self:CreateTab(options)
        options = options or {}
        local tab = setmetatable({}, Tab)
        tab.Window = self
        tab.Name = options.Name or "Tab"
        tab.Icon = options.Icon or "◆"
        tab.Sections = {}
        tab.SectionTabs = {}

        local button = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Surface2,
            Size = UDim2.new(1, 0, 0, 46),
            Text = "",
            Parent = tabListHolder
        })
        Utility.Corner(button, 12)
        local buttonStroke = Utility.Stroke(button, Theme.StrokeSoft, 1)
        Utility.Ripple(button)

        local icon = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.fromOffset(28, 46),
            Font = Defaults.FontBold,
            Text = tab.Icon,
            TextColor3 = Theme.Accent,
            TextSize = 16,
            Parent = button
        })

        local label = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(42, 0),
            Size = UDim2.new(1, -54, 1, 0),
            Font = Defaults.FontMedium,
            Text = tab.Name,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })

        local page = create("Frame", {
            Visible = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = content
        })

        local tabHeader = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 44),
            Parent = page
        })

        local headerTitle = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Defaults.FontBold,
            Text = tab.Name,
            TextColor3 = Theme.Text,
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabHeader
        })

        local sectionTabBar = create("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Parent = tabHeader
        })
        local stLayout = Utility.List(sectionTabBar, 8, Enum.FillDirection.Horizontal)
        stLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        stLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local sectionPages = create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 54),
            Size = UDim2.new(1, 0, 1, -54),
            Parent = page
        })

        tab.Button = button
        tab.ButtonStroke = buttonStroke
        tab.Page = page
        tab.SectionPages = sectionPages
        tab.SectionTabBar = sectionTabBar

        function tab:SelectSectionTab(name)
            for _, section in ipairs(self.Sections) do
                local active = section.GroupName == name
                section.Container.Visible = active
                if section.GroupButton then
                    Utility.Tween(section.GroupButton, Defaults.FastAnimation, {
                        BackgroundColor3 = active and Theme.AccentSoft or Theme.Surface2
                    })
                    Utility.Tween(section.GroupStroke, Defaults.FastAnimation, {
                        Color = active and Theme.Accent or Theme.StrokeSoft
                    })
                    section.GroupLabel.TextColor3 = active and Theme.Accent or Theme.TextDim
                end
            end
        end

        function tab:Show()
            if self.Window.ActiveTab then
                self.Window.ActiveTab.Page.Visible = false
                Utility.Tween(self.Window.ActiveTab.Button, Defaults.FastAnimation, {BackgroundColor3 = Theme.Surface2})
                Utility.Tween(self.Window.ActiveTab.ButtonStroke, Defaults.FastAnimation, {Color = Theme.StrokeSoft})
            end
            self.Window.ActiveTab = self
            self.Page.Visible = true
            Utility.Tween(self.Button, Defaults.FastAnimation, {BackgroundColor3 = Theme.AccentSoft})
            Utility.Tween(self.ButtonStroke, Defaults.FastAnimation, {Color = Theme.Accent})
        end

        button.MouseButton1Click:Connect(function()
            tab:Show()
        end)
        Utility.Hover(button, Theme.Surface3, buttonStroke)

        function tab:CreateSection(options)
            options = options or {}
            local section = setmetatable({}, Section)
            section.Tab = self
            section.Name = options.Name or "Section"
            section.GroupName = options.Group or "Main"
            section.Elements = {}

            local existingButton
            for _, sec in ipairs(self.Sections) do
                if sec.GroupName == section.GroupName then
                    existingButton = sec.GroupButton
                    break
                end
            end

            if not existingButton then
                local groupButton = create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = #self.Sections == 0 and Theme.AccentSoft or Theme.Surface2,
                    Size = UDim2.fromOffset(96, 30),
                    Font = Defaults.FontMedium,
                    Text = section.GroupName,
                    TextColor3 = #self.Sections == 0 and Theme.Accent or Theme.TextDim,
                    TextSize = 13,
                    Parent = sectionTabBar
                })
                Utility.Corner(groupButton, 999)
                local gs = Utility.Stroke(groupButton, #self.Sections == 0 and Theme.Accent or Theme.StrokeSoft, 1)
                Utility.Ripple(groupButton)
                groupButton.MouseButton1Click:Connect(function()
                    self:SelectSectionTab(section.GroupName)
                end)
                section.GroupButton = groupButton
                section.GroupStroke = gs
                section.GroupLabel = groupButton
            end

            local container = create("ScrollingFrame", {
                Name = section.Name,
                Visible = (#self.Sections == 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 0,
                BorderSizePixel = 0,
                Parent = sectionPages
            })
            Utility.List(container, 12)

            local holder = create("Frame", {
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 44),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = container
            })
            Utility.Corner(holder, 14)
            Utility.Stroke(holder, Theme.StrokeSoft, 1)
            Utility.Padding(holder, 14, 14, 14, 14)
            local holderLayout = Utility.List(holder, 10)

            local header = create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = holder
            })

            local sectionTitle = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.fromOffset(0, 0),
                Font = Defaults.FontBold,
                Text = section.Name,
                TextColor3 = Theme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })

            local sectionSub = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.fromOffset(0, 16),
                Font = Defaults.FontMedium,
                Text = options.Description or "smooth modern controls",
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })

            section.Container = container
            section.Frame = holder
            section.List = holderLayout
            section.GroupButton = existingButton or section.GroupButton
            section.GroupStroke = section.GroupStroke or (existingButton and existingButton:FindFirstChildOfClass("UIStroke"))
            section.GroupLabel = section.GroupLabel or existingButton

            function section:Resize(item, height)
                item.Size = UDim2.new(1, 0, 0, height)
            end

            function section:CreateDivider(text)
                local line = create("Frame", {
                    BackgroundColor3 = Theme.StrokeSoft,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = holder
                })
                if text then
                    local label = create("TextLabel", {
                        BackgroundColor3 = Theme.Surface2,
                        Text = "  "..text.."  ",
                        TextColor3 = Theme.TextDim,
                        Font = Defaults.FontMedium,
                        TextSize = 11,
                        Size = UDim2.fromOffset(80, 16),
                        Position = UDim2.new(0, 10, 0, -8),
                        Parent = line
                    })
                end
                return line
            end

            local function createElementFrame(height)
                local frame = create("Frame", {
                    BackgroundColor3 = Theme.Surface3,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, height),
                    Parent = holder
                })
                Utility.Corner(frame, 12)
                Utility.Stroke(frame, Theme.StrokeSoft, 1)
                return frame
            end

            local function createLabelPair(parent, titleText, subText)
                local titleLabel = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 9),
                    Size = UDim2.new(1, -140, 0, 18),
                    Font = Defaults.FontMedium,
                    Text = titleText,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = parent
                })
                local subtitleLabel = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 26),
                    Size = UDim2.new(1, -140, 0, 16),
                    Font = Defaults.Font,
                    Text = subText or "",
                    TextColor3 = Theme.TextDim,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = parent
                })
                return titleLabel, subtitleLabel
            end

            function section:AddLabel(text)
                local frame = createElementFrame(36)
                local label = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    Font = Defaults.FontMedium,
                    Text = text,
                    TextColor3 = Theme.TextDim,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })
                return label
            end

            function section:AddButton(options)
                options = options or {}
                local frame = createElementFrame(48)
                local button = create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1,1),
                    Text = "",
                    Parent = frame
                })
                createLabelPair(frame, options.Text or "Button", options.Description or "click me")
                local pill = create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(82, 28),
                    BackgroundColor3 = Theme.AccentSoft,
                    Font = Defaults.FontBold,
                    Text = options.ButtonText or "RUN",
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Parent = frame
                })
                Utility.Corner(pill, 999)
                Utility.Stroke(pill, Theme.Accent, 1, 0.28)
                Utility.Ripple(button)
                Utility.Hover(frame, Theme.Surface3:Lerp(Theme.AccentSoft, 0.18), frame:FindFirstChildOfClass("UIStroke"))
                button.MouseButton1Click:Connect(function()
                    safeCallback(options.Callback)
                end)
                return button
            end

            function section:AddToggle(options)
                options = options or {}
                local flag = options.Flag or options.Text or tostring(#self.Elements + 1)
                local state = options.Default or false
                section.Tab.Window.Flags[flag] = state

                local frame = createElementFrame(54)
                createLabelPair(frame, options.Text or "Toggle", options.Description or "enable / disable")

                local toggleBack = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(52, 28),
                    BackgroundColor3 = state and Theme.Accent or Theme.Surface,
                    Parent = frame
                })
                Utility.Corner(toggleBack, 999)
                local toggleStroke = Utility.Stroke(toggleBack, state and Theme.AccentDark or Theme.StrokeSoft, 1)

                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    Parent = toggleBack
                })
                Utility.Corner(knob, 999)

                local button = create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1,1),
                    Text = "",
                    Parent = frame
                })
                Utility.Ripple(button)

                local object = {}
                function object:Set(value)
                    state = value
                    section.Tab.Window.Flags[flag] = state
                    Utility.Tween(toggleBack, Defaults.Animation, {BackgroundColor3 = state and Theme.Accent or Theme.Surface})
                    Utility.Tween(toggleStroke, Defaults.Animation, {Color = state and Theme.AccentDark or Theme.StrokeSoft})
                    Utility.Tween(knob, Defaults.Animation, {Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)})
                    safeCallback(options.Callback, state)
                end
                function object:Get() return state end
                button.MouseButton1Click:Connect(function() object:Set(not state) end)
                if options.Callback then task.defer(function() options.Callback(state) end) end
                return object
            end

            function section:AddSlider(options)
                options = options or {}
                local min = options.Min or 0
                local max = options.Max or 100
                local step = options.Step or 1
                local value = options.Default or min
                local draggingSlider = false

                local frame = createElementFrame(70)
                local title, sub = createLabelPair(frame, options.Text or "Slider", options.Description or string.format("%s - %s", min, max))
                sub.Text = tostring(value)

                local bar = create("Frame", {
                    BackgroundColor3 = Theme.Surface,
                    Position = UDim2.new(0, 12, 1, -18),
                    Size = UDim2.new(1, -24, 0, 8),
                    Parent = frame
                })
                Utility.Corner(bar, 999)

                local fill = create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((value - min)/(max - min), 0, 1, 0),
                    Parent = bar
                })
                Utility.Corner(fill, 999)

                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((value - min)/(max - min), 0, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    Parent = bar
                })
                Utility.Corner(knob, 999)

                local drag = create("TextButton", {
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1,1),
                    Text = "",
                    Parent = frame
                })

                local object = {}
                function object:Set(v)
                    v = math.clamp(v, min, max)
                    v = math.floor(v / step + 0.5) * step
                    value = v
                    local alpha = (value - min)/(max - min)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                    sub.Text = tostring(value)
                    safeCallback(options.Callback, value)
                end
                function object:Get() return value end

                local function update(input)
                    local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    object:Set(min + ((max - min) * alpha))
                end

                drag.MouseButton1Down:Connect(function(x, y)
                    draggingSlider = true
                    update({Position = Vector3.new(x,y,0)})
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                if options.Callback then task.defer(function() options.Callback(value) end) end
                return object
            end

            function section:AddTextbox(options)
                options = options or {}
                local frame = createElementFrame(58)
                createLabelPair(frame, options.Text or "Textbox", options.Description or "type text here")

                local box = create("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(180, 32),
                    BackgroundColor3 = Theme.Surface,
                    Text = options.Default or "",
                    PlaceholderText = options.Placeholder or "...",
                    ClearTextOnFocus = false,
                    Font = Defaults.FontMedium,
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.TextDim,
                    TextSize = 13,
                    Parent = frame
                })
                Utility.Corner(box, 10)
                Utility.Stroke(box, Theme.StrokeSoft, 1)
                Utility.Padding(box, 12, 12, 0, 0)
                box.FocusLost:Connect(function(enter)
                    if enter or options.FireOnFocusLost ~= false then
                        safeCallback(options.Callback, box.Text)
                    end
                end)
                return box
            end

            function section:AddDropdown(options)
                options = options or {}
                local values = options.Values or {}
                local selected = options.Default or values[1] or "None"
                local opened = false

                local frame = createElementFrame(54)
                createLabelPair(frame, options.Text or "Dropdown", options.Description or "select one")

                local dropdown = create("TextButton", {
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(180, 32),
                    BackgroundColor3 = Theme.Surface,
                    Text = selected,
                    Font = Defaults.FontMedium,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Parent = frame
                })
                Utility.Corner(dropdown, 10)
                Utility.Stroke(dropdown, Theme.StrokeSoft, 1)
                Utility.Ripple(dropdown)

                local list = create("Frame", {
                    Visible = false,
                    BackgroundColor3 = Theme.Surface,
                    Position = UDim2.new(0, 0, 1, 6),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = dropdown
                })
                Utility.Corner(list, 10)
                Utility.Stroke(list, Theme.StrokeSoft, 1)
                Utility.Padding(list, 6, 6, 6, 6)
                Utility.List(list, 6)

                for _, val in ipairs(values) do
                    local optionButton = create("TextButton", {
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme.Surface2,
                        Size = UDim2.new(1, 0, 0, 28),
                        Text = tostring(val),
                        Font = Defaults.FontMedium,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        Parent = list
                    })
                    Utility.Corner(optionButton, 8)
                    local st = Utility.Stroke(optionButton, Theme.StrokeSoft, 1)
                    Utility.Hover(optionButton, Theme.Surface3, st)
                    optionButton.MouseButton1Click:Connect(function()
                        selected = val
                        dropdown.Text = tostring(val)
                        opened = false
                        list.Visible = false
                        safeCallback(options.Callback, selected)
                    end)
                end

                dropdown.MouseButton1Click:Connect(function()
                    opened = not opened
                    list.Visible = opened
                end)

                if options.Callback then task.defer(function() options.Callback(selected) end) end
                return {
                    Set = function(_, v)
                        selected = v
                        dropdown.Text = tostring(v)
                        safeCallback(options.Callback, selected)
                    end,
                    Get = function() return selected end
                }
            end

            function section:AddColorPicker(options)
                options = options or {}
                local color = options.Default or Theme.Accent
                local hue, sat, val = color:ToHSV()
                local opened = false

                local frame = createElementFrame(54)
                createLabelPair(frame, options.Text or "Color Picker", options.Description or "pick accent / custom color")

                local preview = create("TextButton", {
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(58, 32),
                    BackgroundColor3 = color,
                    Text = "",
                    Parent = frame
                })
                Utility.Corner(preview, 10)
                Utility.Stroke(preview, Theme.StrokeSoft, 1)
                Utility.Ripple(preview)

                local picker = create("Frame", {
                    Visible = false,
                    BackgroundColor3 = Theme.Surface,
                    Position = UDim2.new(0, 0, 1, 6),
                    Size = UDim2.fromOffset(220, 170),
                    Parent = preview
                })
                Utility.Corner(picker, 12)
                Utility.Stroke(picker, Theme.StrokeSoft, 1)
                Utility.Padding(picker, 10, 10, 10, 10)

                local sv = create("ImageButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    Size = UDim2.fromOffset(150, 120),
                    Image = "rbxassetid://4155801252",
                    Parent = picker
                })
                Utility.Corner(sv, 10)
                local svCursor = create("Frame", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(sat, 0, 1 - val, 0),
                    Size = UDim2.fromOffset(10,10),
                    BackgroundColor3 = Color3.new(1,1,1),
                    Parent = sv
                })
                Utility.Corner(svCursor, 999)

                local hueBar = create("ImageButton", {
                    AutoButtonColor = false,
                    Position = UDim2.fromOffset(160, 0),
                    Size = UDim2.fromOffset(18, 120),
                    BackgroundColor3 = Color3.new(1,1,1),
                    Image = "rbxassetid://3641079629",
                    Parent = picker
                })
                Utility.Corner(hueBar, 999)

                local hueCursor = create("Frame", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(0.5, 0, hue, 0),
                    Size = UDim2.new(1, 4, 0, 4),
                    BackgroundColor3 = Color3.new(1,1,1),
                    Parent = hueBar
                })
                Utility.Corner(hueCursor, 999)

                local rgbBox = create("TextBox", {
                    Position = UDim2.fromOffset(0, 128),
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.Surface2,
                    Text = string.format("%d, %d, %d", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                    Font = Defaults.FontMedium,
                    TextColor3 = Theme.Text,
                    PlaceholderText = "r, g, b",
                    ClearTextOnFocus = false,
                    TextSize = 12,
                    Parent = picker
                })
                Utility.Corner(rgbBox, 8)
                Utility.Stroke(rgbBox, Theme.StrokeSoft, 1)
                Utility.Padding(rgbBox, 10, 10, 0, 0)

                local draggingSV, draggingHue = false, false

                local object = {}
                function object:Set(newColor)
                    color = newColor
                    hue, sat, val = color:ToHSV()
                    preview.BackgroundColor3 = color
                    sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
                    rgbBox.Text = string.format("%d, %d, %d", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                    safeCallback(options.Callback, color)
                end
                function object:Get() return color end

                local function updateFromSV(input)
                    local x = math.clamp((input.Position.X - sv.AbsolutePosition.X)/sv.AbsoluteSize.X, 0, 1)
                    local y = math.clamp((input.Position.Y - sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y, 0, 1)
                    sat = x
                    val = 1 - y
                    object:Set(Color3.fromHSV(hue, sat, val))
                end
                local function updateFromHue(input)
                    local y = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y, 0, 1)
                    hue = y
                    object:Set(Color3.fromHSV(hue, sat, val))
                end

                sv.MouseButton1Down:Connect(function(x, y)
                    draggingSV = true
                    updateFromSV({Position = Vector3.new(x,y,0)})
                end)
                hueBar.MouseButton1Down:Connect(function(x, y)
                    draggingHue = true
                    updateFromHue({Position = Vector3.new(x,y,0)})
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingSV then updateFromSV(input) end
                        if draggingHue then updateFromHue(input) end
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = false
                        draggingHue = false
                    end
                end)
                rgbBox.FocusLost:Connect(function()
                    local r,g,b = rgbBox.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
                    if r and g and b then
                        object:Set(Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)))
                    end
                end)
                preview.MouseButton1Click:Connect(function()
                    opened = not opened
                    picker.Visible = opened
                end)
                if options.Callback then task.defer(function() options.Callback(color) end) end
                return object
            end

            function section:AddKeybind(options)
                options = options or {}
                local bind = setmetatable({}, KeybindPicker)
                bind.Window = section.Tab.Window
                bind.Title = options.Text or "Keybind"
                bind.Value = options.Default or Enum.KeyCode.E
                bind.Mode = options.Mode or "Toggle"
                bind.State = false
                bind.Callback = options.Callback
                bind.Enabled = true

                local frame = createElementFrame(60)
                createLabelPair(frame, bind.Title, options.Description or "pick a key + toggle / hold mode")

                local modeButton = create("TextButton", {
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -82, 0.5, 0),
                    Size = UDim2.fromOffset(70, 32),
                    BackgroundColor3 = Theme.Surface,
                    Font = Defaults.FontMedium,
                    Text = bind.Mode,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Parent = frame
                })
                Utility.Corner(modeButton, 10)
                Utility.Stroke(modeButton, Theme.StrokeSoft, 1)
                Utility.Ripple(modeButton)

                local keyButton = create("TextButton", {
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(62, 32),
                    BackgroundColor3 = Theme.Surface,
                    Font = Defaults.FontBold,
                    Text = bind.Value.Name,
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Parent = frame
                })
                Utility.Corner(keyButton, 10)
                Utility.Stroke(keyButton, Theme.StrokeSoft, 1)
                Utility.Ripple(keyButton)

                local listening = false
                keyButton.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    keyButton.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            bind.Value = input.KeyCode
                            keyButton.Text = bind.Value.Name
                            if bind.VisualValue then
                                bind.VisualValue.Text = bind.Value.Name
                            end
                            listening = false
                            conn:Disconnect()
                        end
                    end)
                end)

                modeButton.MouseButton1Click:Connect(function()
                    bind.Mode = bind.Mode == "Toggle" and "Hold" or "Toggle"
                    modeButton.Text = bind.Mode
                    if bind.VisualMeta then
                        bind.VisualMeta.Text = string.format("%s mode", string.lower(bind.Mode))
                    end
                end)

                function bind:SetVisualState(active)
                    Utility.Tween(keyButton, Defaults.FastAnimation, {
                        BackgroundColor3 = active and Theme.AccentSoft or Theme.Surface
                    })
                    keyButton.TextColor3 = active and Theme.Accent or Theme.Text
                end

                function bind:SetKey(key)
                    bind.Value = key
                    keyButton.Text = key.Name
                    if bind.VisualValue then bind.VisualValue.Text = key.Name end
                end

                function bind:SetMode(mode)
                    bind.Mode = mode
                    modeButton.Text = mode
                    if bind.VisualMeta then bind.VisualMeta.Text = string.format("%s mode", string.lower(mode)) end
                end

                section.Tab.Window:RegisterKeybind(bind)
                return bind
            end

            function section:AddParagraph(options)
                options = options or {}
                local text = options.Text or "Paragraph"
                local contentText = options.Content or "Content"
                local bounds = Utility.TextBounds(contentText, 12, Defaults.Font, 560)
                local frame = createElementFrame(54 + bounds.Y)
                local titleLabel, bodyLabel = createLabelPair(frame, text, "")
                bodyLabel.Position = UDim2.fromOffset(12, 28)
                bodyLabel.Size = UDim2.new(1, -24, 0, bounds.Y + 4)
                bodyLabel.TextWrapped = true
                bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
                bodyLabel.Text = contentText
                return frame
            end

            table.insert(self.Sections, section)
            return section
        end

        table.insert(self.Tabs, tab)
        if not self.ActiveTab then
            task.defer(function() tab:Show() end)
        end
        return tab
    end

    return self
end

return setmetatable({}, Library)
