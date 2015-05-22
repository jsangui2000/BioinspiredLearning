local folderDir = (...):match("(.-)[^%/]+$")
local N = require (folderDir.."Normal")
local CoarseCode = {}
local Vector = require (folderDir.."Vector")

CoarseCode.distance = function (val,minval,maxval,cant,sigma)
	local code = Vector()
	local step = (maxval-minval)/(cant-1)
	local sum = 0
	local maximo = N.pdf(0,0,sigma)
	for i=0,cant-1 do
		code[#code+1] = N.pdf(val,minval+i*step,sigma)
		sum = code[i+1] + sum
	end
	for i=1,cant do
		--code[i] = code[i]/maximo
		code[i] = code[i]/sum
	end
	return code,sum,maximo
end

CoarseCode.angle = function (val,cant,sigma)
	local code = Vector()
	local step = 2*math.pi/cant
	local sum = 0
	local maximo = N.pdf(0,0,sigma)
	for i=0,cant-1 do
		local dist = math.abs(-math.pi+i*step-val)
		if dist > math.pi then
			dist = 2*math.pi - dist
		end
		code[i+1] = N.pdf(dist,0,sigma)
		sum = code[i+1] + sum
	end
	for i=1,cant do
		--code[i] = code[i]/maximo
		code[i] = code[i]/sum
	end
	return code,sum,maximo
end

CoarseCode.RingDistance = function(angdist,cant,sigma)
	local code = Vector()
	local step = 2*math.pi/cant
	local sum = 0
	local maximo = 0
	for i=0,cant-1 do
		local ang = -math.pi+i*step
		code[i+1] = 0
		for meassuredAngle,meassuredDistance in pairs(angdist) do
			dist = math.abs(ang-meassuredAngle)
			if dist > math.pi then
				dist = 2*math.pi - dist
			end
			code[i+1] = code[i+1] + meassuredDistance*N.pdf(dist,0,sigma)/N.pdf(0,0,sigma)
			sum = code[i+1] +sum
		end
		maximo = math.max(maximo,code[i+1])
	end
	
	for i=1,cant do
		--code[i] = code[i]/maximo
		code[i] = code[i]/sum
	end
	return code,sum,maximo
end


-- -- Pruebo angle
-- local code = CoarseCode.angle(-math.pi/6,100,0.5)
-- for i = 1,100 do
	-- local step = 2*math.pi / 99
	-- local ang = -math.pi + step * (i-1)	
	-- print(ang..','..code[i])
-- end


-- --Pruebo distance
-- local code = CoarseCode.distance(3,0,20,100,1)
-- local step = 20 / 99
-- for i = 1,100 do
	-- local ang = step * (i-1)	
	-- print(ang..','..code[i])
-- end


-- -- Pruebo RingDistance
-- local distances = {}
-- distances[-math.pi/6] = 10
-- distances[math.pi/6] = 10
-- local code = CoarseCode.RingDistance(distances,100,0.3)
-- for i = 1,100 do
	-- local step = 2*math.pi / 99
	-- local ang = -math.pi + step * (i-1)	
	-- print(ang..','..code[i])
-- end



return CoarseCode