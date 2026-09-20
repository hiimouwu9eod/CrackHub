--[[
  CrackedLib v2.6.0
  + Sounds (click / toggle / hover)
  + Avatar preview (LocalPlayer thumbnail)
  + Full theme refresh on every element
  + Volume control
  Elements: Toggle, ConfigToggle, Button, Label, Paragraph, Separator,
            Slider, ConfigSlider, Textbox, ConfigTextbox, Keybind,
            Dropdown, ConfigDropdown, ToggleList, ColorPicker, ConfigColorPicker
]]

local CrackedLib = {}
CrackedLib.Version = "2.6.0"
CrackedLib._Active = CrackedLib._Active or {}

-- =============================================================================
-- SOUNDS
-- =============================================================================
local SoundService = game:GetService("SoundService")

CrackedLib.Sounds = {
	Enabled = true,
	Volume = 0.35,
	Click = "rbxassetid://6895079853",
	ToggleOn = "rbxassetid://9113089209",
	ToggleOff = "rbxassetid://9113089209",
	Hover = "rbxassetid://10066921516",
	Notify = "rbxassetid://4590662766",
	Open = "rbxassetid://6042053626",
}

local function playSound(kind)
	if not CrackedLib.Sounds.Enabled then return end
	local id = CrackedLib.Sounds[kind]
	if not id or id == "" then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = CrackedLib.Sounds.Volume
		s.PlayOnRemove = true
		s.Parent = SoundService
		s:Destroy()
	end)
end

CrackedLib.PlaySound = playSound

function CrackedLib:UnloadAll()
	local list = {}
	for gui, _ in pairs(self._Active) do
		table.insert(list, gui)
	end
	for _, gui in ipairs(list) do
		pcall(function()
			if gui.Unload then gui:Unload()
			elseif gui.Destroy then gui:Destroy() end
		end)
	end
	table.clear(self._Active)
	local Players = game:GetService("Players")
	local lp = Players.LocalPlayer
	local parents = { lp and lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui") }
	pcall(function()
		if type(gethui) == "function" then table.insert(parents, gethui()) end
	end)
	for _, parent in ipairs(parents) do
		if parent then
			for _, name in ipairs({ "CrackLib", "KeySystem", "CracksRoundTimer" }) do
				local o = parent:FindFirstChild(name)
				if o then pcall(function() o:Destroy() end) end
			end
		end
	end
	return true
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =============================================================================
-- THEMES
-- =============================================================================
CrackedLib.Theme = {
	Default = {
		TextColor = Color3.fromRGB(240, 240, 240), Background = Color3.fromRGB(25, 25, 25),
		Topbar = Color3.fromRGB(34, 34, 34), Line = Color3.fromRGB(48, 48, 48), Navigation = Color3.fromRGB(30, 30, 30),
		TabBackground = Color3.fromRGB(80, 80, 80), TabStroke = Color3.fromRGB(85, 85, 85),
		TabBackgroundSelected = Color3.fromRGB(210, 210, 210), TabTextColor = Color3.fromRGB(240, 240, 240),
		SelectedTabTextColor = Color3.fromRGB(50, 50, 50), ElementBackground = Color3.fromRGB(45, 45, 45),
		ElementBackgroundHover = Color3.fromRGB(80, 80, 80), ElementStroke = Color3.fromRGB(80, 80, 80),
		ElementStrokeHover = Color3.fromRGB(100, 100, 100), Accent = Color3.fromRGB(210, 210, 210),
	},
	Light = {
		TextColor = Color3.fromRGB(30, 30, 30), Background = Color3.fromRGB(245, 245, 245),
		Topbar = Color3.fromRGB(230, 230, 230), Line = Color3.fromRGB(200, 200, 200), Navigation = Color3.fromRGB(235, 235, 235),
		TabBackground = Color3.fromRGB(220, 220, 220), TabStroke = Color3.fromRGB(180, 180, 180),
		TabBackgroundSelected = Color3.fromRGB(100, 100, 100), TabTextColor = Color3.fromRGB(40, 40, 40),
		SelectedTabTextColor = Color3.fromRGB(255, 255, 255), ElementBackground = Color3.fromRGB(255, 255, 255),
		ElementBackgroundHover = Color3.fromRGB(230, 230, 230), ElementStroke = Color3.fromRGB(200, 200, 200),
		ElementStrokeHover = Color3.fromRGB(160, 160, 160), Accent = Color3.fromRGB(100, 100, 100),
	},
	Purple = {
		TextColor = Color3.fromRGB(245, 245, 255), Background = Color3.fromRGB(28, 20, 48), Topbar = Color3.fromRGB(45, 30, 75),
		Line = Color3.fromRGB(130, 70, 220), Navigation = Color3.fromRGB(38, 25, 62), TabBackground = Color3.fromRGB(55, 35, 90),
		TabStroke = Color3.fromRGB(160, 90, 255), TabBackgroundSelected = Color3.fromRGB(190, 110, 255),
		TabTextColor = Color3.fromRGB(245, 245, 255), SelectedTabTextColor = Color3.fromRGB(30, 15, 55),
		ElementBackground = Color3.fromRGB(45, 30, 75), ElementBackgroundHover = Color3.fromRGB(80, 50, 130),
		ElementStroke = Color3.fromRGB(160, 90, 255), ElementStrokeHover = Color3.fromRGB(200, 130, 255),
		Accent = Color3.fromRGB(190, 110, 255),
	},
	Ocean = {
		TextColor = Color3.fromRGB(230, 245, 255), Background = Color3.fromRGB(15, 30, 55), Topbar = Color3.fromRGB(20, 45, 85),
		Line = Color3.fromRGB(70, 160, 240), Navigation = Color3.fromRGB(18, 38, 70), TabBackground = Color3.fromRGB(30, 60, 110),
		TabStroke = Color3.fromRGB(90, 180, 255), TabBackgroundSelected = Color3.fromRGB(110, 205, 255),
		TabTextColor = Color3.fromRGB(230, 245, 255), SelectedTabTextColor = Color3.fromRGB(10, 25, 50),
		ElementBackground = Color3.fromRGB(25, 50, 85), ElementBackgroundHover = Color3.fromRGB(50, 95, 160),
		ElementStroke = Color3.fromRGB(90, 180, 255), ElementStrokeHover = Color3.fromRGB(130, 215, 255),
		Accent = Color3.fromRGB(110, 205, 255),
	},
	Red = {
		TextColor = Color3.fromRGB(255, 235, 235), Background = Color3.fromRGB(35, 20, 20), Topbar = Color3.fromRGB(55, 25, 25),
		Line = Color3.fromRGB(220, 60, 60), Navigation = Color3.fromRGB(48, 22, 22), TabBackground = Color3.fromRGB(70, 30, 30),
		TabStroke = Color3.fromRGB(255, 90, 90), TabBackgroundSelected = Color3.fromRGB(255, 120, 120),
		TabTextColor = Color3.fromRGB(255, 235, 235), SelectedTabTextColor = Color3.fromRGB(45, 15, 15),
		ElementBackground = Color3.fromRGB(55, 25, 25), ElementBackgroundHover = Color3.fromRGB(90, 40, 40),
		ElementStroke = Color3.fromRGB(255, 100, 100), ElementStrokeHover = Color3.fromRGB(255, 150, 150),
		Accent = Color3.fromRGB(255, 120, 120),
	},
	Green = {
		TextColor = Color3.fromRGB(230, 255, 235), Background = Color3.fromRGB(15, 30, 20), Topbar = Color3.fromRGB(20, 50, 32),
		Line = Color3.fromRGB(50, 190, 90), Navigation = Color3.fromRGB(18, 38, 25), TabBackground = Color3.fromRGB(25, 60, 40),
		TabStroke = Color3.fromRGB(70, 220, 120), TabBackgroundSelected = Color3.fromRGB(110, 255, 160),
		TabTextColor = Color3.fromRGB(230, 255, 235), SelectedTabTextColor = Color3.fromRGB(10, 30, 18),
		ElementBackground = Color3.fromRGB(25, 55, 35), ElementBackgroundHover = Color3.fromRGB(45, 100, 65),
		ElementStroke = Color3.fromRGB(70, 220, 120), ElementStrokeHover = Color3.fromRGB(110, 255, 160),
		Accent = Color3.fromRGB(110, 255, 160),
	},
	Midnight = {
		TextColor = Color3.fromRGB(235, 235, 245), Background = Color3.fromRGB(16, 16, 26), Topbar = Color3.fromRGB(26, 26, 46),
		Line = Color3.fromRGB(75, 75, 120), Navigation = Color3.fromRGB(20, 20, 34), TabBackground = Color3.fromRGB(35, 35, 58),
		TabStroke = Color3.fromRGB(110, 110, 190), TabBackgroundSelected = Color3.fromRGB(145, 145, 255),
		TabTextColor = Color3.fromRGB(235, 235, 245), SelectedTabTextColor = Color3.fromRGB(20, 20, 40),
		ElementBackground = Color3.fromRGB(28, 28, 48), ElementBackgroundHover = Color3.fromRGB(55, 55, 85),
		ElementStroke = Color3.fromRGB(95, 95, 170), ElementStrokeHover = Color3.fromRGB(135, 135, 225),
		Accent = Color3.fromRGB(145, 145, 255),
	},
	Sakura = {
		TextColor = Color3.fromRGB(255, 235, 240), Background = Color3.fromRGB(45, 25, 35), Topbar = Color3.fromRGB(65, 35, 50),
		Line = Color3.fromRGB(255, 140, 180), Navigation = Color3.fromRGB(52, 29, 41), TabBackground = Color3.fromRGB(80, 45, 65),
		TabStroke = Color3.fromRGB(255, 160, 200), TabBackgroundSelected = Color3.fromRGB(255, 190, 220),
		TabTextColor = Color3.fromRGB(255, 235, 240), SelectedTabTextColor = Color3.fromRGB(60, 20, 40),
		ElementBackground = Color3.fromRGB(70, 40, 55), ElementBackgroundHover = Color3.fromRGB(100, 60, 80),
		ElementStroke = Color3.fromRGB(255, 170, 210), ElementStrokeHover = Color3.fromRGB(255, 200, 230),
		Accent = Color3.fromRGB(255, 190, 220),
	},
	Cyberpunk = {
		TextColor = Color3.fromRGB(200, 255, 240), Background = Color3.fromRGB(10, 8, 25), Topbar = Color3.fromRGB(25, 10, 60),
		Line = Color3.fromRGB(0, 255, 200), Navigation = Color3.fromRGB(14, 10, 38), TabBackground = Color3.fromRGB(35, 15, 80),
		TabStroke = Color3.fromRGB(0, 255, 220), TabBackgroundSelected = Color3.fromRGB(0, 230, 190),
		TabTextColor = Color3.fromRGB(200, 255, 240), SelectedTabTextColor = Color3.fromRGB(10, 5, 30),
		ElementBackground = Color3.fromRGB(20, 15, 55), ElementBackgroundHover = Color3.fromRGB(50, 30, 100),
		ElementStroke = Color3.fromRGB(0, 255, 200), ElementStrokeHover = Color3.fromRGB(120, 255, 220),
		Accent = Color3.fromRGB(0, 230, 190),
	},
}

-- =============================================================================
-- CONFIG
-- =============================================================================
local function fsAvailable()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

CrackedLib.Config = { Folder = "CrackedLib", FileName = "CrackedLib.json", Data = {} }

function CrackedLib.Config:GetPath()
	if type(makefolder) == "function" then return self.Folder .. "/" .. self.FileName end
	return self.FileName
end

function CrackedLib.Config:Save()
	if not fsAvailable() then return false end
	pcall(function()
		if type(makefolder) == "function" then
			if type(isfolder) ~= "function" or not isfolder(self.Folder) then makefolder(self.Folder) end
		end
	end)
	return pcall(function()
		writefile(self:GetPath(), HttpService:JSONEncode(self.Data))
	end)
end

function CrackedLib.Config:Load()
	if not fsAvailable() then return false end
	local exists = false
	pcall(function() exists = isfile(self:GetPath()) end)
	if not exists then self.Data = {} return false end
	local ok, result = pcall(function()
		local raw = readfile(self:GetPath())
		if not raw or raw == "" then return {} end
		return HttpService:JSONDecode(raw)
	end)
	if not ok or type(result) ~= "table" then self.Data = {} return false end
	self.Data = result
	return true
end

function CrackedLib.Config:Clear()
	self.Data = {}
	return self:Save()
end

CrackedLib.Config:Load()

-- =============================================================================
-- UTILS
-- =============================================================================
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

local function connectAndTrack(list, signal, cb)
	local c = signal:Connect(cb)
	table.insert(list, c)
	return c
end

local function disconnectAll(list)
	for _, c in ipairs(list) do pcall(function() c:Disconnect() end) end
	table.clear(list)
end

local function destroyElement(data)
	if not data then return end
	if data._frame and data._frame.Parent then data._frame:Destroy() end
	if data._connections then disconnectAll(data._connections) end
	data._destroyed = true
end

local function clamp(n, a, b)
	return math.max(a, math.min(b, n))
end

local function colorToTable(c)
	return { R = c.R, G = c.G, B = c.B }
end

local function tableToColor(t)
	if typeof(t) == "Color3" then return t end
	if type(t) == "table" and t.R then return Color3.new(t.R, t.G, t.B) end
	return Color3.new(1, 1, 1)
end

local function hoverBind(frame, stroke, themeRef, list)
	connectAndTrack(list, frame.MouseEnter, function()
		playSound("Hover")
		frame.BackgroundColor3 = themeRef().ElementBackgroundHover
		if stroke then stroke.Color = themeRef().ElementStrokeHover end
	end)
	connectAndTrack(list, frame.MouseLeave, function()
		frame.BackgroundColor3 = themeRef().ElementBackground
		if stroke then stroke.Color = themeRef().ElementStroke end
	end)
end

-- =============================================================================
-- INIT
-- =============================================================================
function CrackedLib:Init(name, draggable, keybind, theme, keysystem)
	local GUI = {}
	local CurrentTheme = self.Theme[theme] or self.Theme.Default
	self.CurrentTheme = CurrentTheme
	CrackedLib.CurrentTheme = CurrentTheme

	local themedElements = {}
	local sectionButtonInfos = {}
	local connections = {}
	local destroyed = false
	local tabs = {}
	local selectedTab = nil

	local function themeRef() return CurrentTheme end

	local function registerTheme(data)
		if data and type(data.RefreshTheme) == "function" then
			table.insert(themedElements, data)
		end
		return data
	end

	local function refreshAllThemes()
		for i = #themedElements, 1, -1 do
			local d = themedElements[i]
			if not d or d._destroyed then
				table.remove(themedElements, i)
			else
				pcall(function() d:RefreshTheme() end)
			end
		end
		for _, item in ipairs(sectionButtonInfos) do
			pcall(function()
				local active = item.IsActive and item.IsActive()
				if item.Button then
					item.Button.BackgroundColor3 = active and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabBackground
					item.Button.TextColor3 = active and CurrentTheme.SelectedTabTextColor or CurrentTheme.TabTextColor
				end
				if item.Stroke then
					item.Stroke.Color = active and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabStroke
				end
				if item.Page then
					item.Page.BackgroundColor3 = CurrentTheme.Background
					item.Page.ScrollBarImageColor3 = CurrentTheme.Line
				end
			end)
		end
	end

	local function getGuiParent()
		local ok, hui = pcall(function()
			if type(gethui) == "function" then return gethui() end
		end)
		if ok and hui then return hui end
		local cg = game:GetService("CoreGui")
		local can = pcall(function()
			local t = Instance.new("Folder")
			t.Parent = cg
			t:Destroy()
		end)
		if can then return cg end
		return LocalPlayer:WaitForChild("PlayerGui")
	end

	local GuiParent = getGuiParent()

	for _, parent in ipairs({ GuiParent, game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }) do
		if parent then
			for _, n in ipairs({ "CrackLib", "KeySystem" }) do
				local old = parent:FindFirstChild(n)
				if old then pcall(function() old:Destroy() end) end
			end
		end
	end

	-- Key system
	if type(keysystem) == "table" and keysystem.Enabled then
		local Key = tostring(keysystem.Key or "")
		local KeyPassed, Cancelled = false, false
		local KeySystem = Instance.new("ScreenGui")
		KeySystem.Name = "KeySystem"
		KeySystem.ResetOnSpawn = false
		KeySystem.IgnoreGuiInset = true
		KeySystem.DisplayOrder = 999999
		KeySystem.Parent = GuiParent

		local KM = Instance.new("Frame")
		KM.Size = UDim2.fromScale(0.4, 0.32)
		KM.Position = UDim2.fromScale(0.3, 0.34)
		KM.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		KM.BorderSizePixel = 0
		KM.Parent = KeySystem
		makeCorner(KM, 10)
		makeStroke(KM, Color3.fromRGB(80, 80, 80), 2)

		local box = Instance.new("TextBox")
		box.Size = UDim2.fromScale(0.7, 0.18)
		box.Position = UDim2.fromScale(0.15, 0.4)
		box.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
		box.Text = ""
		box.PlaceholderText = "Key"
		box.TextColor3 = Color3.new(1, 1, 1)
		box.TextScaled = true
		box.Parent = KM
		makeCorner(box, 8)

		local loadBtn = Instance.new("TextButton")
		loadBtn.Size = UDim2.fromScale(0.35, 0.18)
		loadBtn.Position = UDim2.fromScale(0.325, 0.7)
		loadBtn.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
		loadBtn.Text = "Load"
		loadBtn.TextColor3 = Color3.new(1, 1, 1)
		loadBtn.TextScaled = true
		loadBtn.Parent = KM
		makeCorner(loadBtn, 8)

		local close = Instance.new("TextButton")
		close.Size = UDim2.fromScale(0.1, 0.12)
		close.Position = UDim2.fromScale(0.88, 0.04)
		close.BackgroundTransparency = 1
		close.Text = "×"
		close.TextColor3 = Color3.new(1, 1, 1)
		close.TextScaled = true
		close.Parent = KM

		connectAndTrack(connections, loadBtn.MouseButton1Click, function()
			playSound("Click")
			if box.Text:gsub("%s+", "") == Key then
				KeyPassed = true
				playSound("Open")
				KeySystem:Destroy()
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

	-- Main chrome
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CrackLib"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999
	ScreenGui.Parent = GuiParent

	local Main = Instance.new("Frame")
	Main.Size = UDim2.fromScale(0.51, 0.56)
	Main.Position = UDim2.fromScale(0.245, 0.22)
	Main.BackgroundColor3 = CurrentTheme.Background
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	makeCorner(Main, 10)
	local MainStroke = makeStroke(Main, CurrentTheme.ElementStroke, 2)

	local Topbar = Instance.new("Frame")
	Topbar.Size = UDim2.new(1, 0, 0, 52)
	Topbar.BackgroundColor3 = CurrentTheme.Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Main
	makeCorner(Topbar, 10)

	-- ===== AVATAR PREVIEW =====
	local AvatarFrame = Instance.new("Frame")
	AvatarFrame.Name = "AvatarPreview"
	AvatarFrame.Position = UDim2.new(0, 10, 0, 6)
	AvatarFrame.Size = UDim2.fromOffset(40, 40)
	AvatarFrame.BackgroundColor3 = CurrentTheme.ElementBackground
	AvatarFrame.BorderSizePixel = 0
	AvatarFrame.Parent = Topbar
	makeCorner(AvatarFrame, 20)
	local AvatarStroke = makeStroke(AvatarFrame, CurrentTheme.ElementStroke, 1)

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Name = "Image"
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Size = UDim2.fromScale(1, 1)
	AvatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	AvatarImage.Parent = AvatarFrame
	makeCorner(AvatarImage, 20)

	task.spawn(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
		end)
		if ok and url then
			AvatarImage.Image = url
		else
			-- fallback
			pcall(function()
				AvatarImage.Image = string.format(
					"https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=48&height=48&format=png",
					LocalPlayer.UserId
				)
			end)
		end
	end)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 58, 0, 4)
	title.Size = UDim2.new(0.55, 0, 0, 22)
	title.Font = Enum.Font.SourceSansBold
	title.Text = tostring(name or "CrackedLib")
	title.TextColor3 = CurrentTheme.TextColor
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = Topbar

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.new(0, 58, 0, 26)
	subtitle.Size = UDim2.new(0.55, 0, 0, 18)
	subtitle.Font = Enum.Font.SourceSans
	subtitle.Text = (LocalPlayer.DisplayName or LocalPlayer.Name) .. "  •  v" .. CrackedLib.Version
	subtitle.TextColor3 = CurrentTheme.TextColor
	subtitle.TextTransparency = 0.35
	subtitle.TextScaled = true
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = Topbar

	local Minus = Instance.new("TextButton")
	Minus.BackgroundTransparency = 1
	Minus.Position = UDim2.new(1, -82, 0, 8)
	Minus.Size = UDim2.fromOffset(32, 32)
	Minus.Text = "−"
	Minus.TextColor3 = CurrentTheme.TextColor
	Minus.TextScaled = true
	Minus.Parent = Topbar

	local Exit = Instance.new("TextButton")
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(1, -44, 0, 8)
	Exit.Size = UDim2.fromOffset(32, 32)
	Exit.Text = "×"
	Exit.TextColor3 = CurrentTheme.TextColor
	Exit.TextScaled = true
	Exit.Parent = Topbar

	local Line = Instance.new("Frame")
	Line.Position = UDim2.new(0, 0, 0, 50)
	Line.Size = UDim2.new(1, 0, 0, 2)
	Line.BackgroundColor3 = CurrentTheme.Line
	Line.BorderSizePixel = 0
	Line.Parent = Main

	local Navigation = Instance.new("ScrollingFrame")
	Navigation.Position = UDim2.new(0, 0, 0, 52)
	Navigation.Size = UDim2.new(0.255, 0, 1, -52)
	Navigation.BackgroundColor3 = CurrentTheme.Navigation
	Navigation.BorderSizePixel = 0
	Navigation.ScrollBarThickness = 3
	Navigation.ScrollBarImageColor3 = CurrentTheme.Line
	Navigation.CanvasSize = UDim2.new(0, 0, 0, 0)
	Navigation.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Navigation.Parent = Main

	local NavLayout = Instance.new("UIListLayout")
	NavLayout.Padding = UDim.new(0, 6)
	NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NavLayout.Parent = Navigation

	local NavPad = Instance.new("UIPadding")
	NavPad.PaddingTop = UDim.new(0, 8)
	NavPad.PaddingLeft = UDim.new(0, 8)
	NavPad.PaddingRight = UDim.new(0, 8)
	NavPad.Parent = Navigation

	local Divider = Instance.new("Frame")
	Divider.Position = UDim2.new(0.255, 0, 0, 52)
	Divider.Size = UDim2.new(0, 2, 1, -52)
	Divider.BackgroundColor3 = CurrentTheme.Line
	Divider.BorderSizePixel = 0
	Divider.Parent = Main

	local TabHolder = Instance.new("Frame")
	TabHolder.Position = UDim2.new(0.255, 2, 0, 52)
	TabHolder.Size = UDim2.new(0.745, -2, 1, -52)
	TabHolder.BackgroundTransparency = 1
	TabHolder.Parent = Main

	playSound("Open")

	-- =========================================================================
	-- CREATE TAB
	-- =========================================================================
	function GUI:CreateTab(tabName)
		local TabData = {}
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 36)
		btn.BackgroundColor3 = CurrentTheme.TabBackground
		btn.BorderSizePixel = 0
		btn.Text = tostring(tabName or "Tab")
		btn.TextColor3 = CurrentTheme.TabTextColor
		btn.TextScaled = true
		btn.Font = Enum.Font.SourceSansBold
		btn.AutoButtonColor = false
		btn.Parent = Navigation
		makeCorner(btn, 8)
		local btnStroke = makeStroke(btn, CurrentTheme.TabStroke, 1)

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundColor3 = CurrentTheme.Background
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 4
		page.ScrollBarImageColor3 = CurrentTheme.Line
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = TabHolder

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		local pagePad = Instance.new("UIPadding")
		pagePad.PaddingTop = UDim.new(0, 10)
		pagePad.PaddingBottom = UDim.new(0, 10)
		pagePad.PaddingLeft = UDim.new(0, 12)
		pagePad.PaddingRight = UDim.new(0, 12)
		pagePad.Parent = page

		local info = {
			Button = btn,
			Stroke = btnStroke,
			Content = page,
			Page = page,
			Name = tabName,
		}
		table.insert(tabs, info)
		table.insert(sectionButtonInfos, {
			Button = btn,
			Stroke = btnStroke,
			Page = page,
			IsActive = function() return selectedTab == info end,
		})

		local function selectThis()
			playSound("Click")
			for _, t in ipairs(tabs) do
				t.Content.Visible = false
				t.Button.BackgroundColor3 = CurrentTheme.TabBackground
				t.Button.TextColor3 = CurrentTheme.TabTextColor
				t.Stroke.Color = CurrentTheme.TabStroke
			end
			page.Visible = true
			btn.BackgroundColor3 = CurrentTheme.TabBackgroundSelected
			btn.TextColor3 = CurrentTheme.SelectedTabTextColor
			btnStroke.Color = CurrentTheme.TabBackgroundSelected
			selectedTab = info
		end

		connectAndTrack(connections, btn.MouseButton1Click, selectThis)
		if not selectedTab then selectThis() end

		-- SECTION
		function TabData:Section(sectionName)
			local SectionData = {}

			local header = Instance.new("TextLabel")
			header.Size = UDim2.new(1, 0, 0, 22)
			header.BackgroundTransparency = 1
			header.Text = tostring(sectionName or "Section")
			header.TextColor3 = CurrentTheme.TextColor
			header.TextScaled = true
			header.Font = Enum.Font.SourceSansBold
			header.TextXAlignment = Enum.TextXAlignment.Left
			header.Parent = page

			local function baseFrame(height)
				local f = Instance.new("Frame")
				f.Size = UDim2.new(1, 0, 0, height or 45)
				f.BackgroundColor3 = CurrentTheme.ElementBackground
				f.BorderSizePixel = 0
				f.Parent = page
				makeCorner(f, 8)
				local fs = makeStroke(f, CurrentTheme.ElementStroke, 2)
				return f, fs
			end

			-- TOGGLE
			function SectionData:Toggle(label, default, callback)
				local data = { Value = default == true, _connections = {} }
				local f, fs = baseFrame(45)
				data._frame = f
				hoverBind(f, fs, themeRef, data._connections)

				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 16, 0, 0)
				t.Size = UDim2.new(1, -70, 1, 0)
				t.Text = tostring(label or "Toggle")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f

				local box = Instance.new("Frame")
				box.AnchorPoint = Vector2.new(1, 0.5)
				box.Position = UDim2.new(1, -14, 0.5, 0)
				box.Size = UDim2.fromOffset(40, 22)
				box.BackgroundColor3 = data.Value and (CurrentTheme.Accent or CurrentTheme.TabBackgroundSelected) or CurrentTheme.ElementStroke
				box.BorderSizePixel = 0
				box.Parent = f
				makeCorner(box, 11)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.fromOffset(18, 18)
				knob.Position = data.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
				knob.BackgroundColor3 = Color3.new(1, 1, 1)
				knob.BorderSizePixel = 0
				knob.Parent = box
				makeCorner(knob, 9)

				local function applyVisual()
					box.BackgroundColor3 = data.Value and (CurrentTheme.Accent or CurrentTheme.TabBackgroundSelected) or CurrentTheme.ElementStroke
					knob.Position = data.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
				end

				local function set(v, fire)
					data.Value = v and true or false
					applyVisual()
					playSound(data.Value and "ToggleOn" or "ToggleOff")
					if fire and callback then task.spawn(callback, data.Value) end
				end

				local hit = Instance.new("TextButton")
				hit.Size = UDim2.fromScale(1, 1)
				hit.BackgroundTransparency = 1
				hit.Text = ""
				hit.Parent = f
				connectAndTrack(data._connections, hit.MouseButton1Click, function()
					set(not data.Value, true)
				end)

				function data:Set(v) set(v, true) end
				function data:Get() return data.Value end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					applyVisual()
				end
				return registerTheme(data)
			end

			function SectionData:ConfigToggle(label, default, callback, key)
				local cfgKey = key or label
				local saved = CrackedLib.Config.Data[cfgKey]
				local start = saved ~= nil and saved or default
				local data = self:Toggle(label, start, function(v)
					CrackedLib.Config.Data[cfgKey] = v
					CrackedLib.Config:Save()
					if callback then callback(v) end
				end)
				task.defer(function()
					if callback then pcall(callback, data.Value) end
				end)
				return data
			end

			-- BUTTON
			function SectionData:Button(label, callback)
				local data = { _connections = {} }
				local f, fs = baseFrame(42)
				data._frame = f
				hoverBind(f, fs, themeRef, data._connections)
				local t = Instance.new("TextButton")
				t.Size = UDim2.fromScale(1, 1)
				t.BackgroundTransparency = 1
				t.Text = tostring(label or "Button")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.Font = Enum.Font.SourceSansBold
				t.Parent = f
				connectAndTrack(data._connections, t.MouseButton1Click, function()
					playSound("Click")
					if callback then task.spawn(callback) end
				end)
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			-- LABEL
			function SectionData:Label(label)
				local data = { _connections = {} }
				local f, fs = baseFrame(45)
				data._frame = f
				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Size = UDim2.new(1, -48, 1, 0)
				t.Position = UDim2.new(0, 24, 0, 0)
				t.Text = tostring(label or "Label")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextWrapped = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f
				function data:SetText(value) t.Text = tostring(value) end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			-- PARAGRAPH
			function SectionData:Paragraph(titleText, body)
				local data = { _connections = {} }
				local f, fs = baseFrame(70)
				data._frame = f
				local t1 = Instance.new("TextLabel")
				t1.BackgroundTransparency = 1
				t1.Position = UDim2.new(0, 16, 0, 4)
				t1.Size = UDim2.new(1, -32, 0, 22)
				t1.Text = tostring(titleText or "")
				t1.TextColor3 = CurrentTheme.TextColor
				t1.TextScaled = true
				t1.Font = Enum.Font.SourceSansBold
				t1.TextXAlignment = Enum.TextXAlignment.Left
				t1.Parent = f
				local t2 = Instance.new("TextLabel")
				t2.BackgroundTransparency = 1
				t2.Position = UDim2.new(0, 16, 0, 28)
				t2.Size = UDim2.new(1, -32, 0, 36)
				t2.Text = tostring(body or "")
				t2.TextColor3 = CurrentTheme.TextColor
				t2.TextTransparency = 0.25
				t2.TextScaled = true
				t2.TextWrapped = true
				t2.TextXAlignment = Enum.TextXAlignment.Left
				t2.Parent = f
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t1.TextColor3 = CurrentTheme.TextColor
					t2.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			-- SEPARATOR
			function SectionData:Separator()
				local data = { _connections = {} }
				local f = Instance.new("Frame")
				f.Size = UDim2.new(1, 0, 0, 12)
				f.BackgroundTransparency = 1
				f.Parent = page
				data._frame = f
				local line = Instance.new("Frame")
				line.AnchorPoint = Vector2.new(0.5, 0.5)
				line.Position = UDim2.fromScale(0.5, 0.5)
				line.Size = UDim2.new(1, -20, 0, 2)
				line.BackgroundColor3 = CurrentTheme.Line
				line.BorderSizePixel = 0
				line.Parent = f
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme() line.BackgroundColor3 = CurrentTheme.Line end
				return registerTheme(data)
			end

			-- SLIDER
			function SectionData:Slider(label, min, max, default, callback, decimals)
				min, max = min or 0, max or 100
				decimals = decimals or 0
				local data = {
					Value = clamp(default or min, min, max),
					_connections = {},
				}
				local f, fs = baseFrame(56)
				data._frame = f

				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 16, 0, 2)
				t.Size = UDim2.new(0.7, 0, 0, 20)
				t.Text = tostring(label or "Slider")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f

				local val = Instance.new("TextLabel")
				val.BackgroundTransparency = 1
				val.Position = UDim2.new(0.7, 0, 0, 2)
				val.Size = UDim2.new(0.3, -12, 0, 20)
				val.Text = string.format("%." .. decimals .. "f", data.Value)
				val.TextColor3 = CurrentTheme.TextColor
				val.TextScaled = true
				val.TextXAlignment = Enum.TextXAlignment.Right
				val.Parent = f

				local track = Instance.new("Frame")
				track.Position = UDim2.new(0, 16, 0, 32)
				track.Size = UDim2.new(1, -32, 0, 10)
				track.BackgroundColor3 = CurrentTheme.ElementStroke
				track.BorderSizePixel = 0
				track.Parent = f
				makeCorner(track, 5)

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((data.Value - min) / math.max(max - min, 1e-6), 0, 1, 0)
				fill.BackgroundColor3 = CurrentTheme.Accent or CurrentTheme.TabBackgroundSelected
				fill.BorderSizePixel = 0
				fill.Parent = track
				makeCorner(fill, 5)

				local function setFromX(x)
					local a = clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					local raw = min + (max - min) * a
					local mult = 10 ^ decimals
					data.Value = math.floor(raw * mult + 0.5) / mult
					fill.Size = UDim2.new(a, 0, 1, 0)
					val.Text = string.format("%." .. decimals .. "f", data.Value)
					if callback then task.spawn(callback, data.Value) end
				end

				local dragging = false
				local hit = Instance.new("TextButton")
				hit.Size = UDim2.fromScale(1, 1)
				hit.BackgroundTransparency = 1
				hit.Text = ""
				hit.Parent = track
				connectAndTrack(data._connections, hit.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						playSound("Click")
						setFromX(input.Position.X)
					end
				end)
				connectAndTrack(data._connections, UserInputService.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				connectAndTrack(data._connections, UserInputService.InputChanged, function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						setFromX(input.Position.X)
					end
				end)

				function data:Set(v)
					data.Value = clamp(v, min, max)
					local a = (data.Value - min) / math.max(max - min, 1e-6)
					fill.Size = UDim2.new(a, 0, 1, 0)
					val.Text = string.format("%." .. decimals .. "f", data.Value)
					if callback then task.spawn(callback, data.Value) end
				end
				function data:Get() return data.Value end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					val.TextColor3 = CurrentTheme.TextColor
					track.BackgroundColor3 = CurrentTheme.ElementStroke
					fill.BackgroundColor3 = CurrentTheme.Accent or CurrentTheme.TabBackgroundSelected
				end
				return registerTheme(data)
			end

			function SectionData:ConfigSlider(label, min, max, default, callback, decimals, key)
				local cfgKey = key or label
				local saved = CrackedLib.Config.Data[cfgKey]
				local start = type(saved) == "number" and saved or default
				local data = self:Slider(label, min, max, start, function(v)
					CrackedLib.Config.Data[cfgKey] = v
					CrackedLib.Config:Save()
					if callback then callback(v) end
				end, decimals)
				task.defer(function()
					if callback then pcall(callback, data.Value) end
				end)
				return data
			end

			-- TEXTBOX
			function SectionData:Textbox(label, default, callback)
				local data = { Value = tostring(default or ""), _connections = {} }
				local f, fs = baseFrame(45)
				data._frame = f
				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 14, 0, 0)
				t.Size = UDim2.new(0.4, 0, 1, 0)
				t.Text = tostring(label or "")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f
				local box = Instance.new("TextBox")
				box.Position = UDim2.new(0.42, 0, 0.15, 0)
				box.Size = UDim2.new(0.55, -8, 0.7, 0)
				box.BackgroundColor3 = CurrentTheme.Background
				box.Text = data.Value
				box.PlaceholderText = "..."
				box.TextColor3 = CurrentTheme.TextColor
				box.TextScaled = true
				box.ClearTextOnFocus = false
				box.Parent = f
				makeCorner(box, 6)
				connectAndTrack(data._connections, box.FocusLost, function()
					data.Value = box.Text
					playSound("Click")
					if callback then task.spawn(callback, data.Value) end
				end)
				function data:Set(v) data.Value = tostring(v) box.Text = data.Value end
				function data:Get() return data.Value end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					box.BackgroundColor3 = CurrentTheme.Background
					box.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			function SectionData:ConfigTextbox(label, default, callback, key)
				local cfgKey = key or label
				local saved = CrackedLib.Config.Data[cfgKey]
				local start = saved ~= nil and tostring(saved) or tostring(default or "")
				local data = self:Textbox(label, start, function(v)
					CrackedLib.Config.Data[cfgKey] = v
					CrackedLib.Config:Save()
					if callback then callback(v) end
				end)
				task.defer(function()
					if callback then pcall(callback, data.Value) end
				end)
				return data
			end

			-- KEYBIND
			function SectionData:Keybind(label, default, callback)
				local data = {
					Value = typeof(default) == "EnumItem" and default or Enum.KeyCode.Unknown,
					Listening = false,
					_connections = {},
				}
				local f, fs = baseFrame(45)
				data._frame = f
				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 16, 0, 0)
				t.Size = UDim2.new(1, -100, 1, 0)
				t.Text = tostring(label or "Keybind")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f
				local keyBtn = Instance.new("TextButton")
				keyBtn.AnchorPoint = Vector2.new(1, 0.5)
				keyBtn.Position = UDim2.new(1, -12, 0.5, 0)
				keyBtn.Size = UDim2.fromOffset(70, 28)
				keyBtn.BackgroundColor3 = CurrentTheme.Background
				keyBtn.Text = data.Value.Name
				keyBtn.TextColor3 = CurrentTheme.TextColor
				keyBtn.TextScaled = true
				keyBtn.Parent = f
				makeCorner(keyBtn, 6)

				connectAndTrack(data._connections, keyBtn.MouseButton1Click, function()
					data.Listening = true
					keyBtn.Text = "..."
					playSound("Click")
				end)
				connectAndTrack(data._connections, UserInputService.InputBegan, function(input, gpe)
					if not data.Listening then return end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						data.Value = input.KeyCode
						data.Listening = false
						keyBtn.Text = data.Value.Name
						playSound("ToggleOn")
						if callback then task.spawn(callback, data.Value) end
					end
				end)

				function data:Set(k)
					if typeof(k) == "EnumItem" then
						data.Value = k
						keyBtn.Text = k.Name
					end
				end
				function data:Get() return data.Value end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					keyBtn.BackgroundColor3 = CurrentTheme.Background
					keyBtn.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			-- DROPDOWN
			function SectionData:Dropdown(label, options, callback, multi)
				options = type(options) == "table" and options or {}
				local data = {
					Value = nil,
					Values = {},
					Open = false,
					_connections = {},
				}
				local rows = {}
				local f, fs = baseFrame(45)
				f.ClipsDescendants = true
				data._frame = f
				local txt = Instance.new("TextLabel")
				txt.BackgroundTransparency = 1
				txt.Position = UDim2.new(0, 20, 0, 0)
				txt.Size = UDim2.new(1, -60, 0, 45)
				txt.Text = tostring(label or "Dropdown")
				txt.TextColor3 = CurrentTheme.TextColor
				txt.TextScaled = true
				txt.TextXAlignment = Enum.TextXAlignment.Left
				txt.Parent = f
				local arrow = Instance.new("TextButton")
				arrow.BackgroundTransparency = 1
				arrow.Position = UDim2.new(1, -44, 0, 0)
				arrow.Size = UDim2.fromOffset(44, 45)
				arrow.Text = "▼"
				arrow.TextColor3 = CurrentTheme.TextColor
				arrow.TextScaled = true
				arrow.Parent = f
				local list = Instance.new("Frame")
				list.Position = UDim2.new(0, 0, 0, 45)
				list.Size = UDim2.new(1, 0, 0, 0)
				list.BackgroundColor3 = CurrentTheme.Background
				list.BorderSizePixel = 0
				list.Parent = f
				Instance.new("UIListLayout", list)

				local function selectedText()
					if multi then
						local on = {}
						for _, o in ipairs(options) do
							if data.Values[o] then table.insert(on, tostring(o)) end
						end
						return #on > 0 and table.concat(on, ", ") or tostring(label or "Dropdown")
					end
					return data.Value and tostring(data.Value) or tostring(label or "Dropdown")
				end

				local function refreshSize()
					local n = #options
					list.Size = UDim2.new(1, 0, 0, data.Open and n * 34 or 0)
					f.Size = UDim2.new(1, 0, 0, data.Open and 45 + n * 34 or 45)
					arrow.Text = data.Open and "▲" or "▼"
				end

				local function build()
					for _, r in ipairs(rows) do if r.Parent then r:Destroy() end end
					table.clear(rows)
					for _, option in ipairs(options) do
						local row = Instance.new("TextButton")
						row.Size = UDim2.new(1, 0, 0, 34)
						row.BackgroundColor3 = CurrentTheme.ElementBackground
						row.BorderSizePixel = 0
						row.Text = tostring(option)
						row.TextColor3 = CurrentTheme.TextColor
						row.TextScaled = true
						row.AutoButtonColor = false
						row.Parent = list
						connectAndTrack(data._connections, row.MouseButton1Click, function()
							playSound("Click")
							if multi then
								data.Values[option] = not data.Values[option]
							else
								data.Value = option
								data.Open = false
							end
							txt.Text = selectedText()
							refreshSize()
							if callback then task.spawn(callback, multi and data.Values or data.Value) end
						end)
						table.insert(rows, row)
					end
					txt.Text = selectedText()
					refreshSize()
				end
				build()
				connectAndTrack(data._connections, arrow.MouseButton1Click, function()
					data.Open = not data.Open
					playSound("Click")
					refreshSize()
				end)
				function data:Set(v)
					if multi then data.Values = type(v) == "table" and v or {}
					else data.Value = v end
					txt.Text = selectedText()
				end
				function data:Get() return multi and data.Values or data.Value end
				function data:Refresh(newOpts, keep)
					options = type(newOpts) == "table" and newOpts or {}
					if not keep then data.Value = nil data.Values = {} end
					build()
				end
				function data:ChangeOptions(n, k) self:Refresh(n, k) end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					txt.TextColor3 = CurrentTheme.TextColor
					arrow.TextColor3 = CurrentTheme.TextColor
					list.BackgroundColor3 = CurrentTheme.Background
					for _, r in ipairs(rows) do
						r.BackgroundColor3 = CurrentTheme.ElementBackground
						r.TextColor3 = CurrentTheme.TextColor
					end
				end
				return registerTheme(data)
			end

			function SectionData:ConfigDropdown(label, options, callback, multi, key)
				local cfgKey = key or label
				local saved = CrackedLib.Config.Data[cfgKey]
				local data = self:Dropdown(label, options, function(v)
					CrackedLib.Config.Data[cfgKey] = v
					CrackedLib.Config:Save()
					if callback then callback(v) end
				end, multi)
				if saved ~= nil then
					task.defer(function()
						data:Set(saved)
						if callback then pcall(callback, multi and data.Values or data.Value) end
					end)
				end
				return data
			end

			-- COLOR PICKER
			function SectionData:ColorPicker(label, default, callback)
				local data = {
					Value = typeof(default) == "Color3" and default or Color3.fromRGB(255, 255, 255),
					Open = false,
					_connections = {},
				}
				local f, fs = baseFrame(45)
				f.ClipsDescendants = true
				data._frame = f

				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 20, 0, 0)
				t.Size = UDim2.new(1, -70, 0, 45)
				t.Text = tostring(label or "Color")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f

				local preview = Instance.new("Frame")
				preview.AnchorPoint = Vector2.new(1, 0.5)
				preview.Position = UDim2.new(1, -16, 0, 22)
				preview.Size = UDim2.fromOffset(28, 28)
				preview.BackgroundColor3 = data.Value
				preview.BorderSizePixel = 0
				preview.Parent = f
				makeCorner(preview, 6)
				local ps = makeStroke(preview, CurrentTheme.ElementStroke, 1)

				local panel = Instance.new("Frame")
				panel.Position = UDim2.new(0, 0, 0, 45)
				panel.Size = UDim2.new(1, 0, 0, 0)
				panel.BackgroundColor3 = CurrentTheme.Background
				panel.BorderSizePixel = 0
				panel.Parent = f

				local function makeChannel(name, y, getComp, setComp)
					local lab = Instance.new("TextLabel")
					lab.BackgroundTransparency = 1
					lab.Position = UDim2.new(0, 12, 0, y)
					lab.Size = UDim2.new(0, 24, 0, 18)
					lab.Text = name
					lab.TextColor3 = CurrentTheme.TextColor
					lab.TextScaled = true
					lab.Parent = panel
					local track = Instance.new("Frame")
					track.Position = UDim2.new(0, 40, 0, y + 4)
					track.Size = UDim2.new(1, -52, 0, 10)
					track.BackgroundColor3 = CurrentTheme.ElementBackground
					track.BorderSizePixel = 0
					track.Parent = panel
					makeCorner(track, 4)
					local fill = Instance.new("Frame")
					fill.Size = UDim2.new(getComp(), 0, 1, 0)
					fill.BackgroundColor3 = CurrentTheme.Accent or CurrentTheme.TabBackgroundSelected
					fill.BorderSizePixel = 0
					fill.Parent = track
					makeCorner(fill, 4)
					local hit = Instance.new("TextButton")
					hit.Size = UDim2.fromScale(1, 1)
					hit.BackgroundTransparency = 1
					hit.Text = ""
					hit.Parent = track
					local dragging = false
					local function apply(input)
						local a = clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
						setComp(a)
						fill.Size = UDim2.new(a, 0, 1, 0)
						preview.BackgroundColor3 = data.Value
						if callback then task.spawn(callback, data.Value) end
					end
					connectAndTrack(data._connections, hit.InputBegan, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							apply(input)
						end
					end)
					connectAndTrack(data._connections, UserInputService.InputEnded, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
						end
					end)
					connectAndTrack(data._connections, UserInputService.InputChanged, function(input)
						if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							apply(input)
						end
					end)
					return function()
						fill.Size = UDim2.new(getComp(), 0, 1, 0)
						fill.BackgroundColor3 = CurrentTheme.Accent or CurrentTheme.TabBackgroundSelected
						track.BackgroundColor3 = CurrentTheme.ElementBackground
						lab.TextColor3 = CurrentTheme.TextColor
					end
				end

				local refreshR = makeChannel("R", 8, function() return data.Value.R end, function(a)
					data.Value = Color3.new(a, data.Value.G, data.Value.B)
				end)
				local refreshG = makeChannel("G", 32, function() return data.Value.G end, function(a)
					data.Value = Color3.new(data.Value.R, a, data.Value.B)
				end)
				local refreshB = makeChannel("B", 56, function() return data.Value.B end, function(a)
					data.Value = Color3.new(data.Value.R, data.Value.G, a)
				end)

				local function setOpen(o)
					data.Open = o
					panel.Size = UDim2.new(1, 0, 0, o and 84 or 0)
					f.Size = UDim2.new(1, 0, 0, o and 45 + 84 or 45)
					playSound("Click")
				end

				local hitTop = Instance.new("TextButton")
				hitTop.Size = UDim2.new(1, 0, 0, 45)
				hitTop.BackgroundTransparency = 1
				hitTop.Text = ""
				hitTop.Parent = f
				connectAndTrack(data._connections, hitTop.MouseButton1Click, function()
					setOpen(not data.Open)
				end)

				function data:Set(c)
					data.Value = typeof(c) == "Color3" and c or tableToColor(c)
					preview.BackgroundColor3 = data.Value
					refreshR() refreshG() refreshB()
					if callback then task.spawn(callback, data.Value) end
				end
				function data:Get() return data.Value end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					ps.Color = CurrentTheme.ElementStroke
					panel.BackgroundColor3 = CurrentTheme.Background
					refreshR() refreshG() refreshB()
				end
				return registerTheme(data)
			end

			function SectionData:ConfigColorPicker(label, default, callback, key)
				local cfgKey = key or label
				local saved = CrackedLib.Config.Data[cfgKey]
				local start = saved and tableToColor(saved) or default
				local data = self:ColorPicker(label, start, function(c)
					CrackedLib.Config.Data[cfgKey] = colorToTable(c)
					CrackedLib.Config:Save()
					if callback then callback(c) end
				end)
				task.defer(function()
					if callback then pcall(callback, start) end
				end)
				return data
			end

			-- TOGGLE LIST
			function SectionData:ToggleList(label, options, callback, defaults)
				options = type(options) == "table" and options or {}
				defaults = type(defaults) == "table" and defaults or {}
				local data = { Open = false, States = {}, _connections = {} }
				for _, o in ipairs(options) do data.States[o] = defaults[o] == true end
				local f, fs = baseFrame(45)
				f.ClipsDescendants = true
				data._frame = f
				local txt = Instance.new("TextLabel")
				txt.BackgroundTransparency = 1
				txt.Position = UDim2.new(0, 20, 0, 0)
				txt.Size = UDim2.new(1, -60, 0, 45)
				txt.Text = tostring(label or "List")
				txt.TextColor3 = CurrentTheme.TextColor
				txt.TextScaled = true
				txt.TextXAlignment = Enum.TextXAlignment.Left
				txt.Parent = f
				local arrow = Instance.new("TextButton")
				arrow.BackgroundTransparency = 1
				arrow.Position = UDim2.new(1, -44, 0, 0)
				arrow.Size = UDim2.fromOffset(44, 45)
				arrow.Text = "▼"
				arrow.TextColor3 = CurrentTheme.TextColor
				arrow.TextScaled = true
				arrow.Parent = f
				local list = Instance.new("Frame")
				list.Position = UDim2.new(0, 0, 0, 45)
				list.BackgroundColor3 = CurrentTheme.Background
				list.BorderSizePixel = 0
				list.Parent = f
				Instance.new("UIListLayout", list)
				local function refreshSize()
					local n = #options
					list.Size = UDim2.new(1, 0, 0, data.Open and n * 36 or 0)
					f.Size = UDim2.new(1, 0, 0, data.Open and 45 + n * 36 or 45)
					arrow.Text = data.Open and "▲" or "▼"
				end
				for _, option in ipairs(options) do
					local row = Instance.new("TextButton")
					row.Size = UDim2.new(1, 0, 0, 36)
					row.BackgroundColor3 = CurrentTheme.ElementBackground
					row.BorderSizePixel = 0
					row.Text = tostring(option)
					row.TextColor3 = CurrentTheme.TextColor
					row.TextScaled = true
					row.Parent = list
					connectAndTrack(data._connections, row.MouseButton1Click, function()
						data.States[option] = not data.States[option]
						playSound(data.States[option] and "ToggleOn" or "ToggleOff")
						if callback then task.spawn(callback, option, data.States[option], data.States) end
					end)
				end
				refreshSize()
				connectAndTrack(data._connections, arrow.MouseButton1Click, function()
					data.Open = not data.Open
					playSound("Click")
					refreshSize()
				end)
				function data:Get() return data.States end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					txt.TextColor3 = CurrentTheme.TextColor
					arrow.TextColor3 = CurrentTheme.TextColor
					list.BackgroundColor3 = CurrentTheme.Background
				end
				return registerTheme(data)
			end

			return SectionData
		end

		return TabData
	end

	function GUI:SetTheme(newTheme)
		local t = CrackedLib.Theme[newTheme]
		if not t then return false end
		CurrentTheme = t
		CrackedLib.CurrentTheme = t
		title.TextColor3 = t.TextColor
		subtitle.TextColor3 = t.TextColor
		Topbar.BackgroundColor3 = t.Topbar
		Line.BackgroundColor3 = t.Line
		Navigation.BackgroundColor3 = t.Navigation
		Navigation.ScrollBarImageColor3 = t.Line
		Main.BackgroundColor3 = t.Background
		MainStroke.Color = t.ElementStroke
		Minus.TextColor3 = t.TextColor
		Exit.TextColor3 = t.TextColor
		Divider.BackgroundColor3 = t.Line
		AvatarFrame.BackgroundColor3 = t.ElementBackground
		AvatarStroke.Color = t.ElementStroke
		for _, info in ipairs(tabs) do
			local active = info == selectedTab
			info.Button.BackgroundColor3 = active and t.TabBackgroundSelected or t.TabBackground
			info.Button.TextColor3 = active and t.SelectedTabTextColor or t.TabTextColor
			info.Stroke.Color = active and t.TabBackgroundSelected or t.TabStroke
			info.Content.BackgroundColor3 = t.Background
			info.Content.ScrollBarImageColor3 = t.Line
		end
		refreshAllThemes()
		playSound("Click")
		return true
	end

	function GUI:SetSounds(enabled)
		CrackedLib.Sounds.Enabled = enabled and true or false
	end

	function GUI:SetVolume(v)
		CrackedLib.Sounds.Volume = clamp(tonumber(v) or 0.35, 0, 1)
	end

	function GUI:RefreshAvatar()
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(
					LocalPlayer.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size48x48
				)
			end)
			if ok and url then AvatarImage.Image = url end
		end)
	end

	function GUI:Notify(nTitle, content, duration)
		duration = duration or 3
		playSound("Notify")
		local notif = Instance.new("Frame")
		notif.Size = UDim2.fromOffset(280, 70)
		notif.Position = UDim2.new(1, -300, 1, -90)
		notif.BackgroundColor3 = CurrentTheme.ElementBackground
		notif.BorderSizePixel = 0
		notif.Parent = ScreenGui
		makeCorner(notif, 8)
		makeStroke(notif, CurrentTheme.ElementStroke, 2)
		local nt = Instance.new("TextLabel")
		nt.BackgroundTransparency = 1
		nt.Position = UDim2.fromOffset(12, 6)
		nt.Size = UDim2.new(1, -24, 0, 22)
		nt.Text = tostring(nTitle or "")
		nt.TextColor3 = CurrentTheme.TextColor
		nt.TextScaled = true
		nt.TextXAlignment = Enum.TextXAlignment.Left
		nt.Parent = notif
		local nc = Instance.new("TextLabel")
		nc.BackgroundTransparency = 1
		nc.Position = UDim2.fromOffset(12, 30)
		nc.Size = UDim2.new(1, -24, 0, 30)
		nc.Text = tostring(content or "")
		nc.TextColor3 = CurrentTheme.TextColor
		nc.TextScaled = true
		nc.TextXAlignment = Enum.TextXAlignment.Left
		nc.Parent = notif
		task.delay(duration, function() if notif.Parent then notif:Destroy() end end)
	end

	if draggable then
		local dragging, dragStart, startPos
		connectAndTrack(connections, Topbar.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
			end
		end)
		connectAndTrack(connections, Topbar.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		connectAndTrack(connections, UserInputService.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - dragStart
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	if keybind then
		connectAndTrack(connections, UserInputService.InputBegan, function(input, gpe)
			if not gpe and input.KeyCode == keybind and not destroyed then
				ScreenGui.Enabled = not ScreenGui.Enabled
				playSound("Click")
			end
		end)
	end

	local minimized, normalSize = false, Main.Size
	connectAndTrack(connections, Exit.MouseButton1Click, function()
		playSound("Click")
		GUI:Destroy()
	end)
	connectAndTrack(connections, Minus.MouseButton1Click, function()
		playSound("Click")
		minimized = not minimized
		Navigation.Visible = not minimized
		TabHolder.Visible = not minimized
		Line.Visible = not minimized
		Divider.Visible = not minimized
		Main.Size = minimized and UDim2.new(normalSize.X.Scale, normalSize.X.Offset, 0, 52) or normalSize
		Minus.Text = minimized and "+" or "−"
	end)

	function GUI:Destroy()
		if destroyed then return end
		destroyed = true
		disconnectAll(connections)
		table.clear(themedElements)
		table.clear(sectionButtonInfos)
		pcall(function()
			if CrackedLib._Active then CrackedLib._Active[GUI] = nil end
		end)
		if ScreenGui then ScreenGui:Destroy() end
	end

	function GUI:Unload() self:Destroy() end
	function GUI:SaveConfig() return CrackedLib.Config:Save() end
	function GUI:LoadConfig() return CrackedLib.Config:Load() end
	function GUI:ClearConfig() return CrackedLib.Config:Clear() end
	function GUI:GetConfig() return CrackedLib.Config.Data end
	function GUI:Show() ScreenGui.Enabled = true playSound("Open") end
	function GUI:Hide() ScreenGui.Enabled = false end
	function GUI:RefreshAll() refreshAllThemes() end

	GUI.ScreenGui = ScreenGui
	GUI.Main = Main
	GUI.AvatarImage = AvatarImage
	CrackedLib._Active = CrackedLib._Active or {}
	CrackedLib._Active[GUI] = true
	print("[CrackedLib]", CrackedLib.Version, "loaded — sounds + avatar")
	return GUI
end

return CrackedLib
