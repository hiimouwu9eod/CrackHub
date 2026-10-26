local MarcoLoader = {}

MarcoLoader.CODELOADER = [[
{"TTDInanseLobby":[{"y":518,"x":960,"k":"mouse","t":0.3485283851623535,"btn":0,"down":true},{"y":518,"x":960,"k":"mouse","t":0.41477346420288086,"btn":0,"down":false},{"y":518,"x":960,"k":"mouse","t":0.4994354248046875,"btn":0,"down":true},{"y":518,"x":960,"k":"mouse","t":0.5658082962036133,"btn":0,"down":false},{"y":518,"x":960,"k":"mouse","t":0.6475512981414795,"btn":0,"down":true},{"y":518,"x":960,"k":"mouse","t":0.732480525970459,"btn":0,"down":false},{"y":518,"x":960,"k":"mouse","t":0.7814099788665771,"btn":0,"down":true},{"y":518,"x":960,"k":"mouse","t":0.8653466701507568,"btn":0,"down":false}]}
]]
MarcoLoader.ScriptSystemFiles = {
	FP = "MarcoLoader",
	CacheLoader = "MarcoLoader/CacheDataFolder",
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Playing = false
local PlayToken = 0

local Opt = {
	PlayCamera = true,
	PlayMove = true,
	PlayKeys = true,
	PlayMouse = true,
	Speed = 1,
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

function MarcoLoader.EnsureFolders()
	safe(function()
		if isfolder and not isfolder(MarcoLoader.ScriptSystemFiles.FP) then
			makefolder(MarcoLoader.ScriptSystemFiles.FP)
		end
		if isfolder and not isfolder(MarcoLoader.ScriptSystemFiles.CacheLoader) then
			makefolder(MarcoLoader.ScriptSystemFiles.CacheLoader)
		end
	end)
end

function MarcoLoader.SetEvents(events)
	if type(events) == "table" then
		MarcoLoader.CODELOADER = HttpService:JSONEncode(events)
	elseif type(events) == "string" then
		MarcoLoader.CODELOADER = events
	end
end

function MarcoLoader.GetEvents(name)
	name = name or "TTDInanseLobby"
	if type(MarcoLoader.CODELOADER) ~= "string" or MarcoLoader.CODELOADER == "" then
		return {}
	end
	local data = safe(function()
		return HttpService:JSONDecode(MarcoLoader.CODELOADER)
	end)
	if type(data) ~= "table" then
		return {}
	end
	if type(data[name]) == "table" then
		return data[name]
	end
	if data[1] and type(data[1]) == "table" and data[1].k then
		return data
	end
	for _, v in pairs(data) do
		if type(v) == "table" and v[1] and type(v[1]) == "table" and v[1].k then
			return v
		end
	end
	return {}
end

function MarcoLoader.SaveCode(name)
	MarcoLoader.EnsureFolders()
	name = tostring(name or "TTDInanseLobby")
	local path = MarcoLoader.ScriptSystemFiles.CacheLoader .. "/" .. name .. ".json"
	safe(function()
		if writefile then
			writefile(path, MarcoLoader.CODELOADER)
		end
	end)
	print("[MarcoLoader] saved", path)
	return path
end

function MarcoLoader.LoadCode(name)
	MarcoLoader.EnsureFolders()
	name = tostring(name or "TTDInanseLobby")
	local path = MarcoLoader.ScriptSystemFiles.CacheLoader .. "/" .. name .. ".json"
	local src = safe(function()
		if isfile and isfile(path) then
			return readfile(path)
		end
	end)
	if type(src) == "string" and #src > 0 then
		MarcoLoader.CODELOADER = src
		print("[MarcoLoader] loaded", path)
		return true
	end
	warn("[MarcoLoader] missing", path)
	return false
end

function MarcoLoader.ListSaves()
	MarcoLoader.EnsureFolders()
	local list = {}
	safe(function()
		if listfiles then
			for _, f in ipairs(listfiles(MarcoLoader.ScriptSystemFiles.CacheLoader)) do
				local n = tostring(f):match("([^/\\]+)%.json$")
				if n then
					table.insert(list, n)
				end
			end
		end
	end)
	table.sort(list)
	return list
end

function MarcoLoader.Stop()
	PlayToken += 1
	Playing = false
end

function MarcoLoader.PlayTheRecoder(name)
	local steps = MarcoLoader.GetEvents(name or "TTDInanseLobby")
	if type(steps) ~= "table" or #steps == 0 then
		warn("[MarcoLoader] CODELOADER empty / invalid JSON")
		return false
	end

	MarcoLoader.Stop()
	Playing = true
	local token = PlayToken
	local speed = math.clamp(tonumber(Opt.Speed) or 1, 0.1, 8)
	print("[MarcoLoader] play events=", #steps)

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

			local target = t0 + ((tonumber(ev.t) or 0) / speed)
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
						root.CFrame = CFrame.new(ev.x, ev.y, ev.z)
							* CFrame.Angles(0, math.rad(ev.yaw or 0), 0)
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
		print("[MarcoLoader] play done")
	end)

	return true
end

MarcoLoader.EnsureFolders()

task.defer(function()
	local n = #MarcoLoader.GetEvents("TTDInanseLobby")
	print("[MarcoLoader] events =", n)
	if n > 0 then
		MarcoLoader.PlayTheRecoder("TTDInanseLobby")
	else
		warn("[MarcoLoader] no events in CODELOADER")
	end
end)

return MarcoLoader
