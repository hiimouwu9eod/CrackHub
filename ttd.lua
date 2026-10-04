print("[Cracks TTD] starting...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FarmLocation
pcall(function()
	FarmLocation = Workspace.Lifts.ToiletHQ.Base
end)

local LobbyGui, QueueFrame, Start
pcall(function()
	LobbyGui = PlayerGui.Lobby
end)
pcall(function()
	QueueFrame = LobbyGui.QueueFrame
end)
pcall(function()
	Start = QueueFrame.Start
end)

local MatchGui, TopFrame, AutoSkipFrame, AutoSkipButton
pcall(function()
	MatchGui = PlayerGui.Match
end)
pcall(function()
	TopFrame = MatchGui.TopFrame
end)
pcall(function()
	AutoSkipFrame = TopFrame.AutoSkip
end)
pcall(function()
	AutoSkipButton = AutoSkipFrame.OnAndOff
end)

local Lobby, MainGame
pcall(function()
	Lobby = rp.IsLobby
end)
pcall(function()
	MainGame = rp.IsMainGame
end)

print("[Cracks TTD] FarmLocation =", FarmLocation)
print("[Cracks TTD] LobbyGui =", LobbyGui, "Start =", Start)
print("[Cracks TTD] MatchGui =", MatchGui, "AutoSkip =", AutoSkipButton)
print("[Cracks TTD] IsLobby =", Lobby, Lobby and Lobby.Value)
print("[Cracks TTD] IsMainGame =", MainGame, MainGame and MainGame.Value)

local AntiAfk = false
local autofarm = getgenv().CracksTTD_AutoFarm == true
local running = true
local clickedSkipThisMatch = false

local SCRIPT_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/ttd.lua"

local function queueSelf()
	local code = string.format([[
		getgenv().CracksTTD_AutoFarm = %s
		pcall(function()
			loadstring(game:HttpGet("%s", true))()
		end)
	]], tostring(getgenv().CracksTTD_AutoFarm == true), SCRIPT_URL)

	local fns = {
		queue_on_teleport,
		syn and syn.queue_on_teleport,
		fluxus and fluxus.queue_on_teleport,
		queueonteleport,
		getgenv().queue_on_teleport,
	}

	local queued = false
	for _, fn in ipairs(fns) do
		if typeof(fn) == "function" then
			if pcall(fn, code) then
				queued = true
			end
		end
	end

	if not queued then
		warn("[Cracks TTD] no queue_on_teleport — use AutoExec")
	else
		print("[Cracks TTD] queued for teleport")
	end
end

pcall(queueSelf)

local func = {}

function func.refreshRefs()
	pcall(function()
		FarmLocation = Workspace.Lifts.ToiletHQ.Base
	end)
	pcall(function()
		LobbyGui = PlayerGui.Lobby
	end)
	pcall(function()
		QueueFrame = LobbyGui.QueueFrame
	end)
	pcall(function()
		Start = QueueFrame.Start
	end)
	pcall(function()
		MatchGui = PlayerGui.Match
	end)
	pcall(function()
		TopFrame = MatchGui.TopFrame
	end)
	pcall(function()
		AutoSkipFrame = TopFrame.AutoSkip
	end)
	pcall(function()
		AutoSkipButton = AutoSkipFrame.OnAndOff
	end)
	pcall(function()
		Lobby = rp.IsLobby
	end)
	pcall(function()
		MainGame = rp.IsMainGame
	end)
end

function func.isLobby()
	local v = false
	pcall(function()
		v = rp.IsLobby.Value == true
	end)
	return v
end

function func.isGame()
	local v = false
	pcall(function()
		v = rp.IsMainGame.Value == true
	end)
	return v
end

function func.TeleportToFarmLocation()
	func.refreshRefs()

	local root
	pcall(function()
		root = LocalPlayer.Character.HumanoidRootPart
	end)
	if not root then
		print("[Cracks TTD] TP fail: no root")
		return
	end

	local part = FarmLocation
	pcall(function()
		if FarmLocation:IsA("Model") then
			part = FarmLocation.PrimaryPart
		end
	end)
	if not part then
		print("[Cracks TTD] TP fail: no FarmLocation")
		return
	end

	pcall(function()
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end)
	print("[Cracks TTD] teleported to ToiletHQ")
end

function func.ClickStartButton()
	func.refreshRefs()
	if not Start then
		print("[Cracks TTD] Start button not found")
		return
	end

	local fired = false
	pcall(function()
		if getconnections then
			for _, c in ipairs(getconnections(Start.MouseButton1Click)) do
				pcall(function()
					c:Fire()
					fired = true
				end)
			end
			for _, c in ipairs(getconnections(Start.Activated)) do
				pcall(function()
					c:Fire()
					fired = true
				end)
			end
		end
	end)
	pcall(function()
		if firesignal then
			firesignal(Start.MouseButton1Click)
			firesignal(Start.Activated)
			fired = true
		end
	end)
	pcall(function()
		Start:Activate()
		fired = true
	end)
	print("[Cracks TTD] ClickStart fired =", fired)
end

function func.clickAutoFarmButtonOnce()
	func.refreshRefs()

	local btn
	pcall(function()
		btn = PlayerGui.Match.TopFrame.AutoSkip.OnAndOff
	end)

	if btn and not (btn:IsA("GuiButton") or btn:IsA("TextButton") or btn:IsA("ImageButton")) then
		pcall(function()
			for _, d in ipairs(PlayerGui.Match.TopFrame.AutoSkip:GetDescendants()) do
				if d:IsA("GuiButton") or d:IsA("TextButton") or d:IsA("ImageButton") then
					btn = d
					break
				end
			end
		end)
	end

	if not btn then
		print("[Cracks TTD] AutoSkip button not found")
		pcall(function()
			print("[Cracks TTD] AutoSkip children:")
			for _, d in ipairs(PlayerGui.Match.TopFrame.AutoSkip:GetDescendants()) do
				print(" ", d.ClassName, d.Name, d:GetFullName())
			end
		end)
		return
	end

	print("[Cracks TTD] AutoSkip target =", btn.ClassName, btn:GetFullName())

	local fired = false

	pcall(function()
		if not getconnections then
			return
		end
		for _, sigName in ipairs({
			"Activated",
			"MouseButton1Click",
			"MouseButton1Down",
			"MouseButton1Up",
			"InputBegan",
			"InputEnded",
		}) do
			local sig = btn[sigName]
			if sig then
				for _, c in ipairs(getconnections(sig)) do
					pcall(function()
						if c.Function then
							c.Function()
						end
						c:Fire()
						fired = true
					end)
				end
			end
		end
	end)

	pcall(function()
		if not firesignal then
			return
		end
		firesignal(btn.Activated)
		firesignal(btn.MouseButton1Click)
		firesignal(btn.MouseButton1Down)
		fired = true
	end)

	pcall(function()
		btn:Activate()
		fired = true
	end)

	pcall(function()
		if btn:IsA("GuiButton") then
			btn.Selected = not btn.Selected
			fired = true
		end
	end)

	pcall(function()
		local vim = game:GetService("VirtualInputManager")
		local abs = btn.AbsolutePosition
		local size = btn.AbsoluteSize
		local x = abs.X + size.X / 2
		local y = abs.Y + size.Y / 2
		vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
		task.wait()
		vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
		fired = true
	end)

	print("[Cracks TTD] AutoSkip fired =", fired)
end

task.spawn(function()
	while running do
		if autofarm then
			local lobby = func.isLobby()
			local game_ = func.isGame()
			print("[Cracks TTD] loop Lobby=", lobby, "Game=", game_)

			if lobby then
				clickedSkipThisMatch = false
				func.TeleportToFarmLocation()
				task.wait(0.6)
				func.ClickStartButton()
				task.wait(2)
			elseif game_ then
				if not clickedSkipThisMatch then
					task.wait(1.5)
					func.clickAutoFarmButtonOnce()
					clickedSkipThisMatch = true
				end
				task.wait(1)
			else
				print("[Cracks TTD] waiting (both false)")
				task.wait(1)
			end
		else
			task.wait(0.5)
		end
	end
end)

task.spawn(function()
	local lastLobby = nil
	local lastGame = nil
	local lastChange = tick()

	while running do
		local curLobby = func.isLobby()
		local curGame = func.isGame()

		if lastLobby == nil then
			lastLobby = curLobby
			lastGame = curGame
			lastChange = tick()
		elseif curLobby ~= lastLobby or curGame ~= lastGame then
			lastLobby = curLobby
			lastGame = curGame
			lastChange = tick()
		elseif autofarm and (tick() - lastChange) >= 10 then
			print("[Cracks TTD] safety: bools unchanged 10s Lobby=", curLobby, "Game=", curGame)
			lastChange = tick()
		end

		task.wait(0.5)
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
local libOk, libRes = pcall(function()
	return game:HttpGet(
		"https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua",
		true
	)
end)
if libOk then
	libSrc = libRes
else
	print("[Cracks TTD] lib HttpGet failed:", libRes)
end

if type(libSrc) == "string" then
	local chunkOk, chunk = pcall(loadstring, libSrc)
	if chunkOk and type(chunk) == "function" then
		local runOk, Lib = pcall(chunk)
		if runOk and type(Lib) == "table" and type(Lib.Init) == "function" then
			local executor = "Unknown"
			pcall(function()
				if identifyexecutor then
					executor = identifyexecutor()
				end
			end)

			local GUI
			pcall(function()
				GUI = Lib:Init(
					"Cracks Hub | TTD | " .. executor,
					true,
					Enum.KeyCode.LeftControl,
					"Default",
					{ Enabled = false }
				)
			end)

			if GUI then
				local function harden(sec)
					if type(sec) ~= "table" then
						return sec
					end
					if type(sec.ConfigToggle) ~= "function" and type(sec.Toggle) == "function" then
						function sec:ConfigToggle(a, b, c)
							return self:Toggle(a, b, c)
						end
					end
					return sec
				end

				local MainTab = GUI:CreateTab("Main")
				local FarmSec = harden(MainTab:Section("Farm"))
				local MiscSec = harden(MainTab:Section("Misc"))

				FarmSec:ConfigToggle("Auto Farm", autofarm, function(v)
					autofarm = v
					getgenv().CracksTTD_AutoFarm = v
					clickedSkipThisMatch = false
					print("[Cracks TTD] Auto Farm =", v)
					pcall(queueSelf)
				end)

				FarmSec:Button("TP ToiletHQ", function()
					func.TeleportToFarmLocation()
				end)

				FarmSec:Button("Click Start", function()
					func.ClickStartButton()
				end)

				FarmSec:Button("Click AutoSkip", function()
					func.clickAutoFarmButtonOnce()
				end)

				MiscSec:ConfigToggle("Anti Afk", false, function(v)
					AntiAfk = v
				end)

				MiscSec:Button("Unload", function()
					running = false
					autofarm = false
					getgenv().CracksTTD_AutoFarm = false
					AntiAfk = false
					pcall(function()
						if GUI.Unload then
							GUI:Unload()
						elseif GUI.Destroy then
							GUI:Destroy()
						end
					end)
				end)

				print("[Cracks TTD] UI loaded — LeftControl")
			end
		else
			print("[Cracks TTD] lib run failed")
		end
	else
		print("[Cracks TTD] lib compile failed")
	end
end

print("[Cracks TTD] loaded OK")
