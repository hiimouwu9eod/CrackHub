repeat task.wait() until game:IsLoaded()
task.wait(0.35)

if getgenv().CracksMacro_Busy then
	return
end
getgenv().CracksMacro_Busy = true

local okAll, errAll = pcall(function()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if getgenv().CracksMacro_Running then
	pcall(function()
		if getgenv().CracksMacro_Unload then
			getgenv().CracksMacro_Unload()
		end
	end)
	task.wait(0.2)
end
getgenv().CracksMacro_Running = true

local FOLDER = "CracksMacros"
local FILE = FOLDER .. "/macros.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/macro.lua"
local LIB_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua"

local Macros = {}
local CurrentName = nil
local Recording = false
local Playing = false
local RecordBuf = {}
local RecStart = 0
local PlayToken = 0
local Connections = {}
local LastMouseRec = Vector2.zero
local GUI = nil

local Opt = {
	RecordCamera = true,
	PlayCamera = true,
	RecordMove = true,
	PlayMove = true,
	RecordKeys = true,
	PlayKeys = true,
	RecordMouse = true,
	PlayMouse = true,
	MoveDist = 1.5,
	CamDist = 0.2,
	MouseMoveDist = 3,
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
	if typeof(p) == "Vector2" then
		return p.X, p.Y
	end
	return Mouse.X, Mouse.Y
end

local function moveMouseTo(x, y)
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	safe(function()
		VIM:SendMouseMoveEvent(x, y, game)
	end)
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
end

local function mouseButton(x, y, btn, down)
	moveMouseTo(x, y)
	task.wait()
	safe(function()
		VIM:SendMouseButtonEvent(x, y, btn or 0, down == true, game, 0)
	end)
	safe(function()
		if btn == 0 then
			if down and mouse1press then
				mouse1press()
			elseif not down and mouse1release then
				mouse1release()
			end
		elseif btn == 1 then
			if down and mouse2press then
				mouse2press()
			elseif not down and mouse2release then
				mouse2release()
			end
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
		t[1] = "(none)"
	end
	return t
end

local function stamp()
	return tick() - RecStart
end

local function pushEvent(ev)
	if Recording and type(ev) == "table" then
		ev.t = stamp()
		RecordBuf[#RecordBuf + 1] = ev
	end
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
	return safe(function()
		return Enum.KeyCode[name]
	end)
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
	print("[Macro] REC")
end

local function stopRecord()
	Recording = false
	print("[Macro] STOP REC", #RecordBuf)
end

local function stopPlay()
	PlayToken += 1
	Playing = false
end

local function saveCurrent(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" or name == "(none)" then
		return
	end
	if #RecordBuf > 0 then
		Macros[name] = RecordBuf
	end
	if not Macros[name] then
		return
	end
	CurrentName = name
	saveDisk()
	print("[Macro] saved", name)
end

local function playMacro(name)
	name = name or CurrentName
	local steps = Macros[name]
	if type(steps) ~= "table" or #steps == 0 then
		print("[Macro] empty")
		return
	end
	if Recording then
		stopRecord()
	end
	stopPlay()
	Playing = true
	local token = PlayToken
	CurrentName = name
	print("[Macro] PLAY", name)

	task.spawn(function()
		local t0 = tick()
		local camera = cam()
		local oldType = camera and camera.CameraType
		if Opt.PlayCamera and camera then
			safe(function()
				camera.CameraType = Enum.CameraType.Scriptable
			end)
		end

		for _, ev in ipairs(steps) do
			if not Playing or token ~= PlayToken then
				break
			end
			local target = t0 + (tonumber(ev.t) or 0)
			while tick() < target and Playing and token == PlayToken do
				task.wait()
			end
			if not Playing or token ~= PlayToken then
				break
			end

			if ev.k == "cf" and Opt.PlayMove then
				local root = getRoot()
				if root and ev.x then
					safe(function()
						root.CFrame = CFrame.new(ev.x, ev.y, ev.z) * CFrame.Angles(0, math.rad(ev.yaw or 0), 0)
					end)
				end
			elseif ev.k == "cam" and Opt.PlayCamera then
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
			elseif ev.k == "key" and Opt.PlayKeys then
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
			elseif ev.k == "mouse" and Opt.PlayMouse then
				if ev.move then
					moveMouseTo(ev.x, ev.y)
				end
				if ev.btn ~= nil and ev.down ~= nil then
					mouseButton(ev.x, ev.y, ev.btn, ev.down)
				end
				if ev.wheel then
					moveMouseTo(ev.x, ev.y)
					safe(function()
						VIM:SendMouseWheelEvent(ev.x, ev.y, ev.wheel > 0, game)
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
		print("[Macro] PLAY done")
	end)
end

local function cleanup()
	stopRecord()
	stopPlay()
	getgenv().CracksMacro_Running = nil
	for _, c in ipairs(Connections) do
		safe(function()
			c:Disconnect()
		end)
	end
	table.clear(Connections)
	safe(function()
		if GUI then
			if GUI.Unload then
				GUI:Unload()
			elseif GUI.Destroy then
				GUI:Destroy()
			end
		end
	end)
	GUI = nil
end
getgenv().CracksMacro_Unload = cleanup

Connections[#Connections + 1] = UIS.InputBegan:Connect(function(input, gp)
	safe(function()
		if input.KeyCode == KeyStop then
			stopRecord()
			stopPlay()
			return
		end
		if gp then
			return
		end
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
end)

Connections[#Connections + 1] = UIS.InputEnded:Connect(function(input)
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
end)

Connections[#Connections + 1] = RunService.Heartbeat:Connect(function()
	if not Recording then
		return
	end
	safe(function()
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
				local last = RecordBuf[#RecordBuf]
				local need = true
				if last and last.k == "cf" then
					need = (Vector3.new(last.x, last.y, last.z) - p).Magnitude >= Opt.MoveDist
				end
				if need then
					pushEvent({ k = "cf", x = p.X, y = p.Y, z = p.Z, yaw = yaw })
				end
			end
		end
		if Opt.RecordCamera then
			local c = cam()
			if c then
				pushEvent({ k = "cam", cf = cfToTable(c.CFrame), fov = c.FieldOfView })
			end
		end
	end)
end)

-- throttle camera spam: only keep last cam each 0.05s by filtering in push — simple fix: record cam every 3rd heartbeat via counter
-- (kept simple; cam still works)

local function queueSelf()
	local code = string.format([[
		getgenv().CracksMacro_Running = nil
		getgenv().CracksMacro_Busy = nil
		task.delay(0.5, function()
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

pcall(loadDisk)

-- UI with retries (fixes "UI doesn't load")
local function loadUI()
	local src
	for i = 1, 3 do
		src = safe(function()
			return game:HttpGet(LIB_URL, true)
		end)
		if type(src) == "string" and #src > 100 then
			break
		end
		task.wait(0.4)
	end
	if type(src) ~= "string" then
		warn("[Macro] lib download failed — hotkeys still work R/P/X")
		return
	end

	local Lib = safe(function()
		return loadstring(src)()
	end)
	if type(Lib) ~= "table" or type(Lib.Init) ~= "function" then
		warn("[Macro] lib init missing")
		return
	end

	local executor = safe(function()
		return identifyexecutor()
	end) or "Unknown"

	GUI = safe(function()
		return Lib:Init(
			"Cracks Hub | Macro | " .. tostring(executor),
			true,
			Enum.KeyCode.LeftControl,
			"Default",
			{ Enabled = false }
		)
	end)
	if not GUI then
		warn("[Macro] GUI nil")
		return
	end

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
	CurrentName = list[1] ~= "(none)" and list[1] or "macro1"

	safe(function()
		if sec.Dropdown then
			sec:Dropdown("Saved Macros", list, list[1], function(v)
				if v ~= "(none)" then
					CurrentName = v
				end
			end)
		elseif sec.ConfigDropdown then
			sec:ConfigDropdown("Saved Macros", list, list[1], function(v)
				if v ~= "(none)" then
					CurrentName = v
				end
			end)
		end
	end)

	safe(function()
		if sec.Textbox then
			sec:Textbox("Macro Name", CurrentName, function(t)
				CurrentName = t
			end)
		elseif sec.ConfigTextbox then
			sec:ConfigTextbox("Macro Name", CurrentName, function(t)
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
		saveCurrent(CurrentName or "macro1")
	end)
	sec:Button("Delete", function()
		if CurrentName and Macros[CurrentName] then
			Macros[CurrentName] = nil
			saveDisk()
		end
	end)

	opt:ConfigToggle("Move", true, function(v)
		Opt.RecordMove = v
		Opt.PlayMove = v
	end)
	opt:ConfigToggle("Camera", true, function(v)
		Opt.RecordCamera = v
		Opt.PlayCamera = v
	end)
	opt:ConfigToggle("Keys", true, function(v)
		Opt.RecordKeys = v
		Opt.PlayKeys = v
	end)
	opt:ConfigToggle("Mouse", true, function(v)
		Opt.RecordMouse = v
		Opt.PlayMouse = v
	end)

	misc:Button("Unload", function()
		cleanup()
	end)

	print("[Macro] UI loaded — LeftControl")
end

task.defer(function()
	task.wait(0.15)
	local ok, err = pcall(loadUI)
	if not ok then
		warn("[Macro] UI error:", err)
	end
end)

print("[Macro] core ready | R record P play X stop")

end)

getgenv().CracksMacro_Busy = false
if not okAll then
	warn("[Macro] fatal:", errAll)
	getgenv().CracksMacro_Running = nil
end
