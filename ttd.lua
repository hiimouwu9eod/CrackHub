print("[Cracks TTD] starting...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local FarmLocation = nil
pcall(function()
	FarmLocation = Workspace.Lifts.ToiletHQ.Base
end)
print("[Cracks TTD] FarmLocation =", FarmLocation)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local LobbyGui = PlayerGui:FindFirstChild("Lobby")
local QueueFrame = LobbyGui and LobbyGui:FindFirstChild("QueueFrame", true)
local Start = QueueFrame and QueueFrame:FindFirstChild("Start", true)

local MatchGui = PlayerGui:FindFirstChild("Match")
local TopFrame = MatchGui and MatchGui:FindFirstChild("TopFrame", true)
local AutoSkipFrame = TopFrame and TopFrame:FindFirstChild("AutoSkip", true)
local AutoSkipButton = AutoSkipFrame and AutoSkipFrame:FindFirstChild("OnAndOff", true)

print("[Cracks TTD] LobbyGui =", LobbyGui, "Start =", Start)
print("[Cracks TTD] MatchGui =", MatchGui, "AutoSkipButton =", AutoSkipButton)

local AntiAfk = false
local autofarm = getgenv().CracksTTD_AutoFarm == true
local running = true
local clickedSkipThisMatch = false

local Lobby = rp:FindFirstChild("IsLobby", true)
local MainGame = rp:FindFirstChild("IsMainGame", true)

print("[Cracks TTD] IsLobby =", Lobby, Lobby and Lobby.Value)
print("[Cracks TTD] IsMainGame =", MainGame, MainGame and MainGame.Value)

if not Lobby and not MainGame then
	print("[Cracks TTD] wrong game (no IsLobby/IsMainGame found)")
	-- still load UI so you can press buttons manually
end

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

function func.isLobby()
	if Lobby and Lobby:IsA("BoolValue") then
		return Lobby.Value == true
	end
	return false
end

function func.isGame()
	if MainGame and MainGame:IsA("BoolValue") then
		return MainGame.Value == true
	end
	return false
end

function func.TeleportToFarmLocation()
	if not FarmLocation then
		pcall(function()
			FarmLocation = Workspace.Lifts.ToiletHQ.Base
		end)
	end

	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		print("[Cracks TTD] TP fail: no root")
		return
	end
	if not FarmLocation then
		print("[Cracks TTD] TP fail: no FarmLocation")
		return
	end

	local part = FarmLocation
	if part:IsA("Model") then
		part = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart", true)
	end
	if not part then
		print("[Cracks TTD] TP fail: no part")
		return
	end

	root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	print("[Cracks TTD] teleported to ToiletHQ")
end

function func.ClickStartButton()
	if not Start or not Start.Parent then
		LobbyGui = PlayerGui:FindFirstChild("Lobby")
		QueueFrame = LobbyGui and LobbyGui:FindFirstChild("QueueFrame", true)
		Start = QueueFrame and QueueFrame:FindFirstChild("Start", true)
	end
	if not Start then
		print("[Cracks TTD] Start button not found")
		return
	end

	local fired = false
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
	if firesignal then
		pcall(function()
			firesignal(Start.MouseButton1Click)
			fired = true
		end)
		pcall(function()
			firesignal(Start.Activated)
			fired = true
		end)
	end
	print("[Cracks TTD] ClickStart fired =", fired, "btn =", Start:GetFullName())
end

function func.clickAutoFarmButtonOnce()
	if not AutoSkipButton or not AutoSkipButton.Parent then
		MatchGui = PlayerGui:FindFirstChild("Match")
		TopFrame = MatchGui and MatchGui:FindFirstChild("TopFrame", true)
		AutoSkipFrame = TopFrame and TopFrame:FindFirstChild("AutoSkip", true)
		AutoSkipButton = AutoSkipFrame and AutoSkipFrame:FindFirstChild("OnAndOff", true)
	end
	if not AutoSkipButton then
		print("[Cracks TTD] AutoSkip button not found")
		return
	end

	local fired = false
	if getconnections then
		for _, c in ipairs(getconnections(AutoSkipButton.MouseButton1Click)) do
			pcall(function()
				c:Fire()
				fired = true
			end)
		end
		for _, c in ipairs(getconnections(AutoSkipButton.Activated)) do
			pcall(function()
				c:Fire()
				fired = true
			end)
		end
	end
	if firesignal then
		pcall(function()
			firesignal(AutoSkipButton.MouseButton1Click)
			fired = true
		end)
		pcall(function()
			firesignal(AutoSkipButton.Activated)
			fired = true
		end)
	end
	print("[Cracks TTD] AutoSkip fired =", fired, "btn =", AutoSkipButton:GetFullName())
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
					task.wait(1)
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
		local curLobby = Lobby and Lobby:IsA("BoolValue") and Lobby.Value or false
		local curGame = MainGame and MainGame:IsA("BoolValue") and MainGame.Value or false

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
local libErr
local libOk, libRes = pcall(function()
	return game:HttpGet(
		"https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua",
		true
	)
end)
if libOk then
	libSrc = libRes
else
	libErr = libRes
	print("[Cracks TTD] lib HttpGet failed:", libErr)
end

if type(libSrc) ~= "string" then
	print("[Cracks TTD] no UI (lib missing) — farm loop still runs if AutoFarm was saved on")
else
	local chunkOk, chunk = pcall(loadstring, libSrc)
	if not chunkOk or type(chunk) ~= "function" then
		print("[Cracks TTD] lib compile failed")
	else
		local runOk, Lib = pcall(chunk)
		if not runOk or type(Lib) ~= "table" or type(Lib.Init) ~= "function" then
			print("[Cracks TTD] lib Init failed:", Lib)
		else
			local executor = "Unknown"
			pcall(function()
				if identifyexecutor then
					executor = identifyexecutor()
				end
			end)

			local GUI = Lib:Init(
				"Cracks Hub | TTD | " .. executor,
				true,
				Enum.KeyCode.LeftControl,
				"Default",
				{ Enabled = false }
			)

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

				print("[Cracks TTD] UI loaded — press LeftControl")
			else
				print("[Cracks TTD] GUI Init returned nil")
			end
		end
	end
end

print("[Cracks TTD] loaded OK")
