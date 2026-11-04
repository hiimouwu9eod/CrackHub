--[[
	CrackLib — UI library matching your CrackLib ScreenGui design
	API:
		local Lib = loadstring(...)()
		local Window = Lib:Init("Title", true, Enum.KeyCode.LeftControl)
		local Tab = Window:CreateTab("Main")
		local Sec = Tab:Section("Combat")
		Sec:Toggle / ConfigToggle / Slider / ConfigSlider / Button / Label / Info / Warning
		Sec:Dropdown / MultiDropdown / Textbox / Keybind
		Window:Unload()
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local CrackLib = {}
CrackLib.__index = CrackLib

local GRAD = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.12, Color3.fromRGB(190, 190, 190)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})

local Theme = {
	Main = Color3.fromRGB(54, 54, 54),
	TopBar = Color3.fromRGB(59, 59, 59),
	TabPlace = Color3.fromRGB(42, 42, 42),
	Element = Color3.fromRGB(52, 52, 52),
	TabBtn = Color3.fromRGB(81, 81, 81),
	SectionBtn = Color3.fromRGB(71, 71, 71),
	Stroke = Color3.fromRGB(125, 125, 125),
	BulbOff = Color3.fromRGB(88, 88, 88),
	BulbOn = Color3.fromRGB(90, 200, 90),
	Info = Color3.fromRGB(51, 157, 186),
	Warning = Color3.fromRGB(216, 174, 76),
	SliderBack = Color3.fromRGB(80, 80, 80),
	SliderFill = Color3.fromRGB(59, 59, 59),
	Text = Color3.fromRGB(255, 255, 255),
	Placeholder = Color3.fromRGB(127, 127, 127),
	SearchBox = Color3.fromRGB(65, 65, 65),
	ItemActive = Color3.fromRGB(80, 80, 80),
	ItemHover = Color3.fromRGB(117, 117, 117),
	ItemInactive = Color3.fromRGB(49, 49, 49),
}

local function protect(gui)
	local ok = pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif gethui then
			gui.Parent = gethui()
			return
		end
	end)
	if not ok or not gui.Parent then
		pcall(function()
			gui.Parent = CoreGui
		end)
	end
	if not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function tween(obj, props, t)
	local ti = TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, ti, props)
	tw:Play()
	return tw
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 12)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function gradient(parent)
	local g = Instance.new("UIGradient")
	g.Color = GRAD
	g.Parent = parent
	return g
end

local function pad(parent, n)
	local p = Instance.new("UIPadding")
	n = n or 12
	p.PaddingTop = UDim.new(0, n)
	p.PaddingBottom = UDim.new(0, n)
	p.PaddingLeft = UDim.new(0, n)
	p.PaddingRight = UDim.new(0, n)
	p.Parent = parent
	return p
end

local function list(parent, padding, horizontal)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, padding or 12)
	if horizontal then
		l.FillDirection = Enum.FillDirection.Horizontal
	end
	l.Parent = parent
	return l
end

local function autoCanvas(scroll, layout)
	local function upd()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
	task.defer(upd)
end

-- ===================== WINDOW =====================
function CrackLib:Init(title, draggable, toggleKey, _theme, _cfg)
	local self = setmetatable({}, CrackLib)
	self._connections = {}
	self._tabs = {}
	self._sections = {}
	self._flags = {}
	self._minimized = false
	self._visible = true
	self.ToggleKey = toggleKey or Enum.KeyCode.LeftControl

	local gui = Instance.new("ScreenGui")
	gui.Name = "CrackLib"
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	protect(gui)
	self.Gui = gui

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.5, -320, 0.5, -220)
	Main.Size = UDim2.new(0, 640, 0, 440)
	Main.Parent = gui
	corner(Main, 12)
	stroke(Main, Theme.Stroke, 3)
	gradient(Main)
	self.Main = Main

	-- Drop shadow
	local shadowHolder = Instance.new("Frame")
	shadowHolder.Name = "DropShadowHolder"
	shadowHolder.BackgroundTransparency = 1
	shadowHolder.Size = UDim2.fromScale(1, 1)
	shadowHolder.ZIndex = 0
	shadowHolder.Parent = Main
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "DropShadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.fromScale(0.5, 0.5)
	shadow.Size = UDim2.new(1.06, 0, 1.12, 0)
	shadow.ZIndex = 0
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Parent = shadowHolder

	-- TopBar
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.BackgroundColor3 = Theme.TopBar
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(1, 0, 0, 56)
	TopBar.Parent = Main
	gradient(TopBar)
	self.TopBar = TopBar

	local line = Instance.new("Frame")
	line.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
	line.BorderSizePixel = 0
	line.Position = UDim2.new(0, 0, 1, -2)
	line.Size = UDim2.new(1, 0, 0, 2)
	line.Parent = TopBar

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(12, 0)
	Title.Size = UDim2.new(0, 180, 1, 0)
	Title.Font = Enum.Font.FredokaOne
	Title.Text = tostring(title or "CrackLib")
	Title.TextColor3 = Theme.Text
	Title.TextSize = 22
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar
	self.Title = Title

	local SearchBox = Instance.new("TextBox")
	SearchBox.Name = "SearchBox"
	SearchBox.BackgroundColor3 = Theme.SearchBox
	SearchBox.BorderSizePixel = 0
	SearchBox.Position = UDim2.new(0, 200, 0.5, -14)
	SearchBox.Size = UDim2.new(0, 260, 0, 28)
	SearchBox.Font = Enum.Font.FredokaOne
	SearchBox.PlaceholderText = "Click to search"
	SearchBox.PlaceholderColor3 = Theme.Placeholder
	SearchBox.Text = ""
	SearchBox.TextColor3 = Theme.Text
	SearchBox.TextSize = 14
	SearchBox.ClearTextOnFocus = false
	SearchBox.Parent = TopBar
	corner(SearchBox, 8)
	self.SearchBox = SearchBox

	local function iconBtn(name, x, imageId)
		local img = Instance.new("ImageButton")
		img.Name = name
		img.BackgroundTransparency = 1
		img.Position = UDim2.new(1, x, 0.5, -12)
		img.Size = UDim2.fromOffset(24, 24)
		img.Image = imageId
		img.Parent = TopBar
		return img
	end

	local ExitBtn = iconBtn("Exit", -36, "rbxassetid://99554242879064")
	local MinBtn = iconBtn("Min", -68, "rbxassetid://101289624554673")

	-- Tab sidebar
	local TabPlace = Instance.new("Frame")
	TabPlace.Name = "TabPlace"
	TabPlace.BackgroundColor3 = Theme.TabPlace
	TabPlace.BorderSizePixel = 0
	TabPlace.Position = UDim2.fromOffset(0, 56)
	TabPlace.Size = UDim2.new(0, 150, 1, -56)
	TabPlace.Parent = Main
	gradient(TabPlace)
	self.TabPlace = TabPlace

	local TabScroll = Instance.new("ScrollingFrame")
	TabScroll.Name = "TabScroll"
	TabScroll.BackgroundTransparency = 1
	TabScroll.BorderSizePixel = 0
	TabScroll.Size = UDim2.fromScale(1, 1)
	TabScroll.ScrollBarThickness = 3
	TabScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	TabScroll.CanvasSize = UDim2.new()
	TabScroll.Parent = TabPlace
	local tabList = list(TabScroll, 10)
	pad(TabScroll, 12)
	autoCanvas(TabScroll, tabList)
	self.TabScroll = TabScroll

	-- Content holder
	local TabHolder = Instance.new("Frame")
	TabHolder.Name = "TabHolder"
	TabHolder.BackgroundTransparency = 1
	TabHolder.Position = UDim2.fromOffset(150, 56)
	TabHolder.Size = UDim2.new(1, -150, 1, -56)
	TabHolder.Parent = Main
	self.TabHolder = TabHolder

	local TabsFolder = Instance.new("Folder")
	TabsFolder.Name = "Tabs"
	TabsFolder.Parent = TabHolder
	self.TabsFolder = TabsFolder

	-- Fade overlay for minimize
	local Fade = Instance.new("Frame")
	Fade.Name = "Fade"
	Fade.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	Fade.BackgroundTransparency = 0.3
	Fade.BorderSizePixel = 0
	Fade.Size = UDim2.fromScale(1, 1)
	Fade.Visible = false
	Fade.ZIndex = 50
	Fade.Parent = Main
	self.Fade = Fade

	-- Drag
	if draggable ~= false then
		local dragging, start, startPos
		TopBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				start = input.Position
				startPos = Main.Position
			end
		end)
		TopBar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		table.insert(self._connections, UIS.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - start
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end))
	end

	ExitBtn.MouseButton1Click:Connect(function()
		self:Unload()
	end)

	MinBtn.MouseButton1Click:Connect(function()
		self._minimized = not self._minimized
		if self._minimized then
			tween(Main, { Size = UDim2.new(0, 640, 0, 56) })
			TabPlace.Visible = false
			TabHolder.Visible = false
		else
			tween(Main, { Size = UDim2.new(0, 640, 0, 440) })
			TabPlace.Visible = true
			TabHolder.Visible = true
		end
	end)

	-- Toggle key
	table.insert(self._connections, UIS.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == self.ToggleKey then
			self._visible = not self._visible
			Main.Visible = self._visible
		end
	end))

	-- Search filter
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(SearchBox.Text)
		for _, tabData in pairs(self._tabs) do
			if tabData.Page then
				for _, child in ipairs(tabData.Page:GetDescendants()) do
					if child:IsA("Frame") and child:FindFirstChild("Text") and child.Text:IsA("TextLabel") then
						local label = child.Text
						if q == "" then
							child.Visible = true
						else
							child.Visible = string.find(string.lower(label.Text), q, 1, true) ~= nil
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
			pcall(function()
				c:Disconnect()
			end)
		end
		if self.Gui then
			self.Gui:Destroy()
		end
	end

	function self:SetToggleKey(key)
		self.ToggleKey = key
	end

	function self:SetVisible(v)
		self._visible = v
		Main.Visible = v
	end

	return self
end

-- ===================== TAB =====================
function CrackLib:CreateTab(name)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = name
	tabBtn.BackgroundColor3 = Theme.TabBtn
	tabBtn.BorderSizePixel = 0
	tabBtn.Size = UDim2.new(1, -8, 0, 36)
	tabBtn.Font = Enum.Font.FredokaOne
	tabBtn.Text = tostring(name)
	tabBtn.TextColor3 = Theme.Text
	tabBtn.TextSize = 16
	tabBtn.AutoButtonColor = false
	tabBtn.Parent = self.TabScroll
	corner(tabBtn, 12)
	gradient(tabBtn)

	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Size = UDim2.fromScale(1, 1)
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	page.CanvasSize = UDim2.new()
	page.Visible = false
	page.Parent = self.TabsFolder
	local pageList = list(page, 12)
	pad(page, 12)
	autoCanvas(page, pageList)

	local tabData = { Name = name, Button = tabBtn, Page = page, Sections = {} }
	self._tabs[name] = tabData

	local function select()
		for _, t in pairs(self._tabs) do
			t.Page.Visible = false
			t.Button.BackgroundColor3 = Theme.TabBtn
		end
		page.Visible = true
		tabBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end

	tabBtn.MouseButton1Click:Connect(select)

	-- first tab auto select
	local count = 0
	for _ in pairs(self._tabs) do
		count += 1
	end
	if count == 1 then
		select()
	end

	local tabApi = {}
	function tabApi:Section(secName)
		return CrackLib.CreateSection(self, tabData, secName)
	end
	-- bind self window
	setmetatable(tabApi, {
		__index = function(_, k)
			if k == "Window" then
				return self
			end
		end,
	})
	tabApi._window = self
	tabApi._tabData = tabData

	function tabApi:Section(secName)
		return CrackLib.CreateSection(tabApi._window, tabData, secName)
	end

	return tabApi
end

-- ===================== SECTION =====================
function CrackLib.CreateSection(window, tabData, secName)
	-- Section header row
	local header = Instance.new("Frame")
	header.Name = "SectionHeader_" .. secName
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 40)
	header.Parent = tabData.Page

	local secBtn = Instance.new("TextButton")
	secBtn.Name = "SectionTab"
	secBtn.BackgroundColor3 = Theme.SectionBtn
	secBtn.BorderSizePixel = 0
	secBtn.Size = UDim2.new(0, 160, 0, 28)
	secBtn.Position = UDim2.fromOffset(0, 4)
	secBtn.Font = Enum.Font.FredokaOne
	secBtn.Text = tostring(secName)
	secBtn.TextColor3 = Theme.Text
	secBtn.TextSize = 14
	secBtn.AutoButtonColor = false
	secBtn.Parent = header
	corner(secBtn, 12)
	gradient(secBtn)
	stroke(secBtn, Theme.Stroke, 2)

	local container = Instance.new("Frame")
	container.Name = "Section_" .. secName
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = tabData.Page
	local cList = list(container, 10)
	autoCanvas(tabData.Page, tabData.Page:FindFirstChildOfClass("UIListLayout"))

	local open = true
	secBtn.MouseButton1Click:Connect(function()
		open = not open
		container.Visible = open
	end)

	local section = { _container = container, _window = window }

	local function makeElementFrame(height, bg)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = bg or Theme.Element
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, height or 45)
		f.Parent = container
		corner(f, 12)
		return f
	end

	local function makeText(parent, str, xAlign)
		local t = Instance.new("TextLabel")
		t.Name = "Text"
		t.BackgroundTransparency = 1
		t.Size = UDim2.new(1, -50, 1, 0)
		t.Position = UDim2.fromOffset(12, 0)
		t.Font = Enum.Font.FredokaOne
		t.Text = tostring(str)
		t.TextColor3 = Theme.Text
		t.TextSize = 16
		t.TextXAlignment = xAlign or Enum.TextXAlignment.Left
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.Parent = parent
		return t
	end

	-- Label
	function section:Label(text)
		local f = makeElementFrame(45)
		local t = makeText(f, text)
		local data = {}
		function data:SetText(v)
			t.Text = tostring(v)
		end
		return data
	end

	function section:Info(text)
		local f = makeElementFrame(45, Theme.Info)
		local t = makeText(f, text)
		local data = {}
		function data:SetText(v)
			t.Text = tostring(v)
		end
		return data
	end

	function section:Warning(text)
		local f = makeElementFrame(45, Theme.Warning)
		local t = makeText(f, text)
		local data = {}
		function data:SetText(v)
			t.Text = tostring(v)
		end
		return data
	end

	-- Toggle
	function section:Toggle(text, default, callback)
		local state = default == true
		local f = makeElementFrame(45)
		makeText(f, text)
		local bulb = Instance.new("Frame")
		bulb.Name = "Bulb"
		bulb.AnchorPoint = Vector2.new(1, 0.5)
		bulb.Position = UDim2.new(1, -10, 0.5, 0)
		bulb.Size = UDim2.fromOffset(34, 34)
		bulb.BackgroundColor3 = state and Theme.BulbOn or Theme.BulbOff
		bulb.BorderSizePixel = 0
		bulb.Parent = f
		corner(bulb, 8)
		local icon = Instance.new("ImageLabel")
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.fromScale(1, 1)
		icon.Image = "rbxassetid://122127875939444"
		icon.Parent = bulb

		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.fromScale(1, 1)
		btn.Text = ""
		btn.Parent = f

		local function set(v, fire)
			state = v and true or false
			tween(bulb, { BackgroundColor3 = state and Theme.BulbOn or Theme.BulbOff })
			if fire ~= false and callback then
				task.spawn(callback, state)
			end
		end
		btn.MouseButton1Click:Connect(function()
			set(not state, true)
		end)
		if default and callback then
			task.defer(callback, true)
		end

		local data = {}
		function data:Set(v)
			set(v, true)
		end
		function data:Get()
			return state
		end
		return data
	end
	section.ConfigToggle = section.Toggle

	-- Button
	function section:Button(text, callback)
		local f = makeElementFrame(45, Color3.fromRGB(70, 70, 78))
		makeText(f, text, Enum.TextXAlignment.Center).Position = UDim2.fromOffset(0, 0)
		f:FindFirstChild("Text").Size = UDim2.fromScale(1, 1)
		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.fromScale(1, 1)
		btn.Text = ""
		btn.Parent = f
		btn.MouseButton1Click:Connect(function()
			if callback then
				task.spawn(callback)
			end
		end)
		return {}
	end

	-- Slider
	function section:Slider(text, min, max, default, callback, decimals)
		min = min or 0
		max = max or 100
		default = default or min
		decimals = decimals or 0
		local value = default

		local f = makeElementFrame(72)
		local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(12, 4)
		title.Size = UDim2.new(0.6, 0, 0, 22)
		title.Font = Enum.Font.FredokaOne
		title.Text = tostring(text)
		title.TextColor3 = Theme.Text
		title.TextSize = 15
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = f

		local valLbl = Instance.new("TextLabel")
		valLbl.Name = "Val"
		valLbl.BackgroundTransparency = 1
		valLbl.Position = UDim2.new(0.55, 0, 0, 4)
		valLbl.Size = UDim2.new(0.4, -12, 0, 22)
		valLbl.Font = Enum.Font.FredokaOne
		valLbl.Text = tostring(default)
		valLbl.TextColor3 = Theme.Text
		valLbl.TextSize = 15
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = f

		local back = Instance.new("Frame")
		back.Name = "SliderBack"
		back.BackgroundColor3 = Theme.SliderBack
		back.BorderSizePixel = 0
		back.Position = UDim2.new(0, 14, 0, 40)
		back.Size = UDim2.new(1, -28, 0, 10)
		back.Parent = f
		corner(back, 12)
		stroke(back, Color3.fromRGB(75, 75, 75), 2)

		local fill = Instance.new("Frame")
		fill.Name = "SliderDrag"
		fill.BackgroundColor3 = Theme.SliderFill
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(math.clamp((default - min) / math.max(max - min, 1e-6), 0, 1), 0, 1, 0)
		fill.Parent = back
		corner(fill, 12)

		local sliding = false
		local function setFromX(x)
			local rel = math.clamp((x - back.AbsolutePosition.X) / math.max(back.AbsoluteSize.X, 1), 0, 1)
			local raw = min + (max - min) * rel
			if decimals <= 0 then
				value = math.floor(raw + 0.5)
			else
				local m = 10 ^ decimals
				value = math.floor(raw * m + 0.5) / m
			end
			fill.Size = UDim2.new(rel, 0, 1, 0)
			valLbl.Text = tostring(value)
			if callback then
				task.spawn(callback, value)
			end
		end

		back.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				setFromX(input.Position.X)
			end
		end)
		table.insert(window._connections, UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end))
		table.insert(window._connections, UIS.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setFromX(input.Position.X)
			end
		end))

		local data = {}
		function data:Set(v)
			value = math.clamp(v, min, max)
			local rel = (value - min) / math.max(max - min, 1e-6)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			valLbl.Text = tostring(value)
			if callback then
				callback(value)
			end
		end
		function data:Get()
			return value
		end
		return data
	end
	section.ConfigSlider = section.Slider

	-- Dropdown (single)
	function section:Dropdown(text, options, default, callback)
		options = options or {}
		local selected = default or options[1]
		local open = false

		local f = makeElementFrame(45)
		f.ClipsDescendants = true
		makeText(f, text .. (selected and (" : " .. tostring(selected)) or ""))
		local arrow = Instance.new("ImageLabel")
		arrow.BackgroundTransparency = 1
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -10, 0.5, 0)
		arrow.Size = UDim2.fromOffset(28, 28)
		arrow.Image = "rbxassetid://109652315428403"
		arrow.Parent = f

		local itemFrame = Instance.new("Frame")
		itemFrame.BackgroundTransparency = 1
		itemFrame.Position = UDim2.fromOffset(8, 45)
		itemFrame.Size = UDim2.new(1, -16, 0, 0)
		itemFrame.ClipsDescendants = true
		itemFrame.Parent = f

		local items = Instance.new("ScrollingFrame")
		items.BackgroundTransparency = 1
		items.Size = UDim2.fromScale(1, 1)
		items.ScrollBarThickness = 3
		items.BorderSizePixel = 0
		items.CanvasSize = UDim2.new()
		items.Parent = itemFrame
		local iList = list(items, 6)
		pad(items, 6)
		autoCanvas(items, iList)

		local titleLbl = f:FindFirstChild("Text")

		local function rebuild()
			for _, c in ipairs(items:GetChildren()) do
				if c:IsA("TextButton") then
					c:Destroy()
				end
			end
			for _, opt in ipairs(options) do
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = (opt == selected) and Theme.ItemActive or Theme.ItemInactive
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 22)
				b.Font = Enum.Font.FredokaOne
				b.Text = "  " .. tostring(opt)
				b.TextColor3 = Theme.Text
				b.TextSize = 13
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.Parent = items
				corner(b, 6)
				b.MouseButton1Click:Connect(function()
					selected = opt
					titleLbl.Text = text .. " : " .. tostring(opt)
					open = false
					tween(f, { Size = UDim2.new(1, 0, 0, 45) })
					itemFrame.Size = UDim2.new(1, -16, 0, 0)
					if callback then
						task.spawn(callback, selected)
					end
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, 45)
		hit.Text = ""
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.min(120, #options * 28 + 20)
				itemFrame.Size = UDim2.new(1, -16, 0, h)
				tween(f, { Size = UDim2.new(1, 0, 0, 45 + h) })
			else
				itemFrame.Size = UDim2.new(1, -16, 0, 0)
				tween(f, { Size = UDim2.new(1, 0, 0, 45) })
			end
		end)

		local data = {}
		function data:Set(v)
			selected = v
			titleLbl.Text = text .. " : " .. tostring(v)
			if callback then
				callback(v)
			end
		end
		function data:Get()
			return selected
		end
		function data:Refresh(newOpts)
			options = newOpts or options
			rebuild()
		end
		return data
	end
	section.ConfigDropdown = section.Dropdown

	-- Multi dropdown
	function section:MultiDropdown(text, options, defaults, callback)
		options = options or {}
		local selected = {}
		if type(defaults) == "table" then
			for _, d in ipairs(defaults) do
				selected[d] = true
			end
		end
		local open = false

		local f = makeElementFrame(45)
		f.ClipsDescendants = true
		local titleLbl = makeText(f, text)
		local arrow = Instance.new("ImageLabel")
		arrow.BackgroundTransparency = 1
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -10, 0.5, 0)
		arrow.Size = UDim2.fromOffset(28, 28)
		arrow.Image = "rbxassetid://109652315428403"
		arrow.Parent = f

		local itemFrame = Instance.new("Frame")
		itemFrame.BackgroundTransparency = 1
		itemFrame.Position = UDim2.fromOffset(8, 45)
		itemFrame.Size = UDim2.new(1, -16, 0, 0)
		itemFrame.ClipsDescendants = true
		itemFrame.Parent = f
		local items = Instance.new("ScrollingFrame")
		items.BackgroundTransparency = 1
		items.Size = UDim2.fromScale(1, 1)
		items.ScrollBarThickness = 3
		items.BorderSizePixel = 0
		items.Parent = itemFrame
		local iList = list(items, 6)
		pad(items, 6)
		autoCanvas(items, iList)

		local function selectedList()
			local t = {}
			for _, o in ipairs(options) do
				if selected[o] then
					t[#t + 1] = o
				end
			end
			return t
		end

		local function rebuild()
			for _, c in ipairs(items:GetChildren()) do
				if c:IsA("TextButton") then
					c:Destroy()
				end
			end
			for _, opt in ipairs(options) do
				local on = selected[opt] == true
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = on and Theme.ItemActive or Theme.ItemInactive
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 22)
				b.Font = Enum.Font.FredokaOne
				b.Text = (on and "  ✓ " or "    ") .. tostring(opt)
				b.TextColor3 = Theme.Text
				b.TextSize = 13
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.Parent = items
				corner(b, 6)
				b.MouseButton1Click:Connect(function()
					selected[opt] = not selected[opt]
					if callback then
						task.spawn(callback, selectedList())
					end
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, 45)
		hit.Text = ""
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.min(120, #options * 28 + 20)
				itemFrame.Size = UDim2.new(1, -16, 0, h)
				tween(f, { Size = UDim2.new(1, 0, 0, 45 + h) })
			else
				itemFrame.Size = UDim2.new(1, -16, 0, 0)
				tween(f, { Size = UDim2.new(1, 0, 0, 45) })
			end
		end)

		local data = {}
		function data:Get()
			return selectedList()
		end
		function data:Refresh(newOpts)
			options = newOpts or options
			rebuild()
		end
		return data
	end

	-- Textbox
	function section:Textbox(text, default, callback)
		local f = makeElementFrame(45)
		makeText(f, text).Size = UDim2.new(0.4, 0, 1, 0)
		local box = Instance.new("TextBox")
		box.BackgroundColor3 = Theme.SearchBox
		box.BorderSizePixel = 0
		box.Position = UDim2.new(0.42, 0, 0.5, -12)
		box.Size = UDim2.new(0.55, -10, 0, 24)
		box.Font = Enum.Font.FredokaOne
		box.Text = tostring(default or "")
		box.PlaceholderText = "..."
		box.PlaceholderColor3 = Theme.Placeholder
		box.TextColor3 = Theme.Text
		box.TextSize = 14
		box.ClearTextOnFocus = false
		box.Parent = f
		corner(box, 6)
		box.FocusLost:Connect(function(enter)
			if callback then
				callback(box.Text)
			end
		end)
		local data = {}
		function data:Set(v)
			box.Text = tostring(v)
		end
		function data:Get()
			return box.Text
		end
		return data
	end
	section.ConfigTextbox = section.Textbox

	-- Keybind
	function section:Keybind(text, defaultKey, callback)
		local key = defaultKey or Enum.KeyCode.E
		local listening = false
		local f = makeElementFrame(45)
		makeText(f, text)
		local keyBtn = Instance.new("TextButton")
		keyBtn.AnchorPoint = Vector2.new(1, 0.5)
		keyBtn.Position = UDim2.new(1, -10, 0.5, 0)
		keyBtn.Size = UDim2.fromOffset(70, 28)
		keyBtn.BackgroundColor3 = Theme.TabBtn
		keyBtn.BorderSizePixel = 0
		keyBtn.Font = Enum.Font.FredokaOne
		keyBtn.Text = key.Name
		keyBtn.TextColor3 = Theme.Text
		keyBtn.TextSize = 13
		keyBtn.Parent = f
		corner(keyBtn, 8)

		keyBtn.MouseButton1Click:Connect(function()
			listening = true
			keyBtn.Text = "..."
		end)

		table.insert(window._connections, UIS.InputBegan:Connect(function(input, gp)
			if listening and input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
				keyBtn.Text = key.Name
				listening = false
				if callback then
					callback(key)
				end
			elseif not listening and not gp and input.KeyCode == key then
				if callback then
					-- optional press fire: only if second arg style
				end
			end
		end))

		local data = {}
		function data:Set(k)
			key = k
			keyBtn.Text = k.Name
		end
		function data:Get()
			return key
		end
		return data
	end
	section.ConfigKeybind = section.Keybind

	-- Separator
	function section:Separator()
		local f = Instance.new("Frame")
		f.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, 2)
		f.Parent = container
	end

	return section
end

return CrackLib
