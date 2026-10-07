if getgenv().CracksMacro_Running then
	return
end
getgenv().CracksMacro_Running = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

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

local KeyRecord = Enum.KeyCode.R
local KeyPlay = Enum.KeyCode.P
local KeyStop = Enum.KeyCode.X

local function ensureFolder()
	pcall(function()
		if isfolder and not isfolder(FOLDER) then
			makefolder(FOLDER)
		end
	end)
end

local function loadDisk()
	ensureFolder()
	local ok, data = pcall(function()
		if isfile and isfile(FILE) then
			return HttpService:JSONDecode(readfile(FILE))
		end
	end)
	if ok and type(data) == "table" then
		Macros = data
	else
		Macros = getgenv().CracksMacro_Data or {}
	end
	getgenv().CracksMacro_Data = Macros
end

local function saveDisk()
	ensureFolder()
	getgenv().CracksMacro_Data = Macros
	pcall(function()
		if writefile then
			writefile(FILE, HttpService:JSONEncode(Macros))
		end
	end)
end

local function namesList()
	local t = {}
	for n in pairs(Macros) do
		table.insert(t, n)
	end
	table.sort(t)
	if #t == 0 then
		table.insert(t, "(none)")
	end
	return t
end

local function getRoot()
	local c = LocalPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
	local c = LocalPlayer.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function stamp()
	return tick() - RecStart
end

local function pushEvent(ev)
	if not Recording then
		return
	end
	ev.t = stamp()
	table.insert(RecordBuf, ev)
end

local function startRecord()
	if Playing then
		return
	end
	Recording = true
	RecordBuf = {}
	RecStart = tick()
	print("[Macro] recording...")
end

local function stopRecord()
	Recording = false
	print("[Macro] stopped | events=", #RecordBuf)
end

local function saveCurrent(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" or name == "(none)" then
		print("[Macro] invalid name")
		return
	end
	if #RecordBuf == 0 and not Macros[name] then
		print("[Macro] nothing to save")
		return
	end
	if #RecordBuf > 0 then
		Macros[name] = RecordBuf
	end
	CurrentName = name
	saveDisk()
	print("[Macro] saved", name, "events=", #(Macros[name] or {}))
end

local function stopPlay()
	PlayToken += 1
	Playing = false
end

local function playMacro(name)
	name = name or CurrentName
	local steps = Macros[name]
	if type(steps) ~= "table" or #steps == 0 then
		print("[Macro] empty:", name)
		return
	end
	if Recording then
		stopRecord()
	end
	stopPlay()
	Playing = true
	local token = PlayToken
	CurrentName = name
	print("[Macro] playing", name, #steps)

	task.spawn(function()
		local t0 = tick()
		for i, ev in ipairs(steps) do
			if not Playing or token ~= PlayToken then
				break
			end
			local target = t0 + (tonumber(ev.t) or 0)
			while tick() < target do
				if not Playing or token ~= PlayToken then
					return
				end
				task.wait()
			end

			if ev.k == "cf" then
				local root = getRoot()
				if root and ev.x then
					root.CFrame = CFrame.new(ev.x, ev.y, ev.z)
						* CFrame.Angles(0, math.rad(ev.yaw or 0), 0)
				end
			elseif ev.k == "key" then
				-- visual only: jump / move hints
				local hum = getHum()
				if hum and ev.code == "Space" then
					hum.Jump = true
				end
			elseif ev.k == "click" then
				pcall(function()
					local vim = game:GetService("VirtualInputManager")
					vim:SendMouseButtonEvent(ev.x or 0, ev.y or 0, 0, true, game, 0)
					task.wait()
					vim:SendMouseButtonEvent(ev.x or 0, ev.y or 0, 0, false, game, 0)
				end)
			end
		end
		Playing = false
		print("[Macro] finished", name)
	end)
end

-- input capture
table.insert(Connections, UIS.InputBegan:Connect(function(input, gp)
	if gp then
		return
	end
	if input.KeyCode == KeyStop then
		stopRecord()
		stopPlay()
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
	if input.UserInputType == Enum.UserInputType.Keyboard then
		pushEvent({ k = "key", code = input.KeyCode.Name })
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		local p = input.Position
		pushEvent({ k = "click", x = p.X, y = p.Y })
	end
end))

-- path waypoints while recording
table.insert(Connections, RunService.Heartbeat:Connect(function()
	if not Recording then
		return
	end
	local root = getRoot()
	if not root then
		return
	end
	local last = RecordBuf[#RecordBuf]
	local pos = root.Position
	local yaw = select(2, root.CFrame:ToEulerAnglesYXZ())
	yaw = math.deg(yaw)
	if not last or last.k ~= "cf" or (Vector3.new(last.x, last.y, last.z) - pos).Magnitude > 1.5 then
		pushEvent({ k = "cf", x = pos.X, y = pos.Y, z = pos.Z, yaw = yaw })
	end
end))

-- queue_on_teleport
local function queueSelf()
	local code = string.format([[
		getgenv().CracksMacro_Running = nil
		getgenv().CracksMacro_Data = getgenv().CracksMacro_Data
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
queueSelf()
pcall(function()
	LocalPlayer.OnTeleport:Connect(queueSelf)
end)
task.spawn(function()
	while getgenv().CracksMacro_Running do
		queueSelf()
		task.wait(6)
	end
end)

loadDisk()

-- UI
local libSrc
pcall(function()
	libSrc = game:HttpGet("https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua", true)
end)

local DropRef = nil
local NameBox = nil

local function refreshDrop()
	if DropRef and DropRef.SetOptions then
		pcall(function()
			DropRef:SetOptions(namesList())
		end)
	end
	if DropRef and DropRef.Refresh then
		pcall(function()
			DropRef:Refresh(namesList())
		end)
	end
end

if type(libSrc) == "string" then
	local ok, Lib = pcall(function()
		return loadstring(libSrc)()
	end)
	if ok and type(Lib) == "table" and Lib.Init then
		local executor = "Unknown"
		pcall(function()
			executor = identifyexecutor()
		end)
		local GUI = Lib:Init(
			"Cracks Hub | Macro | " .. tostring(executor),
			true,
			Enum.KeyCode.LeftControl,
			"Default",
			{ Enabled = false }
		)
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
			local bind = harden(tab:Section("Keybinds"))
			local misc = harden(tab:Section("Misc"))

			local list = namesList()
			CurrentName = list[1] ~= "(none)" and list[1] or nil

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

			if sec.Textbox then
				NameBox = sec:Textbox("Macro Name", CurrentName or "macro1", function(t)
					CurrentName = t
				end)
			elseif sec.ConfigTextbox then
				NameBox = sec:ConfigTextbox("Macro Name", CurrentName or "macro1", function(t)
					CurrentName = t
				end)
			end

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
				if NameBox and NameBox.GetText then
					pcall(function()
						n = NameBox:GetText()
					end)
				end
				saveCurrent(n or CurrentName or "macro1")
				refreshDrop()
			end)
			sec:Button("Delete Selected", function()
				if CurrentName and Macros[CurrentName] then
					Macros[CurrentName] = nil
					saveDisk()
					CurrentName = nil
					refreshDrop()
					print("[Macro] deleted")
				end
			end)

			if bind.Keybind then
				bind:Keybind("Record Key", KeyRecord, function(k)
					KeyRecord = k
				end)
				bind:Keybind("Play Key", KeyPlay, function(k)
					KeyPlay = k
				end)
				bind:Keybind("Stop Key", KeyStop, function(k)
					KeyStop = k
				end)
			end

			misc:Button("Unload", function()
				running = false
				stopRecord()
				stopPlay()
				getgenv().CracksMacro_Running = nil
				for _, c in ipairs(Connections) do
					pcall(function()
						c:Disconnect()
					end)
				end
				pcall(function()
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

print("[Macro] loaded — R record | P play | X stop | LeftControl UI | saves →", FILE)
