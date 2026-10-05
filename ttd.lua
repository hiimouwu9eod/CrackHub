local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FarmMap = {
	ToiletCity = {
		Mode = "Easy",
		TpLocation = workspace.Lifts.ToiletCity.Base,
	},
}

local CurrentFarm = "ToiletCity"

local GUIS = {
	StartGui = nil,
}

pcall(function()
	GUIS.StartGui = PlayerGui.Lobby.QueueFrame.QueueFrame
end)

local AntiAfk = false
local autofarm = getgenv().CracksTTD_AutoFarm == true
local running = true
local clickedSkip = false

local SCRIPT_URL = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/ttd.lua"

local function queueSelf()
	local code = string.format([[
		getgenv().CracksTTD_AutoFarm = %s
		task.spawn(function()
			local ok, err = pcall(function()
				loadstring(game:HttpGet("%s", true))()
			end)
			if not ok then
				warn("[Cracks TTD] re-exec failed:", err)
			end
		end)
	]], tostring(getgenv().CracksTTD_AutoFarm == true), SCRIPT_URL)

	local queued = false
	for _, fn in ipairs({
		queue_on_teleport,
		syn and syn.queue_on_teleport,
		fluxus and fluxus.queue_on_teleport,
		queueonteleport,
		getgenv().queue_on_teleport,
	}) do
		if typeof(fn) == "function" then
			local ok = pcall(fn, code)
			if ok then
				queued = true
			end
		end
	end

	if queued then
		print("[Cracks TTD] execute-on-tp queued")
	else
		warn("[Cracks TTD] no queue_on_teleport — put script in AutoExec")
	end
end

-- queue every time this place loads
queueSelf()

-- re-queue when leaving this place
pcall(function()
	LocalPlayer.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Started or state == Enum.TeleportState.RequestedFromServer then
			queueSelf()
		end
	end)
end)

local func = {}

function func.GetFarm()
	return FarmMap.ToiletCity
end

function func.TeleportToFarmLocation()
	local part
	pcall(function()
		part = workspace.Lifts.ToiletCity.Base
	end)
	pcall(function()
		if part and part:IsA("Model") then
			part = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart", true)
		end
	end)

	local root
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
					local name = string.lower(d.Name)
					local text = string.lower(tostring(d.Text or ""))
					if name:find("start") or text:find("start") then
						btn = d
						break
					end
				end
			end
		end)
	end

	GUIS.StartGui = btn

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
		print("[Cracks TTD] DataRemote missing")
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
	print("[Cracks TTD] AutoSkip remote x" .. tostring(callamt))
end

function func.IsLobby()
	local v = false
	pcall(function()
		v = rp.IsLobby.Value == true
	end)
	return v
end

function func.IsGame()
	local v = false
	pcall(function()
		v = rp.IsMainGame.Value == true
	end)
	return v
end

task.spawn(function()
	while running do
		if autofarm then
			if func.IsGame() then
				if not clickedSkip then
					task.wait(1)
					func.AutoSkipRemote(1)
					clickedSkip = true
				end
				task.wait(1)
			elseif func.IsLobby() then
				clickedSkip = false
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
	libSrc = game:HttpGet(
		"https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/lib.lua",
		true
	)
end)

if type(libSrc) == "string" then
	local ok, Lib = pcall(function()
		return loadstring(libSrc)()
	end)
	if ok and type(Lib) == "table" and type(Lib.Init) == "function" then
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
				clickedSkip = false
				queueSelf()
			end)

			FarmSec:Button("TP + Start", function()
				func.TeleportAndStart()
			end)

			FarmSec:Button("TP ToiletCity", function()
				func.TeleportToFarmLocation()
			end)

			FarmSec:Button("Click Start", function()
				func.ClickStartButton()
			end)

			FarmSec:Button("AutoSkip Remote", function()
				func.AutoSkipRemote(1)
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
		end
	end
end

print("[Cracks TTD] execute-on-tp ready — LeftControl")
