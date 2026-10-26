
local ourplayer = game:GetService("Players").LocalPlayer
local options = {}

for _, child in ipairs(workspace.Lifts:GetChildren()) do
	if child.Name == "CameramanHQ" then
		table.insert(options, child)
	end
end

local Mode1 = options[1]
local Mode2 = options[2]
local Mode3 = options[3]
local Mode4 = options[4]

print("[DEBUG] Found", #options, "CameramanHQ pads")

if #options < 4 then
	warn("[DEBUG] Only found " .. #options .. " CameramanHQ objects instead of 4")
end

function GetPlayerCount(Mode)
	if not Mode then
		Mode = Mode1 or Mode2 or Mode3 or Mode4
	end
	if not Mode then
		print("[DEBUG] GetPlayerCount: No valid Mode")
		return nil
	end
	local playersCountLabel = Mode.Base.StatusGui:WaitForChild("PlayersCount", 3)
	if playersCountLabel then
		return playersCountLabel.Text
	else
		print("[DEBUG] PlayersCount label not found")
		return nil
	end
end

function GetPlayersInPad(Mode)
	if not Mode then
		Mode = Mode1 or Mode2 or Mode3 or Mode4
	end
	if not Mode then
		return {}
	end
	local Area = Mode:FindFirstChild("Area")
	if not Area then
		print("[DEBUG] No Area found in pad")
		return {}
	end

	local playersInPad = {}
	local region = Region3.new(Area.Position - (Area.Size / 2), Area.Position + (Area.Size / 2))
	local parts = workspace:FindPartsInRegion3(region, nil, 100)
	for _, part in ipairs(parts) do
		local character = part.Parent
		local player = game.Players:GetPlayerFromCharacter(character)
		if player and not table.find(playersInPad, player) then
			table.insert(playersInPad, player)
		end
	end
	return playersInPad
end

local Vim = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

function ClickStart()
	print("[DEBUG] Trying to click Start button...")

	local success, startButton = pcall(function()
		return ourplayer.PlayerGui.Lobby.QueueFrame.Start
	end)

	if not success or not startButton then
		warn("[DEBUG] Start button NOT found")
		return
	end
	
	local inset = GuiService:GetGuiInset()
	local absPos = startButton.AbsolutePosition
	local absSize = startButton.AbsoluteSize

	local centerX = absPos.X + (absSize.X / 2)
	local centerY = absPos.Y + (absSize.Y / 2) + inset.Y

	print("[DEBUG] Clicking at:", centerX, centerY)

	for i = 1, 15 do

		Vim:SendMouseMoveEvent(centerX, centerY, game)
		task.wait(0.02)

		-- Click
		Vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)  -- down
		task.wait(0.04)
		Vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1) -- up

		task.wait(0.06)
	end

	print("[DEBUG] Finished clicking")
end

function BotChoosePad()
	print("[DEBUG] BotChoosePad started")

	local character = ourplayer.Character or ourplayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local pads = {Mode1, Mode2, Mode3, Mode4}
	local currentPad = nil
	local hasClicked = false

	while true do
		task.wait(0.4)

		-- Refresh character
		if not character or not character.Parent or not hrp or not hrp.Parent then
			print("[DEBUG] Character missing, waiting...")
			character = ourplayer.Character or ourplayer.CharacterAdded:Wait()
			hrp = character:WaitForChild("HumanoidRootPart")
		end

		-- Check if current pad is still good
		local stillGood = false
		if currentPad then
			local players = GetPlayersInPad(currentPad)
			local countText = GetPlayerCount(currentPad)
			print("[DEBUG] Current pad players:", #players, "| GUI:", countText)

			local isAlone = (#players == 1 and players[1] == ourplayer) or (countText and string.find(countText, "1/"))
			local isEmpty = (#players == 0) or (countText and string.find(countText, "0/"))

			if isAlone or isEmpty then
				stillGood = true
			else
				print("[DEBUG] Current pad is no longer good")
			end
		end

		if stillGood then
			if not hasClicked then
				local players = GetPlayersInPad(currentPad)
				local countText = GetPlayerCount(currentPad)

				if (#players == 1 and players[1] == ourplayer) or (countText and string.find(countText, "1/")) then
					print("[DEBUG] Alone on pad → Clicking Start")
					task.wait(0.5)
					ClickStart()
					hasClicked = true
				end
			end
		else
			hasClicked = false
			currentPad = nil

			print("[DEBUG] Looking for empty pad...")

			local emptyPad = nil
			for i, pad in ipairs(pads) do
				if pad then
					local players = GetPlayersInPad(pad)
					local countText = GetPlayerCount(pad)
					print("[DEBUG] Pad", i, "→ Players:", #players, "| GUI:", countText)

					if #players == 0 or (countText and string.find(countText, "0/")) then
						emptyPad = pad
						print("[DEBUG] Found empty pad:", i)
						break
					end
				end
			end

			if emptyPad then
				local area = emptyPad:FindFirstChild("Area")
				if area then
					print("[DEBUG] Teleporting to empty pad")
					hrp.CFrame = CFrame.new(area.Position)
					currentPad = emptyPad
					hasClicked = false
				else
					print("[DEBUG] Empty pad has no Area")
				end
			else
				print("[DEBUG] No empty pads found → going to TeleportBox")
				local teleportBox = workspace:FindFirstChild("TeleportBox")
				if teleportBox then
					hrp.CFrame = CFrame.new(teleportBox.Position)
				else
					print("[DEBUG] TeleportBox not found")
				end
			end
		end
	end
end

-- Start the bot
print("[DEBUG] Script loaded, starting bot...")
BotChoosePad()
