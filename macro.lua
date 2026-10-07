if getgenv().CracksMacro_Running then
	return
end
getgenv().CracksMacro_Running = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local FOLDER = "CracksMacros"
local FILE = FOLDER .. "/macros.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/macro.lua"

local Macros = {}
local CurrentName = nil
local Recording = false
local Playing = false
local RecordBuf = {}
local RecStart = 0
local PlayToken = 0
local Connections = {}
local LastMouseRec = Vector2.zero

local Opt = {
	RecordCamera = true,
	PlayCamera = true,
	RecordMove = true,
	PlayMove = true,
	RecordKeys = true,
	PlayKeys = true,
	RecordMouse = true,
	PlayMouse = true,
	MoveDist = 1.25,
	CamDist = 0.12,
	CamDot = 0.998,
	MouseMoveDist = 2,
}

local KeyRecord = Enum.KeyCode.R
local KeyPlay = Enum.KeyCode.P
local KeyStop = Enum.KeyCode.X

local MouseBtnMap = {
	[Enum.UserInputType.MouseButton1] = 0,
	[Enum.UserInputType.MouseButton2] = 1,
	[Enum.UserInputType.MouseButton3] = 2,
}

local function safe(fn, ...)
	local ok, a, b, c = pcall(fn, ...)
	if ok then
		return a, b, c
	end
	return nil
end

local function cam()
	return workspace.CurrentCamera
end

local function getRoot()
	local c = LocalPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
	local c = LocalPlayer.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function getMousePos()
	local p = safe(function()
		return UIS:GetMouseLocation()
	end)
	if p then
		return p.X, p.Y
	end
	return Mouse.X, Mouse.Y
end

local function moveMouseTo(x, y)
	x = tonumber(x) or 0
	y = tonumber(y) or 0

	-- 1) VirtualInputManager
	safe(function()
		VIM:SendMouseMoveEvent(x, y, game)
	end)

	-- 2) some executors
	safe(function()
		if mousemoveabs then
			mousemoveabs(x, y)
		end
	end)
	safe(function()
		if syn and syn.mousemoveabs then
			syn.mousemoveabs(x, y)
		end
	end)
	safe(function()
		if mouse_move then
			mouse_move(x, y)
		end
	end)

	-- 3) force InputChanged-style by tiny jitter then set
	safe(function()
		VIM:SendMouseMoveEvent(x + 0.01, y + 0.01, game)
		VIM:SendMouseMoveEvent(x, y, game)
	end)
end

local function mouseButton(x, y, btn, down)
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	btn = tonumber(btn) or 0
	moveMouseTo(x, y)
	task.wait()
	safe(function()
		VIM:SendMouseButtonEvent(x, y, btn, down == true, game, 0)
	end)
	safe(function()
		if down then
			if btn == 0 and mouse1click then
				-- don't full click if we send down/up separately
			end
		end
	end)
	safe(function()
		if down and mouse1press and btn == 0 then
			mouse1press()
		elseif not down and mouse1release and btn == 0 then
			mouse1release()
		end
		if down and mouse2press and btn == 1 then
			mouse2press()
		elseif not down and mouse2release and btn == 1 then
			mouse2release()
		end
	end)
end

local function ensureFolder()
	safe(function()
		if isfolder and not isfolder(FOLDER) then
			makefolder(FOLDER)
		end
	end)
end

local function loadDisk()
	ensureFolder()
	local data = safe(function()
		if isfile and isfile(FILE) then
			return HttpService:JSONDecode(readfile(FILE))
		end
	end)
	if type(data) == "table" then
		Macros = data
	else
		Macros = type(getgenv().CracksMacro_Data) == "table" and getgenv().CracksMacro_Data or {}
	end
	getgenv().CracksMacro_Data = Macros
end

local function saveDisk()
	ensureFolder()
	getgenv().CracksMacro_Data = Macros
	safe(function()
		if writefile then
			writefile(FILE, HttpService:JSONEncode(Macros))
		end
	end)
end

local function namesList()
	local t = {}
	for n in pairs(Macros) do
		table.insert(t, tostring(n))
	end
	table.sort(t)
	if #t == 0 then
		table.insert(t, "(none)")
	end
	return t
end

local function stamp()
	return tick() - RecStart
end

local function pushEvent(ev)
	if not Recording or type(ev) ~= "table" then
		return
	end
	ev.t = stamp()
	table.insert(RecordBuf, ev)
end

local function cfToTable(cf)
	local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
	return { x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 }
end

local function tableToCf(t)
	if type(t) ~= "table" or #t < 12 then
		return nil
	end
	return CFrame.new(t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12])
end

local function keycodeFromName(name)
	local ok, k = pcall(function()
		return Enum.KeyCode[name]
	end)
	if ok then
		return k
	end
	return nil
end

local function startRecord()
	if Playing then
		return
	end
	Recording = true
	RecordBuf = {}
	RecStart = tick()
	local x, y = getMousePos()
	LastMouseRec = Vector2.new(x, y)
	pushEvent({ k = "mouse", x = x, y = y, move = true })
	print("[Macro] REC start")
end

local function stopRecord()
	Recording = false
	print("[Macro] REC stop events=", #RecordBuf)
end

local function stopPlay()
	PlayToken += 1
	Playing = false
end

local function saveCurrent(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" or name == "(none)" then
		print("[Macro] bad name")
		return false
	end
	if #RecordBuf == 0 and not Macros[name] then
		print("[Macro] empty buffer")
		return false
	end
	if #RecordBuf > 0 then
		Macros[name] = RecordBuf
	end
	CurrentName = name
	saveDisk()
	print("[Macro] saved", name, #(Macros[name] or {}))
	return true
end

local function playMacro(name)
	name = name or CurrentName
	local steps = Macros[name]
	if type(steps) ~= "table" or #steps == 0 then
		print("[Macro] empty", name)
		return
	end
	if Recording then
		stopRecord()
	end
	stopPlay()
	Playing = true
	local token = PlayToken
	CurrentName = name
	print("[Macro] PLAY", name, #steps)

	task.spawn(function()
		local t0 = tick()
		local camera = cam()
		local oldType
		if Opt.PlayCamera and camera then
			oldType = camera.CameraType
			safe(function()
				camera.CameraType = Enum.CameraType.Scriptable
			end)
		end

		for _, ev in ipairs(steps) do
			if not Playing or token ~= PlayToken then
				break
			end
			local target = t0 + (tonumber(ev.t) or 0)
			while tick() < target do
				if not Playing or token ~= PlayToken then
					break
				end
				task.wait()
			end
			if not Playing or token ~= PlayToken then
				break
			end

			local kind = ev.k
			if kind == "cf" and Opt.PlayMove then
				local root = getRoot()
				if root and ev.x then
					safe(function()
						root.CFrame = CFrame.new(ev.x, ev.y, ev.z) * CFrame.Angles(0, math.rad(ev.yaw or 0), 0)
					end)
				end
			elseif kind == "cam" and Opt.PlayCamera then
				local c = cam()
				local cf = tableToCf(ev.cf)
				if c and cf then
					safe(function()
						c.CFrame = cf
						if ev.fov then
							c.FieldOfView = ev.fov
						end
					end)
				end
			elseif kind == "key" and Opt.PlayKeys then
				local code = keycodeFromName(ev.code)
				if code then
					safe(function()
						VIM:SendKeyEvent(ev.down == true, code, false, game)
					end)
				end
				if ev.down and ev.code == "Space" then
					local hum = getHum()
					if hum then
						hum.Jump = true
					end
				end
			elseif kind == "mouse" and Opt.PlayMouse then
				local x, y = ev.x or 0, ev.y or 0
				if ev.move then
					moveMouseTo(x, y)
				end
				if ev.btn ~= nil and ev.down ~= nil then
					mouseButton(x, y, ev.btn, ev.down)
				end
				if ev.wheel then
					moveMouseTo(x, y)
					safe(function()
						VIM:SendMouseWheelEvent(x, y, ev.wheel > 0, game)
					end)
				end
			end
		end

		if Opt.PlayCamera and camera and oldType then
			safe(function()
				camera.CameraType = oldType
			end)
		end
		Playing = false
		print("[Macro] PLAY done", name)
	end)
end

table.insert(Connections, UIS.InputBegan:Connect(function(input, gp)
	safe(function()
		if input.KeyCode == KeyStop then
			stopRecord()
			stopPlay()
			return
		end
		if not gp then
			if input.KeyCode == KeyRecord and not Playing then
				if Recording then
					stopRecord()
				else
					startRecord()
				end
				return
			end
			if input.KeyCode == KeyPlay and not Recording then
				playMacro(CurrentName)
				return
			end
		end
		if not Recording then
			return
		end
		if Opt.RecordKeys and input.UserInputType == Enum.UserInputType.Keyboard then
			pushEvent({ k = "key", code = input.KeyCode.Name, down = true })
		end
		if Opt.RecordMouse then
			local btn = MouseBtnMap[input.UserInputType]
			if btn ~= nil then
				local x, y = getMousePos()
				pushEvent({ k = "mouse", x = x, y = y, btn = btn, down = true })
			end
		end
	end)
end))

table.insert(Connections, UIS.InputEnded:Connect(function(input)
	safe(function()
		if not Recording then
			return
		end
		if Opt.RecordKeys and input.UserInputType == Enum.UserInputType.Keyboard then
			pushEvent({ k = "key", code = input.KeyCode.Name, down = false })
		end
		if Opt.RecordMouse then
			local btn = MouseBtnMap[input.UserInputType]
			if btn ~= nil then
				local x, y = getMousePos()
				pushEvent({ k = "mouse", x = x, y = y, btn = btn, down = false })
			end
		end
	end)
end))

-- continuous mouse track (fixes move not recording)
table.insert(Connections, RunService.RenderStepped:Connect(function()
	safe(function()
		if not Recording then
			return
		end

		if Opt.RecordMouse then
			local x, y = getMousePos()
			local pos = Vector2.new(x, y)
			if (pos - LastMouseRec).Magnitude >= Opt.MouseMoveDist then
				LastMouseRec = pos
				pushEvent({ k = "mouse", x = x, y = y, move = true })
			end
		end

		if Opt.RecordMove then
			local root = getRoot()
			if root then
				local p = root.Position
				local yaw = math.deg(select(2, root.CFrame:ToEulerAnglesYXZ()))
				local last
				for i = #RecordBuf, 1, -1 do
					if RecordBuf[i].k == "cf" then
						last = RecordBuf[i]
						break
					end
				end
				if not last or (Vector3.new(last.x, last.y, last.z) - p).Magnitude >= Opt.MoveDist then
					pushEvent({ k = "cf", x = p.X, y = p.Y, z = p.Z, yaw = yaw })
				end
			end
		end

		if Opt.RecordCamera then
			local c = cam()
			if c then
				local cf = c.CFrame
				local last
				for i = #RecordBuf, 1, -1 do
					if RecordBuf[i].k == "cam" then
						last = RecordBuf[i]
						break
					end
				end
				local should = true
				if last and last.cf then
					local prev = tableToCf(last.cf)
					if prev and (prev.Position - cf.Position).Magnitude < Opt.CamDist and prev.LookVector:Dot(cf.LookVector) > Opt.CamDot then
						if math.abs((last.fov or 70) - c.FieldOfView) < 0.4 then
							should = false
						end
					end
				end
				if should then
					pushEvent({ k = "cam", cf = cfToTable(cf), fov = c.FieldOfView })
				end
			end
		end
	end)
end))

table.insert(Connections, UIS.InputChanged:Connect(function(input)
	safe(function()
		if not Recording or not Opt.RecordMouse then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local x, y = getMousePos()
			pushEvent({ k = "mouse", x = x, y = y, wheel = input.Position.Z })
		end
	end)
end))

local function queueSelf()
	local code = string.format([[
		getgenv().CracksMacro_Running = nil
		task.defer(function()
			pcall(function()
				loadstring(game:HttpGet("%s", true))()
			end)
		end)
	]], SCRIPT_URL)
	for _, fn in ipairs({
		queue_on_teleport,
		syn and syn.queue_on_teleport,
		fluxus and fluxus.queue_on_teleport,
		queueonteleport,
		getgenv().queue_on_teleport,
	}) do
		if typeof(fn) == "function" then
			pcall(fn, code)
		end
	end
end
pcall(queueSelf)
pcall(function()
	LocalPlayer.OnTeleport:Connect(function()
		pcall(queueSelf)
	end)
end)
task.spawn(function()
	while getgenv().CracksMacro_Running do
		pcall(queueSelf)
		task.wait(6)
	end
end)

pcall(loadDisk)

local libSrc = safe(function()
	return game:HttpGet("https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua", true)
end)

local DropRef, NameBox
local function refreshDrop()
	safe(function()
		if DropRef and DropRef.SetOptions then
			DropRef:SetOptions(namesList())
		elseif DropRef and DropRef.Refresh then
			DropRef:Refresh(namesList())
		end
	end)
end

if type(libSrc) == "string" then
	local Lib = safe(function()
		return loadstring(libSrc)()
	end)
	if type(Lib) == "table" and Lib.Init then
		local executor = safe(function()
			return identifyexecutor()
		end) or "Unknown"
		local GUI = safe(function()
			return Lib:Init(
				"Cracks Hub | Macro | " .. tostring(executor),
				true,
				Enum.KeyCode.LeftControl,
				"Default",
				{ Enabled = false }
			)
		end)
		if GUI then
			local function harden(sec)
				if type(sec) == "table" and type(sec.ConfigToggle) ~= "function" and type(sec.Toggle) == "function" then
					function sec:ConfigToggle(a, b, c)
						return self:Toggle(a, b, c)
					end
				end
				return sec
			end

			local tab = GUI:CreateTab("Macro")
			local sec = harden(tab:Section("Recorder"))
			local opt = harden(tab:Section("Capture"))
			local misc = harden(tab:Section("Misc"))

			local list = namesList()
			CurrentName = list[1] ~= "(none)" and list[1] or nil

			safe(function()
				if sec.Dropdown then
					DropRef = sec:Dropdown("Saved Macros", list, list[1], function(v)
						if v ~= "(none)" then
							CurrentName = v
						end
					end)
				elseif sec.ConfigDropdown then
					DropRef = sec:ConfigDropdown("Saved Macros", list, list[1], function(v)
						if v ~= "(none)" then
							CurrentName = v
						end
					end)
				end
			end)

			safe(function()
				if sec.Textbox then
					NameBox = sec:Textbox("Macro Name", CurrentName or "macro1", function(t)
						CurrentName = t
					end)
				elseif sec.ConfigTextbox then
					NameBox = sec:ConfigTextbox("Macro Name", CurrentName or "macro1", function(t)
						CurrentName = t
					end)
				end
			end)

			sec:Button("Record / Stop (R)", function()
				if Recording then
					stopRecord()
				else
					startRecord()
				end
			end)
			sec:Button("Play (P)", function()
				playMacro(CurrentName)
			end)
			sec:Button("Stop (X)", function()
				stopRecord()
				stopPlay()
			end)
			sec:Button("Save", function()
				local n = CurrentName
				safe(function()
					if NameBox and NameBox.GetText then
						n = NameBox:GetText()
					end
				end)
				saveCurrent(n or "macro1")
				refreshDrop()
			end)
			sec:Button("Delete Selected", function()
				if CurrentName and Macros[CurrentName] then
					Macros[CurrentName] = nil
					saveDisk()
					CurrentName = nil
					refreshDrop()
				end
			end)

			opt:ConfigToggle("Record / Play Move", true, function(v)
				Opt.RecordMove = v
				Opt.PlayMove = v
			end)
			opt:ConfigToggle("Record / Play Camera", true, function(v)
				Opt.RecordCamera = v
				Opt.PlayCamera = v
			end)
			opt:ConfigToggle("Record / Play Keys", true, function(v)
				Opt.RecordKeys = v
				Opt.PlayKeys = v
			end)
			opt:ConfigToggle("Record / Play Mouse", true, function(v)
				Opt.RecordMouse = v
				Opt.PlayMouse = v
			end)

			misc:Button("Unload", function()
				stopRecord()
				stopPlay()
				getgenv().CracksMacro_Running = nil
				for _, c in ipairs(Connections) do
					safe(function()
						c:Disconnect()
					end)
				end
				safe(function()
					if GUI.Unload then
						GUI:Unload()
					elseif GUI.Destroy then
						GUI:Destroy()
					end
				end)
			end)
		end
	end
end

print("[Macro] mouse move fixed | R/P/X | LeftControl")
