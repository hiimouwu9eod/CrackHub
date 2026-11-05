--[[
	CrackLib v2 — polished UI lib
	Icons · hover · smooth tweens · same API

	local Lib = loadstring(...)()
	local Window = Lib:Init("Title", true, Enum.KeyCode.LeftControl)
	local Tab = Window:CreateTab("Main")
	local Sec = Tab:Section("Combat")
	Sec:Toggle / ConfigToggle / Slider / Button / Label / Info / Warning
	Sec:Dropdown / MultiDropdown / Textbox / Keybind / Separator
	Window:Unload()
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local CrackLib = {}
CrackLib.__index = CrackLib

local ICONS = {
	Search = "rbxassetid://76708951036896",
	Close = "rbxassetid://99554242879064",
	Min = "rbxassetid://101289624554673",
	Check = "rbxassetid://122127875939444",
	Chevron = "rbxassetid://109652315428403",
	Info = "rbxassetid://140457109989478",
	Warning = "rbxassetid://103386828423129",
	Label = "rbxassetid://100538280224523",
	Shadow = "rbxassetid://6014261993",
}

local Theme = {
	Bg = Color3.fromRGB(28, 28, 32),
	Top = Color3.fromRGB(36, 36, 42),
	Sidebar = Color3.fromRGB(24, 24, 28),
	Element = Color3.fromRGB(40, 40, 48),
	ElementHover = Color3.fromRGB(50, 50, 60),
	Accent = Color3.fromRGB(100, 140, 255),
	AccentDim = Color3.fromRGB(70, 100, 200),
	Success = Color3.fromRGB(80, 200, 120),
	Danger = Color3.fromRGB(220, 70, 70),
	Info = Color3.fromRGB(50, 160, 210),
	Warning = Color3.fromRGB(220, 170, 60),
	Text = Color3.fromRGB(245, 245, 250),
	TextDim = Color3.fromRGB(150, 150, 165),
	Stroke = Color3.fromRGB(60, 60, 72),
	SliderTrack = Color3.fromRGB(55, 55, 65),
	SliderFill = Color3.fromRGB(100, 140, 255),
	Input = Color3.fromRGB(32, 32, 38),
	TabIdle = Color3.fromRGB(38, 38, 46),
}

local function protect(gui)
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	local ok = pcall(function()
		if gethui then gui.Parent = gethui() end
	end)
	if not ok or not gui.Parent then
		pcall(function() gui.Parent = CoreGui end)
	end
	if not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function tw(obj, props, t, style, dir)
	local anim = TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	anim:Play()
	return anim
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end

local function stroke(p, col, th)
	local s = Instance.new("UIStroke")
	s.Color = col or Theme.Stroke
	s.Thickness = th or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function pad(p, n)
	local x = Instance.new("UIPadding")
	n = n or 10
	x.PaddingTop = UDim.new(0, n)
	x.PaddingBottom = UDim.new(0, n)
	x.PaddingLeft = UDim.new(0, n)
	x.PaddingRight = UDim.new(0, n)
	x.Parent = p
	return x
end

local function vlist(p, gap)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, gap or 8)
	l.Parent = p
	return l
end

local function autoCanvas(scroll, layout)
	local function upd()
		scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 16)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
	task.defer(upd)
end

local function hover(btn, idle, over)
	btn.MouseEnter:Connect(function() tw(btn, { BackgroundColor3 = over }, 0.15) end)
	btn.MouseLeave:Connect(function() tw(btn, { BackgroundColor3 = idle }, 0.15) end)
end

function CrackLib:Init(title, draggable, toggleKey)
	local self = setmetatable({}, CrackLib)
	self._connections = {}
	self._tabs = {}
	self._visible = true
	self._minimized = false
	self.ToggleKey = toggleKey or Enum.KeyCode.LeftControl

	local gui = Instance.new("ScreenGui")
	gui.Name = "CrackLib"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	protect(gui)
	self.Gui = gui

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.BackgroundColor3 = Theme.Bg
	Main.BorderSizePixel = 0
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.Position = UDim2.fromScale(0.5, 0.5)
	Main.Size = UDim2.fromOffset(0, 0)
	Main.ClipsDescendants = true
	Main.Parent = gui
	corner(Main, 14)
	stroke(Main, Theme.Stroke, 1.5)
	self.Main = Main
	tw(Main, { Size = UDim2.fromOffset(680, 460) }, 0.35, Enum.EasingStyle.Back)

	local sh = Instance.new("ImageLabel")
	sh.AnchorPoint = Vector2.new(0.5, 0.5)
	sh.BackgroundTransparency = 1
	sh.Position = UDim2.fromScale(0.5, 0.5)
	sh.Size = UDim2.new(1.08, 0, 1.12, 0)
	sh.ZIndex = 0
	sh.Image = ICONS.Shadow
	sh.ImageColor3 = Color3.new(0, 0, 0)
	sh.ImageTransparency = 0.45
	sh.ScaleType = Enum.ScaleType.Slice
	sh.SliceCenter = Rect.new(49, 49, 450, 450)
	sh.Parent = Main

	local Top = Instance.new("Frame")
	Top.Name = "TopBar"
	Top.BackgroundColor3 = Theme.Top
	Top.BorderSizePixel = 0
	Top.Size = UDim2.new(1, 0, 0, 52)
	Top.Parent = Main

	local topFix = Instance.new("Frame")
	topFix.BackgroundColor3 = Theme.Top
	topFix.BorderSizePixel = 0
	topFix.Position = UDim2.new(0, 0, 1, -14)
	topFix.Size = UDim2.new(1, 0, 0, 14)
	topFix.Parent = Top

	local accentLine = Instance.new("Frame")
	accentLine.BackgroundColor3 = Theme.Accent
	accentLine.BorderSizePixel = 0
	accentLine.Position = UDim2.new(0, 0, 1, -2)
	accentLine.Size = UDim2.new(1, 0, 0, 2)
	accentLine.Parent = Top

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(16, 0)
	Title.Size = UDim2.new(0, 190, 1, 0)
	Title.Font = Enum.Font.GothamBold
	Title.Text = tostring(title or "CrackLib")
	Title.TextColor3 = Theme.Text
	Title.TextSize = 18
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Top

	local searchWrap = Instance.new("Frame")
	searchWrap.BackgroundColor3 = Theme.Input
	searchWrap.BorderSizePixel = 0
	searchWrap.Position = UDim2.new(0, 210, 0.5, -15)
	searchWrap.Size = UDim2.fromOffset(280, 30)
	searchWrap.Parent = Top
	corner(searchWrap, 8)
	stroke(searchWrap, Theme.Stroke, 1)

	local searchIcon = Instance.new("ImageLabel")
	searchIcon.BackgroundTransparency = 1
	searchIcon.Position = UDim2.fromOffset(8, 5)
	searchIcon.Size = UDim2.fromOffset(20, 20)
	searchIcon.Image = ICONS.Search
	searchIcon.ImageColor3 = Theme.TextDim
	searchIcon.Parent = searchWrap

	local SearchBox = Instance.new("TextBox")
	SearchBox.BackgroundTransparency = 1
	SearchBox.Position = UDim2.fromOffset(32, 0)
	SearchBox.Size = UDim2.new(1, -40, 1, 0)
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.PlaceholderText = "Search..."
	SearchBox.PlaceholderColor3 = Theme.TextDim
	SearchBox.Text = ""
	SearchBox.TextColor3 = Theme.Text
	SearchBox.TextSize = 13
	SearchBox.TextXAlignment = Enum.TextXAlignment.Left
	SearchBox.ClearTextOnFocus = false
	SearchBox.Parent = searchWrap
	self.SearchBox = SearchBox

	local function topIcon(x, id, hoverCol)
		local b = Instance.new("ImageButton")
		b.BackgroundTransparency = 1
		b.Position = UDim2.new(1, x, 0.5, -12)
		b.Size = UDim2.fromOffset(24, 24)
		b.Image = id
		b.ImageColor3 = Theme.TextDim
		b.Parent = Top
		b.MouseEnter:Connect(function() tw(b, { ImageColor3 = hoverCol or Theme.Text }, 0.12) end)
		b.MouseLeave:Connect(function() tw(b, { ImageColor3 = Theme.TextDim }, 0.12) end)
		return b
	end

	local ExitBtn = topIcon(-36, ICONS.Close, Theme.Danger)
	local MinBtn = topIcon(-68, ICONS.Min, Theme.Accent)

	local Sidebar = Instance.new("Frame")
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Position = UDim2.fromOffset(0, 52)
	Sidebar.Size = UDim2.new(0, 148, 1, -52)
	Sidebar.Parent = Main
	self.Sidebar = Sidebar

	local sideLine = Instance.new("Frame")
	sideLine.BackgroundColor3 = Theme.Stroke
	sideLine.BorderSizePixel = 0
	sideLine.Position = UDim2.new(1, -1, 0, 0)
	sideLine.Size = UDim2.new(0, 1, 1, 0)
	sideLine.Parent = Sidebar

	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.Size = UDim2.fromScale(1, 1)
	TabScroll.ScrollBarThickness = 2
	TabScroll.ScrollBarImageColor3 = Theme.Accent
	TabScroll.CanvasSize = UDim2.new()
	TabScroll.Parent = Sidebar
	local tabLayout = vlist(TabScroll, 6)
	pad(TabScroll, 10)
	autoCanvas(TabScroll, tabLayout)
	self.TabScroll = TabScroll

	local Content = Instance.new("Frame")
	Content.BackgroundTransparency = 1
	Content.Position = UDim2.fromOffset(148, 52)
	Content.Size = UDim2.new(1, -148, 1, -52)
	Content.ClipsDescendants = true
	Content.Parent = Main
	self.Content = Content

	local TabsFolder = Instance.new("Folder")
	TabsFolder.Name = "Tabs"
	TabsFolder.Parent = Content
	self.TabsFolder = TabsFolder

	if draggable ~= false then
		local dragging, start, startPos
		Top.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				start = i.Position
				startPos = Main.Position
			end
		end)
		Top.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		table.insert(self._connections, UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - start
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end))
	end

	ExitBtn.MouseButton1Click:Connect(function()
		tw(Main, { Size = UDim2.fromOffset(0, 0) }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.25, function() self:Unload() end)
	end)

	MinBtn.MouseButton1Click:Connect(function()
		self._minimized = not self._minimized
		if self._minimized then
			tw(Main, { Size = UDim2.fromOffset(680, 52) }, 0.25)
			Sidebar.Visible = false
			Content.Visible = false
		else
			Sidebar.Visible = true
			Content.Visible = true
			tw(Main, { Size = UDim2.fromOffset(680, 460) }, 0.3, Enum.EasingStyle.Back)
		end
	end)

	table.insert(self._connections, UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == self.ToggleKey then
			self._visible = not self._visible
			if self._visible then
				Main.Visible = true
				Main.Size = UDim2.fromOffset(0, 0)
				tw(Main, { Size = UDim2.fromOffset(680, 460) }, 0.3, Enum.EasingStyle.Back)
			else
				tw(Main, { Size = UDim2.fromOffset(0, 0) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				task.delay(0.2, function()
					if not self._visible then
						Main.Visible = false
						Main.Size = UDim2.fromOffset(680, 460)
					end
				end)
			end
		end
	end))

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(SearchBox.Text)
		for _, tab in pairs(self._tabs) do
			if tab.Page then
				for _, child in ipairs(tab.Page:GetChildren()) do
					if child:IsA("Frame") then
						local label = child:FindFirstChild("TitleText")
						if label and label:IsA("TextLabel") then
							child.Visible = (q == "") or (string.find(string.lower(label.Text), q, 1, true) ~= nil)
						end
					end
				end
			end
		end
	end)

	function self:CreateTab(name)
		return CrackLib.CreateTab(self, name)
	end

	function self:Unload()
		for _, c in ipairs(self._connections) do
			pcall(function() c:Disconnect() end)
		end
		if self.Gui then self.Gui:Destroy() end
	end

	function self:SetToggleKey(k) self.ToggleKey = k end
	function self:SetVisible(v) self._visible = v Main.Visible = v end

	return self
end

function CrackLib:CreateTab(name)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = name
	tabBtn.BackgroundColor3 = Theme.TabIdle
	tabBtn.BorderSizePixel = 0
	tabBtn.Size = UDim2.new(1, -4, 0, 38)
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.Text = "  " .. tostring(name)
	tabBtn.TextColor3 = Theme.TextDim
	tabBtn.TextSize = 14
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.AutoButtonColor = false
	tabBtn.Parent = self.TabScroll
	corner(tabBtn, 8)

	local indicator = Instance.new("Frame")
	indicator.BackgroundColor3 = Theme.Accent
	indicator.BorderSizePixel = 0
	indicator.Position = UDim2.fromOffset(0, 8)
	indicator.Size = UDim2.fromOffset(3, 22)
	indicator.Visible = false
	indicator.Parent = tabBtn
	corner(indicator, 2)

	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Size = UDim2.fromScale(1, 1)
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Theme.Accent
	page.CanvasSize = UDim2.new()
	page.Visible = false
	page.Parent = self.TabsFolder
	local pageList = vlist(page, 8)
	pad(page, 12)
	autoCanvas(page, pageList)

	local tabData = { Name = name, Button = tabBtn, Page = page, Indicator = indicator }
	self._tabs[name] = tabData

	local function select()
		for _, t in pairs(self._tabs) do
			t.Page.Visible = false
			tw(t.Button, { BackgroundColor3 = Theme.TabIdle }, 0.15)
			t.Button.TextColor3 = Theme.TextDim
			t.Indicator.Visible = false
		end
		page.Visible = true
		tw(tabBtn, { BackgroundColor3 = Color3.fromRGB(45, 50, 70) }, 0.15)
		tabBtn.TextColor3 = Theme.Text
		indicator.Visible = true
	end

	tabBtn.MouseButton1Click:Connect(select)
	local idleCol = Theme.TabIdle
	tabBtn.MouseEnter:Connect(function()
		if not indicator.Visible then tw(tabBtn, { BackgroundColor3 = Color3.fromRGB(48, 48, 58) }, 0.12) end
	end)
	tabBtn.MouseLeave:Connect(function()
		if not indicator.Visible then tw(tabBtn, { BackgroundColor3 = idleCol }, 0.12) end
	end)

	local n = 0
	for _ in pairs(self._tabs) do n += 1 end
	if n == 1 then select() end

	local tabApi = { _window = self, _tabData = tabData }
	function tabApi:Section(secName)
		return CrackLib.CreateSection(self._window, tabData, secName)
	end
	return tabApi
end

function CrackLib.CreateSection(window, tabData, secName)
	local header = Instance.new("Frame")
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 28)
	header.Parent = tabData.Page

	local chip = Instance.new("TextLabel")
	chip.BackgroundColor3 = Theme.Element
	chip.BorderSizePixel = 0
	chip.Size = UDim2.fromOffset(0, 26)
	chip.AutomaticSize = Enum.AutomaticSize.X
	chip.Font = Enum.Font.GothamBold
	chip.Text = "  " .. tostring(secName) .. "  "
	chip.TextColor3 = Theme.Accent
	chip.TextSize = 12
	chip.Parent = header
	corner(chip, 8)
	stroke(chip, Theme.AccentDim, 1)

	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = tabData.Page
	vlist(container, 8)

	local section = { _c = container, _w = window }

	local function row(height, bg)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = bg or Theme.Element
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, height or 44)
		f.ClipsDescendants = true
		f.Parent = container
		corner(f, 10)
		stroke(f, Theme.Stroke, 1)
		if not bg then
			f.MouseEnter:Connect(function()
				if f.BackgroundColor3 == Theme.Element then tw(f, { BackgroundColor3 = Theme.ElementHover }, 0.12) end
			end)
			f.MouseLeave:Connect(function()
				if f.BackgroundColor3 == Theme.ElementHover then tw(f, { BackgroundColor3 = Theme.Element }, 0.12) end
			end)
		end
		return f
	end

	local function titleText(parent, str, rightPad)
		local t = Instance.new("TextLabel")
		t.Name = "TitleText"
		t.BackgroundTransparency = 1
		t.Position = UDim2.fromOffset(14, 0)
		t.Size = UDim2.new(1, -(rightPad or 54), 1, 0)
		t.Font = Enum.Font.GothamMedium
		t.Text = tostring(str)
		t.TextColor3 = Theme.Text
		t.TextSize = 14
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.Parent = parent
		return t
	end

	local function sideIcon(parent, id, color)
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1
		img.AnchorPoint = Vector2.new(1, 0.5)
		img.Position = UDim2.new(1, -10, 0.5, 0)
		img.Size = UDim2.fromOffset(22, 22)
		img.Image = id
		img.ImageColor3 = color or Theme.TextDim
		img.Parent = parent
		return img
	end

	function section:Label(text)
		local f = row(44)
		titleText(f, text, 50)
		sideIcon(f, ICONS.Label, Theme.TextDim)
		local d = {}
		function d:SetText(v) local t = f:FindFirstChild("TitleText") if t then t.Text = tostring(v) end end
		return d
	end

	function section:Info(text)
		local f = row(44, Theme.Info)
		titleText(f, text, 50)
		sideIcon(f, ICONS.Info, Color3.new(1, 1, 1))
		local d = {}
		function d:SetText(v) local t = f:FindFirstChild("TitleText") if t then t.Text = tostring(v) end end
		return d
	end

	function section:Warning(text)
		local f = row(44, Theme.Warning)
		titleText(f, text, 50)
		sideIcon(f, ICONS.Warning, Color3.new(1, 1, 1))
		local d = {}
		function d:SetText(v) local t = f:FindFirstChild("TitleText") if t then t.Text = tostring(v) end end
		return d
	end

	function section:Toggle(text, default, callback)
		local state = default == true
		local f = row(44)
		titleText(f, text, 60)

		local track = Instance.new("Frame")
		track.AnchorPoint = Vector2.new(1, 0.5)
		track.Position = UDim2.new(1, -12, 0.5, 0)
		track.Size = UDim2.fromOffset(44, 24)
		track.BackgroundColor3 = state and Theme.Success or Theme.SliderTrack
		track.BorderSizePixel = 0
		track.Parent = f
		corner(track, 12)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(18, 18)
		knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Parent = track
		corner(knob, 9)

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.Text = ""
		hit.Parent = f

		local function set(v, fire)
			state = v and true or false
			tw(track, { BackgroundColor3 = state and Theme.Success or Theme.SliderTrack }, 0.18)
			tw(knob, { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.2, Enum.EasingStyle.Back)
			if fire ~= false and callback then task.spawn(callback, state) end
		end

		hit.MouseButton1Click:Connect(function() set(not state, true) end)
		if default and callback then task.defer(callback, true) end

		local d = {}
		function d:Set(v) set(v, true) end
		function d:Get() return state end
		return d
	end
	section.ConfigToggle = section.Toggle

	function section:Button(text, callback)
		local f = row(44, Color3.fromRGB(48, 52, 68))
		local t = titleText(f, text, 0)
		t.Size = UDim2.fromScale(1, 1)
		t.Position = UDim2.new()
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.TextColor3 = Theme.Accent

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.Text = ""
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			tw(f, { BackgroundColor3 = Theme.Accent }, 0.08)
			task.delay(0.1, function() tw(f, { BackgroundColor3 = Color3.fromRGB(48, 52, 68) }, 0.2) end)
			if callback then task.spawn(callback) end
		end)
		return {}
	end

	function section:Slider(text, min, max, default, callback, decimals)
		min, max = min or 0, max or 100
		default = default or min
		decimals = decimals or 0
		local value = default

		local f = row(68)
		local title = Instance.new("TextLabel")
		title.Name = "TitleText"
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(14, 6)
		title.Size = UDim2.new(0.55, 0, 0, 20)
		title.Font = Enum.Font.GothamMedium
		title.Text = tostring(text)
		title.TextColor3 = Theme.Text
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = f

		local valLbl = Instance.new("TextLabel")
		valLbl.BackgroundTransparency = 1
		valLbl.Position = UDim2.new(0.55, 0, 0, 6)
		valLbl.Size = UDim2.new(0.42, -10, 0, 20)
		valLbl.Font = Enum.Font.GothamBold
		valLbl.Text = tostring(default)
		valLbl.TextColor3 = Theme.Accent
		valLbl.TextSize = 14
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = f

		local track = Instance.new("Frame")
		track.BackgroundColor3 = Theme.SliderTrack
		track.BorderSizePixel = 0
		track.Position = UDim2.new(0, 14, 0, 40)
		track.Size = UDim2.new(1, -28, 0, 8)
		track.Parent = f
		corner(track, 4)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = Theme.SliderFill
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(math.clamp((default - min) / math.max(max - min, 1e-9), 0, 1), 0, 1, 0)
		fill.Parent = track
		corner(fill, 4)

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Parent = track
		corner(knob, 7)
		stroke(knob, Theme.Accent, 1)

		local sliding = false
		local function apply(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local raw = min + (max - min) * rel
			if decimals <= 0 then value = math.floor(raw + 0.5)
			else local m = 10 ^ decimals value = math.floor(raw * m + 0.5) / m end
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			valLbl.Text = tostring(value)
			if callback then task.spawn(callback, value) end
		end

		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				apply(i.Position.X)
			end
		end)
		table.insert(window._connections, UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
		end))
		table.insert(window._connections, UIS.InputChanged:Connect(function(i)
			if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then apply(i.Position.X) end
		end))

		local d = {}
		function d:Set(v)
			value = math.clamp(v, min, max)
			local rel = (value - min) / math.max(max - min, 1e-9)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			valLbl.Text = tostring(value)
			if callback then callback(value) end
		end
		function d:Get() return value end
		return d
	end
	section.ConfigSlider = section.Slider

	function section:Dropdown(text, options, default, callback)
		options = options or {}
		local selected = default or options[1]
		local open = false

		local f = row(44)
		f.ClipsDescendants = true
		local title = titleText(f, text .. (selected and ("  ·  " .. tostring(selected)) or ""), 48)
		local chev = sideIcon(f, ICONS.Chevron, Theme.TextDim)

		local drop = Instance.new("Frame")
		drop.BackgroundTransparency = 1
		drop.Position = UDim2.fromOffset(8, 44)
		drop.Size = UDim2.new(1, -16, 0, 0)
		drop.ClipsDescendants = true
		drop.Parent = f

		local scroll = Instance.new("ScrollingFrame")
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.Size = UDim2.fromScale(1, 1)
		scroll.ScrollBarThickness = 2
		scroll.ScrollBarImageColor3 = Theme.Accent
		scroll.Parent = drop
		local sList = vlist(scroll, 4)
		pad(scroll, 4)
		autoCanvas(scroll, sList)

		local function rebuild()
			for _, c in ipairs(scroll:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = (opt == selected) and Theme.AccentDim or Theme.Input
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 28)
				b.Font = Enum.Font.Gotham
				b.Text = "  " .. tostring(opt)
				b.TextColor3 = Theme.Text
				b.TextSize = 13
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.Parent = scroll
				corner(b, 6)
				b.MouseButton1Click:Connect(function()
					selected = opt
					title.Text = text .. "  ·  " .. tostring(opt)
					open = false
					tw(chev, { Rotation = 0 }, 0.15)
					tw(f, { Size = UDim2.new(1, 0, 0, 44) }, 0.2)
					drop.Size = UDim2.new(1, -16, 0, 0)
					if callback then task.spawn(callback, selected) end
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, 44)
		hit.Text = ""
		hit.ZIndex = 2
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.min(130, #options * 32 + 12)
				drop.Size = UDim2.new(1, -16, 0, h)
				tw(f, { Size = UDim2.new(1, 0, 0, 44 + h) }, 0.22, Enum.EasingStyle.Quint)
				tw(chev, { Rotation = 180 }, 0.2)
			else
				drop.Size = UDim2.new(1, -16, 0, 0)
				tw(f, { Size = UDim2.new(1, 0, 0, 44) }, 0.2)
				tw(chev, { Rotation = 0 }, 0.15)
			end
		end)

		local d = {}
		function d:Set(v) selected = v title.Text = text .. "  ·  " .. tostring(v) if callback then callback(v) end end
		function d:Get() return selected end
		function d:Refresh(opts) options = opts or options rebuild() end
		return d
	end
	section.ConfigDropdown = section.Dropdown

	function section:MultiDropdown(text, options, defaults, callback)
		options = options or {}
		local selected = {}
		if type(defaults) == "table" then for _, x in ipairs(defaults) do selected[x] = true end end
		local open = false

		local f = row(44)
		f.ClipsDescendants = true
		titleText(f, text, 48)
		local chev = sideIcon(f, ICONS.Chevron, Theme.TextDim)

		local drop = Instance.new("Frame")
		drop.BackgroundTransparency = 1
		drop.Position = UDim2.fromOffset(8, 44)
		drop.Size = UDim2.new(1, -16, 0, 0)
		drop.ClipsDescendants = true
		drop.Parent = f
		local scroll = Instance.new("ScrollingFrame")
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.Size = UDim2.fromScale(1, 1)
		scroll.ScrollBarThickness = 2
		scroll.Parent = drop
		local sList = vlist(scroll, 4)
		pad(scroll, 4)
		autoCanvas(scroll, sList)

		local function listSel()
			local t = {}
			for _, o in ipairs(options) do if selected[o] then t[#t + 1] = o end end
			return t
		end

		local function rebuild()
			for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
			for _, opt in ipairs(options) do
				local on = selected[opt]
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = on and Theme.AccentDim or Theme.Input
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 28)
				b.Font = Enum.Font.Gotham
				b.Text = (on and "  ✓  " or "      ") .. tostring(opt)
				b.TextColor3 = Theme.Text
				b.TextSize = 13
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.Parent = scroll
				corner(b, 6)
				b.MouseButton1Click:Connect(function()
					selected[opt] = not selected[opt]
					if callback then task.spawn(callback, listSel()) end
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, 44)
		hit.Text = ""
		hit.ZIndex = 2
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.min(130, #options * 32 + 12)
				drop.Size = UDim2.new(1, -16, 0, h)
				tw(f, { Size = UDim2.new(1, 0, 0, 44 + h) }, 0.22)
				tw(chev, { Rotation = 180 }, 0.2)
			else
				drop.Size = UDim2.new(1, -16, 0, 0)
				tw(f, { Size = UDim2.new(1, 0, 0, 44) }, 0.2)
				tw(chev, { Rotation = 0 }, 0.15)
			end
		end)

		local d = {}
		function d:Get() return listSel() end
		function d:Refresh(opts) options = opts or options rebuild() end
		return d
	end

	function section:Textbox(text, default, callback)
		local f = row(44)
		titleText(f, text, 0).Size = UDim2.new(0.35, 0, 1, 0)
		local box = Instance.new("TextBox")
		box.BackgroundColor3 = Theme.Input
		box.BorderSizePixel = 0
		box.Position = UDim2.new(0.38, 0, 0.5, -13)
		box.Size = UDim2.new(0.58, -10, 0, 26)
		box.Font = Enum.Font.Gotham
		box.Text = tostring(default or "")
		box.PlaceholderText = "..."
		box.PlaceholderColor3 = Theme.TextDim
		box.TextColor3 = Theme.Text
		box.TextSize = 13
		box.ClearTextOnFocus = false
		box.Parent = f
		corner(box, 6)
		local st = stroke(box, Theme.Stroke, 1)
		box.Focused:Connect(function() st.Color = Theme.Accent end)
		box.FocusLost:Connect(function()
			st.Color = Theme.Stroke
			if callback then callback(box.Text) end
		end)
		local d = {}
		function d:Set(v) box.Text = tostring(v) end
		function d:Get() return box.Text end
		return d
	end
	section.ConfigTextbox = section.Textbox

	function section:Keybind(text, defaultKey, callback)
		local key = defaultKey or Enum.KeyCode.E
		local listening = false
		local f = row(44)
		titleText(f, text, 90)

		local keyBtn = Instance.new("TextButton")
		keyBtn.AnchorPoint = Vector2.new(1, 0.5)
		keyBtn.Position = UDim2.new(1, -12, 0.5, 0)
		keyBtn.Size = UDim2.fromOffset(72, 26)
		keyBtn.BackgroundColor3 = Theme.Input
		keyBtn.BorderSizePixel = 0
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.Text = key.Name
		keyBtn.TextColor3 = Theme.Accent
		keyBtn.TextSize = 12
		keyBtn.AutoButtonColor = false
		keyBtn.Parent = f
		corner(keyBtn, 6)
		stroke(keyBtn, Theme.Stroke, 1)

		keyBtn.MouseButton1Click:Connect(function()
			listening = true
			keyBtn.Text = "..."
			tw(keyBtn, { BackgroundColor3 = Theme.AccentDim }, 0.12)
		end)

		table.insert(window._connections, UIS.InputBegan:Connect(function(input, gp)
			if listening and input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
				keyBtn.Text = key.Name
				listening = false
				tw(keyBtn, { BackgroundColor3 = Theme.Input }, 0.15)
				if callback then callback(key) end
			end
		end))

		local d = {}
		function d:Set(k) key = k keyBtn.Text = k.Name end
		function d:Get() return key end
		return d
	end
	section.ConfigKeybind = section.Keybind

	function section:Separator()
		local f = Instance.new("Frame")
		f.BackgroundColor3 = Theme.Stroke
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, 1)
		f.Parent = container
	end

	return section
end

return CrackLib
