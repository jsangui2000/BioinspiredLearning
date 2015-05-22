local folderDir = (...):match("(.-)[^%/]+$")
local Utils = {}
local Vector = require (folderDir.."Vector")

--Producto punto
Utils.dotprod = function (v1,v2)
	local res = 0
	for i in ipairs(v1) do
		res = res + v1[i]*v2[i]
	end
	return res
end

--La norma 2 vectorial
Utils.norm = function (v1)
	return math.sqrt(Utils.dotprod(v1,v1))
end

--Devuelve el angulo entre dos vectores de Rn (obs: resultado siempre menor a 180)
Utils.vectorAngles = function(v1,v2)
	return math.acos(Utils.dotprod(v1,v2)/(Utils.norm(v1)*Utils.norm(v2)))
end

--Distancia 2 de Rn
Utils.distance2 = function (v1,v2)
	local res = 0
	for i in ipairs(v1) do
		res = res + (v1[i]-v2[i])*(v1[i]-v2[i])
	end
	return math.sqrt(res)
end

--Distancia 1 de Rn
Utils.distance1 = function (v1,v2)
	local res = 0
	for i in ipairs(v1) do
		res = res + math.abs(v1[i]-v2[i])
	end
	return res
end


--Distancia Infinito de Rn
Utils.distanceInf = function (v1,v2)
	local res =0
	for i in ipairs(v1) do
		res = math.max(res,math.abs(v1[i]-v2[i]))
	end
	return res
end

--Devuelve una tabla de vectores polares a partir de una de vectores cartesianos
Utils.toPolar = function(v)
	if (type(v[1]) == "table") then
		local res = Vector()
		for i,w in pairs(v) do
			res[i] = Utils.toPolar(w)
		end
		return res
	else
		return Vector(Utils.norm(v),math.atan2(v[2],v[1]))
	end
end
	
	
--Convierte un vector polar a uno cartesiano o
--Convierte una grafica a polar en un conjunto de puntos cartesianos
Utils.toCartessian = function(v,a)
	if (type(v) == "table") then -- es una tabla de radios
		local res = Vector()
		local cant = #v
		for i,w in ipairs(v) do -- es un radio y un angulo
			res[i] = Utils.toCartessian(w,-math.pi+(i-1)*2*math.pi/cant)
		end
		return res
	else
		return Vector(v*math.cos(a),v*math.sin(a))
	end
end	


--Calcula area (sin signo) de un triangulo
Utils.areaTriangle = function(p1,p2,p3)
	local v1 = {p2[1]-p1[1],p2[2]-p1[2]}
	local v2 = {p3[1]-p1[1],p3[2]-p1[2]}
	return math.abs(v1[1]*v2[2]-v1[2]*v2[1])/2	
end

--Calcula el area de un poligono (sin signo)
Utils.areaPoligon = function(poligon)
	local area = 0
	for i=2,#poligon-1 do
		area = area + Utils.areaTriangle(poligon[1],poligon[i],poligon[i+1])
	end
	return area
end

--Calcula el area de un cuadrilatero auto intersectante
Utils.areaIntersectingQuad = function(quad) --(1-2) inter (3,4) da (14 inter + 23 inter)
	local inter = {}
	local det = (quad[1][1]-quad[2][1] )*(quad[3][2] - quad[4][2])
			  - (quad[1][2] - quad[2][2])*(quad[3][1] - quad[4][1])
			  
	inter[1] = ((quad[1][1]*quad[2][2]-quad[1][2]*quad[2][1])*(quad[3][1]-quad[4][1])
			   -(quad[1][1]-quad[2][1])*(quad[3][1]*quad[4][2]-quad[3][2]*quad[4][1]))/det
			  
	inter[2] = ((quad[1][1]*quad[2][2]-quad[1][2]*quad[2][1])*(quad[3][2]-quad[4][2])
			   -(quad[1][2]-quad[2][2])*(quad[3][1]*quad[4][2]-quad[3][2]*quad[4][1]))/det
	

	return Utils.areaTriangle(quad[1],quad[4],inter) + Utils.areaTriangle(quad[2],quad[3],inter)
end

--calcula el area de la diferencia entre ambos poligonos
--solo funciona para funciones polares
--para generalizarlo habria que hallar la interseccion de ambos poligonos
--y luago calcular A(P1) + A(P2) - 2A(P1 inter P2)
--muy complicado si se hace para cualquier poligono
Utils.poligonDifference =function(polar1,cart1,polar2,cart2)
	local area = 0
	local newarea = 0
	local cant = #polar1
	for i =1,#polar1-1 do
		if (polar1[i] > polar2[i]) == (polar1[i+1] > polar2[i+1]) then
			newarea = Utils.areaPoligon({cart1[i],cart2[i],cart2[i+1],cart1[i+1]})
		else
			newarea = Utils.areaIntersectingQuad({cart1[i],cart1[i+1],cart2[i+1],cart2[i]})
		end
		area = area + newarea
	end
	if (polar1[cant] > polar2[cant]) == (polar1[1] > polar2[1]) then
		newarea = Utils.areaPoligon({cart1[cant],cart2[cant],cart2[1],cart1[1]})
	else
		newarea = Utils.areaIntersectingQuad({cart1[cant],cart1[1],cart2[1],cart2[cant]})
	end
	area = area + newarea
	return area
end

--Calcula el promedio de forma iterativa (requiere promedio Pn, dato nuevo a[n+1] y n
--Admite que Pn y an_1 tengan cualquer estructura siempre y cuando sean la misma
Utils.nAverage = function(Pn,an_1,n)
	if (type(Pn) == "table") then
		local res = Vector()
		for i,Qn in ipairs(Pn) do
			res[i] = Utils.nAverage(Qn,an_1[i],n)
		end
		return res
	else
		return (n*Pn + an_1) / (n+1)
	end
	
end

--Calcula el promedio de los datos 
--Solo admite un array de arrays iguales
Utils.average = function(data)
	local res
	local cant = #data
	if (type(data[1]) =='table') then
		res =Vector()
		for i=1,#data[1] do
			res[i] = 0
		end
		for _,d in ipairs(data) do
			for i,v in ipairs(d) do
				res[i] = res[i] + v
			end
		end
		for i,v in ipairs(res) do
			res[i] = v/cant
		end
		
	else
		res =00
		for _,v in ipairs(data) do
			res = res + v
		end
		res = res/ cant
	
	end
	return res
end

Utils.standardDev = function(data)
	local mean = Utils.average(data)
	local dev = 0
	for k,v in ipairs(data) do
		dev = dev + (mean - v)*(mean-v)
	end
	return math.sqrt(dev)/#data

end

--Calcula si todos los valores dados por 'ids' en la tabla 'values' estan dentro
--de los posibles valores 'value'
Utils.allValue = function (values, ids,value)
	if (type(ids) == 'table') then
		for _,n in ipairs(ids) do
			if not Utils.allValue(values,n,value) then
				return false
			end
		end
		return true
	else
		if (type(value) == 'table') then
			for _,v in ipairs(value) do
				if Utils.allValue(values,ids,v) then
					return true
				end
			end
			return false
		else
			return values[ids] == value
		end
	end

end

--Calcula determinante para vectores R2
Utils.det2 = function(v1,v2)
	return v1[1]*v2[2]-v2[1]*v1[2]
end

--Calcula el centro de masa de un poligono (no autointersectante)
Utils.poligonCentroid = function(poli)
	local A = 0
	local n = #poli
	print(n)
	for i =1,n-1 do
		A = A + Utils.det2(poli[i],poli[i+1])
	end
	A = 3*(A + Utils.det2(poli[n],poli[1]))
	
	print(A)
	
	local res = {0,0}
	
	for i=1,n-1 do
		local d = Utils.det2(poli[i],poli[i+1])
		res[1] = res[1] + (poli[i][1]+poli[i+1][1])*d
		res[2] = res[2] + (poli[i][2]+poli[i+1][2])*d	
	end
	local d = Utils.det2(poli[n],poli[1])
	res[1] = res[1] + (poli[n][1]+poli[1][1])*d
	res[2] = res[2] + (poli[n][2]+poli[1][2])*d	
	
	res = Vector(res[1]/A,res[2]/A)
	return res
end
		
Utils.discreteRandom = function (distribution,weight)
	local randNum = weight*math.random()
	local sum = 0
	for i,v in ipairs(distribution) do
		sum = sum + v
		if randNum < sum then return i end
	end
	derror = distribution
	nerror = randNum
	serror = sum
end

function Utils.rotar(distancias,angulo) --sentido debe ser +1 o -100
	local rotadas = Vector()
	local sentido = angulo < 0 and -1 or 1
	local giro = sentido*math.floor(math.abs(angulo)/math.pi * 50 + 0.5)
	if giro < 0 then
		giro = giro + 100
	end
	giro = 100 - giro
	for i=1,100 do
		rotadas[i] = distancias[1+(i-1+giro)%100]
	end
	return rotadas
end

function Utils.rotarPuntos(puntos,angulo,rotX,rotY)
	local rotX = rotX or Vector(math.cos(angulo),-math.sin(angulo))
	local rotY = rotY or Vector(-rotX[2],rotX[1])
	
	if type(puntos[1]) == "table" then
		local rotadas = Vector()
		for k,v in ipairs(puntos) do
			rotadas[k] = Utils.rotarPuntos(v,angulo,rotX,rotY)
		end
		return rotadas
	else
		return Vector(puntos*rotX,puntos*rotY)
	end
end

function Utils.trasladarPuntos(puntos,deltaV)	
	if type(puntos[1]) == "table" then
		local trasladados = Vector()
		for k,v in ipairs(puntos) do
			trasladados[k] = Utils.trasladarPuntos(v,deltaV)
		end
		return trasladados
	else
		return puntos + deltaV
	end
end

function Utils.deepCopy(orig)
    local copy ={}
	for k, v in pairs(orig) do
		if type(v) == "table" then
			if k ~= "ant" and k ~= "sig" and k~="aristas" and k~= puntos then
				copy[k] = Utils.deepCopy(v)
			end
		else
			copy[k] = v
		end
	end
	setmetatable(copy, getmetatable(orig))
	return copy
end

function Utils.acomodarConexion(segmentos)
	for k,v in ipairs(segmentos) do
		if v.conectado then
			v.sig = segmentos[k+1]
			segmentos[k+1].ant = v
		end
	end
	-- if segmentos.puntos then
		-- segmentos.puntos = {}
		-- for k,v in ipairs(segmentos) do
			-- segmentos.puntos[v.puntos[1]] = v.puntos[1]
			-- segmentos.puntos[v.puntos[2]] = v.puntos[2]
		-- end
	-- end
end

function Utils.truncarAngulo(angulo)
	if angulo <= -math.pi then
		return angulo + 2*math.pi
	elseif angulo > math.pi then
		return angulo - 2*math.pi
	else
		return angulo
	end
end
	
function Utils.median(valores)
	local vals = Vector.copy(valores)
	table.sort(vals)
	return (vals[math.floor(#vals/2)] + vals[math.ceil(#vals/2)])/2
end

function Utils.normalizePDF(valores)
	local sum = 0
	for _,v in ipairs(valores) do
		sum = sum + v
	end
	return valores / sum
end
	
return Utils