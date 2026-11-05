--[[
	CrackLib Pro
	Premium UI · working search · solid callbacks · glass / neon look

	Usage:
	local Lib = loadstring(game:HttpGet("URL"))()
	local Win = Lib:CreateWindow({
		Name = "My Hub",
		ToggleKey = Enum.KeyCode.LeftControl,
		Theme = "Dark", -- Dark | Midnight | Ocean | Crimson
		KeySystem = {
			Enabled = false,
			Key = {"KEY"},
			Steps = {{Name="Get Key", Link="https://..."}},
		},
	})
	local Tab = Win:Tab("Main")
	local Sec = Tab:Section("Combat")
	Sec:Toggle("Aimbot", false, function(v) print(v) end)
]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Lib = {}

local Themes = {
	Dark = {
		Bg = Color3.fromRGB(16, 16, 20),
		Panel = Color3.fromRGB(22, 22, 28),
		Card = Color3.fromRGB(30, 30, 38),
		CardHover = Color3.fromRGB(38, 38, 48),
		Accent = Color3.fromRGB(120, 100, 255),
		Accent2 = Color3.fromRGB(80, 200, 255),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(150, 150, 165),
		Stroke = Color3.fromRGB(55, 55, 70),
		Success = Color3.fromRGB(80, 220, 140),
		Danger = Color3.fromRGB(255, 80, 100),
		Warning = Color3.fromRGB(255, 190, 60),
		Info = Color3.fromRGB(60, 170, 255),
	},
	Midnight = {
		Bg = Color3.fromRGB(8, 10, 18),
		Panel = Color3.fromRGB(12, 14, 24),
		Card = Color3.fromRGB(20, 24, 40),
		CardHover = Color3.fromRGB(28, 34, 55),
		Accent = Color3.fromRGB(90, 140, 255),
		Accent2 = Color3.fromRGB(180, 100, 255),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(130, 140, 170),
		Stroke = Color3.fromRGB(40, 50, 80),
		Success = Color3.fromRGB(80, 220, 140),
		Danger = Color3.fromRGB(255, 80, 100),
		Warning = Color3.fromRGB(255, 190, 60),
		Info = Color3.fromRGB(60, 170, 255),
	},
	Ocean = {
		Bg = Color3.fromRGB(8, 16, 20),
		Panel = Color3.fromRGB(12, 22, 28),
		Card = Color3.fromRGB(18, 32, 40),
		CardHover = Color3.fromRGB(24, 42, 52),
		Accent = Color3.fromRGB(40, 220, 200),
		Accent2 = Color3.fromRGB(60, 160, 255),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(130, 160, 165),
		Stroke = Color3.fromRGB(30, 60, 70),
		Success = Color3.fromRGB(80, 220, 140),
		Danger = Color3.fromRGB(255, 80, 100),
		Warning = Color3.fromRGB(255, 190, 60),
		Info = Color3.fromRGB(60, 170, 255),
	},
	Crimson = {
		Bg = Color3.fromRGB(18, 10, 12),
		Panel = Color3.fromRGB(26, 14, 16),
		Card = Color3.fromRGB(36, 20, 24),
		CardHover = Color3.fromRGB(48, 28, 32),
		Accent = Color3.fromRGB(255, 70, 90),
		Accent2 = Color3.fromRGB(255, 140, 80),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(170, 140, 145),
		Stroke = Color3.fromRGB(70, 35, 40),
		Success = Color3.fromRGB(80, 220, 140),
		Danger = Color3.fromRGB(255, 80, 100),
		Warning = Color3.fromRGB(255, 190, 60),
		Info = Color3.fromRGB(60, 170, 255),
	},
}

local function parentGui(gui)
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

local function tween(o, props, t, style)
	local tw = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end

local function stroke(p, col, th, trans)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Thickness = th or 1
	s.Transparency = trans or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function gradient(p, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rot or 90
	g.Parent = p
	return g
end

local function pad(p, n)
	local x = Instance.new("UIPadding")
	x.PaddingTop = UDim.new(0, n)
	x.PaddingBottom = UDim.new(0, n)
	x.PaddingLeft = UDim.new(0, n)
	x.PaddingRight = UDim.new(0, n)
	x.Parent = p
	return x
end

local function list(p, gap)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, gap or 8)
	l.Parent = p
	return l
end

local function fire(fn, ...)
	if type(fn) ~= "function" then return end
	local a = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(fn, table.unpack(a, 1, a.n))
		if not ok then warn("[CrackLib]", err) end
	end)
end

local function writefile_(path, data)
	return pcall(function()
		if makefolder then
			local f = path:match("^(.*)/")
			if f then pcall(makefolder, f) end
		end
		writefile(path, data)
	end)
end

local function readfile_(path)
	local ok, r = pcall(readfile, path)
	return ok and r or nil
end

local function clipboard_(s)
	pcall(function()
		if setclipboard then setclipboard(s)
		elseif toclipboard then toclipboard(s) end
	end)
end

-- ===================== WINDOW =====================
function Lib:CreateWindow(cfg)
	cfg = cfg or {}
	local T = Themes[cfg.Theme or "Dark"] or Themes.Dark
	local toggleKey = cfg.ToggleKey or Enum.KeyCode.LeftControl
	local configFolder = cfg.ConfigFolder or "CrackLibPro"

	local state = {
		tabs = {},
		flags = {},
		setters = {},
		cons = {},
		visible = true,
		theme = T,
	}

	local gui = Instance.new("ScreenGui")
	gui.Name = "CrackLibPro"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	parentGui(gui)

	-- Main window
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.Position = UDim2.fromScale(0.5, 0.5)
	Main.Size = UDim2.fromOffset(0, 0)
	Main.BackgroundColor3 = T.Bg
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = gui
	corner(Main, 16)
	stroke(Main, T.Accent, 1.5, 0.3)
	gradient(Main, T.Bg, Color3.fromRGB(
		math.clamp(T.Bg.R * 255 + 12, 0, 255) / 255,
		math.clamp(T.Bg.G * 255 + 8, 0, 255) / 255,
		math.clamp(T.Bg.B * 255 + 20, 0, 255) / 255
	), 135)

	-- soft glow ring
	local glow = Instance.new("ImageLabel")
	glow.BackgroundTransparency = 1
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromScale(0.5, 0.5)
	glow.Size = UDim2.new(1.15, 0, 1.2, 0)
	glow.Image = "rbxassetid://6014261993"
	glow.ImageColor3 = T.Accent
	glow.ImageTransparency = 0.82
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(49, 49, 450, 450)
	glow.ZIndex = 0
	glow.Parent = Main

	tween(Main, { Size = UDim2.fromOffset(720, 500) }, 0.4, Enum.EasingStyle.Back)

	-- Top bar
	local Top = Instance.new("Frame")
	Top.Size = UDim2.new(1, 0, 0, 54)
	Top.BackgroundColor3 = T.Panel
	Top.BorderSizePixel = 0
	Top.Parent = Main
	corner(Top, 16)
	local topFix = Instance.new("Frame")
	topFix.BackgroundColor3 = T.Panel
	topFix.BorderSizePixel = 0
	topFix.Position = UDim2.new(0, 0, 1, -16)
	topFix.Size = UDim2.new(1, 0, 0, 16)
	topFix.Parent = Top

	local accentLine = Instance.new("Frame")
	accentLine.BorderSizePixel = 0
	accentLine.Position = UDim2.new(0, 0, 1, -2)
	accentLine.Size = UDim2.new(1, 0, 0, 2)
	accentLine.BackgroundColor3 = T.Accent
	accentLine.Parent = Top
	gradient(accentLine, T.Accent, T.Accent2, 0)

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.fromOffset(18, 0)
	Title.Size = UDim2.new(0, 180, 1, 0)
	Title.Font = Enum.Font.GothamBold
	Title.Text = cfg.Name or "CrackLib Pro"
	Title.TextColor3 = T.Text
	Title.TextSize = 18
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Top

	-- Search
	local searchBox = Instance.new("Frame")
	searchBox.BackgroundColor3 = T.Card
	searchBox.BorderSizePixel = 0
	searchBox.Position = UDim2.new(0, 200, 0.5, -15)
	searchBox.Size = UDim2.fromOffset(280, 30)
	searchBox.Parent = Top
	corner(searchBox, 8)
	stroke(searchBox, T.Stroke, 1)

	local searchInput = Instance.new("TextBox")
	searchInput.BackgroundTransparency = 1
	searchInput.Position = UDim2.fromOffset(12, 0)
	searchInput.Size = UDim2.new(1, -24, 1, 0)
	searchInput.Font = Enum.Font.Gotham
	searchInput.PlaceholderText = "Search features..."
	searchInput.PlaceholderColor3 = T.Sub
	searchInput.Text = ""
	searchInput.TextColor3 = T.Text
	searchInput.TextSize = 13
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.ClearTextOnFocus = false
	searchInput.Parent = searchBox

	local function doSearch()
		local q = string.lower(searchInput.Text or "")
		for _, tab in pairs(state.tabs) do
			if tab.page then
				for _, desc in ipairs(tab.page:GetDescendants()) do
					if desc:IsA("GuiObject") and desc:GetAttribute("SearchText") then
						local st = string.lower(tostring(desc:GetAttribute("SearchText")))
						if q == "" then
							desc.Visible = true
						else
							desc.Visible = string.find(st, q, 1, true) ~= nil
						end
					end
				end
			end
		end
	end
	searchInput:GetPropertyChangedSignal("Text"):Connect(doSearch)

	-- Window buttons
	local function winBtn(x, txt, col)
		local b = Instance.new("TextButton")
		b.Position = UDim2.new(1, x, 0.5, -12)
		b.Size = UDim2.fromOffset(24, 24)
		b.BackgroundColor3 = T.Card
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamBold
		b.Text = txt
		b.TextColor3 = col or T.Sub
		b.TextSize = 14
		b.AutoButtonColor = false
		b.Parent = Top
		corner(b, 6)
		b.MouseEnter:Connect(function() tween(b, { BackgroundColor3 = T.CardHover }, 0.1) end)
		b.MouseLeave:Connect(function() tween(b, { BackgroundColor3 = T.Card }, 0.1) end)
		return b
	end

	local closeBtn = winBtn(-36, "×", T.Danger)
	local minBtn = winBtn(-66, "–", T.Sub)

	-- Sidebar
	local Side = Instance.new("Frame")
	Side.BackgroundColor3 = T.Panel
	Side.BorderSizePixel = 0
	Side.Position = UDim2.fromOffset(0, 54)
	Side.Size = UDim2.new(0, 155, 1, -54)
	Side.Parent = Main

	local sideLine = Instance.new("Frame")
	sideLine.BackgroundColor3 = T.Stroke
	sideLine.BorderSizePixel = 0
	sideLine.Position = UDim2.new(1, -1, 0, 0)
	sideLine.Size = UDim2.new(0, 1, 1, 0)
	sideLine.Parent = Side

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.Size = UDim2.fromScale(1, 1)
	tabScroll.ScrollBarThickness = 2
	tabScroll.ScrollBarImageColor3 = T.Accent
	tabScroll.CanvasSize = UDim2.new()
	tabScroll.Parent = Side
	local tabList = list(tabScroll, 6)
	pad(tabScroll, 10)
	tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabScroll.CanvasSize = UDim2.fromOffset(0, tabList.AbsoluteContentSize.Y + 16)
	end)

	-- Content
	local Content = Instance.new("Frame")
	Content.BackgroundTransparency = 1
	Content.Position = UDim2.fromOffset(155, 54)
	Content.Size = UDim2.new(1, -155, 1, -54)
	Content.ClipsDescendants = true
	Content.Parent = Main

	local pages = Instance.new("Folder")
	pages.Parent = Content

	-- Drag
	do
		local drag, start, spos
		Top.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				drag = true
				start = i.Position
				spos = Main.Position
			end
		end)
		table.insert(state.cons, UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				drag = false
			end
		end))
		table.insert(state.cons, UIS.InputChanged:Connect(function(i)
			if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - start
				Main.Position = UDim2.new(spos.X.Scale, spos.X.Offset + d.X, spos.Y.Scale, spos.Y.Offset + d.Y)
			end
		end))
	end

	closeBtn.MouseButton1Click:Connect(function()
		tween(Main, { Size = UDim2.fromOffset(0, 0) }, 0.2)
		task.delay(0.22, function()
			for _, c in ipairs(state.cons) do pcall(function() c:Disconnect() end) end
			gui:Destroy()
		end)
	end)

	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(Main, { Size = UDim2.fromOffset(720, 54) }, 0.2)
			Side.Visible = false
			Content.Visible = false
		else
			Side.Visible = true
			Content.Visible = true
			tween(Main, { Size = UDim2.fromOffset(720, 500) }, 0.28, Enum.EasingStyle.Back)
		end
	end)

	table.insert(state.cons, UIS.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == toggleKey then
			state.visible = not state.visible
			Main.Visible = state.visible
		end
	end))

	-- Key system
	local ks = cfg.KeySystem
	if type(ks) == "table" and ks.Enabled then
		local keyFile = configFolder .. "/key.txt"
		local saved = readfile_(keyFile)
		local okKey = false
		if ks.SaveKey ~= false and saved then
			saved = tostring(saved):gsub("%s+", "")
			for _, k in ipairs(ks.Key or {}) do
				if saved == tostring(k) then okKey = true break end
			end
		end
		if not okKey then
			Main.Visible = false
			local overlay = Instance.new("Frame")
			overlay.BackgroundColor3 = Color3.new(0, 0, 0)
			overlay.BackgroundTransparency = 0.35
			overlay.Size = UDim2.fromScale(1, 1)
			overlay.BorderSizePixel = 0
			overlay.Parent = gui

			local card = Instance.new("Frame")
			card.AnchorPoint = Vector2.new(0.5, 0.5)
			card.Position = UDim2.fromScale(0.5, 0.5)
			card.Size = UDim2.fromOffset(420, 340)
			card.BackgroundColor3 = T.Bg
			card.BorderSizePixel = 0
			card.Parent = overlay
			corner(card, 16)
			stroke(card, T.Accent, 1.5, 0.2)
			gradient(card, T.Bg, T.Panel, 120)

			local kt = Instance.new("TextLabel")
			kt.BackgroundTransparency = 1
			kt.Position = UDim2.fromOffset(22, 18)
			kt.Size = UDim2.new(1, -44, 0, 28)
			kt.Font = Enum.Font.GothamBold
			kt.Text = ks.Title or "Access Key"
			kt.TextColor3 = T.Text
			kt.TextSize = 20
			kt.TextXAlignment = Enum.TextXAlignment.Left
			kt.Parent = card

			local sub = Instance.new("TextLabel")
			sub.BackgroundTransparency = 1
			sub.Position = UDim2.fromOffset(22, 50)
			sub.Size = UDim2.new(1, -44, 0, 18)
			sub.Font = Enum.Font.Gotham
			sub.Text = ks.Subtitle or "Complete steps then enter your key"
			sub.TextColor3 = T.Sub
			sub.TextSize = 13
			sub.TextXAlignment = Enum.TextXAlignment.Left
			sub.Parent = card

			local stepsF = Instance.new("Frame")
			stepsF.BackgroundTransparency = 1
			stepsF.Position = UDim2.fromOffset(18, 80)
			stepsF.Size = UDim2.new(1, -36, 0, 120)
			stepsF.Parent = card
			local sList = list(stepsF, 8)

			for i, step in ipairs(ks.Steps or {}) do
				local row = Instance.new("Frame")
				row.BackgroundColor3 = T.Card
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, 36)
				row.Parent = stepsF
				corner(row, 8)

				local num = Instance.new("TextLabel")
				num.BackgroundColor3 = T.Accent
				num.Size = UDim2.fromOffset(22, 22)
				num.Position = UDim2.fromOffset(8, 7)
				num.Font = Enum.Font.GothamBold
				num.Text = tostring(i)
				num.TextColor3 = T.Text
				num.TextSize = 12
				num.Parent = row
				corner(num, 6)

				local nm = Instance.new("TextLabel")
				nm.BackgroundTransparency = 1
				nm.Position = UDim2.fromOffset(38, 0)
				nm.Size = UDim2.new(1, -120, 1, 0)
				nm.Font = Enum.Font.GothamMedium
				nm.Text = step.Name or ("Step " .. i)
				nm.TextColor3 = T.Text
				nm.TextSize = 13
				nm.TextXAlignment = Enum.TextXAlignment.Left
				nm.Parent = row

				if step.Link then
					local btn = Instance.new("TextButton")
					btn.AnchorPoint = Vector2.new(1, 0.5)
					btn.Position = UDim2.new(1, -8, 0.5, 0)
					btn.Size = UDim2.fromOffset(64, 24)
					btn.BackgroundColor3 = T.Accent
					btn.BorderSizePixel = 0
					btn.Font = Enum.Font.GothamBold
					btn.Text = "Copy"
					btn.TextColor3 = T.Text
					btn.TextSize = 12
					btn.Parent = row
					corner(btn, 6)
					btn.MouseButton1Click:Connect(function()
						clipboard_(step.Link)
						btn.Text = "OK"
						task.delay(1, function() if btn.Parent then btn.Text = "Copy" end end)
					end)
				end
			end

			local box = Instance.new("TextBox")
			box.BackgroundColor3 = T.Card
			box.BorderSizePixel = 0
			box.Position = UDim2.fromOffset(22, 216)
			box.Size = UDim2.new(1, -44, 0, 34)
			box.Font = Enum.Font.Gotham
			box.PlaceholderText = "Enter key..."
			box.PlaceholderColor3 = T.Sub
			box.Text = ""
			box.TextColor3 = T.Text
			box.TextSize = 14
			box.ClearTextOnFocus = false
			box.Parent = card
			corner(box, 8)
			stroke(box, T.Stroke, 1)

			local status = Instance.new("TextLabel")
			status.BackgroundTransparency = 1
			status.Position = UDim2.fromOffset(22, 256)
			status.Size = UDim2.new(1, -44, 0, 16)
			status.Font = Enum.Font.Gotham
			status.Text = ""
			status.TextSize = 12
			status.TextXAlignment = Enum.TextXAlignment.Left
			status.Parent = card

			local submit = Instance.new("TextButton")
			submit.Position = UDim2.fromOffset(22, 280)
			submit.Size = UDim2.new(1, -44, 0, 40)
			submit.BackgroundColor3 = T.Accent
			submit.BorderSizePixel = 0
			submit.Font = Enum.Font.GothamBold
			submit.Text = "Unlock"
			submit.TextColor3 = T.Text
			submit.TextSize = 15
			submit.Parent = card
			corner(submit, 10)
			gradient(submit, T.Accent, T.Accent2, 0)

			local function try()
				local entered = tostring(box.Text):gsub("%s+", "")
				local good = false
				for _, k in ipairs(ks.Key or {}) do
					if entered == tostring(k) then good = true break end
				end
				if good then
					status.TextColor3 = T.Success
					status.Text = "Access granted"
					if ks.SaveKey ~= false then writefile_(keyFile, entered) end
					task.delay(0.3, function()
						overlay:Destroy()
						Main.Visible = true
						Main.Size = UDim2.fromOffset(0, 0)
						tween(Main, { Size = UDim2.fromOffset(720, 500) }, 0.35, Enum.EasingStyle.Back)
					end)
				else
					status.TextColor3 = T.Danger
					status.Text = "Invalid key"
				end
			end
			submit.MouseButton1Click:Connect(try)
			box.FocusLost:Connect(function(e) if e then try() end end)
		end
	end

	-- Window API
	local Window = {}

	function Window:Tab(name)
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = T.Card
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(1, -4, 0, 38)
		btn.Font = Enum.Font.GothamMedium
		btn.Text = "  " .. tostring(name)
		btn.TextColor3 = T.Sub
		btn.TextSize = 14
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.Parent = tabScroll
		corner(btn, 10)

		local ind = Instance.new("Frame")
		ind.BackgroundColor3 = T.Accent
		ind.BorderSizePixel = 0
		ind.Position = UDim2.fromOffset(0, 8)
		ind.Size = UDim2.fromOffset(3, 22)
		ind.Visible = false
		ind.Parent = btn
		corner(ind, 2)
		gradient(ind, T.Accent, T.Accent2, 90)

		local page = Instance.new("ScrollingFrame")
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Size = UDim2.fromScale(1, 1)
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = T.Accent
		page.CanvasSize = UDim2.new()
		page.Visible = false
		page.Parent = pages
		local pList = list(page, 10)
		pad(page, 14)
		local function refresh()
			page.CanvasSize = UDim2.fromOffset(0, pList.AbsoluteContentSize.Y + 24)
		end
		pList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refresh)

		local tabData = { btn = btn, page = page, ind = ind, refresh = refresh }
		state.tabs[name] = tabData

		local function select()
			for _, t in pairs(state.tabs) do
				t.page.Visible = false
				t.btn.BackgroundColor3 = T.Card
				t.btn.TextColor3 = T.Sub
				t.ind.Visible = false
			end
			page.Visible = true
			btn.BackgroundColor3 = T.CardHover
			btn.TextColor3 = T.Text
			ind.Visible = true
			refresh()
		end
		btn.MouseButton1Click:Connect(select)
		btn.MouseEnter:Connect(function()
			if not ind.Visible then tween(btn, { BackgroundColor3 = T.CardHover }, 0.12) end
		end)
		btn.MouseLeave:Connect(function()
			if not ind.Visible then tween(btn, { BackgroundColor3 = T.Card }, 0.12) end
		end)

		local n = 0
		for _ in pairs(state.tabs) do n += 1 end
		if n == 1 then select() end

		local Tab = {}
		function Tab:Section(secName)
			return Lib._section(T, state, tabData, secName)
		end
		return Tab
	end

	function Window:Notify(text, dur)
		local n = Instance.new("Frame")
		n.AnchorPoint = Vector2.new(1, 1)
		n.Position = UDim2.new(1, -16, 1, -16)
		n.Size = UDim2.fromOffset(280, 44)
		n.BackgroundColor3 = T.Card
		n.BorderSizePixel = 0
		n.Parent = gui
		corner(n, 10)
		stroke(n, T.Accent, 1, 0.3)
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = "  " .. tostring(text)
		lbl.TextColor3 = T.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = n
		task.delay(dur or 2.5, function() if n.Parent then n:Destroy() end end)
	end

	function Window:SaveConfig(name)
		name = name or "default"
		return writefile_(configFolder .. "/" .. name .. ".json", HttpService:JSONEncode(state.flags))
	end

	function Window:LoadConfig(name)
		name = name or "default"
		local raw = readfile_(configFolder .. "/" .. name .. ".json")
		if not raw then return false end
		local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
		if not ok or type(data) ~= "table" then return false end
		for k, v in pairs(data) do
			state.flags[k] = v
			if state.setters[k] then pcall(state.setters[k], v) end
		end
		return true
	end

	function Window:SetToggleKey(k) toggleKey = k end

	function Window:Unload()
		for _, c in ipairs(state.cons) do pcall(function() c:Disconnect() end) end
		gui:Destroy()
	end

	-- aliases
	Window.CreateTab = Window.Tab
	return Window
end

-- alias
Lib.Init = function(_, a, b, c)
	if type(a) == "table" then
		if a.Name == nil and a.Title then a.Name = a.Title end
		return Lib:CreateWindow(a)
	end
	return Lib:CreateWindow({ Name = tostring(a or "Hub"), ToggleKey = c or Enum.KeyCode.LeftControl })
end

-- ===================== SECTION / ELEMENTS =====================
function Lib._section(T, state, tabData, secName)
	local head = Instance.new("TextLabel")
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, 0, 0, 22)
	head.Font = Enum.Font.GothamBold
	head.Text = string.upper(tostring(secName))
	head.TextColor3 = T.Accent
	head.TextSize = 12
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.Parent = tabData.page

	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Size = UDim2.new(1, 0, 0, 0)
	box.AutomaticSize = Enum.AutomaticSize.Y
	box.Parent = tabData.page
	list(box, 8)

	local Sec = {}

	local function card(h, bg)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = bg or T.Card
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, h or 44)
		f.ClipsDescendants = true
		f.Parent = box
		corner(f, 12)
		stroke(f, T.Stroke, 1, 0.35)
		return f
	end

	local function label(parent, text, right)
		local t = Instance.new("TextLabel")
		t.Name = "TitleText"
		t.BackgroundTransparency = 1
		t.Position = UDim2.fromOffset(14, 0)
		t.Size = UDim2.new(1, -(right or 56), 1, 0)
		t.Font = Enum.Font.GothamMedium
		t.Text = tostring(text)
		t.TextColor3 = T.Text
		t.TextSize = 14
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextTruncate = Enum.TextTruncate.AtEnd
		t.Parent = parent
		return t
	end

	local function mark(obj, text)
		obj:SetAttribute("SearchText", tostring(text))
	end

	function Sec:Label(text)
		local f = card(44)
		label(f, text, 14)
		mark(f, text)
		local d = {}
		function d:SetText(v) f.TitleText.Text = tostring(v) mark(f, v) end
		return d
	end

	function Sec:Info(text)
		local f = card(44, T.Info)
		label(f, text, 14)
		mark(f, text)
		return {}
	end

	function Sec:Warning(text)
		local f = card(44, T.Warning)
		label(f, text, 14)
		mark(f, text)
		return {}
	end

	function Sec:Toggle(text, default, callback, flag)
		local on = default == true
		local f = card(44)
		label(f, text, 60)
		mark(f, text)

		local track = Instance.new("Frame")
		track.AnchorPoint = Vector2.new(1, 0.5)
		track.Position = UDim2.new(1, -14, 0.5, 0)
		track.Size = UDim2.fromOffset(46, 24)
		track.BackgroundColor3 = on and T.Success or Color3.fromRGB(50, 50, 60)
		track.BorderSizePixel = 0
		track.Parent = f
		corner(track, 12)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(18, 18)
		knob.Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Parent = track
		corner(knob, 9)

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.Text = ""
		hit.ZIndex = 10
		hit.Parent = f

		local function set(v, doFire)
			on = v and true or false
			tween(track, { BackgroundColor3 = on and T.Success or Color3.fromRGB(50, 50, 60) }, 0.15)
			tween(knob, { Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, 0.2, Enum.EasingStyle.Back)
			if flag then state.flags[flag] = on end
			if doFire then fire(callback, on) end
		end

		hit.MouseButton1Click:Connect(function() set(not on, true) end)

		if flag then
			state.flags[flag] = on
			state.setters[flag] = function(v) set(v, true) end
		end

		local d = {}
		function d:Set(v) set(v, true) end
		function d:Get() return on end
		return d
	end
	Sec.ConfigToggle = Sec.Toggle

	function Sec:Button(text, callback)
		local f = card(44, Color3.fromRGB(40, 44, 60))
		local t = label(f, text, 0)
		t.Size = UDim2.fromScale(1, 1)
		t.Position = UDim2.new()
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.TextColor3 = T.Accent
		mark(f, text)

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.Text = ""
		hit.ZIndex = 10
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			tween(f, { BackgroundColor3 = T.Accent }, 0.08)
			task.delay(0.1, function() tween(f, { BackgroundColor3 = Color3.fromRGB(40, 44, 60) }, 0.2) end)
			fire(callback)
		end)
		return {}
	end

	function Sec:Slider(text, min, max, default, callback, decimals, flag)
		min, max = min or 0, max or 100
		default = default or min
		decimals = decimals or 0
		local value = default

		local f = card(70)
		mark(f, text)
		local title = Instance.new("TextLabel")
		title.Name = "TitleText"
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(14, 6)
		title.Size = UDim2.new(0.55, 0, 0, 20)
		title.Font = Enum.Font.GothamMedium
		title.Text = tostring(text)
		title.TextColor3 = T.Text
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = f

		local val = Instance.new("TextLabel")
		val.BackgroundTransparency = 1
		val.Position = UDim2.new(0.55, 0, 0, 6)
		val.Size = UDim2.new(0.42, -12, 0, 20)
		val.Font = Enum.Font.GothamBold
		val.Text = tostring(default)
		val.TextColor3 = T.Accent
		val.TextSize = 14
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Parent = f

		local track = Instance.new("Frame")
		track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		track.BorderSizePixel = 0
		track.Position = UDim2.new(0, 14, 0, 40)
		track.Size = UDim2.new(1, -28, 0, 8)
		track.Parent = f
		corner(track, 4)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = T.Accent
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(math.clamp((default - min) / math.max(max - min, 1e-9), 0, 1), 0, 1, 0)
		fill.Parent = track
		corner(fill, 4)
		gradient(fill, T.Accent, T.Accent2, 0)

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.BorderSizePixel = 0
		knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Parent = track
		corner(knob, 7)
		stroke(knob, T.Accent, 1)

		local sliding = false
		local function apply(x)
			local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local raw = min + (max - min) * rel
			if decimals <= 0 then value = math.floor(raw + 0.5)
			else local m = 10 ^ decimals value = math.floor(raw * m + 0.5) / m end
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			val.Text = tostring(value)
			if flag then state.flags[flag] = value end
			fire(callback, value)
		end

		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				apply(i.Position.X)
			end
		end)
		table.insert(state.cons, UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
		end))
		table.insert(state.cons, UIS.InputChanged:Connect(function(i)
			if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				apply(i.Position.X)
			end
		end))

		if flag then
			state.flags[flag] = value
			state.setters[flag] = function(v)
				value = math.clamp(tonumber(v) or value, min, max)
				local rel = (value - min) / math.max(max - min, 1e-9)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				knob.Position = UDim2.new(rel, 0, 0.5, 0)
				val.Text = tostring(value)
				fire(callback, value)
			end
		end

		local d = {}
		function d:Set(v)
			value = math.clamp(v, min, max)
			local rel = (value - min) / math.max(max - min, 1e-9)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			val.Text = tostring(value)
			if flag then state.flags[flag] = value end
			fire(callback, value)
		end
		function d:Get() return value end
		return d
	end
	Sec.ConfigSlider = Sec.Slider

	function Sec:Dropdown(text, options, default, callback, flag)
		options = options or { "None" }
		local selected = default or options[1]
		local open = false
		local CLOSED = 44

		local f = card(CLOSED)
		f.ClipsDescendants = true
		mark(f, text)
		local title = label(f, text .. "  ·  " .. tostring(selected), 40)

		local chev = Instance.new("TextLabel")
		chev.BackgroundTransparency = 1
		chev.AnchorPoint = Vector2.new(1, 0)
		chev.Position = UDim2.new(1, -12, 0, 10)
		chev.Size = UDim2.fromOffset(24, 24)
		chev.Font = Enum.Font.GothamBold
		chev.Text = "▾"
		chev.TextColor3 = T.Sub
		chev.TextSize = 16
		chev.Parent = f

		local listF = Instance.new("Frame")
		listF.BackgroundColor3 = T.Panel
		listF.BorderSizePixel = 0
		listF.Position = UDim2.fromOffset(8, 42)
		listF.Size = UDim2.new(1, -16, 0, 0)
		listF.ClipsDescendants = true
		listF.Parent = f
		corner(listF, 8)
		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.fromScale(1, 1)
		holder.Parent = listF
		list(holder, 3)
		pad(holder, 4)

		local function rebuild()
			for _, c in ipairs(holder:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local b = Instance.new("TextButton")
				b.BackgroundColor3 = tostring(opt) == tostring(selected) and T.Accent or T.Card
				b.BorderSizePixel = 0
				b.Size = UDim2.new(1, 0, 0, 30)
				b.Font = Enum.Font.Gotham
				b.Text = "  " .. tostring(opt)
				b.TextColor3 = T.Text
				b.TextSize = 13
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = true
				b.Parent = holder
				corner(b, 6)
				b.MouseButton1Click:Connect(function()
					selected = opt
					title.Text = text .. "  ·  " .. tostring(opt)
					if flag then state.flags[flag] = selected end
					fire(callback, selected)
					open = false
					listF.Size = UDim2.new(1, -16, 0, 0)
					f.Size = UDim2.new(1, 0, 0, CLOSED)
					chev.Text = "▾"
					tabData.refresh()
					rebuild()
				end)
			end
		end
		rebuild()

		local hit = Instance.new("TextButton")
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.new(1, 0, 0, CLOSED)
		hit.Text = ""
		hit.ZIndex = 10
		hit.Parent = f
		hit.MouseButton1Click:Connect(function()
			open = not open
			if open then
				local h = math.clamp(#options * 33 + 12, 50, 160)
				listF.Size = UDim2.new(1, -16, 0, h)
				f.Size = UDim2.new(1, 0, 0, CLOSED + h + 8)
				chev.Text = "▴"
			else
				listF.Size = UDim2.new(1, -16, 0, 0)
				f.Size = UDim2.new(1, 0, 0, CLOSED)
				chev.Text = "▾"
			end
			tabData.refresh()
		end)

		if flag then
			state.flags[flag] = selected
			state.setters[flag] = function(v)
				selected = v
				title.Text = text .. "  ·  " .. tostring(v)
				fire(callback, v)
				rebuild()
			end
		end

		local d = {}
		function d:Set(v)
			selected = v
			title.Text = text .. "  ·  " .. tostring(v)
			if flag then state.flags[flag] = v end
			fire(callback, v)
			rebuild()
		end
		function d:Get() return selected end
		function d:Refresh(o) options = o or options rebuild() end
		return d
	end
	Sec.ConfigDropdown = Sec.Dropdown

	function Sec:Textbox(text, default, callback, flag)
		local f = card(44)
		mark(f, text)
		label(f, text, 0).Size = UDim2.new(0.3, 0, 1, 0)
		local box = Instance.new("TextBox")
		box.BackgroundColor3 = T.Panel
		box.BorderSizePixel = 0
		box.Position = UDim2.new(0.32, 0, 0.5, -13)
		box.Size = UDim2.new(0.5, 0, 0, 26)
		box.Font = Enum.Font.Gotham
		box.Text = tostring(default or "")
		box.PlaceholderText = "..."
		box.PlaceholderColor3 = T.Sub
		box.TextColor3 = T.Text
		box.TextSize = 13
		box.ClearTextOnFocus = false
		box.Parent = f
		corner(box, 6)
		local st = stroke(box, T.Stroke, 1)

		local copy = Instance.new("TextButton")
		copy.AnchorPoint = Vector2.new(1, 0.5)
		copy.Position = UDim2.new(1, -10, 0.5, 0)
		copy.Size = UDim2.fromOffset(30, 26)
		copy.BackgroundColor3 = T.Panel
		copy.BorderSizePixel = 0
		copy.Font = Enum.Font.GothamBold
		copy.Text = "⎘"
		copy.TextColor3 = T.Sub
		copy.TextSize = 14
		copy.Parent = f
		corner(copy, 6)
		copy.MouseButton1Click:Connect(function()
			clipboard_(box.Text)
			copy.TextColor3 = T.Success
			task.delay(0.8, function() copy.TextColor3 = T.Sub end)
		end)

		box.Focused:Connect(function() st.Color = T.Accent end)
		box.FocusLost:Connect(function()
			st.Color = T.Stroke
			if flag then state.flags[flag] = box.Text end
			fire(callback, box.Text)
		end)

		local d = {}
		function d:Set(v) box.Text = tostring(v) end
		function d:Get() return box.Text end
		return d
	end
	Sec.ConfigTextbox = Sec.Textbox

	function Sec:Keybind(text, defaultKey, callback, flag)
		local key = defaultKey or Enum.KeyCode.E
		local listening = false
		local f = card(44)
		mark(f, text)
		label(f, text, 90)

		local kb = Instance.new("TextButton")
		kb.AnchorPoint = Vector2.new(1, 0.5)
		kb.Position = UDim2.new(1, -12, 0.5, 0)
		kb.Size = UDim2.fromOffset(80, 26)
		kb.BackgroundColor3 = T.Panel
		kb.BorderSizePixel = 0
		kb.Font = Enum.Font.GothamBold
		kb.Text = key.Name
		kb.TextColor3 = T.Accent
		kb.TextSize = 12
		kb.Parent = f
		corner(kb, 6)

		kb.MouseButton1Click:Connect(function()
			listening = true
			kb.Text = "..."
		end)

		table.insert(state.cons, UIS.InputBegan:Connect(function(i, gp)
			if listening and i.UserInputType == Enum.UserInputType.Keyboard then
				key = i.KeyCode
				kb.Text = key.Name
				listening = false
				if flag then state.flags[flag] = key.Name end
				fire(callback, key)
			end
		end))

		local d = {}
		function d:Set(k) key = k kb.Text = k.Name end
		function d:Get() return key end
		return d
	end
	Sec.ConfigKeybind = Sec.Keybind

	function Sec:ColorPicker(text, default, callback, flag)
		local color = default or T.Accent
		local presets = {
			Color3.fromRGB(120, 100, 255), Color3.fromRGB(80, 200, 255),
			Color3.fromRGB(80, 220, 140), Color3.fromRGB(255, 80, 100),
			Color3.fromRGB(255, 190, 60), Color3.fromRGB(255, 255, 255),
		}
		local idx = 1
		local f = card(44)
		mark(f, text)
		label(f, text, 50)
		local sw = Instance.new("TextButton")
		sw.AnchorPoint = Vector2.new(1, 0.5)
		sw.Position = UDim2.new(1, -14, 0.5, 0)
		sw.Size = UDim2.fromOffset(28, 28)
		sw.BackgroundColor3 = color
		sw.BorderSizePixel = 0
		sw.Text = ""
		sw.Parent = f
		corner(sw, 8)
		stroke(sw, T.Stroke, 1)
		sw.MouseButton1Click:Connect(function()
			idx = (idx % #presets) + 1
			color = presets[idx]
			sw.BackgroundColor3 = color
			if flag then state.flags[flag] = { R = color.R, G = color.G, B = color.B } end
			fire(callback, color)
		end)
		local d = {}
		function d:Set(c) color = c sw.BackgroundColor3 = c end
		function d:Get() return color end
		return d
	end

	function Sec:Separator()
		local f = Instance.new("Frame")
		f.BackgroundColor3 = T.Stroke
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, 1)
		f.Parent = box
	end

	return Sec
end

return Lib
