--[[
https://discord.gg/7fDasxV2Ht
enjoy auto building
i used ai for help, no hate
                                                                                    
  :::.      .,-:::::/   :::.    :::::::..       .::    .   .::::::.    :::::::..  .,::::::  
  ;;`;;   ,;;-'````'    ;;`;;   ;;;;``;;;;      ';;,  ;;  ;;;' ;;`;;   ;;;;``;;;; ;;;;''''  
 ,[[ '[[, [[[   [[[[[[/,[[ '[[,  [[[,/[[['       '[[, [[, [[' ,[[ '[[,  [[[,/[[['  [[cccc   
c$$$cc$$$c"$$c.    "$$c$$$cc$$$c $$$$$$c           Y$c$$$c$P c$$$cc$$$c $$$$$$c    $$""""   
 888   888,`Y8bo,,,o88o888   888,888b "88bo,        "88"888   888   888,888b "88bo,888oo,__ 
 YMM   ""`   `'YMUP"YMMYMM   ""` MMMM   "W"          "M "M"   YMM   ""` MMMM   "W" """"YUMMM                                                      

]]

local buildString = _G.buildString or "PUTPASTEHERE"
local buildOffset = _G.buildOffset or Vector3.new(0, 0, 0)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local CONFIG = {
	BUILD_HEIGHT_OFFSET = 12
}

_G.stopautobuild = false

-- ============================================================================
-- MATERIAL
-- ============================================================================
local SymbolToMaterial = {
	["!"] = Enum.Material.SmoothPlastic,
	["@"] = Enum.Material.Plastic,
	["#"] = Enum.Material.CeramicTiles,
	["$"] = Enum.Material.Brick,
	["%"] = Enum.Material.WoodPlanks,
	["^"] = Enum.Material.Ice,
	["&"] = Enum.Material.Grass,
	["*"] = Enum.Material.Sand,
	["("] = Enum.Material.Snow,
	[")"] = Enum.Material.Glass,
	["-"] = Enum.Material.Wood,
	["_"] = Enum.Material.Slate,
	["="] = Enum.Material.Pebble,
	["+"] = Enum.Material.Marble,
	["["] = Enum.Material.Granite,
	["]"] = Enum.Material.DiamondPlate,
	["{"] = Enum.Material.Metal,
	["}"] = Enum.Material.Asphalt,
	["~"] = Enum.Material.Concrete,
	["`"] = Enum.Material.Pavement,
	["?"] = Enum.Material.Neon
}

-- ============================================================================
-- MATERIAL NAME MAPPING
-- ============================================================================
local MaterialToPaintName = {
	[Enum.Material.SmoothPlastic] = "smooth",
	[Enum.Material.Plastic] = "plastic",
	[Enum.Material.CeramicTiles] = "tiles",
	[Enum.Material.Brick] = "bricks",
	[Enum.Material.WoodPlanks] = "planks",
	[Enum.Material.Ice] = "ice",
	[Enum.Material.Grass] = "grass",
	[Enum.Material.Sand] = "sand",
	[Enum.Material.Snow] = "snow",
	[Enum.Material.Glass] = "glass",
	[Enum.Material.Wood] = "wood",
	[Enum.Material.Slate] = "stone",
	[Enum.Material.Pebble] = "pebble",
	[Enum.Material.Marble] = "marble",
	[Enum.Material.Granite] = "granite",
	[Enum.Material.DiamondPlate] = "steel",
	[Enum.Material.Metal] = "metal",
	[Enum.Material.Asphalt] = "asphalt",
	[Enum.Material.Concrete] = "concrete",
	[Enum.Material.Pavement] = "pavement",
	[Enum.Material.Neon] = "neon"
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================
local function hexToColor(hex)
	local r = tonumber(hex:sub(1, 2), 16) / 255
	local g = tonumber(hex:sub(3, 4), 16) / 255
	local b = tonumber(hex:sub(5, 6), 16) / 255
	return Color3.new(r, g, b)
end

local function findBuildTools()
	local tools = {}
	local locations = {LocalPlayer.Character, LocalPlayer.Backpack}
	for _, location in pairs(locations) do
		if location then
			for _, item in pairs(location:GetChildren()) do
				if item:IsA("Tool") and item.Name == "Build" then
					local remote = item:FindFirstChild("Script", true)
						and item.Script:FindFirstChild("Event")
					if remote then
						table.insert(tools, {tool = item, event = remote})
					end
				end
			end
		end
	end
	return tools
end

local function findShapeTool()
	local locations = {LocalPlayer.Character, LocalPlayer.Backpack}
	for _, location in pairs(locations) do
		if location then
			for _, item in pairs(location:GetChildren()) do
				if item:IsA("Tool") and item.Name == "Shape" then
					local remote = item:FindFirstChild("Script", true)
						and item.Script:FindFirstChild("Event")
					if remote then
						return {tool = item, event = remote}
					end
				end
			end
		end
	end
	return nil
end

local function findPaintTool()
	local locations = {LocalPlayer.Character, LocalPlayer.Backpack}
	for _, location in pairs(locations) do
		if location then
			for _, item in pairs(location:GetChildren()) do
				if item:IsA("Tool") and item.Name == "Paint" then
					local remote = item:FindFirstChild("Script", true)
						and item.Script:FindFirstChild("Event")
					if remote then
						return {tool = item, event = remote}
					end
				end
			end
		end
	end
	return nil
end

local function getPlayerBricksFolder()
	local bricksFolder = workspace:FindFirstChild("Bricks")
	if not bricksFolder then return nil end
	return bricksFolder:FindFirstChild(LocalPlayer.Name)
end

local function getBrickCount()
	local playerFolder = getPlayerBricksFolder()
	if not playerFolder then return 0 end

	local count = 0
	for _, brick in pairs(playerFolder:GetChildren()) do
		if brick:IsA("BasePart") and brick.Name == "Brick" then
			count = count + 1
		end
	end
	return count
end

local function getNewestBrick()
	local playerFolder = getPlayerBricksFolder()
	if not playerFolder then return nil end

	local bricks = {}
	for _, brick in pairs(playerFolder:GetChildren()) do
		if brick:IsA("BasePart") and brick.Name == "Brick" then
			table.insert(bricks, brick)
		end
	end

	return bricks[#bricks]
end




-- ============================================================================
-- DElETE BLOCK
-- ============================================================================
local function deleteBrick(brick)
	local deleteTool = nil
	local locations = {LocalPlayer.Character, LocalPlayer.Backpack}
	for _, location in pairs(locations) do
		if location then
			for _, item in pairs(location:GetChildren()) do
				if item:IsA("Tool") and item.Name == "Delete" then
					local remote = item:FindFirstChild("Script", true) and item.Script:FindFirstChild("Event")
					if remote then
						deleteTool = {tool = item, event = remote}
						break
					end
				end
			end
		end
		if deleteTool then break end
	end

	if not deleteTool then return false end

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	pcall(function()
		deleteTool.event:FireServer(brick, hrp.Position)
	end)

	return true
end







-- ============================================================================
-- NOCLIP
-- ============================================================================
local noclipConnection = nil
local nocollideParts = {"Head", "Left Arm", "Right Arm", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm"}

local function setCollisionDefaults()
	local character = LocalPlayer.Character
	if not character then return end
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			local shouldCollide = true
			for _, name in pairs(nocollideParts) do
				if part.Name == name then
					shouldCollide = false
					break
				end
			end
			part.CanCollide = shouldCollide
		end
	end
end

local function enableNoclip()
	if noclipConnection then
		noclipConnection:Disconnect()
	end

	noclipConnection = RunService.Stepped:Connect(function()
		local character = LocalPlayer.Character
		if not character then return end
		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

local function disableNoclip()
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	setCollisionDefaults()

	local character = LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

-- ============================================================================
-- EQUIP TOOLS
-- ============================================================================
local toolEquipConnection = nil
local isBuilding = false

local function startToolForcing()
	isBuilding = true

	if LocalPlayer.Character then
		for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") and (tool.Name == "Build" or tool.Name == "Paint" or tool.Name == "Shape" or tool.Name == "Delete") then
				tool.Parent = LocalPlayer.Character
			end
		end
	end

	if toolEquipConnection then
		toolEquipConnection:Disconnect()
	end

	toolEquipConnection = LocalPlayer.Backpack.ChildAdded:Connect(function(tool)
		if not isBuilding then return end

		if tool:IsA("Tool") and (tool.Name == "Build" or tool.Name == "Paint" or tool.Name == "Shape" or tool.Name == "Delete") then
			task.wait(0.01)
			if LocalPlayer.Character and tool.Parent == LocalPlayer.Backpack then
				tool.Parent = LocalPlayer.Character
			end
		end
	end)
end

local function stopToolForcing()
	isBuilding = false
	if toolEquipConnection then
		toolEquipConnection:Disconnect()
		toolEquipConnection = nil
	end
end

-- ============================================================================
-- POSITION LOCKING
-- ============================================================================
local positionLock = nil

local function lockPosition(targetPos)
	if positionLock then
		positionLock:Disconnect()
	end
	positionLock = RunService.RenderStepped:Connect(function()
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local hrp = char.HumanoidRootPart
			hrp.CFrame = CFrame.new(targetPos)
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end
	end)
end

local function unlockPosition()
	if positionLock then
		positionLock:Disconnect()
		positionLock = nil
	end
end

-- ============================================================================
-- BLOCK DETECTION
-- ============================================================================
local function findBlockNear(targetPos, searchRadius)
	local playerFolder = getPlayerBricksFolder()
	if not playerFolder then return nil end

	local closestBrick = nil
	local closestDist = searchRadius or 1

	for _, brick in pairs(playerFolder:GetChildren()) do
		if brick:IsA("BasePart") and brick.Name == "Brick" then
			local dist = (brick.Position - targetPos).Magnitude
			if dist < closestDist then
				closestBrick = brick
				closestDist = dist
			end
		end
	end

	return closestBrick
end

-- ============================================================================
-- CALCULATE CORNER POSITION
-- ============================================================================
local function getCornerPosition(centerPos, size)
	local halfSize = size / 2
	return Vector3.new(
		centerPos.X - halfSize.X + 0.5,
		centerPos.Y - halfSize.Y + 0.5,
		centerPos.Z - halfSize.Z + 0.5
	)
end

-- ============================================================================
-- PAINT BLOCK
-- ============================================================================
local function paintBlock(brick, color, material)
	local paintTool = findPaintTool()
	if not paintTool then return false end

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local materialName = MaterialToPaintName[material] or "smooth"

	for i = 1, 2 do
		pcall(function()
			paintTool.event:FireServer(
				brick,
				Enum.NormalId.Left,
				hrp.Position,
				"both 🤝",
				color,
				materialName,
				""
			)
		end)
		task.wait(0.05)
	end

	return true
end


-- ============================================================================
-- SPRAY BLOCK
-- ============================================================================
local function sprayBlock(brick, face, text, colorHex)
	local paintTool = findPaintTool()
	if not paintTool then return false end

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local sprayColor = hexToColor(colorHex)

	pcall(function()
		paintTool.event:FireServer(
			brick,
			face,
			hrp.Position,
			"both 🤝",
			sprayColor,
			"spray",
			text
		)
	end)

	return true
end




-- ============================================================================
-- SHAPE TOOL RESIZING
-- ============================================================================
local function resizeBlock(brick, targetSize)
	local shapeTool = findShapeTool()
	if not shapeTool or not brick then return false end

	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local hrpPos = hrp.Position

	local rightResizes = math.floor(targetSize.X - 1)
	local topResizes = math.floor(targetSize.Y - 1)
	local backResizes = math.floor(targetSize.Z - 1)

	local maxResizes = math.max(rightResizes, topResizes, backResizes)

	for iteration = 1, maxResizes do
		local needsRight = iteration <= rightResizes
		local needsTop = iteration <= topResizes
		local needsBack = iteration <= backResizes

		-- Count how many sides are active this iteration
		local activeSides = 0
		if needsRight then activeSides = activeSides + 1 end
		if needsTop then activeSides = activeSides + 1 end
		if needsBack then activeSides = activeSides + 1 end

		local currentBrick = getNewestBrick()
		if not currentBrick then return false end

		-- Apply waits based on number of active sides
		if activeSides == 1 then
			-- 1 side active: 0.1s wait
			if needsRight then
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Right, hrpPos, "increase")
				end)
			elseif needsTop then
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Top, hrpPos, "increase")
				end)
			elseif needsBack then
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Back, hrpPos, "increase")
				end)
			end
			task.wait(0.1)

		elseif activeSides == 2 then
			-- 2 sides active: first side, 0.08s delay, second side, 0.16s wait
			local firstDone = false

			if needsRight then
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Right, hrpPos, "increase")
				end)
				firstDone = true
			end

			if needsTop then
				if firstDone then task.wait(0.08) end
				currentBrick = getNewestBrick()
				if not currentBrick then return false end
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Top, hrpPos, "increase")
				end)
				firstDone = true
			end

			if needsBack then
				if firstDone then task.wait(0.08) end
				currentBrick = getNewestBrick()
				if not currentBrick then return false end
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Back, hrpPos, "increase")
				end)
			end

			task.wait(0.16)

		else
			-- 3 sides active: 0.07s delays, 0.2s wait
			if needsRight then
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Right, hrpPos, "increase")
				end)
			end

			if needsTop then
				task.wait(0.07)
				currentBrick = getNewestBrick()
				if not currentBrick then return false end
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Top, hrpPos, "increase")
				end)
			end

			if needsBack then
				task.wait(0.07)
				currentBrick = getNewestBrick()
				if not currentBrick then return false end
				pcall(function()
					shapeTool.event:FireServer(currentBrick, Enum.NormalId.Back, hrpPos, "increase")
				end)
			end

			task.wait(0.2)
		end
	end

	return true
end

-- ============================================================================
-- PARSE BUILD STRING
-- ============================================================================
local function parseBlocks(buildStr)
	local blocks = {}
	for blockData in buildStr:gmatch("|([^|]+)") do
		local colorHex = blockData:sub(1, 6)
		local materialSymbol = blockData:sub(7, 7)
		local rest = blockData:sub(8)
		local canCollide = true
		if rest:sub(1, 1) == "^" then
			canCollide = false
			rest = rest:sub(2)
		end

		-- Match size.position first, then everything after
		local sizeData, posData, extraData = rest:match("^([%d,]+)%.([%-%.%d,]+)%.?(.*)")

		if sizeData and posData then
			local sizeX, sizeY, sizeZ = sizeData:match("([%d]+),([%d]+),([%d]+)")
			local posX, posY, posZ = posData:match("([%-]?%d+%.?%d*),([%-]?%d+%.?%d*),([%-]?%d+%.?%d*)")

			if sizeX and posX then
				local size = Vector3.new(tonumber(sizeX), tonumber(sizeY), tonumber(sizeZ))
				local centerPos = Vector3.new(tonumber(posX), tonumber(posY), tonumber(posZ)) + buildOffset

				local is4x4x4 = (size == Vector3.new(4, 4, 4))
				local function mod4(n)
					return ((n % 4) + 4) % 4
				end
				local onGrid = mod4(centerPos.X) == 2 and mod4(centerPos.Y) == 2 and mod4(centerPos.Z) == 2

				local needsResize = not (is4x4x4 and onGrid)

				-- Parse sprays from extraData
				local sprays = {}
				if extraData and extraData ~= "" then
					-- Match all spray patterns: Face"text""color"
					for face, text, color in extraData:gmatch('(%a+)"([^"]*)""([^"]*)"') do
						local faceMap = {
							L = Enum.NormalId.Left,
							R = Enum.NormalId.Right,
							T = Enum.NormalId.Top,
							Bo = Enum.NormalId.Bottom,
							F = Enum.NormalId.Front,
							Ba = Enum.NormalId.Back
						}
						local normalId = faceMap[face]
						if normalId then
							table.insert(sprays, {face = normalId, text = text or "", colorHex = color})
						end
					end
				end

				table.insert(blocks, {
					size = size,
					centerPos = centerPos,
					color = hexToColor(colorHex),
					material = SymbolToMaterial[materialSymbol] or Enum.Material.SmoothPlastic,
					canCollide = canCollide,
					needsResize = needsResize,
					sprays = sprays
				})
			end
		end
	end
	return blocks
end

-- ============================================================================
-- VISUALIZATION
-- ============================================================================
local function createPreviews(blocks)
	local folder = Instance.new("Folder")
	folder.Name = "BuildPreview"
	folder.Parent = workspace

	for i, blockData in ipairs(blocks) do
		local preview = Instance.new("Part")
		preview.Name = "Preview_" .. i
		preview.Size = blockData.size
		preview.CFrame = CFrame.new(blockData.centerPos)
		preview.Anchored = true
		preview.CanCollide = false
		preview.Material = blockData.material
		preview.Color = blockData.color
		preview.Transparency = 0.5
		preview.Parent = folder
		blockData.preview = preview
	end

	return folder
end

-- ============================================================================
-- CLEANUP FUNCTION
-- ============================================================================
local function cleanup(previewFolder)
	unlockPosition()
	stopToolForcing()
	disableNoclip()

	if previewFolder then
		pcall(function() previewFolder:Destroy() end)
	end
end

-- ============================================================================
-- PLACE BLOCK
-- ============================================================================
local function placeBlock(blockData, buildTools)
	local tpPos = blockData.needsResize and getCornerPosition(blockData.centerPos, blockData.size) or blockData.centerPos
	local buildPos = tpPos + Vector3.new(0, CONFIG.BUILD_HEIGHT_OFFSET, 0)
	lockPosition(buildPos)

	local existing = findBlockNear(blockData.centerPos, 1)
	if existing then
		return true
	end

	task.wait(0.01)

	local placePos
	if blockData.needsResize then
		placePos = getCornerPosition(blockData.centerPos, blockData.size)
	else
		placePos = blockData.centerPos
	end

	local placeMode
	if not blockData.canCollide then
		placeMode = blockData.needsResize and "detailed nocollide" or "nocollide"
	else
		placeMode = blockData.needsResize and "detailed" or "normal"
	end

	local playerFolder = getPlayerBricksFolder()
	local adjacentBrick = nil
	local adjacentFace = nil

	if playerFolder then
		for _, brick in pairs(playerFolder:GetChildren()) do
			if brick:IsA("BasePart") and brick.Name == "Brick" then
				local colorMatch = math.abs(brick.Color.R - blockData.color.R) < 0.01 and 
					math.abs(brick.Color.G - blockData.color.G) < 0.01 and 
					math.abs(brick.Color.B - blockData.color.B) < 0.01
				local materialMatch = brick.Material == blockData.material
				local sizeMatch = brick.Size == blockData.size
				local canCollideMatch = brick.CanCollide == blockData.canCollide

				if colorMatch and materialMatch and sizeMatch and canCollideMatch then
					local halfSize1 = blockData.size / 2
					local halfSize2 = brick.Size / 2
					local posDiff = blockData.centerPos - brick.Position

					local expectedDistX = halfSize1.X + halfSize2.X
					local expectedDistY = halfSize1.Y + halfSize2.Y
					local expectedDistZ = halfSize1.Z + halfSize2.Z

					if math.abs(math.abs(posDiff.X) - expectedDistX) < 1 and 
						math.abs(posDiff.Y) < halfSize1.Y + 0.5 and 
						math.abs(posDiff.Z) < halfSize1.Z + 0.5 then
						adjacentFace = posDiff.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left
					elseif math.abs(math.abs(posDiff.Y) - expectedDistY) < 1 and 
						math.abs(posDiff.X) < halfSize1.X + 0.5 and 
						math.abs(posDiff.Z) < halfSize1.Z + 0.5 then
						adjacentFace = posDiff.Y > 0 and Enum.NormalId.Top or Enum.NormalId.Bottom
					elseif math.abs(math.abs(posDiff.Z) - expectedDistZ) < 1 and 
						math.abs(posDiff.X) < halfSize1.X + 0.5 and 
						math.abs(posDiff.Y) < halfSize1.Y + 0.5 then
						adjacentFace = posDiff.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front
					end

					if adjacentFace then
						local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if hrp then
							local distanceToFace = (brick.Position - hrp.Position).Magnitude
							if distanceToFace <= 25 then
								-- Verify the adjacent placement would put block at correct position
								local expectedPos = blockData.centerPos
								local testPos = brick.Position

								-- Calculate where adjacent placement would actually put the block
								if adjacentFace == Enum.NormalId.Right then
									testPos = brick.Position + Vector3.new(brick.Size.X/2 + blockData.size.X/2, 0, 0)
								elseif adjacentFace == Enum.NormalId.Left then
									testPos = brick.Position - Vector3.new(brick.Size.X/2 + blockData.size.X/2, 0, 0)
								elseif adjacentFace == Enum.NormalId.Top then
									testPos = brick.Position + Vector3.new(0, brick.Size.Y/2 + blockData.size.Y/2, 0)
								elseif adjacentFace == Enum.NormalId.Bottom then
									testPos = brick.Position - Vector3.new(0, brick.Size.Y/2 + blockData.size.Y/2, 0)
								elseif adjacentFace == Enum.NormalId.Back then
									testPos = brick.Position + Vector3.new(0, 0, brick.Size.Z/2 + blockData.size.Z/2)
								elseif adjacentFace == Enum.NormalId.Front then
									testPos = brick.Position - Vector3.new(0, 0, brick.Size.Z/2 + blockData.size.Z/2)
								end

								-- Check if the adjacent placement position matches the target position
								if (testPos - expectedPos).Magnitude < 0.5 then
									adjacentBrick = brick
									break
								else
									adjacentFace = nil
								end
							else
								adjacentFace = nil
							end
						end
					end
				end
			end
		end
	end

	local initialCount = getBrickCount()
	local toolIndex = 1
	local bt = buildTools[toolIndex]

	local retryDelay = blockData.canCollide and 0.05 or 0.2

	if adjacentBrick and adjacentFace then
		local adjacentPlaceMode = blockData.canCollide and "normal" or "nocollide"

		pcall(function()
			bt.event:FireServer(adjacentBrick, adjacentFace, placePos, adjacentPlaceMode)
		end)

		local attempts = 0
		local maxAttempts = 40
		while getBrickCount() == initialCount and attempts < maxAttempts do
			task.wait(retryDelay)

			if getBrickCount() > initialCount then
				break
			end

			attempts = attempts + 1
			pcall(function()
				bt.event:FireServer(adjacentBrick, adjacentFace, placePos, adjacentPlaceMode)
			end)
		end

		if getBrickCount() == initialCount then
			return false
		end

		local newBrick = getNewestBrick()
		if newBrick then
			blockData.placedBrick = newBrick
		end

		return true
	else
		pcall(function()
			bt.event:FireServer(workspace.Terrain, Enum.NormalId.Top, placePos, placeMode)
		end)

		local attempts = 0
		local maxAttempts = 40

		while getBrickCount() == initialCount and attempts < maxAttempts do
			task.wait(retryDelay)

			if getBrickCount() > initialCount then
				break
			end

			attempts = attempts + 1

			pcall(function()
				bt.event:FireServer(workspace.Terrain, Enum.NormalId.Top, placePos, placeMode)
			end)
		end

		if getBrickCount() == initialCount then
			return false
		end

		local newBrick = getNewestBrick()
		if not newBrick then return false end

		task.wait(0.02)

		paintBlock(newBrick, blockData.color, blockData.material)
		
		-- SPRAY IF ANY
		if blockData.sprays and #blockData.sprays > 0 then
			task.wait(0.03)
			for _, spray in ipairs(blockData.sprays) do
				sprayBlock(newBrick, spray.face, spray.text, spray.colorHex)
				task.wait(0.03)
			end
		end

		if not blockData.canCollide then
			task.wait(0.03)
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local paintTool = findPaintTool()
			if paintTool and hrp then
				pcall(function()
					paintTool.event:FireServer(newBrick, Enum.NormalId.Back, hrp.Position, "material", blockData.color, "collide", "")
				end)
			end
		end

		if blockData.needsResize and blockData.size ~= Vector3.new(1, 1, 1) then
			task.wait(0.02)
			resizeBlock(newBrick, blockData.size)
		end

		blockData.placedBrick = newBrick
		return true
	end
end
-- ============================================================================
-- NEAREST UNBUILT BLOCK SELECTOR
-- ============================================================================
local function getNearestUnbuiltIndex(blocks, done)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local bestIndex = nil
	local bestDist = math.huge

	for i, blockData in ipairs(blocks) do
		if not done[i] then
			local dist = (hrp.Position - blockData.centerPos).Magnitude
			if dist < bestDist then
				bestDist = dist
				bestIndex = i
			end
		end
	end

	return bestIndex
end

-- ============================================================================
-- MAIN BUILD PROCESS
-- ============================================================================
local function main()
	_G.stopautobuild = false

	local blocks = parseBlocks(buildString)
	if #blocks == 0 then
		return
	end

	local previewFolder = createPreviews(blocks)

	local buildTools = findBuildTools()
	local shapeTool = findShapeTool()
	local paintTool = findPaintTool()

	if #buildTools == 0 then
		cleanup(previewFolder)
		return
	end

	if not shapeTool then
		cleanup(previewFolder)
		return
	end

	if not paintTool then
		cleanup(previewFolder)
		return
	end

	startToolForcing()
	enableNoclip()

	local successCount = 0
	local failCount = 0
	local totalBlocks = #blocks
	local done = {}
	local placed = 0
	local previousBlock = nil
	local needsFixing = nil

	while placed < totalBlocks do
		if _G.stopautobuild then
			cleanup(previewFolder)
			return
		end

		buildTools = findBuildTools()
		shapeTool = findShapeTool()
		paintTool = findPaintTool()

		if #buildTools == 0 or not shapeTool or not paintTool then
			cleanup(previewFolder)
			return
		end






		-- Check if there's a block that needs fixing from LAST iteration
		if needsFixing then
			print("Fixing incorrect block before continuing...")

			-- Delete the wrong brick WITHOUT moving
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and needsFixing.placedBrick and needsFixing.placedBrick.Parent then
				deleteBrick(needsFixing.placedBrick)
				task.wait(0.1)

				-- TP to empty space where block should be
				unlockPosition()
				local tpPos = needsFixing.needsResize and getCornerPosition(needsFixing.centerPos, needsFixing.size) or needsFixing.centerPos
				local buildPos = tpPos + Vector3.new(0, CONFIG.BUILD_HEIGHT_OFFSET, 0)
				lockPosition(buildPos)
				task.wait(0.05)

				-- Place new block (no adjacent detection since old one is deleted)
				placeBlock(needsFixing, buildTools)
			end

			needsFixing = nil
			unlockPosition()
			task.wait(0.05)
		end





		local i = getNearestUnbuiltIndex(blocks, done)
		if not i then break end

		local blockData = blocks[i]
		local success = placeBlock(blockData, buildTools)

		if success then
			done[i] = true
			placed = placed + 1
			successCount = successCount + 1
			_G.autobuildPlaced = successCount

			if blockData.preview then
				pcall(function()
					blockData.preview:Destroy()
				end)
			end

			-- Check if PREVIOUS block size is correct WHILE at current block
			if previousBlock and previousBlock.needsResize and previousBlock.placedBrick then
				local brick = previousBlock.placedBrick
				if brick and brick.Parent and brick.Size ~= previousBlock.size then
					-- Mark for fixing on NEXT teleport
					needsFixing = previousBlock
					print("Previous block size wrong, will fix on next TP")
				end
			end

			-- Store as previous block
			previousBlock = blockData
		else
			failCount = failCount + 1
		end

		unlockPosition()
		task.wait(0.05)
	end  -- This is line 960, the end of the while loop

	-- Fix any remaining failed block after main loop ends
	if needsFixing then
		print("Fixing final incorrect block...")

		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp and needsFixing.placedBrick and needsFixing.placedBrick.Parent then
			deleteBrick(needsFixing.placedBrick)
			task.wait(0.1)

			unlockPosition()
			local tpPos = needsFixing.needsResize and getCornerPosition(needsFixing.centerPos, needsFixing.size) or needsFixing.centerPos
			local buildPos = tpPos + Vector3.new(0, CONFIG.BUILD_HEIGHT_OFFSET, 0)
			lockPosition(buildPos)
			task.wait(0.05)

			placeBlock(needsFixing, buildTools)
			unlockPosition()
		end
	end

	cleanup(previewFolder)  -- This stays here
end

main()
