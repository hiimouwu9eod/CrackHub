--[[
  CrackedLib v2.3.1
  Fix: SetTheme refreshes every registered element + section chips
]]

local CrackedLib = {}
CrackedLib.Version = "2.3.1"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

CrackedLib.Theme = {
	Default = {
		TextColor = Color3.fromRGB(240, 240, 240), Background = Color3.fromRGB(25, 25, 25),
		Topbar = Color3.fromRGB(34, 34, 34), Line = Color3.fromRGB(48, 48, 48), Navigation = Color3.fromRGB(30, 30, 30),
		TabBackground = Color3.fromRGB(80, 80, 80), TabStroke = Color3.fromRGB(85, 85, 85),
		TabBackgroundSelected = Color3.fromRGB(210, 210, 210), TabTextColor = Color3.fromRGB(240, 240, 240),
		SelectedTabTextColor = Color3.fromRGB(50, 50, 50), ElementBackground = Color3.fromRGB(45, 45, 45),
		ElementBackgroundHover = Color3.fromRGB(80, 80, 80), ElementStroke = Color3.fromRGB(80, 80, 80),
		ElementStrokeHover = Color3.fromRGB(100, 100, 100),
	},
	Light = {
		TextColor = Color3.fromRGB(30, 30, 30), Background = Color3.fromRGB(245, 245, 245),
		Topbar = Color3.fromRGB(230, 230, 230), Line = Color3.fromRGB(200, 200, 200), Navigation = Color3.fromRGB(235, 235, 235),
		TabBackground = Color3.fromRGB(220, 220, 220), TabStroke = Color3.fromRGB(180, 180, 180),
		TabBackgroundSelected = Color3.fromRGB(100, 100, 100), TabTextColor = Color3.fromRGB(40, 40, 40),
		SelectedTabTextColor = Color3.fromRGB(255, 255, 255), ElementBackground = Color3.fromRGB(255, 255, 255),
		ElementBackgroundHover = Color3.fromRGB(230, 230, 230), ElementStroke = Color3.fromRGB(200, 200, 200),
		ElementStrokeHover = Color3.fromRGB(160, 160, 160),
	},
	Purple = {
		TextColor = Color3.fromRGB(245, 245, 255), Background = Color3.fromRGB(28, 20, 48), Topbar = Color3.fromRGB(45, 30, 75),
		Line = Color3.fromRGB(130, 70, 220), Navigation = Color3.fromRGB(38, 25, 62), TabBackground = Color3.fromRGB(55, 35, 90),
		TabStroke = Color3.fromRGB(160, 90, 255), TabBackgroundSelected = Color3.fromRGB(190, 110, 255),
		TabTextColor = Color3.fromRGB(245, 245, 255), SelectedTabTextColor = Color3.fromRGB(30, 15, 55),
		ElementBackground = Color3.fromRGB(45, 30, 75), ElementBackgroundHover = Color3.fromRGB(80, 50, 130),
		ElementStroke = Color3.fromRGB(160, 90, 255), ElementStrokeHover = Color3.fromRGB(200, 130, 255),
	},
	Ocean = {
		TextColor = Color3.fromRGB(230, 245, 255), Background = Color3.fromRGB(15, 30, 55), Topbar = Color3.fromRGB(20, 45, 85),
		Line = Color3.fromRGB(70, 160, 240), Navigation = Color3.fromRGB(18, 38, 70), TabBackground = Color3.fromRGB(30, 60, 110),
		TabStroke = Color3.fromRGB(90, 180, 255), TabBackgroundSelected = Color3.fromRGB(110, 205, 255),
		TabTextColor = Color3.fromRGB(230, 245, 255), SelectedTabTextColor = Color3.fromRGB(10, 25, 50),
		ElementBackground = Color3.fromRGB(25, 50, 85), ElementBackgroundHover = Color3.fromRGB(50, 95, 160),
		ElementStroke = Color3.fromRGB(90, 180, 255), ElementStrokeHover = Color3.fromRGB(130, 215, 255),
	},
	Red = {
		TextColor = Color3.fromRGB(255, 235, 235), Background = Color3.fromRGB(35, 20, 20), Topbar = Color3.fromRGB(55, 25, 25),
		Line = Color3.fromRGB(220, 60, 60), Navigation = Color3.fromRGB(48, 22, 22), TabBackground = Color3.fromRGB(70, 30, 30),
		TabStroke = Color3.fromRGB(255, 90, 90), TabBackgroundSelected = Color3.fromRGB(255, 120, 120),
		TabTextColor = Color3.fromRGB(255, 235, 235), SelectedTabTextColor = Color3.fromRGB(45, 15, 15),
		ElementBackground = Color3.fromRGB(55, 25, 25), ElementBackgroundHover = Color3.fromRGB(90, 40, 40),
		ElementStroke = Color3.fromRGB(255, 100, 100), ElementStrokeHover = Color3.fromRGB(255, 150, 150),
	},
	Green = {
		TextColor = Color3.fromRGB(230, 255, 235), Background = Color3.fromRGB(15, 30, 20), Topbar = Color3.fromRGB(20, 50, 32),
		Line = Color3.fromRGB(50, 190, 90), Navigation = Color3.fromRGB(18, 38, 25), TabBackground = Color3.fromRGB(25, 60, 40),
		TabStroke = Color3.fromRGB(70, 220, 120), TabBackgroundSelected = Color3.fromRGB(110, 255, 160),
		TabTextColor = Color3.fromRGB(230, 255, 235), SelectedTabTextColor = Color3.fromRGB(10, 30, 18),
		ElementBackground = Color3.fromRGB(25, 55, 35), ElementBackgroundHover = Color3.fromRGB(45, 100, 65),
		ElementStroke = Color3.fromRGB(70, 220, 120), ElementStrokeHover = Color3.fromRGB(110, 255, 160),
	},
	Midnight = {
		TextColor = Color3.fromRGB(235, 235, 245), Background = Color3.fromRGB(16, 16, 26), Topbar = Color3.fromRGB(26, 26, 46),
		Line = Color3.fromRGB(75, 75, 120), Navigation = Color3.fromRGB(20, 20, 34), TabBackground = Color3.fromRGB(35, 35, 58),
		TabStroke = Color3.fromRGB(110, 110, 190), TabBackgroundSelected = Color3.fromRGB(145, 145, 255),
		TabTextColor = Color3.fromRGB(235, 235, 245), SelectedTabTextColor = Color3.fromRGB(20, 20, 40),
		ElementBackground = Color3.fromRGB(28, 28, 48), ElementBackgroundHover = Color3.fromRGB(55, 55, 85),
		ElementStroke = Color3.fromRGB(95, 95, 170), ElementStrokeHover = Color3.fromRGB(135, 135, 225),
	},
	Sakura = {
		TextColor = Color3.fromRGB(255, 235, 240), Background = Color3.fromRGB(45, 25, 35), Topbar = Color3.fromRGB(65, 35, 50),
		Line = Color3.fromRGB(255, 140, 180), Navigation = Color3.fromRGB(52, 29, 41), TabBackground = Color3.fromRGB(80, 45, 65),
		TabStroke = Color3.fromRGB(255, 160, 200), TabBackgroundSelected = Color3.fromRGB(255, 190, 220),
		TabTextColor = Color3.fromRGB(255, 235, 240), SelectedTabTextColor = Color3.fromRGB(60, 20, 40),
		ElementBackground = Color3.fromRGB(70, 40, 55), ElementBackgroundHover = Color3.fromRGB(100, 60, 80),
		ElementStroke = Color3.fromRGB(255, 170, 210), ElementStrokeHover = Color3.fromRGB(255, 200, 230),
	},
	Cyberpunk = {
		TextColor = Color3.fromRGB(200, 255, 240), Background = Color3.fromRGB(10, 8, 25), Topbar = Color3.fromRGB(25, 10, 60),
		Line = Color3.fromRGB(0, 255, 200), Navigation = Color3.fromRGB(14, 10, 38), TabBackground = Color3.fromRGB(35, 15, 80),
		TabStroke = Color3.fromRGB(0, 255, 220), TabBackgroundSelected = Color3.fromRGB(0, 230, 190),
		TabTextColor = Color3.fromRGB(200, 255, 240), SelectedTabTextColor = Color3.fromRGB(10, 5, 30),
		ElementBackground = Color3.fromRGB(20, 15, 55), ElementBackgroundHover = Color3.fromRGB(50, 30, 100),
		ElementStroke = Color3.fromRGB(0, 255, 200), ElementStrokeHover = Color3.fromRGB(120, 255, 220),
	},
}

local function fsAvailable()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

CrackedLib.Config = { Folder = "CrackedLib", FileName = "CrackedLib.json", Data = {} }

function CrackedLib.Config:GetPath()
	if type(makefolder) == "function" then
		return self.Folder .. "/" .. self.FileName
	end
	return self.FileName
end

function CrackedLib.Config:Save()
	if not fsAvailable() then return false end
	local path = self:GetPath()
	pcall(function()
		if type(makefolder) == "function" then
			if type(isfolder) ~= "function" or not isfolder(self.Folder) then
				makefolder(self.Folder)
			end
		end
	end)
	local ok = pcall(function()
		writefile(path, HttpService:JSONEncode(self.Data))
	end)
	return ok
end

function CrackedLib.Config:Load()
	if not fsAvailable() then return false end
	local path = self:GetPath()
	local exists = false
	pcall(function() exists = isfile(path) end)
	if not exists then self.Data = {} return false end
	local ok, result = pcall(function()
		local raw = readfile(path)
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

local function destroyElement(data)
	if not data then return end
	if data._frame and data._frame.Parent then
		data._frame:Destroy()
	end
	if data._connections then
		disconnectAll(data._connections)
	end
	data._destroyed = true
end

local function copyText(text)
	if type(setclipboard) == "function" then
		return pcall(setclipboard, text)
	end
	return false
end

function CrackedLib:Init(name, draggable, keybind, theme, keysystem)
	local GUI = {}
	local CurrentTheme = self.Theme[theme] or self.Theme.Default
	self.CurrentTheme = CurrentTheme
	CrackedLib.CurrentTheme = CurrentTheme

	local themedElements = {}
	local sectionButtonInfos = {}

	local function registerTheme(data)
		if data and type(data.RefreshTheme) == "function" then
			table.insert(themedElements, data)
		end
		return data
	end

	local function refreshAllThemes()
		for i = #themedElements, 1, -1 do
			local data = themedElements[i]
			if not data or data._destroyed then
				table.remove(themedElements, i)
			else
				pcall(function() data:RefreshTheme() end)
			end
		end
		for _, item in ipairs(sectionButtonInfos) do
			pcall(function()
				local active = item.IsActive and item.IsActive() or false
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
			return nil
		end)
		if ok and hui then return hui end
		local cg = game:GetService("CoreGui")
		if cg then
			local ok2 = pcall(function()
				local t = Instance.new("Folder")
				t.Parent = cg
				t:Destroy()
			end)
			if ok2 then return cg end
		end
		return LocalPlayer:WaitForChild("PlayerGui")
	end

	local GuiParent = getGuiParent()
	local connections = {}
	local destroyed = false

	for _, parent in ipairs({ GuiParent, game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }) do
		if parent then
			local old = parent:FindFirstChild("CrackLib")
			if old then pcall(function() old:Destroy() end) end
			local oldKey = parent:FindFirstChild("KeySystem")
			if oldKey then pcall(function() oldKey:Destroy() end) end
		end
	end

	-- Key system
	if type(keysystem) == "table" and keysystem.Enabled then
		local Key = tostring(keysystem.Key or "")
		local CopyLink = tostring(keysystem.copyLink or "")
		local KeyPassed, Cancelled = false, false

		local KeySystem = Instance.new("ScreenGui")
		KeySystem.Name = "KeySystem"
		KeySystem.ResetOnSpawn = false
		KeySystem.IgnoreGuiInset = true
		KeySystem.DisplayOrder = 999999
		KeySystem.Parent = GuiParent

		local KM = Instance.new("Frame")
		KM.Size = UDim2.fromScale(0.49, 0.36)
		KM.Position = UDim2.fromScale(0.255, 0.32)
		KM.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		KM.BorderSizePixel = 0
		KM.Parent = KeySystem
		makeCorner(KM, 10)
		makeStroke(KM, Color3.fromRGB(82, 82, 82), 3)

		local ktitle = Instance.new("TextLabel")
		ktitle.BackgroundTransparency = 1
		ktitle.Position = UDim2.fromScale(0.05, 0.08)
		ktitle.Size = UDim2.fromScale(0.9, 0.16)
		ktitle.Font = Enum.Font.SourceSansBold
		ktitle.Text = tostring(keysystem.Title or "Cracked Hub Key")
		ktitle.TextColor3 = Color3.new(1, 1, 1)
		ktitle.TextScaled = true
		ktitle.Parent = KM

		local box = Instance.new("TextBox")
		box.Position = UDim2.fromScale(0.18, 0.40)
		box.Size = UDim2.fromScale(0.64, 0.14)
		box.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
		box.BorderSizePixel = 0
		box.PlaceholderText = "Enter Key"
		box.Text = ""
		box.TextColor3 = Color3.new(1, 1, 1)
		box.TextScaled = true
		box.Parent = KM
		makeCorner(box, 8)

		local loadBtn = Instance.new("TextButton")
		loadBtn.Position = UDim2.fromScale(0.70, 0.66)
		loadBtn.Size = UDim2.fromScale(0.25, 0.20)
		loadBtn.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
		loadBtn.BorderSizePixel = 0
		loadBtn.Text = "Load Key"
		loadBtn.TextColor3 = Color3.new(1, 1, 1)
		loadBtn.TextScaled = true
		loadBtn.Parent = KM
		makeCorner(loadBtn, 8)

		local link = Instance.new("TextButton")
		link.Position = UDim2.fromScale(0.05, 0.66)
		link.Size = UDim2.fromScale(0.25, 0.20)
		link.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
		link.BorderSizePixel = 0
		link.Text = "Copy Link"
		link.TextColor3 = Color3.new(1, 1, 1)
		link.TextScaled = true
		link.Parent = KM
		makeCorner(link, 8)

		local notice = Instance.new("TextLabel")
		notice.BackgroundTransparency = 1
		notice.Position = UDim2.fromScale(0.30, 0.66)
		notice.Size = UDim2.fromScale(0.40, 0.20)
		notice.Text = ""
		notice.TextColor3 = Color3.new(1, 1, 1)
		notice.TextScaled = true
		notice.Parent = KM

		local close = Instance.new("TextButton")
		close.BackgroundTransparency = 1
		close.Position = UDim2.fromScale(0.90, 0.04)
		close.Size = UDim2.fromScale(0.06, 0.10)
		close.Text = "×"
		close.TextColor3 = Color3.new(1, 1, 1)
		close.TextScaled = true
		close.Parent = KM

		local function checkKey()
			if box.Text:gsub("%s+", "") == Key then
				KeyPassed = true
				task.delay(0.2, function()
					if KeySystem.Parent then KeySystem:Destroy() end
				end)
			else
				notice.Text = "Wrong Key!"
				notice.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
		end

		connectAndTrack(connections, loadBtn.MouseButton1Click, checkKey)
		connectAndTrack(connections, box.FocusLost, function(ep) if ep then checkKey() end end)
		connectAndTrack(connections, link.MouseButton1Click, function()
			if CopyLink ~= "" then copyText(CopyLink) end
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

	-- Main UI
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CrackLib"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999
	ScreenGui.Parent = GuiParent

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.fromScale(0.51, 0.54)
	Main.Position = UDim2.fromScale(0.245, 0.228)
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

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 14, 0, 7)
	title.Size = UDim2.new(0.68, 0, 1, -14)
	title.Font = Enum.Font.SourceSansBold
	title.Text = tostring(name or "CrackedLib")
	title.TextColor3 = CurrentTheme.TextColor
	title.TextScaled = true
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = Topbar

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

	local Navigation = Instance.new("Frame")
	Navigation.Position = UDim2.new(0, 0, 0, 52)
	Navigation.Size = UDim2.new(0.255, 0, 1, -52)
	Navigation.BackgroundColor3 = CurrentTheme.Navigation
	Navigation.BorderSizePixel = 0
	Navigation.Parent = Main
	makeCorner(Navigation, 8)

	local ButtonHolder = Instance.new("ScrollingFrame")
	ButtonHolder.Size = UDim2.fromScale(1, 1)
	ButtonHolder.BackgroundTransparency = 1
	ButtonHolder.BorderSizePixel = 0
	ButtonHolder.ScrollBarThickness = 0
	ButtonHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ButtonHolder.CanvasSize = UDim2.new()
	ButtonHolder.Parent = Navigation

	local NavLayout = Instance.new("UIListLayout")
	NavLayout.Padding = UDim.new(0, 6)
	NavLayout.Parent = ButtonHolder
	local NavPadding = Instance.new("UIPadding")
	NavPadding.PaddingTop = UDim.new(0, 8)
	NavPadding.PaddingLeft = UDim.new(0, 8)
	NavPadding.PaddingRight = UDim.new(0, 8)
	NavPadding.Parent = ButtonHolder

	local Divider = Instance.new("Frame")
	Divider.Position = UDim2.new(1, -2, 0, 0)
	Divider.Size = UDim2.new(0, 2, 1, 0)
	Divider.BackgroundColor3 = CurrentTheme.Line
	Divider.BorderSizePixel = 0
	Divider.Parent = Navigation

	local TabHolder = Instance.new("Frame")
	TabHolder.Position = UDim2.new(0.255, 0, 0, 52)
	TabHolder.Size = UDim2.new(0.745, 0, 1, -52)
	TabHolder.BackgroundTransparency = 1
	TabHolder.Parent = Main

	local TabContent = Instance.new("Folder")
	TabContent.Parent = TabHolder

	local tabs = {}
	local selectedTab

	local function selectTab(tabInfo)
		selectedTab = tabInfo
		for _, info in ipairs(tabs) do
			local active = info == tabInfo
			info.Content.Visible = active
			info.Button.BackgroundColor3 = active and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabBackground
			info.Button.TextColor3 = active and CurrentTheme.SelectedTabTextColor or CurrentTheme.TabTextColor
			info.Stroke.Color = active and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabStroke
		end
	end

	function GUI:CreateTab(text)
		local TabData = {}
		local info = {}
		local Tab = Instance.new("TextButton")
		Tab.Size = UDim2.new(1, 0, 0, 38)
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
		content.Size = UDim2.fromScale(1, 1)
		content.BackgroundColor3 = CurrentTheme.Background
		content.BorderSizePixel = 0
		content.Visible = false
		content.Parent = TabContent

		info.Button, info.Content, info.Stroke = Tab, content, stroke
		table.insert(tabs, info)
		connectAndTrack(connections, Tab.MouseButton1Click, function() selectTab(info) end)
		if not selectedTab then selectTab(info) end

		local sectionBar = Instance.new("Frame")
		sectionBar.Size = UDim2.new(1, 0, 0, 46)
		sectionBar.BackgroundTransparency = 1
		sectionBar.Parent = content

		local sectionLayout = Instance.new("UIListLayout")
		sectionLayout.FillDirection = Enum.FillDirection.Horizontal
		sectionLayout.Padding = UDim.new(0, 8)
		sectionLayout.Parent = sectionBar
		local sectionPadding = Instance.new("UIPadding")
		sectionPadding.PaddingLeft = UDim.new(0, 8)
		sectionPadding.PaddingRight = UDim.new(0, 8)
		sectionPadding.Parent = sectionBar

		local sectionPages = Instance.new("Frame")
		sectionPages.Position = UDim2.new(0, 0, 0, 46)
		sectionPages.Size = UDim2.new(1, 0, 1, -46)
		sectionPages.BackgroundTransparency = 1
		sectionPages.Parent = content

		local sectionTabs = {}
		local selectedSection

		local function selectSection(s)
			selectedSection = s
			for _, item in ipairs(sectionTabs) do
				local active = item == s
				item.Page.Visible = active
				item.Button.BackgroundColor3 = active and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabBackground
				item.Button.TextColor3 = active and CurrentTheme.SelectedTabTextColor or CurrentTheme.TabTextColor
				item.Stroke.Color = active and CurrentTheme.TabBackgroundSelected or CurrentTheme.TabStroke
			end
		end

		function TabData:Section(sectionName)
			local SectionData = {}
			local displayName = tostring(sectionName or "Section")

			local secBtn = Instance.new("TextButton")
			secBtn.Size = UDim2.new(0, 100, 0, 32)
			secBtn.AutomaticSize = Enum.AutomaticSize.X
			secBtn.BackgroundColor3 = CurrentTheme.TabBackground
			secBtn.BorderSizePixel = 0
			secBtn.Text = "  " .. displayName .. "  "
			secBtn.TextColor3 = CurrentTheme.TabTextColor
			secBtn.TextScaled = true
			secBtn.AutoButtonColor = false
			secBtn.Parent = sectionBar
			makeCorner(secBtn, 6)
			local secStroke = makeStroke(secBtn, CurrentTheme.TabStroke, 2)

			local page = Instance.new("ScrollingFrame")
			page.Size = UDim2.fromScale(1, 1)
			page.BackgroundColor3 = CurrentTheme.Background
			page.BorderSizePixel = 0
			page.ScrollBarThickness = 4
			page.ScrollBarImageColor3 = CurrentTheme.Line
			page.AutomaticCanvasSize = Enum.AutomaticSize.Y
			page.CanvasSize = UDim2.new()
			page.Visible = false
			page.Parent = sectionPages

			local pageLayout = Instance.new("UIListLayout")
			pageLayout.Padding = UDim.new(0, 8)
			pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
			pageLayout.Parent = page
			local pagePad = Instance.new("UIPadding")
			pagePad.PaddingTop = UDim.new(0, 8)
			pagePad.PaddingLeft = UDim.new(0, 10)
			pagePad.PaddingRight = UDim.new(0, 10)
			pagePad.PaddingBottom = UDim.new(0, 12)
			pagePad.Parent = page

			local secRef = { Button = secBtn, Stroke = secStroke, Page = page }
			table.insert(sectionTabs, secRef)
			table.insert(sectionButtonInfos, {
				Button = secBtn,
				Stroke = secStroke,
				Page = page,
				IsActive = function()
					return selectedSection == secRef
				end,
			})

			connectAndTrack(connections, secBtn.MouseButton1Click, function()
				selectSection(secRef)
			end)
			if not selectedSection then selectSection(secRef) end

			-- ========== TOGGLE ==========
			function SectionData:Toggle(label, default, callback)
				local data = { Value = default == true, _connections = {} }
				local f = Instance.new("TextButton")
				f.Size = UDim2.new(1, 0, 0, 45)
				f.BackgroundColor3 = CurrentTheme.ElementBackground
				f.BorderSizePixel = 0
				f.Text = ""
				f.AutoButtonColor = false
				f.Parent = page
				makeCorner(f, 8)
				local fs = makeStroke(f, CurrentTheme.ElementStroke, 2)
				data._frame = f

				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 24, 0, 0)
				t.Size = UDim2.new(1, -90, 1, 0)
				t.Text = tostring(label or "Toggle")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f

				local knob = Instance.new("Frame")
				knob.AnchorPoint = Vector2.new(1, 0.5)
				knob.Position = UDim2.new(1, -16, 0.5, 0)
				knob.Size = UDim2.fromOffset(44, 24)
				knob.BorderSizePixel = 0
				knob.Parent = f
				makeCorner(knob, 12)
				local ks = makeStroke(knob, CurrentTheme.ElementStroke, 1)

				local dot = Instance.new("Frame")
				dot.Size = UDim2.fromOffset(18, 18)
				dot.AnchorPoint = Vector2.new(0, 0.5)
				dot.BorderSizePixel = 0
				dot.BackgroundColor3 = Color3.new(1, 1, 1)
				dot.Parent = knob
				makeCorner(dot, 9)

				local function paint()
					knob.BackgroundColor3 = data.Value and CurrentTheme.TabBackgroundSelected or CurrentTheme.Background
					dot.Position = data.Value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
				end
				paint()

				local function set(v, fire)
					data.Value = v and true or false
					paint()
					if fire and callback then task.spawn(callback, data.Value) end
				end

				connectAndTrack(data._connections, f.MouseButton1Click, function()
					set(not data.Value, true)
				end)
				connectAndTrack(data._connections, f.MouseEnter, function()
					f.BackgroundColor3 = CurrentTheme.ElementBackgroundHover
				end)
				connectAndTrack(data._connections, f.MouseLeave, function()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
				end)

				function data:Set(v) set(v, true) end
				function data:Get() return data.Value end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					ks.Color = CurrentTheme.ElementStroke
					paint()
				end
				return registerTheme(data)
			end

			function SectionData:ConfigToggle(label, default, callback, key)
				local cfgKey = key or label
				local saved = CrackedLib.Config.Data[cfgKey]
				local start = saved ~= nil and (saved == true) or (default == true)
				local data = self:Toggle(label, start, function(v)
					CrackedLib.Config.Data[cfgKey] = v
					CrackedLib.Config:Save()
					if callback then callback(v) end
				end)
				return data
			end

			-- ========== BUTTON ==========
			function SectionData:Button(label, callback)
				local data = { _connections = {} }
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, 0, 0, 45)
				b.BackgroundColor3 = CurrentTheme.ElementBackground
				b.BorderSizePixel = 0
				b.Text = tostring(label or "Button")
				b.TextColor3 = CurrentTheme.TextColor
				b.TextScaled = true
				b.AutoButtonColor = false
				b.Parent = page
				makeCorner(b, 8)
				local bs = makeStroke(b, CurrentTheme.ElementStroke, 2)
				data._frame = b

				connectAndTrack(data._connections, b.MouseButton1Click, function()
					if callback then task.spawn(callback) end
				end)
				connectAndTrack(data._connections, b.MouseEnter, function()
					b.BackgroundColor3 = CurrentTheme.ElementBackgroundHover
				end)
				connectAndTrack(data._connections, b.MouseLeave, function()
					b.BackgroundColor3 = CurrentTheme.ElementBackground
				end)

				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					b.BackgroundColor3 = CurrentTheme.ElementBackground
					b.TextColor3 = CurrentTheme.TextColor
					bs.Color = CurrentTheme.ElementStroke
				end
				return registerTheme(data)
			end

			-- ========== LABEL ==========
			function SectionData:Label(text)
				local data = { _connections = {} }
				local f = Instance.new("Frame")
				f.Size = UDim2.new(1, 0, 0, 36)
				f.BackgroundColor3 = CurrentTheme.ElementBackground
				f.BorderSizePixel = 0
				f.Parent = page
				makeCorner(f, 8)
				local fs = makeStroke(f, CurrentTheme.ElementStroke, 2)
				data._frame = f

				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Size = UDim2.new(1, -24, 1, 0)
				t.Position = UDim2.new(0, 12, 0, 0)
				t.Text = tostring(text or "")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = f

				function data:SetText(v) t.Text = tostring(v) end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			function SectionData:Paragraph(text)
				return self:Label(text)
			end

			-- ========== SEPARATOR ==========
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
				function data:RefreshTheme()
					line.BackgroundColor3 = CurrentTheme.Line
				end
				return registerTheme(data)
			end

			-- ========== DROPDOWN ==========
			function SectionData:Dropdown(label, options, callback, multi)
				options = type(options) == "table" and options or {}
				multi = multi == true
				local data = {
					Open = false,
					Value = nil,
					Values = {},
					_connections = {},
				}
				local buttons = {}

				local f = Instance.new("Frame")
				f.Size = UDim2.new(1, 0, 0, 45)
				f.BackgroundColor3 = CurrentTheme.ElementBackground
				f.BorderSizePixel = 0
				f.ClipsDescendants = true
				f.Parent = page
				makeCorner(f, 8)
				local fs = makeStroke(f, CurrentTheme.ElementStroke, 2)
				data._frame = f

				local txt = Instance.new("TextLabel")
				txt.BackgroundTransparency = 1
				txt.Position = UDim2.new(0, 24, 0, 0)
				txt.Size = UDim2.new(1, -64, 0, 45)
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
				arrow.AutoButtonColor = false
				arrow.Parent = f

				local list = Instance.new("Frame")
				list.Position = UDim2.new(0, 0, 0, 45)
				list.Size = UDim2.new(1, 0, 0, 0)
				list.BackgroundColor3 = CurrentTheme.Background
				list.BorderSizePixel = 0
				list.Parent = f
				local ll = Instance.new("UIListLayout")
				ll.Parent = list

				local function selectedText()
					if multi then
						local on = {}
						for _, o in ipairs(options) do
							if data.Values[o] then table.insert(on, tostring(o)) end
						end
						if #on == 0 then return tostring(label or "Dropdown") end
						return table.concat(on, ", ")
					end
					return data.Value and tostring(data.Value) or tostring(label or "Dropdown")
				end

				local function refreshSize()
					local count = #options
					list.Size = UDim2.new(1, 0, 0, data.Open and count * 36 or 0)
					f.Size = UDim2.new(1, 0, 0, data.Open and 45 + count * 36 or 45)
					arrow.Text = data.Open and "▲" or "▼"
				end

				local function clearButtons()
					for _, item in ipairs(buttons) do
						if item.Row then item.Row:Destroy() end
					end
					table.clear(buttons)
				end

				local function buildButtons()
					clearButtons()
					for _, option in ipairs(options) do
						local row = Instance.new("TextButton")
						row.Size = UDim2.new(1, 0, 0, 36)
						row.BackgroundColor3 = CurrentTheme.ElementBackground
						row.BorderSizePixel = 0
						row.Text = tostring(option)
						row.TextColor3 = CurrentTheme.TextColor
						row.TextScaled = true
						row.AutoButtonColor = false
						row.Parent = list

						connectAndTrack(data._connections, row.MouseButton1Click, function()
							if multi then
								data.Values[option] = not data.Values[option]
							else
								data.Value = option
								data.Open = false
							end
							txt.Text = selectedText()
							refreshSize()
							if callback then
								task.spawn(callback, multi and data.Values or data.Value)
							end
						end)
						table.insert(buttons, { Row = row })
					end
					refreshSize()
					txt.Text = selectedText()
				end

				buildButtons()

				connectAndTrack(data._connections, arrow.MouseButton1Click, function()
					data.Open = not data.Open
					refreshSize()
				end)

				function data:Set(value)
					if multi then
						data.Values = {}
						if type(value) == "table" then
							for _, o in ipairs(options) do
								if value[o] == true or table.find(value, o) then
									data.Values[o] = true
								end
							end
						end
					else
						data.Value = value
					end
					txt.Text = selectedText()
					if callback then task.spawn(callback, multi and data.Values or data.Value) end
				end
				function data:Get() return multi and data.Values or data.Value end
				function data:Refresh(newOptions, keep)
					options = type(newOptions) == "table" and newOptions or {}
					if not keep then data.Value = nil data.Values = {} end
					buildButtons()
				end
				function data:ChangeOptions(n, k) self:Refresh(n, k) end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					f.BackgroundColor3 = CurrentTheme.ElementBackground
					fs.Color = CurrentTheme.ElementStroke
					txt.TextColor3 = CurrentTheme.TextColor
					arrow.TextColor3 = CurrentTheme.TextColor
					list.BackgroundColor3 = CurrentTheme.Background
					for _, item in ipairs(buttons) do
						if item.Row then
							item.Row.BackgroundColor3 = CurrentTheme.ElementBackground
							item.Row.TextColor3 = CurrentTheme.TextColor
						end
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
					task.defer(function() if data then data:Set(saved) end end)
				end
				return data
			end

			-- ========== KEYBIND ==========
			function SectionData:Keybind(label, defaultKey, callback)
				local data = {
					Key = defaultKey or Enum.KeyCode.Unknown,
					Listening = false,
					_connections = {},
				}
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, 0, 0, 45)
				b.BackgroundColor3 = CurrentTheme.ElementBackground
				b.BorderSizePixel = 0
				b.Text = ""
				b.AutoButtonColor = false
				b.Parent = page
				makeCorner(b, 8)
				local bs = makeStroke(b, CurrentTheme.ElementStroke, 2)
				data._frame = b

				local t = Instance.new("TextLabel")
				t.BackgroundTransparency = 1
				t.Position = UDim2.new(0, 24, 0, 0)
				t.Size = UDim2.new(0.55, 0, 1, 0)
				t.Text = tostring(label or "Keybind")
				t.TextColor3 = CurrentTheme.TextColor
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.Parent = b

				local keyLabel = Instance.new("TextLabel")
				keyLabel.BackgroundTransparency = 1
				keyLabel.Position = UDim2.new(0.58, 0, 0, 0)
				keyLabel.Size = UDim2.new(0.38, 0, 1, 0)
				keyLabel.Text = data.Key.Name
				keyLabel.TextColor3 = CurrentTheme.TextColor
				keyLabel.TextScaled = true
				keyLabel.TextXAlignment = Enum.TextXAlignment.Right
				keyLabel.Parent = b

				local function updateText()
					keyLabel.Text = data.Listening and "..." or data.Key.Name
				end

				connectAndTrack(data._connections, b.MouseButton1Click, function()
					data.Listening = true
					updateText()
				end)
				connectAndTrack(data._connections, UserInputService.InputBegan, function(input)
					if not data.Listening then return end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						data.Key = input.KeyCode
						data.Listening = false
						updateText()
						if callback then task.spawn(callback, data.Key) end
					end
				end)

				function data:Set(key)
					if typeof(key) == "EnumItem" then
						data.Key = key
						updateText()
					end
				end
				function data:Get() return data.Key end
				function data:Destroy() destroyElement(data) end
				function data:RefreshTheme()
					b.BackgroundColor3 = CurrentTheme.ElementBackground
					bs.Color = CurrentTheme.ElementStroke
					t.TextColor3 = CurrentTheme.TextColor
					keyLabel.TextColor3 = CurrentTheme.TextColor
				end
				return registerTheme(data)
			end

			-- ========== TOGGLE LIST ==========
			function SectionData:ToggleList(label, options, callback, defaults)
				options = type(options) == "table" and options or {}
				defaults = type(defaults) == "table" and defaults or {}
				local data = { Open = false, States = {}, _connections = {} }
				local rowItems = {}

				for _, o in ipairs(options) do
					data.States[o] = defaults[o] == true
				end

				local f = Instance.new("Frame")
				f.Size = UDim2.new(1, 0, 0, 45)
				f.BackgroundColor3 = CurrentTheme.ElementBackground
				f.BorderSizePixel = 0
				f.ClipsDescendants = true
				f.Parent = page
				makeCorner(f, 8)
				local fs = makeStroke(f, CurrentTheme.ElementStroke, 2)
				data._frame = f

				local txt = Instance.new("TextLabel")
				txt.BackgroundTransparency = 1
				txt.Position = UDim2.new(0, 24, 0, 0)
				txt.Size = UDim2.new(1, -64, 0, 45)
				txt.Text = tostring(label or "Toggles")
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
				arrow.AutoButtonColor = false
				arrow.Parent = f

				local list = Instance.new("Frame")
				list.Position = UDim2.new(0, 0, 0, 45)
				list.Size = UDim2.new(1, 0, 0, 0)
				list.BackgroundColor3 = CurrentTheme.Background
				list.BorderSizePixel = 0
				list.Parent = f
				Instance.new("UIListLayout").Parent = list

				local function refreshSize()
					local n = #options
					list.Size = UDim2.new(1, 0, 0, data.Open and n * 40 or 0)
					f.Size = UDim2.new(1, 0, 0, data.Open and 45 + n * 40 or 45)
					arrow.Text = data.Open and "▲" or "▼"
				end

				local function build()
					for _, item in ipairs(rowItems) do
						if item.Row then item.Row:Destroy() end
					end
					table.clear(rowItems)
					for _, option in ipairs(options) do
						local row = Instance.new("TextButton")
						row.Size = UDim2.new(1, 0, 0, 40)
						row.BackgroundColor3 = CurrentTheme.ElementBackground
						row.BorderSizePixel = 0
						row.Text = ""
						row.AutoButtonColor = false
						row.Parent = list

						local name = Instance.new("TextLabel")
						name.BackgroundTransparency = 1
						name.Position = UDim2.new(0, 12, 0, 0)
						name.Size = UDim2.new(1, -70, 1, 0)
						name.Text = tostring(option)
						name.TextColor3 = CurrentTheme.TextColor
						name.TextScaled = true
						name.TextXAlignment = Enum.TextXAlignment.Left
						name.Parent = row

						local knob = Instance.new("Frame")
						knob.AnchorPoint = Vector2.new(1, 0.5)
						knob.Position = UDim2.new(1, -12, 0.5, 0)
						knob.Size = UDim2.fromOffset(42, 22)
						knob.BorderSizePixel = 0
						knob.Parent = row
						makeCorner(knob, 11)

						local dot = Instance.new("Frame")
						dot.Size = UDim2.fromOffset(16, 16)
						dot.AnchorPoint = Vector2.new(0, 0.5)
						dot.BorderSizePixel = 0
						dot.BackgroundColor3 = Color3.new(1, 1, 1)
						dot.Parent = knob
						makeCorner(dot, 8)

						local function paint()
							local on = data.States[option] == true
							knob.BackgroundColor3 = on and CurrentTheme.TabBackgroundSelected or CurrentTheme.Background
							dot.Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
						end
						paint()

						connectAndTrack(data._connections, row.MouseButton1Click, function()
							data.States[option] = not data.States[option]
							paint()
							if callback then
								task.spawn(callback, option, data.States[option], data.States)
							end
						end)
						table.insert(rowItems, { Row = row, Name = name, Knob = knob, Paint = paint })
					end
					refreshSize()
				end
				build()

				connectAndTrack(data._connections, arrow.MouseButton1Click, function()
					data.Open = not data.Open
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
					for _, item in ipairs(rowItems) do
						if item.Row then item.Row.BackgroundColor3 = CurrentTheme.ElementBackground end
						if item.Name then item.Name.TextColor3 = CurrentTheme.TextColor end
						if item.Paint then item.Paint() end
					end
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
		Topbar.BackgroundColor3 = t.Topbar
		Line.BackgroundColor3 = t.Line
		Navigation.BackgroundColor3 = t.Navigation
		Main.BackgroundColor3 = t.Background
		MainStroke.Color = t.ElementStroke
		Minus.TextColor3 = t.TextColor
		Exit.TextColor3 = t.TextColor
		Divider.BackgroundColor3 = t.Line

		for _, info in ipairs(tabs) do
			local active = info == selectedTab
			info.Button.BackgroundColor3 = active and t.TabBackgroundSelected or t.TabBackground
			info.Button.TextColor3 = active and t.SelectedTabTextColor or t.TabTextColor
			info.Stroke.Color = active and t.TabBackgroundSelected or t.TabStroke
			info.Content.BackgroundColor3 = t.Background
		end

		refreshAllThemes()
		return true
	end

	function GUI:Notify(nTitle, content, duration)
		duration = duration or 4
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
		nt.Text = tostring(nTitle or "Notification")
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
		nc.TextWrapped = true
		nc.TextXAlignment = Enum.TextXAlignment.Left
		nc.Parent = notif

		task.delay(duration, function()
			if notif.Parent then notif:Destroy() end
		end)
	end

	GUI.ScreenGui = ScreenGui
	GUI.Main = Main

	if draggable then
		local dragging, dragStart, startPos = false, nil, nil
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
				Main.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y
				)
			end
		end)
	end

	if keybind then
		connectAndTrack(connections, UserInputService.InputBegan, function(input, processed)
			if not processed and input.KeyCode == keybind and not destroyed then
				ScreenGui.Enabled = not ScreenGui.Enabled
			end
		end)
	end

	function GUI:Destroy()
		if destroyed then return end
		destroyed = true
		disconnectAll(connections)
		table.clear(themedElements)
		table.clear(sectionButtonInfos)
		if ScreenGui then ScreenGui:Destroy() end
	end

	local minimized = false
	local normalSize = Main.Size
	connectAndTrack(connections, Exit.MouseButton1Click, function() GUI:Destroy() end)
	connectAndTrack(connections, Minus.MouseButton1Click, function()
		minimized = not minimized
		Navigation.Visible = not minimized
		TabHolder.Visible = not minimized
		Line.Visible = not minimized
		Main.Size = minimized and UDim2.new(normalSize.X.Scale, normalSize.X.Offset, 0, 52) or normalSize
		Minus.Text = minimized and "+" or "−"
	end)

	function GUI:SaveConfig() return CrackedLib.Config:Save() end
	function GUI:LoadConfig() return CrackedLib.Config:Load() end
	function GUI:ClearConfig() return CrackedLib.Config:Clear() end
	function GUI:GetConfig() return CrackedLib.Config.Data end
	function GUI:Show() ScreenGui.Enabled = true end
	function GUI:Hide() ScreenGui.Enabled = false end

	print("[CrackedLib]", CrackedLib.Version, "loaded")
	return GUI
end

return CrackedLib
