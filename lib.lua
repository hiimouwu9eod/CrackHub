


local CrackedLib = {}

-- CrackedLib v2
-- Fixed/reworked version of the supplied library.
-- Preserves the public API: Init, CreateTab, Section, Button, Label,
-- Toggle, Slider, Dropdown, ConfigToggle, ConfigSlider, ConfigDropdown.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

CrackedLib.Theme = {
    Default = {
        TextColor = Color3.fromRGB(240,240,240), Background = Color3.fromRGB(25,25,25),
        Topbar = Color3.fromRGB(34,34,34), Line = Color3.fromRGB(48,48,48), Navigation = Color3.fromRGB(30,30,30),
        TabBackground = Color3.fromRGB(80,80,80), TabStroke = Color3.fromRGB(85,85,85),
        TabBackgroundSelected = Color3.fromRGB(210,210,210), TabTextColor = Color3.fromRGB(240,240,240),
        SelectedTabTextColor = Color3.fromRGB(50,50,50), ElementBackground = Color3.fromRGB(45,45,45),
        ElementBackgroundHover = Color3.fromRGB(80,80,80), ElementStroke = Color3.fromRGB(80,80,80),
        ElementStrokeHover = Color3.fromRGB(100,100,100)
    },
    Light = {
        TextColor = Color3.fromRGB(30,30,30), Background = Color3.fromRGB(245,245,245),
        Topbar = Color3.fromRGB(230,230,230), Line = Color3.fromRGB(200,200,200), Navigation = Color3.fromRGB(235,235,235),
        TabBackground = Color3.fromRGB(220,220,220), TabStroke = Color3.fromRGB(180,180,180),
        TabBackgroundSelected = Color3.fromRGB(100,100,100), TabTextColor = Color3.fromRGB(40,40,40),
        SelectedTabTextColor = Color3.fromRGB(255,255,255), ElementBackground = Color3.fromRGB(255,255,255),
        ElementBackgroundHover = Color3.fromRGB(230,230,230), ElementStroke = Color3.fromRGB(200,200,200),
        ElementStrokeHover = Color3.fromRGB(160,160,160)
    },
    Purple = {
        TextColor = Color3.fromRGB(245,245,255), Background = Color3.fromRGB(28,20,48), Topbar = Color3.fromRGB(45,30,75),
        Line = Color3.fromRGB(130,70,220), Navigation = Color3.fromRGB(38,25,62), TabBackground = Color3.fromRGB(55,35,90),
        TabStroke = Color3.fromRGB(160,90,255), TabBackgroundSelected = Color3.fromRGB(190,110,255),
        TabTextColor = Color3.fromRGB(245,245,255), SelectedTabTextColor = Color3.fromRGB(30,15,55),
        ElementBackground = Color3.fromRGB(45,30,75), ElementBackgroundHover = Color3.fromRGB(80,50,130),
        ElementStroke = Color3.fromRGB(160,90,255), ElementStrokeHover = Color3.fromRGB(200,130,255)
    },
    Ocean = {
        TextColor = Color3.fromRGB(230,245,255), Background = Color3.fromRGB(15,30,55), Topbar = Color3.fromRGB(20,45,85),
        Line = Color3.fromRGB(70,160,240), Navigation = Color3.fromRGB(18,38,70), TabBackground = Color3.fromRGB(30,60,110),
        TabStroke = Color3.fromRGB(90,180,255), TabBackgroundSelected = Color3.fromRGB(110,205,255),
        TabTextColor = Color3.fromRGB(230,245,255), SelectedTabTextColor = Color3.fromRGB(10,25,50),
        ElementBackground = Color3.fromRGB(25,50,85), ElementBackgroundHover = Color3.fromRGB(50,95,160),
        ElementStroke = Color3.fromRGB(90,180,255), ElementStrokeHover = Color3.fromRGB(130,215,255)
    },
    Red = {
        TextColor = Color3.fromRGB(255,235,235), Background = Color3.fromRGB(35,20,20), Topbar = Color3.fromRGB(55,25,25),
        Line = Color3.fromRGB(220,60,60), Navigation = Color3.fromRGB(48,22,22), TabBackground = Color3.fromRGB(70,30,30),
        TabStroke = Color3.fromRGB(255,90,90), TabBackgroundSelected = Color3.fromRGB(255,120,120),
        TabTextColor = Color3.fromRGB(255,235,235), SelectedTabTextColor = Color3.fromRGB(45,15,15),
        ElementBackground = Color3.fromRGB(55,25,25), ElementBackgroundHover = Color3.fromRGB(90,40,40),
        ElementStroke = Color3.fromRGB(255,100,100), ElementStrokeHover = Color3.fromRGB(255,150,150)
    },
    Green = {
        TextColor = Color3.fromRGB(230,255,235), Background = Color3.fromRGB(15,30,20), Topbar = Color3.fromRGB(20,50,32),
        Line = Color3.fromRGB(50,190,90), Navigation = Color3.fromRGB(18,38,25), TabBackground = Color3.fromRGB(25,60,40),
        TabStroke = Color3.fromRGB(70,220,120), TabBackgroundSelected = Color3.fromRGB(110,255,160),
        TabTextColor = Color3.fromRGB(230,255,235), SelectedTabTextColor = Color3.fromRGB(10,30,18),
        ElementBackground = Color3.fromRGB(25,55,35), ElementBackgroundHover = Color3.fromRGB(45,100,65),
        ElementStroke = Color3.fromRGB(70,220,120), ElementStrokeHover = Color3.fromRGB(110,255,160)
    },
    Midnight = {
        TextColor = Color3.fromRGB(235,235,245), Background = Color3.fromRGB(16,16,26), Topbar = Color3.fromRGB(26,26,46),
        Line = Color3.fromRGB(75,75,120), Navigation = Color3.fromRGB(20,20,34), TabBackground = Color3.fromRGB(35,35,58),
        TabStroke = Color3.fromRGB(110,110,190), TabBackgroundSelected = Color3.fromRGB(145,145,255),
        TabTextColor = Color3.fromRGB(235,235,245), SelectedTabTextColor = Color3.fromRGB(20,20,40),
        ElementBackground = Color3.fromRGB(28,28,48), ElementBackgroundHover = Color3.fromRGB(55,55,85),
        ElementStroke = Color3.fromRGB(95,95,170), ElementStrokeHover = Color3.fromRGB(135,135,225)
    },
    Sakura = {
        TextColor = Color3.fromRGB(255,235,240), Background = Color3.fromRGB(45,25,35), Topbar = Color3.fromRGB(65,35,50),
        Line = Color3.fromRGB(255,140,180), Navigation = Color3.fromRGB(52,29,41), TabBackground = Color3.fromRGB(80,45,65),
        TabStroke = Color3.fromRGB(255,160,200), TabBackgroundSelected = Color3.fromRGB(255,190,220),
        TabTextColor = Color3.fromRGB(255,235,240), SelectedTabTextColor = Color3.fromRGB(60,20,40),
        ElementBackground = Color3.fromRGB(70,40,55), ElementBackgroundHover = Color3.fromRGB(100,60,80),
        ElementStroke = Color3.fromRGB(255,170,210), ElementStrokeHover = Color3.fromRGB(255,200,230)
    },
    Cyberpunk = {
        TextColor = Color3.fromRGB(200,255,240), Background = Color3.fromRGB(10,8,25), Topbar = Color3.fromRGB(25,10,60),
        Line = Color3.fromRGB(0,255,200), Navigation = Color3.fromRGB(14,10,38), TabBackground = Color3.fromRGB(35,15,80),
        TabStroke = Color3.fromRGB(0,255,220), TabBackgroundSelected = Color3.fromRGB(0,230,190),
        TabTextColor = Color3.fromRGB(200,255,240), SelectedTabTextColor = Color3.fromRGB(10,5,30),
        ElementBackground = Color3.fromRGB(20,15,55), ElementBackgroundHover = Color3.fromRGB(50,30,100),
        ElementStroke = Color3.fromRGB(0,255,200), ElementStrokeHover = Color3.fromRGB(120,255,220)
    }
}

-- Filesystem-backed config is optional. Never let a missing executor API break the UI.
local function fsAvailable()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

CrackedLib.Config = { FileName = "CrackedLib.json", Data = {} }

function CrackedLib.Config:Save()
    if not fsAvailable() then return false end
    local ok = pcall(function()
        writefile(self.FileName, HttpService:JSONEncode(self.Data))
    end)
    return ok
end

function CrackedLib.Config:Load()
    if not fsAvailable() then return false end
    local ok = pcall(function()
        if isfile(self.FileName) then
            local decoded = HttpService:JSONDecode(readfile(self.FileName))
            if type(decoded) == "table" then self.Data = decoded end
        end
    end)
    return ok
end

CrackedLib.Config:Load()

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function connectAndTrack(connections, signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function disconnectAll(connections)
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(connections)
end

local function copyText(text)
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, text)
        return ok
    end
    return false
end

function CrackedLib:Init(name, draggable, keybind, theme, keysystem)
    local GUI = {}
    local CurrentTheme = self.Theme[theme] or self.Theme.Default
    self.CurrentTheme = CurrentTheme

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local connections = {}
    local destroyed = false

    -- Remove an older instance created by this library.
    local old = PlayerGui:FindFirstChild("CrackLib")
    if old then old:Destroy() end

    -- Key system: accepts the documented table. A legacy boolean is treated as disabled
    -- instead of silently hanging Init().
    if type(keysystem) == "table" and keysystem.Enabled then
        local Key = tostring(keysystem.Key or "")
        local CopyLink = tostring(keysystem.copyLink or "")
        local KeyPassed = false
        local Cancelled = false

        local KeySystem = Instance.new("ScreenGui")
        KeySystem.Name = "KeySystem"
        KeySystem.ResetOnSpawn = false
        KeySystem.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        KeySystem.IgnoreGuiInset = true
        KeySystem.Parent = PlayerGui

        local KM = Instance.new("Frame")
        KM.Size = UDim2.fromScale(0.49, 0.36)
        KM.Position = UDim2.fromScale(0.255, 0.32)
        KM.BackgroundColor3 = Color3.fromRGB(35,35,35)
        KM.BorderSizePixel = 0
        KM.Parent = KeySystem
        makeCorner(KM, 10)
        makeStroke(KM, Color3.fromRGB(82,82,82), 3)

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromScale(0.05,0.08)
        title.Size = UDim2.fromScale(0.9,0.16)
        title.Font = Enum.Font.SourceSansBold
        title.Text = tostring(keysystem.Title or "Cracked Hub Key")
        title.TextColor3 = Color3.new(1,1,1)
        title.TextScaled = true
        title.Parent = KM

        local box = Instance.new("TextBox")
        box.Position = UDim2.fromScale(0.18,0.40)
        box.Size = UDim2.fromScale(0.64,0.14)
        box.BackgroundColor3 = Color3.fromRGB(48,48,48)
        box.BorderSizePixel = 0
        box.PlaceholderText = "Enter Key: XXX-XXX"
        box.Text = ""
        box.TextColor3 = Color3.new(1,1,1)
        box.TextScaled = true
        box.Parent = KM
        makeCorner(box, 8)
        makeStroke(box, Color3.fromRGB(102,102,102), 2)

        local link = Instance.new("TextButton")
        link.Position = UDim2.fromScale(0.05,0.66)
        link.Size = UDim2.fromScale(0.25,0.20)
        link.BackgroundColor3 = Color3.fromRGB(64,64,64)
        link.BorderSizePixel = 0
        link.Text = "Copy Key Link"
        link.TextColor3 = Color3.new(1,1,1)
        link.TextScaled = true
        link.Parent = KM
        makeCorner(link, 8)

        local load = Instance.new("TextButton")
        load.Position = UDim2.fromScale(0.70,0.66)
        load.Size = UDim2.fromScale(0.25,0.20)
        load.BackgroundColor3 = Color3.fromRGB(64,64,64)
        load.BorderSizePixel = 0
        load.Text = "Load Key"
        load.TextColor3 = Color3.new(1,1,1)
        load.TextScaled = true
        load.Parent = KM
        makeCorner(load, 8)

        local notice = Instance.new("TextLabel")
        notice.BackgroundTransparency = 1
        notice.Position = UDim2.fromScale(0.30,0.66)
        notice.Size = UDim2.fromScale(0.40,0.20)
        notice.Text = "Fast Keys!"
        notice.TextColor3 = Color3.new(1,1,1)
        notice.TextScaled = true
        notice.Parent = KM

        local close = Instance.new("TextButton")
        close.BackgroundTransparency = 1
        close.Position = UDim2.fromScale(0.90,0.04)
        close.Size = UDim2.fromScale(0.06,0.10)
        close.Text = "×"
        close.TextColor3 = Color3.new(1,1,1)
        close.TextScaled = true
        close.Parent = KM

        local function checkKey()
            local entered = box.Text:gsub("%s+", "")
            if entered == Key then
                notice.Text = "Correct!"
                notice.TextColor3 = Color3.fromRGB(100,255,100)
                KeyPassed = true
                task.delay(0.35, function()
                    if KeySystem.Parent then KeySystem:Destroy() end
                end)
            else
                notice.Text = "Wrong Key!"
                notice.TextColor3 = Color3.fromRGB(255,80,80)
                box.Text = ""
            end
        end

        connectAndTrack(connections, load.MouseButton1Click, checkKey)
        connectAndTrack(connections, box.FocusLost, function(enterPressed)
            if enterPressed then checkKey() end
        end)
        connectAndTrack(connections, link.MouseButton1Click, function()
            if CopyLink == "" then
                notice.Text = "No Link Set"
                notice.TextColor3 = Color3.fromRGB(255,150,80)
            elseif copyText(CopyLink) then
                notice.Text = "Link Copied!"
                notice.TextColor3 = Color3.fromRGB(100,200,255)
            else
                notice.Text = "Clipboard unavailable"
                notice.TextColor3 = Color3.fromRGB(255,150,80)
            end
        end)
        connectAndTrack(connections, close.MouseButton1Click, function()
            Cancelled = true
            KeySystem:Destroy()
        end)

        repeat task.wait() until KeyPassed or Cancelled or not KeySystem.Parent
        if not KeyPassed then
            disconnectAll(connections)
            return nil
        end
        disconnectAll(connections)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrackLib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromScale(0.51,0.54)
    Main.Position = UDim2.fromScale(0.245,0.228)
    Main.BackgroundColor3 = CurrentTheme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    makeCorner(Main, 10)
    makeStroke(Main, CurrentTheme.ElementStroke, 2)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1,0,0,52)
    Topbar.BackgroundColor3 = CurrentTheme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    makeCorner(Topbar, 10)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0,14,0,7)
    title.Size = UDim2.new(0.68,0,1,-14)
    title.Font = Enum.Font.SourceSansBold
    title.Text = tostring(name or "CrackedLib")
    title.TextColor3 = CurrentTheme.TextColor
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = Topbar

    local Minus = Instance.new("TextButton")
    Minus.BackgroundTransparency = 1
    Minus.Position = UDim2.new(1,-82,0,8)
    Minus.Size = UDim2.fromOffset(32,32)
    Minus.Text = "−"
    Minus.TextColor3 = CurrentTheme.TextColor
    Minus.TextScaled = true
    Minus.Parent = Topbar

    local Exit = Instance.new("TextButton")
    Exit.BackgroundTransparency = 1
    Exit.Position = UDim2.new(1,-44,0,8)
    Exit.Size = UDim2.fromOffset(32,32)
    Exit.Text = "×"
    Exit.TextColor3 = CurrentTheme.TextColor
    Exit.TextScaled = true
    Exit.Parent = Topbar

    local Line = Instance.new("Frame")
    Line.Position = UDim2.new(0,0,0,50)
    Line.Size = UDim2.new(1,0,0,2)
    Line.BackgroundColor3 = CurrentTheme.Line
    Line.BorderSizePixel = 0
    Line.Parent = Main

    local Navigation = Instance.new("Frame")
    Navigation.Position = UDim2.new(0,0,0,52)
    Navigation.Size = UDim2.new(0.255,0,1,-52)
    Navigation.BackgroundColor3 = CurrentTheme.Navigation
    Navigation.BorderSizePixel = 0
    Navigation.Parent = Main
    makeCorner(Navigation, 8)

    local ButtonHolder = Instance.new("ScrollingFrame")
    ButtonHolder.Size = UDim2.fromScale(1,1)
    ButtonHolder.BackgroundTransparency = 1
    ButtonHolder.BorderSizePixel = 0
    ButtonHolder.ScrollBarThickness = 0
    ButtonHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ButtonHolder.CanvasSize = UDim2.new()
    ButtonHolder.Parent = Navigation

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.Padding = UDim.new(0,6)
    NavLayout.Parent = ButtonHolder
    local NavPadding = Instance.new("UIPadding")
    NavPadding.PaddingTop = UDim.new(0,8)
    NavPadding.PaddingLeft = UDim.new(0,8)
    NavPadding.PaddingRight = UDim.new(0,8)
    NavPadding.Parent = ButtonHolder

    local Divider = Instance.new("Frame")
    Divider.Position = UDim2.new(1,-2,0,0)
    Divider.Size = UDim2.new(0,2,1,0)
    Divider.BackgroundColor3 = CurrentTheme.Line
    Divider.BorderSizePixel = 0
    Divider.Parent = Navigation

    local TabHolder = Instance.new("Frame")
    TabHolder.Position = UDim2.new(0.255,0,0,52)
    TabHolder.Size = UDim2.new(0.745,0,1,-52)
    TabHolder.BackgroundTransparency = 1
    TabHolder.Parent = Main

    local TabContent = Instance.new("Folder")
    TabContent.Parent = TabHolder

    local tabs = {}
    local selectedTab

    local function selectTab(tabInfo)
        selectedTab = tabInfo
        for _, info in ipairs(tabs) do
            info.Content.Visible = info == tabInfo
            info.Button.BackgroundColor3 = info == tabInfo and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabBackground
            info.Button.TextColor3 = info == tabInfo and CurrentTheme.SelectedTabTextColor or CurrentTheme.TabTextColor
            info.Stroke.Color = info == tabInfo and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabStroke
        end
    end

    function GUI:CreateTab(text)
        local TabData = {}
        local info = {}
        local Tab = Instance.new("TextButton")
        Tab.Size = UDim2.new(1,0,0,38)
        Tab.BackgroundColor3 = CurrentTheme.TabBackground
        Tab.BackgroundTransparency = 0.2
        Tab.BorderSizePixel = 0
        Tab.Text = tostring(text or "Tab")
        Tab.TextColor3 = CurrentTheme.TabTextColor
        Tab.TextScaled = true
        Tab.AutoButtonColor = false
        Tab.Parent = ButtonHolder
        makeCorner(Tab, 7)
        local stroke = makeStroke(Tab, CurrentTheme.TabStroke, 2)

        local content = Instance.new("Frame")
        content.Name = tostring(text or "Tab")
        content.Size = UDim2.fromScale(1,1)
        content.BackgroundColor3 = CurrentTheme.Background
        content.BorderSizePixel = 0
        content.Visible = false
        content.Parent = TabContent

        info.Button, info.Content, info.Stroke = Tab, content, stroke
        table.insert(tabs, info)

        connectAndTrack(connections, Tab.MouseButton1Click, function() selectTab(info) end)
        if not selectedTab then selectTab(info) end

        function TabData:Section(sectionName)
            local SectionData = {}
            local section = Instance.new("Frame")
            section.Name = tostring(sectionName or "Section")
            section.Position = UDim2.new(0,0,0,0)
            section.Size = UDim2.new(1,0,0,42)
            section.BackgroundTransparency = 1
            section.Parent = content

            local sectionButtons = Instance.new("Frame")
            sectionButtons.Size = UDim2.new(1,0,0,42)
            sectionButtons.BackgroundTransparency = 1
            sectionButtons.Parent = section
            local sbLayout = Instance.new("UIListLayout")
            sbLayout.FillDirection = Enum.FillDirection.Horizontal
            sbLayout.Padding = UDim.new(0,8)
            sbLayout.Parent = sectionButtons
            local sbPad = Instance.new("UIPadding")
            sbPad.PaddingLeft = UDim.new(0,8)
            sbPad.PaddingRight = UDim.new(0,8)
            sbPad.Parent = sectionButtons

            local contentHolder = Instance.new("Frame")
            contentHolder.Position = UDim2.new(0,0,0,48)
            contentHolder.Size = UDim2.new(1,0,1,-48)
            contentHolder.BackgroundTransparency = 1
            contentHolder.Parent = section

            local sectionTabs = {}
            local selectedSection

            local function selectSection(s)
                selectedSection = s
                for _, item in ipairs(sectionTabs) do
                    item.Page.Visible = item == s
                    item.Button.BackgroundColor3 = item == s and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabBackground
                    item.Button.TextColor3 = item == s and CurrentTheme.SelectedTabTextColor or CurrentTheme.TabTextColor
                    item.Stroke.Color = item == s and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabStroke
                end
            end

            function SectionData:_Select()
                if selectedSection then selectSection(selectedSection) end
            end

            local SectionButton = Instance.new("TextButton")
            SectionButton.Size = UDim2.fromOffset(100,34)
            SectionButton.BackgroundColor3 = CurrentTheme.TabBackground
            SectionButton.BorderSizePixel = 0
            SectionButton.Text = tostring(sectionName or "Section")
            SectionButton.TextColor3 = CurrentTheme.TabTextColor
            SectionButton.TextScaled = true
            SectionButton.AutoButtonColor = false
            SectionButton.Parent = sectionButtons
            makeCorner(SectionButton, 6)
            local sectionStroke = makeStroke(SectionButton, CurrentTheme.TabStroke, 2)

            local page = Instance.new("ScrollingFrame")
            page.Size = UDim2.fromScale(1,1)
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.ScrollBarThickness = 4
            page.CanvasSize = UDim2.new()
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.Visible = false
            page.Parent = contentHolder

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0,12)
            layout.Parent = page
            local pad = Instance.new("UIPadding")
            pad.PaddingTop = UDim.new(0,12)
            pad.PaddingBottom = UDim.new(0,12)
            pad.PaddingLeft = UDim.new(0,12)
            pad.PaddingRight = UDim.new(0,12)
            pad.Parent = page

            local sInfo = {Button=SectionButton, Page=page, Stroke=sectionStroke}
            table.insert(sectionTabs, sInfo)
            connectAndTrack(connections, SectionButton.MouseButton1Click, function() selectSection(sInfo) end)
            if not selectedSection then selectSection(sInfo) end

            local function addRefresh(method)
                -- UI objects created by this section expose their own RefreshTheme;
                -- this helper exists to keep the API implementation consistent.
                return method
            end

            function SectionData:Button(label, callback)
                local data = {Hover=false}
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,0,0,45)
                b.BackgroundColor3 = CurrentTheme.ElementBackground
                b.BorderSizePixel = 0
                b.Text = ""
                b.AutoButtonColor = false
                b.Parent = page
                makeCorner(b,8)
                local bs = makeStroke(b,CurrentTheme.ElementStroke,2)
                local t = Instance.new("TextLabel")
                t.BackgroundTransparency = 1
                t.Size = UDim2.new(1,-48,1,0)
                t.Position = UDim2.new(0,24,0,0)
                t.Text = tostring(label or "Button")
                t.TextColor3 = CurrentTheme.TextColor
                t.TextScaled = true
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.Parent = b
                connectAndTrack(connections,b.MouseEnter,function() data.Hover=true; b.BackgroundColor3=CurrentTheme.ElementBackgroundHover; bs.Color=CurrentTheme.ElementStrokeHover end)
                connectAndTrack(connections,b.MouseLeave,function() data.Hover=false; b.BackgroundColor3=CurrentTheme.ElementBackground; bs.Color=CurrentTheme.ElementStroke end)
                connectAndTrack(connections,b.MouseButton1Click,function() if callback then task.spawn(callback) end end)
                function data:RefreshTheme()
                    b.BackgroundColor3=data.Hover and CurrentTheme.ElementBackgroundHover or CurrentTheme.ElementBackground
                    bs.Color=data.Hover and CurrentTheme.ElementStrokeHover or CurrentTheme.ElementStroke
                    t.TextColor3=CurrentTheme.TextColor
                end
                return data
            end

            function SectionData:Label(label)
                local data = {}
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1,0,0,45)
                f.BackgroundColor3 = CurrentTheme.ElementBackground
                f.BorderSizePixel = 0
                f.Parent = page
                makeCorner(f,8)
                local s = makeStroke(f,CurrentTheme.ElementStroke,2)
                local t = Instance.new("TextLabel")
                t.BackgroundTransparency = 1
                t.Size = UDim2.new(1,-48,1,0)
                t.Position = UDim2.new(0,24,0,0)
                t.Text = tostring(label or "Label")
                t.TextColor3 = CurrentTheme.TextColor
                t.TextScaled = true
                t.TextWrapped = true
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.Parent = f
                function data:SetText(value) t.Text=tostring(value) end
                function data:RefreshTheme() f.BackgroundColor3=CurrentTheme.ElementBackground; s.Color=CurrentTheme.ElementStroke; t.TextColor3=CurrentTheme.TextColor end
                return data
            end

            function SectionData:Toggle(label, state, callback)
                local data = {State = state == true, Hover=false}
                local b = Instance.new("TextButton")
                b.Size=UDim2.new(1,0,0,45); b.BackgroundColor3=CurrentTheme.ElementBackground; b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false; b.Parent=page
                makeCorner(b,8); local bs=makeStroke(b,CurrentTheme.ElementStroke,2)
                local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Position=UDim2.new(0,24,0,0); t.Size=UDim2.new(0.7,0,1,0); t.Text=tostring(label or "Toggle"); t.TextColor3=CurrentTheme.TextColor; t.TextScaled=true; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=b
                local bg=Instance.new("Frame"); bg.AnchorPoint=Vector2.new(1,0.5); bg.Position=UDim2.new(0.97,0,0.5,0); bg.Size=UDim2.fromOffset(42,22); bg.BackgroundColor3=CurrentTheme.Background; bg.BorderSizePixel=0; bg.Parent=b; makeCorner(bg,11); local gs=makeStroke(bg,CurrentTheme.ElementStroke,2)
                local dot=Instance.new("Frame"); dot.Size=UDim2.fromOffset(18,18); dot.BackgroundColor3=CurrentTheme.TextColor; dot.BorderSizePixel=0; dot.Parent=bg; makeCorner(dot,9)
                local function update(call)
                    dot.Position = data.State and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
                    bg.BackgroundColor3 = data.State and CurrentTheme.TabBackgroundSelected or CurrentTheme.Background
                    if call and callback then callback(data.State) end
                end
                update(false)
                connectAndTrack(connections,b.MouseEnter,function() data.Hover=true; b.BackgroundColor3=CurrentTheme.ElementBackgroundHover; bs.Color=CurrentTheme.ElementStrokeHover end)
                connectAndTrack(connections,b.MouseLeave,function() data.Hover=false; b.BackgroundColor3=CurrentTheme.ElementBackground; bs.Color=CurrentTheme.ElementStroke end)
                connectAndTrack(connections,b.MouseButton1Click,function() data.State=not data.State; update(true) end)
                function data:Set(value) data.State=value==true; update(true) end
                function data:Get() return data.State end
                function data:RefreshTheme() b.BackgroundColor3=data.Hover and CurrentTheme.ElementBackgroundHover or CurrentTheme.ElementBackground; bs.Color=data.Hover and CurrentTheme.ElementStrokeHover or CurrentTheme.ElementStroke; t.TextColor3=CurrentTheme.TextColor; dot.BackgroundColor3=CurrentTheme.TextColor; gs.Color=CurrentTheme.ElementStroke; update(false) end
                return data
            end

            function SectionData:Slider(label, min, max, default, callback)
                min = tonumber(min) or 0; max = tonumber(max) or 100
                if max < min then min,max=max,min end
                local range=max-min
                local value=math.clamp(tonumber(default) or min,min,max)
                local data={Value=value}
                local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,65); f.BackgroundColor3=CurrentTheme.ElementBackground; f.BorderSizePixel=0; f.Parent=page; makeCorner(f,8); local fs=makeStroke(f,CurrentTheme.ElementStroke,2)
                local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Position=UDim2.new(0,24,0,2); t.Size=UDim2.new(0.6,-24,0,28); t.Text=tostring(label or "Slider"); t.TextColor3=CurrentTheme.TextColor; t.TextScaled=true; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=f
                local vt=Instance.new("TextLabel"); vt.BackgroundTransparency=1; vt.Position=UDim2.new(0.6,0,0,2); vt.Size=UDim2.new(0.4,-24,0,28); vt.TextColor3=CurrentTheme.TextColor; vt.TextScaled=true; vt.TextXAlignment=Enum.TextXAlignment.Right; vt.Parent=f
                local back=Instance.new("Frame"); back.Position=UDim2.new(0.05,0,0,43); back.Size=UDim2.new(0.9,0,0,10); back.BackgroundColor3=CurrentTheme.Background; back.BorderSizePixel=0; back.Parent=f; makeCorner(back,5); local backStroke=makeStroke(back,CurrentTheme.ElementStroke,2)
                local fill=Instance.new("Frame"); fill.BackgroundColor3=CurrentTheme.TabBackgroundSelected; fill.BorderSizePixel=0; fill.Parent=back; makeCorner(fill,5)
                local dragging=false
                local function setValue(v,call)
                    v=math.clamp(tonumber(v) or min,min,max)
                    if range==0 then v=min end
                    data.Value=v
                    local pct=range==0 and 0 or (v-min)/range
                    fill.Size=UDim2.new(pct,0,1,0); vt.Text=tostring(v)
                    if call and callback then callback(v) end
                end
                local function updateFromX(x)
                    local size=back.AbsoluteSize.X
                    local pct=size<=0 and 0 or math.clamp((x-back.AbsolutePosition.X)/size,0,1)
                    setValue(range==0 and min or math.floor(min+range*pct+0.5),true)
                end
                setValue(value,false)
                connectAndTrack(connections,back.InputBegan,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; updateFromX(input.Position.X) end end)
                connectAndTrack(connections,UserInputService.InputChanged,function(input) if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then updateFromX(input.Position.X) end end)
                connectAndTrack(connections,UserInputService.InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
                function data:Set(v) setValue(v,true) end
                function data:Get() return data.Value end
                function data:RefreshTheme() f.BackgroundColor3=CurrentTheme.ElementBackground; fs.Color=CurrentTheme.ElementStroke; t.TextColor3=CurrentTheme.TextColor; vt.TextColor3=CurrentTheme.TextColor; back.BackgroundColor3=CurrentTheme.Background; backStroke.Color=CurrentTheme.ElementStroke; fill.BackgroundColor3=CurrentTheme.TabBackgroundSelected end
                return data
            end

            function SectionData:Dropdown(label, options, callback, MultiSelect)
                options = type(options)=="table" and options or {}
                local multi=MultiSelect==true
                local data={Open=false,Value=nil,Values={}}
                local buttons={}
                local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,45); f.BackgroundColor3=CurrentTheme.ElementBackground; f.BorderSizePixel=0; f.ClipsDescendants=true; f.Parent=page; makeCorner(f,8); local fs=makeStroke(f,CurrentTheme.ElementStroke,2)
                local txt=Instance.new("TextLabel"); txt.BackgroundTransparency=1; txt.Position=UDim2.new(0,24,0,0); txt.Size=UDim2.new(1,-64,0,45); txt.Text=tostring(label or "Dropdown"); txt.TextColor3=CurrentTheme.TextColor; txt.TextScaled=true; txt.TextXAlignment=Enum.TextXAlignment.Left; txt.Parent=f
                local arrow=Instance.new("TextButton"); arrow.BackgroundTransparency=1; arrow.Position=UDim2.new(1,-44,0,0); arrow.Size=UDim2.fromOffset(44,45); arrow.Text="▼"; arrow.TextColor3=CurrentTheme.TextColor; arrow.TextScaled=true; arrow.Parent=f
                local list=Instance.new("Frame"); list.Position=UDim2.new(0,0,0,45); list.Size=UDim2.new(1,0,0,0); list.BackgroundColor3=CurrentTheme.Background; list.BorderSizePixel=0; list.Parent=f
                local ll=Instance.new("UIListLayout"); ll.Parent=list
                local function selectedText()
                    if not multi then return data.Value and (tostring(label or "Dropdown")..": "..tostring(data.Value)) or tostring(label or "Dropdown") end
                    local selected={}; for _,o in ipairs(options) do if data.Values[o] then table.insert(selected,tostring(o)) end end
                    return #selected>0 and tostring(label or "Dropdown")..": "..table.concat(selected,", ") or tostring(label or "Dropdown")
                end
                local function refreshButtons()
                    for _,item in ipairs(buttons) do
                        local chosen=multi and data.Values[item.Option] or data.Value==item.Option
                        item.Button.Text=tostring(item.Option)..(chosen and " ✓" or "")
                        item.Button.BackgroundColor3=CurrentTheme.ElementBackground
                        item.Button.TextColor3=CurrentTheme.TextColor
                    end
                end
                local function refreshSize()
                    local count=#options
                    list.Size=UDim2.new(1,0,0,data.Open and count*35 or 0)
                    f.Size=UDim2.new(1,0,0,data.Open and 45+count*35 or 45)
                    arrow.Text=data.Open and "▲" or "▼"
                end
                txt.Text=selectedText()
                for _,option in ipairs(options) do
                    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,35); b.BackgroundColor3=CurrentTheme.ElementBackground; b.BorderSizePixel=0; b.Text=tostring(option); b.TextColor3=CurrentTheme.TextColor; b.TextScaled=true; b.Parent=list
                    local item={Option=option,Button=b}; table.insert(buttons,item)
                    connectAndTrack(connections,b.MouseEnter,function() b.BackgroundColor3=CurrentTheme.ElementBackgroundHover end)
                    connectAndTrack(connections,b.MouseLeave,function() b.BackgroundColor3=CurrentTheme.ElementBackground end)
                    connectAndTrack(connections,b.MouseButton1Click,function()
                        if multi then data.Values[option]=not data.Values[option] else data.Value=option; data.Open=false end
                        txt.Text=selectedText(); refreshButtons(); refreshSize(); if callback then callback(multi and data.Values or data.Value) end
                    end)
                end
                connectAndTrack(connections,arrow.MouseButton1Click,function() data.Open=not data.Open; refreshSize() end)
                function data:Set(value)
                    if multi then
                        data.Values={}
                        if type(value)=="table" then for _,o in ipairs(options) do if value[o] then data.Values[o]=true end end else if value~=nil then data.Values[value]=true end end
                    else
                        local valid=false; for _,o in ipairs(options) do if o==value then valid=true break end end
                        data.Value=valid and value or nil
                    end
                    txt.Text=selectedText(); refreshButtons(); if callback then callback(multi and data.Values or data.Value) end
                end
                function data:Get() return multi and data.Values or data.Value end
                function data:Clear() data.Value=nil; data.Values={}; txt.Text=selectedText(); refreshButtons() end
                function data:RefreshTheme() f.BackgroundColor3=CurrentTheme.ElementBackground; fs.Color=CurrentTheme.ElementStroke; txt.TextColor3=CurrentTheme.TextColor; arrow.TextColor3=CurrentTheme.TextColor; list.BackgroundColor3=CurrentTheme.Background; refreshButtons() end
                refreshSize(); return data
            end

            function SectionData:ConfigToggle(label, default, callback, key)
                local cfgKey=key or label
                local saved=CrackedLib.Config.Data[cfgKey]
                local value=type(saved)=="boolean" and saved or (default==true)
                return self:Toggle(label,value,function(v) CrackedLib.Config.Data[cfgKey]=v; CrackedLib.Config:Save(); if callback then callback(v) end end)
            end

            function SectionData:ConfigSlider(label,min,max,default,callback,key)
                local cfgKey=key or label
                local saved=CrackedLib.Config.Data[cfgKey]
                local value=type(saved)=="number" and saved or default
                return self:Slider(label,min,max,value,function(v) CrackedLib.Config.Data[cfgKey]=v; CrackedLib.Config:Save(); if callback then callback(v) end end)
            end

            function SectionData:ConfigDropdown(label,options,callback,MultiSelect,key)
                local cfgKey=key or label
                local saved=CrackedLib.Config.Data[cfgKey]
                local data
                data=self:Dropdown(label,options,function(v) CrackedLib.Config.Data[cfgKey]=v; CrackedLib.Config:Save(); if callback then callback(v) end end,MultiSelect)
                if saved~=nil then task.defer(function() if not destroyed then data:Set(saved) end end) end
                return data
            end

            SectionData.Section=page
            return SectionData
        end

        return TabData
    end

    function GUI:SetTheme(newTheme)
        local t=self.Theme and self.Theme[newTheme] or CrackedLib.Theme[newTheme]
        if not t then return false end
        CurrentTheme=t
        CrackedLib.CurrentTheme=t
        title.TextColor3=t.TextColor; Topbar.BackgroundColor3=t.Topbar; Line.BackgroundColor3=t.Line; Navigation.BackgroundColor3=t.Navigation; Main.BackgroundColor3=t.Background
        for _,info in ipairs(tabs) do info.Button.BackgroundColor3=info==selectedTab and t.TabBackgroundSelected or t.TabBackground; info.Button.TextColor3=info==selectedTab and t.SelectedTabTextColor or t.TabTextColor; info.Stroke.Color=info==selectedTab and t.TabBackgroundSelected or t.TabStroke; info.Content.BackgroundColor3=t.Background end
        return true
    end

    GUI.ScreenGui=ScreenGui
    GUI.Main=Main
    GUI.Destroy=function() GUI:Destroy() end

    if draggable then
        local dragging=false
        local dragStart=nil
        local startPos=nil
        connectAndTrack(connections,Topbar.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=input.Position; startPos=Main.Position end
        end)
        connectAndTrack(connections,Topbar.InputEnded,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)
        connectAndTrack(connections,UserInputService.InputChanged,function(input)
            if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                local d=input.Position-dragStart
                Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
    end

    if keybind then
        connectAndTrack(connections,UserInputService.InputBegan,function(input,processed)
            if not processed and input.KeyCode==keybind and not destroyed then ScreenGui.Enabled=not ScreenGui.Enabled end
        end)
    end

    function GUI:Destroy()
        if destroyed then return end
        destroyed=true
        disconnectAll(connections)
        if ScreenGui then ScreenGui:Destroy() end
    end

    connectAndTrack(connections,Exit.MouseButton1Click,function() GUI:Destroy() end)
    connectAndTrack(connections,Minus.MouseButton1Click,function() Main.Visible=not Main.Visible end)

    return GUI
end

-- Optional local test from the original file, disabled by default.
CrackedLib.Version = "2.0.0"
CrackedLib.RunStudioTest = function()
    local lib=CrackedLib:Init("CrackLib v2",true,Enum.KeyCode.RightShift,"Default",{Enabled=false})
    if not lib then return end
    local tab=lib:CreateTab("Test")
    local section=tab:Section("Controls")
    section:Button("Button",function() print("Button clicked") end)
    section:Label("CrackedLib v2")
    section:Toggle("Toggle",false,function(v) print("Toggle:",v) end)
    section:Slider("Value",0,100,50,function(v) print("Slider:",v) end)
    section:Dropdown("Items",{"Sword","Potion","Shield"},function(v) print("Dropdown:",v) end,false)
    section:Dropdown("Multi",{"Sword","Potion","Shield"},function(v) print("Multi:",v) end,true)
    return lib
end

return CrackedLib
