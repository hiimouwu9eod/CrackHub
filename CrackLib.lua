--[[
	CrackLib v3
	Fixed dropdowns · clean tweens · themes · config save · copy text · key system steps

	local Lib = loadstring(...)()
	local Window = Lib:Init({
		Title = "Hub",
		ToggleKey = Enum.KeyCode.LeftControl,
		KeySystem = {
			Enabled = true,
			Title = "Key System",
			Subtitle = "Enter key to continue",
			Note = "Get key from our link",
			SaveKey = true,
			Key = { "TESTKEY123" }, -- accepted keys
			Steps = {
				{ Name = "Join Discord", Link = "https://discord.gg/example" },
				{ Name = "Get Key", Link = "https://lootlabs.gg/example" },
			},
		},
		ConfigFolder = "CrackLibConfigs",
	})
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local CrackLib = {}
CrackLib.__index = CrackLib

local ICONS = {
	Search = "rbxassetid://7734053426",
	Close = "rbxassetid://7743878857",
	Min = "rbxassetid://7734057143",
	Chevron = "rbxassetid://7733717447",
	Check = "rbxassetid://7733715400",
	Copy = "rbxassetid://7733717541",
	Key = "rbxassetid://7733917211",
	Link = "rbxassetid://7733964715",
	Settings = "rbxassetid://7734053495",
	Shadow = "rbxassetid://6014261993",
	Info = "rbxassetid://7733960981",
	Warning = "rbxassetid://7733993268",
}

local Themes = {
	Dark = {
		Bg = Color3.fromRGB(22, 22, 26),
		Top = Color3.fromRGB(30, 30, 36),
		Sidebar = Color3.fromRGB(18, 18, 22),
		Element = Color3.fromRGB(34, 34, 42),
		ElementHover = Color3.fromRGB(44, 44, 54),
		Accent = Color3.fromRGB(100, 140, 255),
		AccentDim = Color3.fromRGB(70, 100, 210),
		Success = Color3.fromRGB(70, 200, 120),
		Danger = Color3.fromRGB(230, 70, 80),
		Info = Color3.fromRGB(50, 155, 210),
		Warning = Color3.fromRGB(230, 175, 55),
		Text = Color3.fromRGB(245, 245, 250),
		TextDim = Color3.fromRGB(140, 140, 155),
		Stroke = Color3.fromRGB(50, 50, 60),
		Track = Color3.fromRGB(48, 48, 58),
		Input = Color3.fromRGB(28, 28, 34),
		TabIdle = Color3.fromRGB(32, 32, 40),
	},
	Purple = {
		Bg = Color3.fromRGB(24, 20, 32),
		Top = Color3.fromRGB(34, 28, 44),
		Sidebar = Color3.fromRGB(20, 16, 28),
		Element = Color3.fromRGB(40, 32, 52),
		ElementHover = Color3.fromRGB(52, 42, 68),
		Accent = Color3.fromRGB(170, 100, 255),
		AccentDim = Color3.fromRGB(130, 70, 210),
		Success = Color3.fromRGB(70, 200, 120),
		Danger = Color3.fromRGB(230, 70, 80),
		Info = Color3.fromRGB(100, 140, 255),
		Warning = Color3.fromRGB(230, 175, 55),
		Text = Color3.fromRGB(245, 245, 250),
		TextDim = Color3.fromRGB(150, 140, 170),
		Stroke = Color3.fromRGB(55, 45, 70),
		Track = Color3.fromRGB(50, 42, 62),
		Input = Color3.fromRGB(30, 24, 40),
		TabIdle = Color3.fromRGB(36, 28, 48),
	},
	Green = {
		Bg = Color3.fromRGB(18, 24, 20),
		Top = Color3.fromRGB(26, 34, 28),
		Sidebar = Color3.fromRGB(14, 20, 16),
		Element = Color3.fromRGB(30, 40, 34),
		ElementHover = Color3.fromRGB(40, 52, 44),
		Accent = Color3.fromRGB(80, 220, 140),
		AccentDim = Color3.fromRGB(50, 170, 100),
		Success = Color3.fromRGB(80, 220, 140),
		Danger = Color3.fromRGB(230, 70, 80),
		Info = Color3.fromRGB(50, 160, 200),
		Warning = Color3.fromRGB(230, 175, 55),
		Text = Color3.fromRGB(245, 245, 250),
		TextDim = Color3.fromRGB(140, 155, 145),
		Stroke = Color3.fromRGB(40, 55, 45),
		Track = Color3.fromRGB(40, 50, 44),
		Input = Color3.fromRGB(22, 30, 26),
		TabIdle = Color3.fromRGB(28, 36, 30),
	},
	Red = {
		Bg = Color3.fromRGB(26, 18, 20),
		Top = Color3.fromRGB(36, 24, 26),
		Sidebar = Color3.fromRGB(20, 14, 16),
		Element = Color3.fromRGB(42, 30, 32),
		ElementHover = Color3.fromRGB(55, 38, 40),
		Accent = Color3.fromRGB(240, 80, 90),
		AccentDim = Color3.fromRGB(190, 50, 60),
		Success = Color3.fromRGB(70, 200, 120),
		Danger = Color3.fromRGB(240, 80, 90),
		Info = Color3.fromRGB(50, 155, 210),
		Warning = Color3.fromRGB(230, 175, 55),
		Text = Color3.fromRGB(245, 245, 250),
		TextDim = Color3.fromRGB(160, 140, 145),
		Stroke = Color3.fromRGB(60, 40, 42),
		Track = Color3.fromRGB(50, 36, 38),
		Input = Color3.fromRGB(30, 20, 22),
		TabIdle = Color3.fromRGB(38, 26, 28),
	},
}

local Theme = Themes.Dark

local function protect(gui)
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	local ok = pcall(function()
		if gethui then gui.Parent = gethui() end
	end)
	if not ok or not gui.Parent then pcall(function() gui.Parent = CoreGui end) end
	if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

local function tw(obj, props, t, style, dir)
	local a = TweenService:Create(obj, TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
	a:Play()
	return a
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
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

local function pad(p, t, b, l, r)
	local x = Instance.new("UIPadding")
	x.PaddingTop = UDim.new(0, t or 10)
	x.PaddingBottom = UDim.new(0, b or t or 10)
	x.PaddingLeft = UDim.new(0, l or t or 10)
	x.PaddingRight = UDim.new(0, r or l or t or 10)
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
		pcall(function()
			scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 20)
		end)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
	task.defer(upd)
	return upd
end

local function copyText(str)
	str = tostring(str or "")
	local ok = pcall(function()
		if setclipboard then setclipboard(str)
		elseif toclipboard then toclipboard(str)
		elseif Clipboard and Clipboard.set then Clipboard.set(str)
		else error("no clipboard") end
	end)
	return ok
end

local function isfile_(p)
	local ok, r = pcall(function() return isfile and isfile(p) end)
	return ok and r
end

local function readfile_(p)
	local ok, r = pcall(function() return readfile(p) end)
	return ok and r or nil
end

local function writefile_(p, d)
	return pcall(function()
		if makefolder then
			local folder = p:match("^(.*)/[^/]+$")
			if folder then pcall(makefolder, folder) end
		end
		writefile(p, d)
	end)
end

-- ===================== KEY SYSTEM UI =====================
local function showKeySystem(opts, onSuccess)
	local ks = opts.KeySystem
	if not ks or not ks.Enabled then
		onSuccess()
		return
	end

	-- saved key?
	if ks.SaveKey then
		local path = (opts.ConfigFolder or "CrackLibConfigs") .. "/key.txt"
		local saved = readfile_(path)
		if saved then
			saved = saved:gsub("%s+", "")
			for _, k in ipairs(ks.Key or {}) do
				if saved == tostring(k) then
					onSuccess()
					return
				end
			end
		end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "CrackLibKey"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	protect(gui)

	local bg = Instance.new("Frame")
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BackgroundTransparency = 0.45
	bg.Size = UDim2.fromScale(1, 1)
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(0, 0)
	card.BackgroundColor3 = Theme.Bg
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = gui
	corner(card, 14)
	stroke(card, Theme.Stroke, 1)
	tw(card, { Size = UDim2.fromOffset(420, 380) }, 0.3, Enum.EasingStyle.Back)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(20, 16)
	title.Size = UDim2.new(1, -40, 0, 28)
	title.Font = Enum.Font.GothamBold
	title.Text = ks.Title or "Key System"
	title.TextColor3 = Theme.Text
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromOffset(20, 46)
	sub.Size = UDim2.new(1, -40, 0, 18)
	sub.Font = Enum.Font.Gotham
	sub.Text = ks.Subtitle or "Complete steps & enter key"
	sub.TextColor3 = Theme.TextDim
	sub.TextSize = 13
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Parent = card

	-- steps
	local stepsFrame = Instance.new("ScrollingFrame")
	stepsFrame.BackgroundTransparency = 1
	stepsFrame.Position = UDim2.fromOffset(16, 78)
	stepsFrame.Size = UDim2.new(1, -32, 0, 140)
	stepsFrame.ScrollBarThickness = 3
	stepsFrame.ScrollBarImageColor3 = Theme.Accent
	stepsFrame.BorderSizePixel = 0
	stepsFrame.CanvasSize = UDim2.new()
	stepsFrame.Parent = card
	local sList = vlist(stepsFrame, 8)
	autoCanvas(stepsFrame, sList)

	for i, step in ipairs(ks.Steps or {}) do
		local row = Instance.new("Frame")
		row.BackgroundColor3 = Theme.Element
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 40)
		row.Parent = stepsFrame
		corner(row, 8)

		local num = Instance.new("TextLabel")
		num.BackgroundColor3 = Theme.Accent
		num.Size = UDim2.fromOffset(24, 24)
		num.Position = UDim2.fromOffset(8, 8)
		num.Font = Enum.Font.GothamBold
		num.Text = tostring(i)
		num.TextColor3 = Theme.Text
		num.TextSize = 12
		num.Parent = row
		corner(num, 6)

		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Position = UDim2.fromOffset(40, 0)
		name.Size = UDim2.new(1, -120, 1, 0)
		name.Font = Enum.Font.GothamMedium
		name.Text = step.Name or ("Step " .. i)
		name.TextColor3 = Theme.Text
		name.TextSize = 13
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.Parent = row

		if step.Link then
			local openBtn = Instance.new("TextButton")
			openBtn.AnchorPoint = Vector2.new(1, 0.5)
			openBtn.Position = UDim2.new(1, -8, 0.5, 0)
			openBtn.Size = UDim2.fromOffset(70, 26)
			openBtn.BackgroundColor3 = Theme.Accent
			openBtn.BorderSizePixel = 0
			openBtn.Font = Enum.Font.GothamBold
			openBtn.Text = "Open"
			openBtn.TextColor3 = Theme.Text
			openBtn.TextSize = 12
			openBtn.AutoButtonColor = false
			openBtn.Parent = row
			corner(openBtn, 6)
			openBtn.MouseButton1Click:Connect(function()
				copyText(step.Link)
				pcall(function()
					if setclipboard then setclipboard(step.Link) end
				end)
				-- try open
				pcall(function()
					local req = (syn and syn.request) or http_request or request
					if typeof(req) == "function" then
						-- can't open browser easily; copy is enough
					end
				end)
				openBtn.Text = "Copied"
				task.delay(1.2, function()
					if openBtn.Parent then openBtn.Text = "Open" end
				end)
			end)
		end
	end

	local note = Instance.new("TextLabel")
	note.BackgroundTransparency = 1
	note.Position = UDim2.fromOffset(20, 228)
	note.Size = UDim2.new(1, -40, 0, 16)
	note.Font = Enum.Font.Gotham
	note.Text = ks.Note or ""
	note.TextColor3 = Theme.TextDim
	note.TextSize = 12
	note.TextXAlignment = Enum.TextXAlignment.Left
	note.Parent = card

	local box = Instance.new("TextBox")
	box.BackgroundColor3 = Theme.Input
	box.BorderSizePixel = 0
	box.Position = UDim2.fromOffset(20, 256)
	box.Size = UDim2.new(1, -40, 0, 36)
	box.Font = Enum.Font.Gotham
	box.PlaceholderText = "Enter key..."
	box.PlaceholderColor3 = Theme.TextDim
	box.Text = ""
	box.TextColor3 = Theme.Text
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = card
	corner(box, 8)
	stroke(box, Theme.Stroke, 1)

	local status = Instance.new("TextLabel")
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(20, 298)
	status.Size = UDim2.new(1, -40, 0, 16)
	status.Font = Enum.Font.Gotham
	status.Text = ""
	status.TextColor3 = Theme.Danger
	status.TextSize = 12
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = card

	local submit = Instance.new("TextButton")
	submit.Position = UDim2.fromOffset(20, 322)
	submit.Size = UDim2.new(1, -40, 0, 40)
	submit.BackgroundColor3 = Theme.Accent
	submit.BorderSizePixel = 0
	submit.Font = Enum.Font.GothamBold
	submit.Text = "Submit Key"
	submit.TextColor3 = Theme.Text
	submit.TextSize = 15
	submit.AutoButtonColor = false
	submit.Parent = card
	corner(submit, 8)

	local function tryKey()
		local entered = (box.Text or ""):gsub("%s+", "")
		local ok = false
		for _, k in ipairs(ks.Key or {}) do
			if entered == tostring(k) then ok = true break end
		end
		if ok then
			status.TextColor3 = Theme.Success
			status.Text = "Key accepted"
			if ks.SaveKey then
				writefile_((opts.ConfigFolder or "CrackLibConfigs") .. "/key.txt", entered)
			end
			tw(card, { Size = UDim2.fromOffset(0, 0) }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			task.delay(0.22, function()
				gui:Destroy()
				onSuccess()
			end)
		else
			status.TextColor3 = Theme.Danger
			status.Text = "Invalid key"
			tw(card, { Position = UDim2.new(0.5, 6, 0.5, 0) }, 0.05)
			task.delay(0.05, function()
				tw(card, { Position = UDim2.new(0.5, -6, 0.5, 0) }, 0.05)
				task.delay(0.05, function()
					tw(card, { Position = UDim2.fromScale(0.5, 0.5) }, 0.08)
				end)
			end)
		end
	end

	submit.MouseButton1Click:Connect(tryKey)
	box.FocusLost:Connect(function(enter)
		if enter then tryKey() end
	end)
end

-- ===================== INIT =====================
function CrackLib:Init(opts)
	if type(opts) == "string" then
		opts = { Title = opts, ToggleKey = Enum.KeyCode.LeftControl }
	end
	opts = opts or {}
	local title = opts.Title or "CrackLib"
	local toggleKey = opts.ToggleKey or Enum.KeyCode.LeftControl
	local configFolder = opts.ConfigFolder or "CrackLibConfigs"
	local themeName = opts.Theme or "Dark"
	Theme = Themes[themeName] or Themes.Dark

	local ready = Instance.new("BindableEvent")
	local window

	local function build()
		local self = setmetatable({}, CrackLib)
		self._connections = {}
		self._tabs = {}
		self._flags = {}
		self._visible = true
		self._minimized = false
		self.ToggleKey = toggleKey
		self.ConfigFolder = configFolder
		self.ConfigName = "default"
		self._themeName = themeName

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
		corner(Main, 12)
		stroke(Main, Theme.Stroke, 1)
		self.Main = Main
		tw(Main, { Size = UDim2.fromOffset(700, 480) }, 0.32, Enum.EasingStyle.Back)

		local sh = Instance.new("ImageLabel")
		sh.AnchorPoint = Vector2.new(0.5, 0.5)
		sh.BackgroundTransparency = 1
		sh.Position = UDim2.fromScale(0.5, 0.5)
		sh.Size = UDim2.new(1.1, 0, 1.14, 0)
		sh.ZIndex = 0
		sh.Image = ICONS.Shadow
		sh.ImageColor3 = Color3.new(0, 0, 0)
		sh.ImageTransparency = 0.5
		sh.ScaleType = Enum.ScaleType.Slice
		sh.SliceCenter = Rect.new(49, 49, 450, 450)
		sh.Parent = Main

		-- Top
		local Top = Instance.new("Frame")
		Top.BackgroundColor3 = Theme.Top
		Top.BorderSizePixel = 0
		Top.Size = UDim2.new(1, 0, 0, 50)
		Top.Parent = Main
		self.Top = Top

		local accent = Instance.new("Frame")
		accent.BackgroundColor3 = Theme.Accent
		accent.BorderSizePixel = 0
		accent.Position = UDim2.new(0, 0, 1, -2)
		accent.Size = UDim2.new(1, 0, 0, 2)
		accent.Parent = Top

		local Title = Instance.new("TextLabel")
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.fromOffset(16, 0)
		Title.Size = UDim2.new(0, 180, 1, 0)
		Title.Font = Enum.Font.GothamBold
		Title.Text = title
		Title.TextColor3 = Theme.Text
		Title.TextSize = 17
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Top

		local searchWrap = Instance.new("Frame")
		searchWrap.BackgroundColor3 = Theme.Input
		searchWrap.BorderSizePixel = 0
		searchWrap.Position = UDim2.new(0, 200, 0.5, -14)
		searchWrap.Size = UDim2.fromOffset(260, 28)
		searchWrap.Parent = Top
		corner(searchWrap, 7)
		stroke(searchWrap, Theme.Stroke, 1)

		local SearchBox = Instance.new("TextBox")
		SearchBox.BackgroundTransparency = 1
		SearchBox.Position = UDim2.fromOffset(10, 0)
		SearchBox.Size = UDim2.new(1, -16, 1, 0)
		SearchBox.Font = Enum.Font.Gotham
		SearchBox.PlaceholderText = "Search..."
		SearchBox.PlaceholderColor3 = Theme.TextDim
		SearchBox.Text = ""
		SearchBox.TextColor3 = Theme.Text
		SearchBox.TextSize = 13
		SearchBox.TextXAlignment = Enum.TextXAlignment.Left
		SearchBox.ClearTextOnFocus = false
		SearchBox.Parent = searchWrap

		local function iconBtn(x, img, col)
			local b = Instance.new("ImageButton")
			b.BackgroundTransparency = 1
			b.Position = UDim2.new(1, x, 0.5, -10)
			b.Size = UDim2.fromOffset(20, 20)
			b.Image = img
			b.ImageColor3 = Theme.TextDim
			b.Parent = Top
			b.MouseEnter:Connect(function() tw(b, { ImageColor3 = col or Theme.Text }, 0.1) end)
			b.MouseLeave:Connect(function() tw(b, { ImageColor3 = Theme.TextDim }, 0.1) end)
			return b
		end

		local ExitBtn = iconBtn(-32, ICONS.Close, Theme.Danger)
		local MinBtn = iconBtn(-60, ICONS.Min, Theme.Accent)

		-- Sidebar
		local Sidebar = Instance.new("Frame")
		Sidebar.BackgroundColor3 = Theme.Sidebar
		Sidebar.BorderSizePixel = 0
		Sidebar.Position = UDim2.fromOffset(0, 50)
		Sidebar.Size = UDim2.new(0, 150, 1, -50)
		Sidebar.Parent = Main

		local TabScroll = Instance.new("ScrollingFrame")
		TabScroll.BackgroundTransparency = 1
		TabScroll.BorderSizePixel = 0
		TabScroll.Size = UDim2.fromScale(1, 1)
		TabScroll.ScrollBarThickness = 2
		TabScroll.ScrollBarImageColor3 = Theme.Accent
		TabScroll.CanvasSize = UDim2.new()
		TabScroll.Parent = Sidebar
		local tabLay = vlist(TabScroll, 5)
		pad(TabScroll, 10)
		autoCanvas(TabScroll, tabLay)
		self.TabScroll = TabScroll

		local Content = Instance.new("Frame")
		Content.BackgroundTransparency = 1
		Content.Position = UDim2.fromOffset(150, 50)
		Content.Size = UDim2.new(1, -150, 1, -50)
		Content.ClipsDescendants = true
		Content.Parent = Main
		self.Content = Content

		local TabsFolder = Instance.new("Folder")
		TabsFolder.Parent = Content
		self.TabsFolder = TabsFolder

		-- drag (smooth)
		local dragging, dragStart, startPos
		Top.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = i.Position
				startPos = Main.Position
			end
		end)
		table.insert(self._connections, UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
		table.insert(self._connections, UIS.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - dragStart
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end))

		ExitBtn.MouseButton1Click:Connect(function()
			tw(Main, { Size = UDim2.fromOffset(0, 0) }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.2, function() self:Unload() end)
		end)

		MinBtn.MouseButton1Click:Connect(function()
			self._minimized = not self._minimized
			if self._minimized then
				tw(Main, { Size = UDim2.fromOffset(700, 50) }, 0.22)
				Sidebar.Visible = false
				Content.Visible = false
			else
				Sidebar.Visible = true
				Content.Visible = true
				tw(Main, { Size = UDim2.fromOffset(700, 480) }, 0.28, Enum.EasingStyle.Back)
			end
		end)

		table.insert(self._connections, UIS.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.KeyCode == self.ToggleKey then
				self._visible = not self._visible
				if self._visible then
					Main.Visible = true
					Main.Size = UDim2.fromOffset(0, 0)
					tw(Main, { Size = UDim2.fromOffset(700, 480) }, 0.28, Enum.EasingStyle.Back)
				else
					tw(Main, { Size = UDim2.fromOffset(0, 0) }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
					task.delay(0.2, function()
						if not self._visible then
							Main.Visible = false
							Main.Size = UDim2.fromOffset(700, 480)
						end
					end)
				end
			end
		end))

		SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = string.lower(SearchBox.Text)
			for _, tab in pairs(self._tabs) do
				if tab.Page then
					for _, child in ipairs(tab.Page:GetDescendants()) do
						if child:IsA("Frame") and child:GetAttribute("IsElement") then
							local lab = child:FindFirstChild("TitleText")
							if lab then
								child.Visible = q == "" or string.find(string.lower(lab.Text), q, 1, true) ~= nil
							end
						end
					end
				end
			end
		end)

		-- config helpers
		function self:SetFlag(name, value)
			self._flags[name] = value
		end
		function self:GetFlag(name)
			return self._flags[name]
		end

		function self:SaveConfig(name)
			name = name or self.ConfigName or "default"
			local path = self.ConfigFolder .. "/" .. name .. ".json"
			local ok = writefile_(path, HttpService:JSONEncode(self._flags))
			return ok
		end

		function self:LoadConfig(name)
			name = name or self.ConfigName or "default"
			local path = self.ConfigFolder .. "/" .. name .. ".json"
			local raw = readfile_(path)
			if not raw then return false end
			local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
			if not ok or type(data) ~= "table" then return false end
			for k, v in pairs(data) do
				self._flags[k] = v
				-- fire registered setters
				if self._flagSetters and self._flagSetters[k] then
					pcall(self._flagSetters[k], v)
				end
			end
			return true
		end

		self._flagSetters = {}
		function self:BindFlag(name, setter)
			self._flagSetters[name] = setter
		end

		function self:SetTheme(name)
			if Themes[name] then
				Theme = Themes[name]
				self._themeName = name
				-- full rebuild is heavy; notify user to re-exec for full theme
			end
		end

		function self:CreateTab(n) return CrackLib.CreateTab(self, n) end

		function self:Unload()
			for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
			if self.Gui then self.Gui:Destroy() end
		end

		function self:SetToggleKey(k) self.ToggleKey = k end
		function self:SetVisible(v) self._visible = v Main.Visible = v end
		function self:Notify(text, dur)
			-- lightweight notify
			local n = Instance.new("TextLabel")
			n.BackgroundColor3 = Theme.Element
			n.BorderSizePixel = 0
			n.AnchorPoint = Vector2.new(1, 1)
			n.Position = UDim2.new(1, -16, 1, -16)
			n.Size = UDim2.fromOffset(260, 40)
			n.Font = Enum.Font.GothamMedium
			n.Text = "  " .. tostring(text)
			n.TextColor3 = Theme.Text
			n.TextSize = 13
			n.TextXAlignment = Enum.TextXAlignment.Left
			n.Parent = gui
			corner(n, 8)
			stroke(n, Theme.Accent, 1)
			task.delay(dur or 2.5, function()
				tw(n, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.25)
				task.delay(0.3, function() n:Destroy() end)
			end)
		end

		window = self
		ready:Fire()
	end

	showKeySystem(opts, build)

	-- wait until built (sync API)
	if not window then
		ready.Event:Wait()
	end
	return window
end

-- ===================== TAB =====================
function CrackLib:CreateTab(name)
	local tabBtn = Instance.new("TextButton")
	tabBtn.BackgroundColor3 = Theme.TabIdle
	tabBtn.BorderSizePixel = 0
	tabBtn.Size = UDim2.new(1, -4, 0, 36)
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.Text = "  " .. tostring(name)
	tabBtn.TextColor3 = Theme.TextDim
	tabBtn.TextSize = 13
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.AutoButtonColor = false
	tabBtn.Parent = self.TabScroll
	corner(tabBtn, 7)

	local ind = Instance.new("Frame")
	ind.BackgroundColor3 = Theme.Accent
	ind.BorderSizePixel = 0
	ind.Position = UDim2.fromOffset(0, 7)
	ind.Size = UDim2.fromOffset(3, 22)
	ind.Visible = false
	ind.Parent = tabBtn
	corner(ind, 2)

	local page = Instance.new("ScrollingFrame")
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
	local refreshCanvas = autoCanvas(page, pageList)

	local tabData = { Button = tabBtn, Page = page, Ind = ind, Refresh = refreshCanvas }
	self._tabs[name] = tabData

	local function select()
		for _, t in pairs(self._tabs) do
			t.Page.Visible = false
			t.Button.BackgroundColor3 = Theme.TabIdle
			t.Button.TextColor3 = Theme.TextDim
			t.Ind.Visible = false
		end
		page.Visible = true
		tabBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
		tabBtn.TextColor3 = Theme.Text
		ind.Visible = true
		if refreshCanvas then refreshCanvas() end
	end

	tabBtn.MouseButton1Click:Connect(select)
	local count = 0
	for _ in pairs(self._tabs) do count += 1 end
	if count == 1 then select() end

	local api = { _w = self, _t = tabData }
	function api:Section(n) return CrackLib.CreateSection(self._w, tabData, n) end
	return api
end

-- ===================== SECTION =====================
function CrackLib.CreateSection(window, tabData, secName)
	local head = Instance.new("Frame")
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, 0, 0, 26)
	head.Parent = tabData.Page

	local chip = Instance.new("TextLabel")
	chip.BackgroundColor3 = Theme.Element
	chip.BorderSizePixel = 0
	chip.AutomaticSize = Enum.AutomaticSize.X
	chip.Size = UDim2.fromOffset(0, 24)
	chip.Font = Enum.Font.GothamBold
	chip.Text = "  " .. tostring(secName) .. "  "
	chip.TextColor3 = Theme.Accent
	chip.TextSize = 11
	chip.Parent = head
	corner(chip, 6)
	stroke(chip, Theme.AccentDim, 1)

	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Size = UDim2.new(1, 0, 0, 0)
	box.AutomaticSize = Enum.AutomaticSize.Y
	box.Parent = tabData.Page
	vlist(box, 7)

	local section = { _box = box, _w = window, _page = tabData.Page, _refresh = tabData.Refresh }

	local function element(h, bg)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = bg or Theme.Element
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, h or 42)
		f.ClipsDescendants = true
		f:SetAttribute("IsElement", true)
		f.Parent = box
		corner(f, 8)
		stroke(f, Theme.Stroke, 1)
		if not bg then
			f.MouseEnter:Connect(function()
				if f.BackgroundColor3 == Theme.Element then tw(f, { BackgroundColor3 = Theme.ElementHover }, 0.1) end
			end)
			f.MouseLeave:Connect(function()
				if f.BackgroundColor3 == Theme.ElementHover then tw(f, { BackgroundColor3 = Theme.Element }, 0.1) end
			end)
		end
		return f
	end

	local function label(parent, text, padRight)
		local t = Instance.new("TextLabel")
		t.Name = "TitleText"
		t.BackgroundTransparency = 1
		t.Position = UDim2.fromOffset(12, 0)
		t.Size = UDim2.new(1, -(padRight or 50), 1, 0)
		t.Font = Enum.Font.GothamMedium
		t.Text = tostring(text)
		t.TextColor3 = Theme.Text
		t.TextSize = 13
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.Parent = parent
		return t
	end

	local function refreshPage()
		if section._refresh then task.defer(section._refresh) end
	end

	function section:Label(text)
		local f = element(42)
		label(f, text, 40)
		local d = {}
		function d:SetText(v) local t = f:FindFirstChild("TitleText") if t then t.Text = tostring(v) end end
		return d
	end

	function section:Info(text)
		local f = element(42, Theme.Info)
		label(f, text, 12)
		local d = {}
		function d:SetText(v) local t = f:FindFirstChild("TitleText") if t then t.Text = tostring(v) end end
		return d
	end

	function section:Warning(text)
		local f = element(42, Theme.Warning)
		label(f, text, 12)
		local d = {}
		function d:SetText(v) local t = f:FindFirstChild("TitleText") if t then t.Text = tostring(v) end end
		return d
	end

	function section:Toggle(text, default, callback, flag)
		local state = default == true
		local f = element(42)
		label(f, text, 58)

		local track = Instance.new("Frame")
		track.AnchorPoint = Vector2.new(1, 0.5)
		track.Position = UDim2.new(1, -12, 0.5, 0)
		track.Size = UDim2.fromOffset(42, 22)
		track.BackgroundColor3 = state and Theme.Success or Theme.Track
		track.BorderSizePixel = 0
		track.Parent = f
		corner(track, 11)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(16, 16)
		knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Parent = track
		corner(knob, 8)

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.Text = ""
		hit.Parent = f

		local function set(v, fire)
			state = v and true or false
			tw(track, { BackgroundColor3 = state and Theme.Success or Theme.Track }, 0.15)
			tw(knob, { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, 0.18, Enum.EasingStyle.Back)
			if flag then window:SetFlag(flag, state) end
			if fire ~= false and callback then task.spawn(callback, state) end
		end

		hit.MouseButton1Click:Connect(function() set(not state, true) end)
		if flag then
			window:SetFlag(flag, state)
			window:BindFlag(flag, function(v) set(v, true) end)
		end
		if default and callback then task.defer(callback, true) end

		local d = {}
		function d:Set(v) set(v, true) end
		function d:Get() return state end
		return d
	end
	section.ConfigToggle = section.Toggle

	function section:Button(text, callback)
		local f = element(42, Color3.fromRGB(42, 48, 64))
		local t = label(f, text, 0)
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
			tw(f, { BackgroundColor3 = Theme.Accent }, 0.06)
			task.delay(0.08, function() tw(f, { BackgroundColor3 = Color3.fromRGB(42, 48, 64) }, 0.18) end)
			if callback then task.spawn(callback) end
		end)
		return {}
	end

	function section:Slider(text, min, max, default, callback, decimals, flag)
		min, max = min or 0, max or 100
		default = default or min
		decimals = decimals or 0
		local value = default

		local f = element(64)
		local title = Instance.new("TextLabel")
		title.Name = "TitleText"
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(12, 4)
		title.Size = UDim2.new(0.55, 0, 0, 18)
		title.Font = Enum.Font.GothamMedium
		title.Text = tostring(text)
		title.TextColor3 = Theme.Text
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = f

		local valLbl = Instance.new("TextLabel")
		valLbl.BackgroundTransparency = 1
		valLbl.Position = UDim2.new(0.55, 0, 0, 4)
		valLbl.Size = UDim2.new(0.42, -10, 0, 18)
		valLbl.Font = Enum.Font.GothamBold
		valLbl.Text = tostring(default)
		valLbl.TextColor3 = Theme.Accent
		valLbl.TextSize = 13
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = f

		local track = Instance.new("Frame")
		track.BackgroundColor3 = Theme.Track
		track.BorderSizePixel = 0
		track.Position = UDim2.new(0, 12, 0, 36)
		track.Size = UDim2.new(1, -24, 0, 6)
		track.Parent = f
		corner(track, 3)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(math.clamp((default - min) / math.max(max - min, 1e-9), 0, 1), 0, 1, 0)
		fill.Parent = track
		corner(fill, 3)

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
		knob.Size = UDim2.fromOffset(12, 12)
		knob.Parent = track
		corner(knob, 6)

		local sliding = false
		local function apply(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local raw = min + (max - min) * rel
			if decimals <= 0 then value = math.floor(raw + 0.5)
			else local m = 10 ^ decimals value = math.floor(raw * m + 0.5) / m end
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			valLbl.Text = tostring(value)
			if flag then window:SetFlag(flag, value) end
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

		if flag then
			window:SetFlag(flag, value)
			window:BindFlag(flag, function(v)
				value = math.clamp(tonumber(v) or value, min, max)
				local rel = (value - min) / math.max(max - min, 1e-9)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				knob.Position = UDim2.new(rel, 0, 0.5, 0)
				valLbl.Text = tostring(value)
				if callback then callback(value) end
			end)
		end

		local d = {}
		function d:Set(v)
			value = math.clamp(v, min, max)
			local rel = (value - min) / math.max(max - min, 1e-9)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			valLbl.Text = tostring(value)
			if flag then window:SetFlag(flag, value) end
			if callback then callback(value) end
		end
		function d:Get() return value end
		return d
	end
	section.ConfigSlider = section.Slider

	-- FIXED DROPDOWN
	function section:Dropdown(text, options, default, callback, flag)
		options = options or { "None" }
		local selected = default or options[1]
		local open = false
		local CLOSED_H = 42

		local f = element(CLOSED_H)
		f.ClipsDescendants = true
		local title = label(f, text .. "  ·  " .. tostring(selected), 40)

		local chev = Instance.new("ImageLabel")
		chev.BackgroundTransparency = 1
		chev.AnchorPoint = Vector2.new(1, 0)
		chev.Position = UDim2.new(1, -10, 0, 10)
		chev.Size = UDim2.fromOffset(20, 20)
		chev.Image = ICONS.Chevron
		chev.ImageColor3 = Theme.TextDim
		chev.Parent = f

		local listFrame = Instance.new("Frame")
		listFrame.Name = "DropList"
		listFrame.BackgroundColor3 = Theme.Input
		listFrame.BorderSizePixel = 0
		listFrame.Position = UDim2.fromOffset(8, 40)
		listFrame.Size = UDim2.new(1, -16, 0, 0)
		listFrame.ClipsDescendants = true
		listFrame.Parent = f
		corner(listFrame, 6)

		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.fromScale(1, 1)
		holder.Parent = listFrame
		local holdList = vlist(holder, 2)
		pad(holder, 4)

		local function closeDrop()
			open = false
			tw(chev, { Rotation = 0 }, 0.15)
			tw(listFrame, { Size = UDim2.new(1, -16, 0, 0) }, 0.15)
			tw(f, { Size = UDim2.new(1, 0, 0, CLOSED_H) }, 0.18)
			task.delay(0.2, refreshPage)
		end

		local function rebuild()
			for _, c in ipairs(holder:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = (tostring(opt) == tostring(selected)) and Theme.AccentDim or Theme.Element
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 28)
				b.Font = Enum.Font.Gotham
				b.Text = "  " .. tostring(opt)
				b.TextColor3 = Theme.Text
				b.TextSize = 12
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.Parent = holder
				corner(b, 5)
				b.MouseButton1Click:Connect(function()
					selected = opt
					title.Text = text .. "  ·  " .. tostring(opt)
					if flag then window:SetFlag(flag, selected) end
					if callback then task.spawn(callback, selected) end
					closeDrop()
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, CLOSED_H)
		hit.Text = ""
		hit.ZIndex = 3
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.clamp(#options * 30 + 10, 40, 140)
				listFrame.Size = UDim2.new(1, -16, 0, h)
				tw(f, { Size = UDim2.new(1, 0, 0, CLOSED_H + h + 6) }, 0.2)
				tw(chev, { Rotation = 180 }, 0.15)
				task.delay(0.05, refreshPage)
			else
				closeDrop()
			end
		end)

		if flag then
			window:SetFlag(flag, selected)
			window:BindFlag(flag, function(v)
				selected = v
				title.Text = text .. "  ·  " .. tostring(v)
				if callback then callback(v) end
				rebuild()
			end)
		end

		local d = {}
		function d:Set(v)
			selected = v
			title.Text = text .. "  ·  " .. tostring(v)
			if flag then window:SetFlag(flag, v) end
			if callback then callback(v) end
			rebuild()
		end
		function d:Get() return selected end
		function d:Refresh(opts)
			options = opts or options
			rebuild()
		end
		return d
	end
	section.ConfigDropdown = section.Dropdown

	function section:MultiDropdown(text, options, defaults, callback, flag)
		options = options or {}
		local selected = {}
		if type(defaults) == "table" then
			for _, x in ipairs(defaults) do selected[tostring(x)] = true end
		end
		local open = false
		local CLOSED_H = 42

		local f = element(CLOSED_H)
		f.ClipsDescendants = true
		local title = label(f, text, 40)
		local chev = Instance.new("ImageLabel")
		chev.BackgroundTransparency = 1
		chev.AnchorPoint = Vector2.new(1, 0)
		chev.Position = UDim2.new(1, -10, 0, 10)
		chev.Size = UDim2.fromOffset(20, 20)
		chev.Image = ICONS.Chevron
		chev.ImageColor3 = Theme.TextDim
		chev.Parent = f

		local listFrame = Instance.new("Frame")
		listFrame.BackgroundColor3 = Theme.Input
		listFrame.BorderSizePixel = 0
		listFrame.Position = UDim2.fromOffset(8, 40)
		listFrame.Size = UDim2.new(1, -16, 0, 0)
		listFrame.ClipsDescendants = true
		listFrame.Parent = f
		corner(listFrame, 6)
		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.fromScale(1, 1)
		holder.Parent = listFrame
		vlist(holder, 2)
		pad(holder, 4)

		local function listSel()
			local t = {}
			for _, o in ipairs(options) do
				if selected[tostring(o)] then t[#t + 1] = o end
			end
			return t
		end

		local function rebuild()
			for _, c in ipairs(holder:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local on = selected[tostring(opt)]
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = on and Theme.AccentDim or Theme.Element
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 28)
				b.Font = Enum.Font.Gotham
				b.Text = (on and "  ✓  " or "      ") .. tostring(opt)
				b.TextColor3 = Theme.Text
				b.TextSize = 12
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.Parent = holder
				corner(b, 5)
				b.MouseButton1Click:Connect(function()
					selected[tostring(opt)] = not selected[tostring(opt)]
					local ls = listSel()
					if flag then window:SetFlag(flag, ls) end
					if callback then task.spawn(callback, ls) end
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, CLOSED_H)
		hit.Text = ""
		hit.ZIndex = 3
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.clamp(#options * 30 + 10, 40, 140)
				listFrame.Size = UDim2.new(1, -16, 0, h)
				tw(f, { Size = UDim2.new(1, 0, 0, CLOSED_H + h + 6) }, 0.2)
				tw(chev, { Rotation = 180 }, 0.15)
				task.delay(0.05, refreshPage)
			else
				open = false
				tw(chev, { Rotation = 0 }, 0.15)
				tw(listFrame, { Size = UDim2.new(1, -16, 0, 0) }, 0.15)
				tw(f, { Size = UDim2.new(1, 0, 0, CLOSED_H) }, 0.18)
				task.delay(0.2, refreshPage)
			end
		end)

		local d = {}
		function d:Get() return listSel() end
		function d:Refresh(opts) options = opts or options rebuild() end
		return d
	end

	function section:Textbox(text, default, callback, flag)
		local f = element(42)
		label(f, text, 0).Size = UDim2.new(0.32, 0, 1, 0)
		local box = Instance.new("TextBox")
		box.BackgroundColor3 = Theme.Input
		box.BorderSizePixel = 0
		box.Position = UDim2.new(0.34, 0, 0.5, -12)
		box.Size = UDim2.new(0.5, 0, 0, 24)
		box.Font = Enum.Font.Gotham
		box.Text = tostring(default or "")
		box.PlaceholderText = "..."
		box.PlaceholderColor3 = Theme.TextDim
		box.TextColor3 = Theme.Text
		box.TextSize = 12
		box.ClearTextOnFocus = false
		box.Parent = f
		corner(box, 6)
		local st = stroke(box, Theme.Stroke, 1)

		local copyBtn = Instance.new("TextButton")
		copyBtn.AnchorPoint = Vector2.new(1, 0.5)
		copyBtn.Position = UDim2.new(1, -8, 0.5, 0)
		copyBtn.Size = UDim2.fromOffset(28, 24)
		copyBtn.BackgroundColor3 = Theme.Input
		copyBtn.BorderSizePixel = 0
		copyBtn.Font = Enum.Font.GothamBold
		copyBtn.Text = "⎘"
		copyBtn.TextColor3 = Theme.TextDim
		copyBtn.TextSize = 14
		copyBtn.AutoButtonColor = false
		copyBtn.Parent = f
		corner(copyBtn, 5)
		copyBtn.MouseButton1Click:Connect(function()
			if copyText(box.Text) then
				copyBtn.TextColor3 = Theme.Success
				task.delay(0.8, function() copyBtn.TextColor3 = Theme.TextDim end)
			end
		end)

		box.Focused:Connect(function() st.Color = Theme.Accent end)
		box.FocusLost:Connect(function()
			st.Color = Theme.Stroke
			if flag then window:SetFlag(flag, box.Text) end
			if callback then callback(box.Text) end
		end)
		if flag then
			window:SetFlag(flag, box.Text)
			window:BindFlag(flag, function(v) box.Text = tostring(v or "") if callback then callback(box.Text) end end)
		end
		local d = {}
		function d:Set(v) box.Text = tostring(v) end
		function d:Get() return box.Text end
		return d
	end
	section.ConfigTextbox = section.Textbox

	function section:Keybind(text, defaultKey, callback, flag)
		local key = defaultKey or Enum.KeyCode.E
		local listening = false
		local f = element(42)
		label(f, text, 90)
		local keyBtn = Instance.new("TextButton")
		keyBtn.AnchorPoint = Vector2.new(1, 0.5)
		keyBtn.Position = UDim2.new(1, -10, 0.5, 0)
		keyBtn.Size = UDim2.fromOffset(78, 24)
		keyBtn.BackgroundColor3 = Theme.Input
		keyBtn.BorderSizePixel = 0
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.Text = key.Name
		keyBtn.TextColor3 = Theme.Accent
		keyBtn.TextSize = 11
		keyBtn.AutoButtonColor = false
		keyBtn.Parent = f
		corner(keyBtn, 6)

		keyBtn.MouseButton1Click:Connect(function()
			listening = true
			keyBtn.Text = "..."
		end)

		table.insert(window._connections, UIS.InputBegan:Connect(function(input, gp)
			if listening and input.UserInputType == Enum.UserInputType.Keyboard then
				key = input.KeyCode
				keyBtn.Text = key.Name
				listening = false
				if flag then window:SetFlag(flag, key.Name) end
				if callback then callback(key) end
			end
		end))

		if flag then
			window:SetFlag(flag, key.Name)
			window:BindFlag(flag, function(v)
				local ok, k = pcall(function() return Enum.KeyCode[v] end)
				if ok and k then key = k keyBtn.Text = k.Name end
			end)
		end
		local d = {}
		function d:Set(k) key = k keyBtn.Text = k.Name end
		function d:Get() return key end
		return d
	end
	section.ConfigKeybind = section.Keybind

	function section:ColorPicker(text, default, callback, flag)
		default = default or Theme.Accent
		local color = default
		local f = element(42)
		label(f, text, 50)
		local swatch = Instance.new("TextButton")
		swatch.AnchorPoint = Vector2.new(1, 0.5)
		swatch.Position = UDim2.new(1, -12, 0.5, 0)
		swatch.Size = UDim2.fromOffset(28, 28)
		swatch.BackgroundColor3 = color
		swatch.BorderSizePixel = 0
		swatch.Text = ""
		swatch.AutoButtonColor = false
		swatch.Parent = f
		corner(swatch, 6)
		stroke(swatch, Theme.Stroke, 1)

		-- simple cycle presets on click
		local presets = {
			Color3.fromRGB(100, 140, 255),
			Color3.fromRGB(170, 100, 255),
			Color3.fromRGB(80, 220, 140),
			Color3.fromRGB(240, 80, 90),
			Color3.fromRGB(255, 180, 50),
			Color3.fromRGB(255, 255, 255),
		}
		local idx = 1
		swatch.MouseButton1Click:Connect(function()
			idx = (idx % #presets) + 1
			color = presets[idx]
			swatch.BackgroundColor3 = color
			if flag then
				window:SetFlag(flag, { R = color.R, G = color.G, B = color.B })
			end
			if callback then task.spawn(callback, color) end
		end)
		local d = {}
		function d:Set(c) color = c swatch.BackgroundColor3 = c end
		function d:Get() return color end
		return d
	end

	function section:Paragraph(text)
		local f = element(60)
		local t = label(f, text, 12)
		t.TextWrapped = true
		t.TextYAlignment = Enum.TextYAlignment.Top
		t.Position = UDim2.fromOffset(12, 8)
		t.Size = UDim2.new(1, -24, 1, -12)
		local d = {}
		function d:SetText(v) t.Text = tostring(v) end
		return d
	end

	function section:Separator()
		local f = Instance.new("Frame")
		f.BackgroundColor3 = Theme.Stroke
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, 1)
		f.Parent = box
	end

	return section
end

return CrackLib
