local folderDir = (...):match("(.-)[^%/]+$")
local Nodo = {}
Nodo.__index = Nodo
local utils = require (folderDir.."Utils")

--falta puntos de contacto entro los vecinos
function Nodo.add(self,vecino)
	if not self.adyacentes[vecino] then 
		self.adyacentes[#self.adyacentes +1] = {vecino}
		vecino.adyacentes[#vecino.adyacentes+1] = {self}
		self.adyacentes[vecino]= true
		vecino.adyacentes[self] = true
	end
end

function Nodo.new(pos,adyacentes)
	adyacentes = adyacentes or {}
	local self = setmetatable({},Nodo)
	--puntos que conforman el nodo
	self.puntos = {pos}
	
	--centro de masa (aproximacion, solo es el premedio de los puntos
	self.centroid = pos 
	self.adyacentes = {}
	for _,v in ipairs(adyacentes) do
		self:add(v)
	end
	self.adyacentes[self] = true
	return self
end

function Nodo.addPoint(self,punto)
	--recalculo centro de masa y agrego el punto a la lista de puntos
	local n = #self.puntos
	self.centroid = utils.nAverage(self.centroid,punto,#self.puntos)
	self.puntos[#self.puntos+1] = punto
end

function Nodo.minDistance(self,punto)
	local mindis = utils.distance2(self.centroid,punto)
	local minid = 0
	for i,p in ipairs(self.puntos) do
		local auxdis = utils.distance2(punto,p)
		if auxdis < mindis then
			mindis = auxdis
			minid = i
		end
	end
	return mindis,minid
end

function Nodo.alcanzado(self,pos,walls) --devuelve si puede ser alcanzado o no, en caso de inseguridad devuelve positivo


	local polarRel = utils.toPolar({self.centroid[1] - pos[1],self.centroid[2] - pos[2]})
	local indRel = 51 + math.floor(0.5+polarRel[2]/math.pi * 50)
	if indRel > 100 then indRel = indRel - 100 end
	
	if polarRel[1] < walls[indRel] then
		return true --si veo un centroide, entonces veo el nodo y retorno
	elseif walls[indRel] ==1.5 then --tengo una direccion en la que no veo una pared
		retun = -1
	end
	return false

 
end

function Nodo.alcanzado2(self,pos,walls) --devuelve si puede ser alcanzado o no, en caso de inseguridad devuelve positivo
	local dirCiega = false  --uso para ver si hay alguna direccion en la que no veo pared
	for i,n in pairs(self.puntos) do
		local polarRel = utils.toPolar({n[1] - pos[1],n[2] - pos[2]})
		local indRel = 51 + math.floor(0.5+polarRel[2]/math.pi * 50)
		if indRel > 100 then indRel = indRel - 100 end
		
		if polarRel[1] < walls[indRel] then
			return true --si veo un centroide, entonces veo el nodo y retorno
		end
			
		if walls[indRel] ==1.5 then --tengo una direccion en la que no veo una pared
			dirCiega = true
		end
	end
	if dirCiega then return -1 end
	return false -- en todas las distancias a los nodos la pared estaba mas cerca que el nodo
 
end

function Nodo.alcanzaVecinos(self,pos,walls)
	for _,n in ipairs(self.adyacentes) do
		if not n[1]:alcanzado(pos,walls) then
			return false
		end	
	end
	return true
end

function Nodo.observacionCercana(self,pos,radio)
	for _,p in ipairs(self.observacion) do
		if utils.distance2(pos,p) < radio then
			return true
		end
	end
	return false		
end

return Nodo