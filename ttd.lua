local Workspace = game:GetService("Workspace")
local FarmLocation = Workspace:FindFirstChild("Lifts")
	and Workspace.Lifts:FindFirstChild("ToiletHQ")
	and Workspace.Lifts.ToiletHQ:FindFirstChild("Base")

local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local LobbyGui = PlayerGui:FindFirstChild("Lobby")
local QueueFrame = LobbyGui and LobbyGui:FindFirstChild("QueueFrame", true)
local Start = QueueFrame and QueueFrame:FindFirstChild("Start", true)

local MatchGui = PlayerGui:FindFirstChild("Match")
local TopFrame = MatchGui and MatchGui:FindFirstChild("TopFrame", true)
local AutoSkipFrame = TopFrame and TopFrame:FindFirstChild("AutoSkip", true)
local AutoSkipButton = AutoSkipFrame and AutoSkipFrame:FindFirstChild("OnAndOff", true)

local AntiAfk = false
local autofarm = getgenv().CracksTTD_AutoFarm == true
local running = true
local clickedSkipThisMatch = false

local Lobby = rp:FindFirstChild("IsLobby")
local MainGame = rp:FindFirstChild("IsMainGame")

if not ((Lobby and Lobby:IsA("BoolValue")) or (MainGame and MainGame:IsA("BoolValue"))) then
	print("wrong game")
	return
end

local isMain0 = MainGame and MainGame:IsA("BoolValue") and MainGame.Value == true
local isLobby0 = Lobby and Lobby:IsA("BoolValue") and Lobby.Value == true
if not isMain0 and not isLobby0 then
	print("wrong game")
	return
end

local SCRIPT_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/ttd.lua"

local queueTP = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queueTP then
	queueTP(([[
		getgenv().CracksTTD_AutoFarm = %s
		loadstring(game:HttpGet("%s", true))()
	]]):format(tostring(autofarm), SCRIPT_URL))
end

local func = {}

function func.dectetLobbyOrMainGame(MainGameFlag, lobbyFlag)
	MainGameFlag = false
	lobbyFlag = false

	if Lobby and Lobby:IsA("BoolValue") and Lobby.Value == true then
		lobbyFlag = true
	end

	if MainGame and MainGame:IsA("BoolValue") and MainGame.Value == true then
		MainGameFlag = true
	end

	return MainGameFlag, lobbyFlag
end

function func.TeleportToFarmLocation()
	if not FarmLocation then
		FarmLocation = Workspace:FindFirstChild("Lifts")
			and Workspace.Lifts:FindFirstChild("ToiletHQ")
			and Workspace.Lifts.ToiletHQ:FindFirstChild("Base")
	end
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root or not FarmLocation then
		return
	end

	local part = FarmLocation
	if part:IsA("Model") then
		part = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart", true)
	end
	if not part then
		return
	end

	root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
end

function func.ClickStartButton()
	if not Start or not Start.Parent then
		LobbyGui = PlayerGui:FindFirstChild("Lobby")
		QueueFrame = LobbyGui and LobbyGui:FindFirstChild("QueueFrame", true)
		Start = QueueFrame and QueueFrame:FindFirstChild("Start", true)
	end
	if not Start then
		return
	end

	if getconnections then
		for _, c in ipairs(getconnections(Start.MouseButton1Click)) do
			pcall(function()
				c:Fire()
			end)
		end
		for _, c in ipairs(getconnections(Start.Activated)) do
			pcall(function()
				c:Fire()
			end)
		end
	elseif firesignal then
		pcall(function()
			firesignal(Start.MouseButton1Click)
		end)
		pcall(function()
			firesignal(Start.Activated)
		end)
	end
end

function func.clickAutoFarmButtonOnce()
	if not AutoSkipButton or not AutoSkipButton.Parent then
		MatchGui = PlayerGui:FindFirstChild("MatchGui")
		TopFrame = MatchGui and MatchGui:FindFirstChild("TopFrame", true)
		AutoSkipFrame = TopFrame and TopFrame:FindFirstChild("AutoSkip", true)
		AutoSkipButton = AutoSkipFrame and AutoSkipFrame:FindFirstChild("OnAndOff", true)
	end
	if not AutoSkipButton then
		return
	end

	if getconnections then
		for _, c in ipairs(getconnections(AutoSkipButton.MouseButton1Click)) do
			pcall(function()
				c:Fire()
			end)
		end
		for _, c in ipairs(getconnections(AutoSkipButton.Activated)) do
			pcall(function()
				c:Fire()
			end)
		end
	elseif firesignal then
		pcall(function()
			firesignal(AutoSkipButton.MouseButton1Click)
		end)
		pcall(function()
			firesignal(AutoSkipButton.Activated)
		end)
	end
end

task.spawn(function()
	while running do
		local isMain, isLobby = func.dectetLobbyOrMainGame()

		if not isMain and not isLobby then
			print("wrong game")
			task.wait(2)
		elseif autofarm then
			if isLobby then
				clickedSkipThisMatch = false
				func.TeleportToFarmLocation()
				task.wait(0.6)
				func.ClickStartButton()
				task.wait(2)
			elseif isMain then
				if not clickedSkipThisMatch then
					task.wait(1)
					func.clickAutoFarmButtonOnce()
					clickedSkipThisMatch = true
				end
				task.wait(1)
			end
		else
			task.wait(0.5)
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
	libSrc = game:HttpGet(
		"https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua",
		true
	)
end)

if type(libSrc) ~= "string" then
	return
end

local Lib = loadstring(libSrc)()
if type(Lib) ~= "table" or type(Lib.Init) ~= "function" then
	return
end

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
if not GUI then
	return
end

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
