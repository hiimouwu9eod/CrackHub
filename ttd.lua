local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TTD_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/ttd.lua"
local REMOTE_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/ttdremote.lua"

if not game:IsLoaded() then
	pcall(function()
		game.Loaded:Wait()
	end)
end

-- wait until at least one flag exists / settles
local function waitFlags(timeout)
	local t0 = tick()
	while tick() - t0 < (timeout or 8) do
		local lobby, main
		pcall(function()
			lobby = rp.IsLobby.Value
		end)
		pcall(function()
			main = rp.IsMainGame.Value
		end)
		if lobby ~= nil or main ~= nil then
			if lobby == true or main == true then
				return
			end
		end
		task.wait(0.2)
	end
end

waitFlags(8)

local function isGame()
	local ok, val = pcall(function()
		return rp.IsMainGame.Value
	end)
	if ok then
		return val
	end
	return false
end

local function isLobby()
	local ok, val = pcall(function()
		return rp.IsLobby.Value
	end)
	if ok then
		return val
	end
	return false
end

print("[Cracks TTD] on load IsLobby=", isLobby(), "IsMainGame=", isGame())

-- IN GAME → remote only, then stop this file
if isGame() then
	print("[Cracks TTD] GAME → execute ttdremote.lua now")
	local src
	local okGet, res = pcall(function()
		return game:HttpGet(REMOTE_URL, true)
	end)
	if okGet then
		src = res
	end
	if type(src) == "string" and #src > 0 then
		local okRun, err = pcall(function()
			assert(loadstring(src))()
		end)
		if not okRun then
			warn("[Cracks TTD] ttdremote error:", err)
		else
			print("[Cracks TTD] ttdremote executed")
		end
	else
		warn("[Cracks TTD] ttdremote download failed")
	end
	return
end

-- LOBBY → farm UI
print("[Cracks TTD] LOBBY → farm UI")

local AntiAfk = false
local autofarm = getgenv().CracksTTD_AutoFarm == true
local running = true
local clickedSkip = false

local function queueSelf()
	local code = string.format([[
		getgenv().CracksTTD_AutoFarm = %s
		task.spawn(function()
			pcall(function()
				loadstring(game:HttpGet("%s", true))()
			end)
		end)
	]], tostring(getgenv().CracksTTD_AutoFarm == true), TTD_URL)

	local queued = false
	for _, fn in ipairs({
		queue_on_teleport,
		syn and syn.queue_on_teleport,
		fluxus and fluxus.queue_on_teleport,
		queueonteleport,
		getgenv().queue_on_teleport,
	}) do
		if typeof(fn) == "function" then
			if pcall(fn, code) then
				queued = true
			end
		end
	end
	print(queued and "[Cracks TTD] queued on tp" or "[Cracks TTD] no queue — use AutoExec")
end

queueSelf()

pcall(function()
	LocalPlayer.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Started or state == Enum.TeleportState.RequestedFromServer then
			queueSelf()
		end
	end)
end)

local func = {}

function func.TeleportToFarmLocation()
	local part, root
	pcall(function()
		part = workspace.Lifts.ToiletCity.Base
	end)
	pcall(function()
		if part and part:IsA("Model") then
			part = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart", true)
		end
	end)
	pcall(function()
		root = LocalPlayer.Character.HumanoidRootPart
	end)
	if not root or not part then
		print("[Cracks TTD] TP fail")
		return
	end
	pcall(function()
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end)
	print("[Cracks TTD] TP ToiletCity")
end

function func.ClickStartButton()
	local btn
	pcall(function()
		btn = PlayerGui.Lobby.QueueFrame.QueueFrame
	end)
	if not btn then
		pcall(function()
			btn = PlayerGui.Lobby.QueueFrame.Start
		end)
	end
	if not btn then
		print("[Cracks TTD] Start not found")
		return
	end
	if not (btn:IsA("GuiButton") or btn:IsA("TextButton") or btn:IsA("ImageButton")) then
		pcall(function()
			for _, d in ipairs(btn:GetDescendants()) do
				if d:IsA("GuiButton") or d:IsA("TextButton") or d:IsA("ImageButton") then
					local n = string.lower(d.Name)
					local t = string.lower(tostring(d.Text or ""))
					if n:find("start") or t:find("start") then
						btn = d
						break
					end
				end
			end
		end)
	end
	pcall(function()
		if getconnections then
			for _, n in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down" }) do
				local s = btn[n]
				if s then
					for _, c in ipairs(getconnections(s)) do
						pcall(function()
							if c.Function then
								c.Function()
							end
							c:Fire()
						end)
					end
				end
			end
		end
	end)
	pcall(function()
		if firesignal then
			firesignal(btn.Activated)
			firesignal(btn.MouseButton1Click)
		end
	end)
	pcall(function()
		btn:Activate()
	end)
	print("[Cracks TTD] Start clicked")
end

function func.TeleportAndStart()
	queueSelf()
	func.TeleportToFarmLocation()
	task.wait(0.7)
	func.ClickStartButton()
end

function func.AutoSkipRemote(callamt)
	callamt = tonumber(callamt) or 1
	local Event
	pcall(function()
		Event = rp.NetworkingContainer.DataRemote
	end)
	if not Event then
		return
	end
	for _ = 1, callamt do
		pcall(function()
			Event:FireServer({
				{
					"\xE2\x81\x82'",
				},
			})
		end)
		task.wait(0.1)
	end
	print("[Cracks TTD] AutoSkip x" .. tostring(callamt))
end

task.spawn(function()
	while running do
		if autofarm then
			if isGame() then
				if not clickedSkip then
					task.wait(1)
					func.AutoSkipRemote(1)
					clickedSkip = true
				end
				if not getgenv().CracksTTD_RemoteLoaded then
					getgenv().CracksTTD_RemoteLoaded = true
					pcall(function()
						loadstring(game:HttpGet(REMOTE_URL, true))()
					end)
				end
				task.wait(1)
			elseif isLobby() then
				clickedSkip = false
				getgenv().CracksTTD_RemoteLoaded = false
				func.TeleportAndStart()
				task.wait(2.5)
			else
				task.wait(1)
			end
		else
			task.wait(0.4)
		end
	end
end)

task.spawn(function()
	while running do
		task.wait(25)
		if AntiAfk then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end
	end
end)

LocalPlayer.Idled:Connect(function()
	if AntiAfk and running then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

local libSrc
pcall(function()
	libSrc = game:HttpGet("https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua", true)
end)

if type(libSrc) == "string" then
	local ok, Lib = pcall(function()
		return loadstring(libSrc)()
	end)
	if ok and type(Lib) == "table" and Lib.Init then
		local executor = "Unknown"
		pcall(function()
			executor = identifyexecutor()
		end)
		local GUI
		pcall(function()
			GUI = Lib:Init(
				"Cracks Hub | TTD | " .. tostring(executor),
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
			local tab = GUI:CreateTab("Main")
			local farm = harden(tab:Section("Farm"))
			local misc = harden(tab:Section("Misc"))

			farm:ConfigToggle("Auto Farm", autofarm, function(v)
				autofarm = v
				getgenv().CracksTTD_AutoFarm = v
				clickedSkip = false
				queueSelf()
			end)
			farm:Button("TP + Start", function()
				func.TeleportAndStart()
			end)
			farm:Button("TP ToiletCity", function()
				func.TeleportToFarmLocation()
			end)
			farm:Button("Click Start", function()
				func.ClickStartButton()
			end)
			farm:Button("AutoSkip Remote", function()
				func.AutoSkipRemote(1)
			end)
			farm:Button("Load Place Remote", function()
				pcall(function()
					loadstring(game:HttpGet(REMOTE_URL, true))()
				end)
			end)
			misc:ConfigToggle("Anti Afk", false, function(v)
				AntiAfk = v
			end)
			misc:Button("Unload", function()
				running = false
				autofarm = false
				getgenv().CracksTTD_AutoFarm = false
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

print("[Cracks TTD] lobby UI ready — LeftControl")
