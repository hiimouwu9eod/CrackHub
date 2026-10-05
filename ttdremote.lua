local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Event = rp:WaitForChild("NetworkingContainer"):WaitForChild("DataRemote")

local UNIT = "DarkCamerawoman"
local POS = Vector3.new(-78.71192932128906, 2.3471102714538574, -56.20001220703125)
local SLOT = 1

local PlaceCosts = { 200, 300, 500, 700 }
local Fired = {}

local function getMoney()
	local v = 0
	pcall(function()
		v = LocalPlayer.leaderstats.Money.Value
	end)
	return tonumber(v) or 0
end

local function placeUnit()
	pcall(function()
		Event:FireServer({
			{
				"\xE2\x81\x82\x16",
				UNIT,
				POS,
				SLOT,
			},
		})
	end)
	print("[TTD Remote] placed", UNIT, "money=", getMoney())
end

local function waitMoney(need)
	while getMoney() < need do
		task.wait(0.25)
	end
end

task.spawn(function()
	for _, need in ipairs(PlaceCosts) do
		if not Fired[need] then
			print("[TTD Remote] wait money >=", need)
			waitMoney(need)
			Fired[need] = true
			placeUnit()
			task.wait(0.35)
		end
	end
	print("[TTD Remote] all places done")
end)

print("[TTD Remote] on load money=", getMoney())
