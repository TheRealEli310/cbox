
-- Made by Xelostar: https://www.youtube.com/channel/UCDE2STpSWJrIUyKtiYGeWxw

local function round(number)
	return math.floor(number + 0.5)
end

local function sortVertices(vertices, objectX, objectY, objectZ, cameraX, cameraY, cameraZ)
	local sortedVertices = {}
	
	for vertexNr, vertex in pairs(vertices) do
		local avgX = (math.min(unpack({vertex.x1 + objectX, vertex.x2 + objectX, vertex.x3 + objectX})) + math.max(unpack({vertex.x1 + objectX, vertex.x2 + objectX, vertex.x3 + objectX}))) / 2
		local avgY = (math.min(unpack({vertex.y1 + objectY, vertex.y2 + objectY, vertex.y3 + objectY})) + math.max(unpack({vertex.y1 + objectY, vertex.y2 + objectY, vertex.y3 + objectY}))) / 2
		local avgZ = (math.min(unpack({vertex.z1 + objectZ, vertex.z2 + objectZ, vertex.z3 + objectZ})) + math.max(unpack({vertex.z1 + objectZ, vertex.z2 + objectZ, vertex.z3 + objectZ}))) / 2

		local dX = cameraX - avgX
		local dY = cameraY - avgY
		local dZ = cameraZ - avgZ

		local distance = math.pow(math.pow(dX, 2) + math.pow(dY, 2) + math.pow(dZ, 2), 0.5)

		table.insert(sortedVertices, vertex)
		sortedVertices[table.getn(sortedVertices)].distance = distance
	end
	
	table.sort(sortedVertices, function(a, b) return a.distance > b.distance end)
	
	return sortedVertices
end

local function loadModel(modelName, modelsDir)
	local modelFile = fs.open(modelsDir.."/"..modelName, "r")
	content = modelFile.readAll()
	modelFile.close()

	local model = textutils.unserialise(content)

	return model
end

local function rotateVector(x, y, z, rotationY)
	x = x + 0.0000001
	y = y + 0.0000001
	z = z + 0.0000001
	local hAlpha = math.deg(math.atan(x / z))
	if (z < 0) then
		if (x < 0) then
			hAlpha = hAlpha - 180
		else
			hAlpha = hAlpha + 180
		end
	else
		hAlpha = hAlpha
	end

	local hAlpha2 = hAlpha + rotationY
	if (hAlpha2 > 180) then
		while (hAlpha2 > 180) do
			hAlpha2 = hAlpha2 - 360
		end
	elseif (hAlpha2 < -180) then
		while (hAlpha2 < -180) do
			hAlpha2 = hAlpha2 + 360
		end
	end

	local hDistance = x / math.sin(math.rad(hAlpha))

	local x = hDistance * math.sin(math.rad(hAlpha2))
	local z = hDistance * math.cos(math.rad(hAlpha2))

	return x, y, z
end

local function rotateModel(model, rotationY)
	if (rotationY ~= 0) then
		local rotatedModel = {}

		for vertexNr, vertex in pairs(model) do
			local x1, y1, z1 = rotateVector(vertex.x1, vertex.y1, vertex.z1, rotationY)
			local x2, y2, z2 = rotateVector(vertex.x2, vertex.y2, vertex.z2, rotationY)
			local x3, y3, z3 = rotateVector(vertex.x3, vertex.y3, vertex.z3, rotationY)

			table.insert(rotatedModel, {x1 = x1, y1 = y1, z1 = z1, x2 = x2, y2 = y2, z2 = z2, x3 = x3, y3 = y3, z3 = z3, c = vertex.c, forceRender = vertex.forceRender})
		end

		return rotatedModel
	else
		return model
	end
end

local function sortObjects(objects, cameraX, cameraY, cameraZ, renderDistance)
	local sortedObjects = {}
	
	for objectNr, object in pairs(objects) do
		local distance = ((math.abs(cameraX - object.x)) ^ 2 + (math.abs(cameraY - object.y)) ^ 2 + (math.abs(cameraZ - object.z)) ^ 2) ^ 0.5
		if (distance <= renderDistance) then
			object.distance = distance
			table.insert(sortedObjects, object)
		end
	end
	
	table.sort(sortedObjects, function (a, b) return a.distance > b.distance end)
	
	return sortedObjects
end
 
local function rotate90(vector)
	local newVector = {x = -vector.y, y = vector.x}
	return newVector
end
 
local function dot(a, b)
	return (a.x * b.x + a.y * b.y)
end
 
local function isFacingCamera(pointA, pointB, pointC)
	local dirAB = {}
	dirAB.x = pointB.x - pointA.x
	dirAB.y = pointB.y - pointA.y
 
	local dirBC = {}
	dirBC.x = pointC.x - pointB.x
	dirBC.y = pointC.y - pointB.y
 
	if (dot(rotate90(dirAB), dirBC) < 0) then
		return true
	end
 
	return false
end
 
function newFrame(x1, y1, x2, y2, FoV, cameraX, cameraY, cameraZ, cameraDirZ, cameraDirY, groundColor, modelsDir)
	local frame = {}
	frame.modelsDir = modelsDir
	frame.models = {}
 
	frame.frameX1 = x1
	frame.frameY1 = y1
	frame.frameX2 = x2
	frame.frameY2 = y2

	frame.buffer = bufferAPI.newBuffer(x1, y1, x2, y2)
	frame.buffer:clear(colors.white)

	frame.blittleOn = false

	frame.groundColor = groundColor
 
	frame.renderDistance = 20
	frame.FoV = FoV
	frame.d = 0.2
	frame.t = math.tan(math.rad(FoV / 2)) * 2 * frame.d
 
	frame.cameraDirZ = cameraDirZ
	frame.cameraDirY = cameraDirY
 
	frame.cameraX = cameraX
	frame.cameraY = cameraY
	frame.cameraZ = cameraZ
 
	function frame:setSize(x1, y1, x2, y2)
		frame.frameX1 = x1
		frame.frameY1 = y1
		frame.frameX2 = x2
		frame.frameY2 = y2
 
		if (frame.blittleOn == false) then
			frame.buffer:setBufferSize(x1, y1, x2, y2)
		else
			frame.buffer:setBufferSize(x1 * 2, y1 * 3, x2 * 2, y2 * 3)
		end
	end
 
	function frame:useBLittle(use)
		frame.blittleOn = use
		if (use == true) then
			frame.buffer:setBufferSize((frame.frameX1 - 1) * 2 + 1, (frame.frameY1 - 1) * 3 + 1, (frame.frameX2) * 2, (frame.frameY2 + 1) * 3)
		else
			frame.buffer:setBufferSize(frame.frameX1, frame.frameY1, frame.frameX2, frame.frameY2)
		end
	end
 
	function frame:setCamera(cameraX, cameraY, cameraZ, cameraDirY, cameraDirZ, FoV)
		frame.cameraX = cameraX + 0.001
		frame.cameraY = cameraY + 0.001
		frame.cameraZ = cameraZ + 0.001
 
		if (cameraDirY ~= nil) then
			frame.cameraDirY = cameraDirY + 0.001
		end
		if (cameraDirZ ~= nil) then
			frame.cameraDirZ = cameraDirZ + 0.001
		end
		if (FoV ~= nil) then
			frame.FoV = FoV
		end
	end
 
	function frame:setRenderDistance(renderDistance)
		frame.renderDistance = renderDistance
	end
 
	function frame:findPointOnScreen(oX, oY, oZ, blittleOn)
		local dX = oX - frame.cameraX
		local dY = oY - frame.cameraY
		local dZ = oZ - frame.cameraZ
 
		-- Horizontal rotation
 
		local hAlpha = math.deg(math.atan(dX / dZ))
		if (dZ < 0) then
			if (dX < 0) then
				hAlpha = hAlpha - 180
			else
				hAlpha = hAlpha + 180
			end
		else
			hAlpha = hAlpha
		end
 
		local hAlpha2 = hAlpha + frame.cameraDirY
		if (hAlpha2 > 180) then
			while (hAlpha2 > 180) do
				hAlpha2 = hAlpha2 - 360
			end
		elseif (hAlpha2 < -180) then
			while (hAlpha2 < -180) do
				hAlpha2 = hAlpha2 + 360
			end
		end
 
		local hDistance = dX / math.sin(math.rad(hAlpha))
 
		local dX = hDistance * math.sin(math.rad(hAlpha2))
		local dZ = hDistance * math.cos(math.rad(hAlpha2))
 
		-- Vertical rotation
 
		local vAlpha = math.deg(math.atan(dY / dX))
 
		if (dX < 0) then
			if (dY < 0) then
				vAlpha = vAlpha - 180
			else
				vAlpha = vAlpha + 180
			end
		else
			vAlpha = vAlpha
		end
 
		local vAlpha2 = vAlpha - frame.cameraDirZ
		if (vAlpha2 > 180) then
			vAlpha2 = vAlpha2 - 360
		elseif (hAlpha2 < -180) then
			vAlpha2 = vAlpha2 + 360
		end
 
		local vDistance = dX / math.cos(math.rad(vAlpha))
 
		local dY = vDistance * math.sin(math.rad(vAlpha2))
		local dX = vDistance * math.cos(math.rad(vAlpha2))
		
		-- Recalculating horizontal angle after vertical rotation
 
		local hAlpha3 = math.deg(math.atan(dX / dZ))
		if (dZ < 0) then
			if (dX < 0) then
				hAlpha3 = hAlpha3 - 180
			else
				hAlpha3 = hAlpha3 + 180
			end
		else
			hAlpha3 = hAlpha3
		end
 
		-- Using the angles to calculate the coordinates on the screen
 
		if (hAlpha3 > 0 and hAlpha3 < 90) then
			tx = frame.d / math.tan(math.rad(hAlpha3))
		elseif (hAlpha3 >= 90 and hAlpha3 < 180) then
			if (hAlpha3 - 90 < -180) then
				tx = frame.d * -math.tan(math.rad(hAlpha3 - 90 + 360))
			else
				tx = frame.d * -math.tan(math.rad(hAlpha3 - 90))
			end
		end
 
		local onScreen = true
		if (vAlpha2 >= 90 or vAlpha2 <= -90) then
			onScreen = false
		end
		if (hAlpha3 >= 180 * frame.FoV or hAlpha3 <= 0) then
			onScreen = false
		end
 
		local width = frame.frameX2 - frame.frameX1 + 1
		local height = frame.frameY2 - frame.frameY1 + 1
 
		local pixelratio = 3 / 2
		if (blittleOn == true) then
			width = width * 2
			height = height * 3
			pixelratio = 1
		end
 
		local x = tx / frame.t * width + math.floor(width / 2) + 1
		local y = -frame.d * math.tan(math.rad(vAlpha2)) / (frame.t / width * height * pixelratio) * height + math.floor(height / 2)
 
		if (y ~= y) then
			y = math.floor(height / 2)
		end
 
		return x, y, onScreen
	end
 
	function frame:loadObject(object)
		local x = object.x
		local y = object.y
		local z = object.z
 
		local oX, oY, onScreen = frame:findPointOnScreen(x, y, z, frame.blittleOn)
 
		if (oX ~= nil) then
			local modelName = object.model
			if (modelName == "flip") then
				local oWidth = object.width
				local oHeight = object.height
 
				local x1, y1 = frame:findPointOnScreen(x, y + oHeight, z, frame.blittleOn)
				local x2, y2 = frame:findPointOnScreen(x, y, z, frame.blittleOn)
 
				local height = math.abs(y2 - y1)
				local width = 1
				if (frame.blittleOn == true) then
					width = math.abs(height * oWidth / oHeight)
				else
					width = math.abs(height * oWidth / oHeight * 3 / 2)
				end
 
				height = math.floor(height)
				width = math.floor(width)
 
				local color = object.color
 
				if (x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil) then 
					frame.buffer:loadBox(x1 - (0.5 * width), y1, x2 + (0.5 * width), y2, color, color, " ")
				end
			else
				local model = {}
				if (frame.models[modelName] ~= nil) then
					model = frame.models[modelName]
				else
					model = loadModel(modelName, frame.modelsDir)
					frame.models[modelName] = model
				end
 
				local rotatedModel = rotateModel(model, object.rotationY)
				local sortedVertices = sortVertices(rotatedModel, x, y, z, frame.cameraX, frame.cameraY, frame.cameraZ)
 
				for vertexNr, vertex in pairs(sortedVertices) do
					local x1, y1, onScreen1 = frame:findPointOnScreen(x + vertex.x1, y + vertex.y1, z + vertex.z1, frame.blittleOn)
					local x2, y2, onScreen2 = frame:findPointOnScreen(x + vertex.x2, y + vertex.y2, z + vertex.z2, frame.blittleOn)
					local x3, y3, onScreen3 = frame:findPointOnScreen(x + vertex.x3, y + vertex.y3, z + vertex.z3, frame.blittleOn)
 
					if (vertex.forceRender == true or isFacingCamera({x = x1, y = y1}, {x = x2, y = y2}, {x = x3, y = y3}) == true) then
						local vertexColor = vertex.c
 
						if (onScreen1 == true and onScreen2 == true and onScreen3 == true) then
							frame.buffer:loadTriangle(round(x1), round(y1), round(x2), round(y2), round(x3), round(y3), vertexColor)
						end
					end
				end
			end
		end
	end
 
	function frame:loadObjects(objects)
		local sortedObjects = sortObjects(objects, frame.cameraX, frame.cameraY, frame.cameraZ, frame.renderDistance)
 
		for objNr, object in pairs(sortedObjects) do
			frame:loadObject(object)
		end
	end
 
	function frame:drawBuffer()
		frame.buffer:drawBuffer(frame.blittleOn)
		frame.buffer:clear(colors.white)
	end
 
	function frame:loadGround(color)
		local distance = 10
		local gX = distance * math.cos(math.rad(frame.cameraDirY)) + frame.cameraX
		local gZ = distance * math.sin(math.rad(frame.cameraDirY)) + frame.cameraZ
		local x, y = frame:findPointOnScreen(gX, frame.cameraY -0.01, gZ, frame.blittleOn)
 
		if (y < 0) then y = 0 end
		if (y > (frame.frameY2 - frame.frameY1 + 2) * 3) then y = (frame.frameY2 - frame.frameY1 + 2) * 3 end
 
		if (frame.blittleOn == false) then
			frame.buffer:loadBox(1, y, frame.frameX2 - frame.frameX1 + 1, frame.frameY2 - frame.frameY1 + 2, color, color, " ")
		else
			frame.buffer:loadBox(1, y, (frame.frameX2 - frame.frameX1 + 1) * 2, (frame.frameY2 - frame.frameY1 + 2) * 3, color, color, " ")
		end
	end
 
	function frame:loadSky(color)
		local distance = 10
		local gX = distance * math.cos(math.rad(frame.cameraDirY)) + frame.cameraX
		local gZ = distance * math.sin(math.rad(frame.cameraDirY)) + frame.cameraZ
		local x, y = frame:findPointOnScreen(gX, frame.cameraY - 0.01, gZ, frame.blittleOn)
 
		if (y < 0) then y = 0 end
		if (y > (frame.frameY2 - frame.frameY1 + 2) * 3) then y = (frame.frameY2 - frame.frameY1 + 2) * 3 end
		
		if (frame.blittleOn == false) then
			frame.buffer:loadBox(1, 1, frame.frameX2 - frame.frameX1 + 1, y, color, color, " ")
		else
			frame.buffer:loadBox(1, 1, (frame.frameX2 - frame.frameX1 + 1) * 2, y, color, color, " ")
		end
	end
 
	return frame
end
