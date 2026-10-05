local Players = game:GetService("Players")
local rp = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Event = rp:WaitForChild("NetworkingContainer"):WaitForChild("DataRemote")

local UNIT = "DarkCamerawoman"
local POS = Vector3.new(-78.71192932128906, 2.3471102714538574, -56.20001220703125)
local SLOT = 1

local PlaceCosts = { 200, 300, 500, 700 }
local Cooldown = 0.5
local LastPlace = {}

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

task.spawn(function()
	while true do
		local money = getMoney()
		for _, need in ipairs(PlaceCosts) do
			if money >= need then
				local last = LastPlace[need] or 0
				if tick() - last >= Cooldown then
					LastPlace[need] = tick()
					placeUnit()
					task.wait(0.15)
				end
			end
		end
		task.wait(0.25)
	end
end)

print("[TTD Remote] looping places | money=", getMoney())
