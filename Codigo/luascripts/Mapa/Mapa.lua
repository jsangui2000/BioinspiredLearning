
--mapaReconocimiento

local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require ("Utils/Vector")
local utils = require ("Utils/Utils")
local Segementacion = require (folderDir.."Segmentacion")
local K = require(folderDir .. "MapaConstantes")
local Intersectar = require (folderDir.. "Intersectar")
local D = require ("Utils/Debug")
local StateFinder = require(folderDir .. "StateFinder")

local Mapa = {}
Mapa.__index = Mapa

medianDeltas = {0}
meanDeltas = {0}
meanWDeltas = {0}
diffImportante = {0}
diffTitas = {{}}
diffOri = {{}}

Mapa.new = function(pos,headdir)
	--Debug:
	aristasGlobales = {}
	puntosGlobales = {}


	local self = {}
	setmetatable(self,Mapa)
	
	self.puntos = {}
	self.aristas = {}
	self.estados = {} --poligonos
	self.tablaAristasPoligonos = {} --dado dos puntos orientados da el poligono al que pertenece
	self.cantAristas = 0
	self.cantVertices = 0
	self.hashAngulo = {}
	self.iteracion = {}
	for i=1,360 do
		self.hashAngulo[i] = {}
	end
	
	self.pos = pos or Vector(0,0)
	self.headdir = headdir or 0
	self.nivel = 0
	
	self.aristaImportant = nil --se setea en el update
	
	self.reconocimiento = Mapa.reconocimientoInicial
	
	return self
end

--funcion de hash para hashAngulo
Mapa.conversor =  function(tita)
	return 180 + math.ceil(180*tita/math.pi)
end

Mapa.rotarSegmentos = function(segmentos,tita)
	local rotX = Vector(math.cos(tita),-math.sin(tita))
	local rotY = Vector(-rotX[2],rotX[1])
	for k,v in ipairs(segmentos.puntos) do
		v.coords = Vector(rotX*v.coords,rotY*v.coords)
	end	
	for k,v in ipairs(segmentos) do
		v.vec = Vector(rotX*v.vec,rotY*v.vec)
		v.perpen = Vector(-v.vec[2],v.vec[1])
		v.tita = math.atan2(v.vec[2],v.vec[1])
	end	
end

Mapa.trasladarSegmentos = function(segmentos,deltaV)
	for k,v in ipairs(segmentos.puntos) do
		v.coords = v.coords + deltaV
	end

	for k,v in ipairs(segmentos) do
		v.z = v.puntos[1].coords*v.perpen
		v.proyV1 = v.puntos[1].coords*v.vec
		v.proyV2 = v.puntos[2].coords*v.vec	
	end	
end


Mapa.reconocimientoInicial= function(self,segmentos,estado)
	Mapa.rotarSegmentos(segmentos,self.headdir)
	Mapa.trasladarSegmentos(segmentos,self.pos)
	
	self.reconocimiento = Mapa.reconocimientoGeneral
	return true--no hay return solo se devuelve la lista de segmentos modificada
end

Mapa.reconocimientoGeneral= function(self,segmentos,estado)
	local aristaMatch = self:matchAristaImportante(segmentos)
	if not aristaMatch then
		D.print("WARNING NO MATCH")
	end
	if aristaMatch then
		self.headdir = self.aristaImportante.tita - aristaMatch.tita
		self.headdir = utils.truncarAngulo(self.headdir)
	end
	Mapa.rotarSegmentos(segmentos,self.headdir)
	local deltaTitas = self:matchTodas(segmentos,estado)
	if DOSTATES then
		self:reconocimientoEstado(estado)
	end
	
	--este paso se puede ignorar dependiendo si el resultado es bueno o no
	 table.sort(deltaTitas)
	 local meanDelta = 0
	 local meanWDelta = 0
	 local w = 0
	 diffOri[#diffOri+1] = {}
	 for k,v in ipairs(deltaTitas) do 
		table.insert(diffOri[#diffOri],v/math.pi*180)
		meanDelta = meanDelta + v 
		-- if globalIndex == 95 then
			-- print(#diffOri)
			-- print(v,v/math.pi*180)
			-- print(meanDelta)
		-- end
	 end
	 -- if globalIndex == 95 then
		-- print(meanDelta/#deltaTitas,(meanDelta/#deltaTitas)/math.pi*180)
	-- end
	 
	 
	 diffTitas[#diffTitas+1] = {}
	 for k,v in ipairs(segmentos) do
		if v.match then
			local delta = v.match.tita - v.tita
			delta = utils.truncarAngulo(delta)
			table.insert(diffTitas[#diffTitas],delta/math.pi*180)
			local lw = math.pow(10,v.proyV2-v.proyV1)
			meanWDelta = meanWDelta + lw*delta
			w = w + lw
			
		end
	 end
	 meanWDelta = meanWDelta / w
	 meanWDeltas[#meanWDeltas+1]=meanWDelta/math.pi*180
	 
	 
	 
	 
	 meanDelta = meanDelta/#deltaTitas
	 local top,bot = math.ceil(#deltaTitas/2+0.5),math.floor(#deltaTitas/2+0.5)
	 local medianDeltaTita = (deltaTitas[top] + deltaTitas[bot])/2
	 medianDeltas[#medianDeltas+1] = medianDeltaTita/math.pi*180
	 meanDeltas[#meanDeltas+1] = meanDelta/math.pi*180
	 
	 Mapa.rotarSegmentos(segmentos,meanWDelta)
	 self.headdir = self.headdir + meanWDelta
	 self.headdir = utils.truncarAngulo(self.headdir)
	--Fin del paso que se puede eliminar
	
	
	local pos,nivel = self:posicionar(segmentos)
	if not pos then return false end
	self.pos,self.nivel = pos, nivel
	Mapa.trasladarSegmentos(segmentos,self.pos)
	return true
	
end

Mapa.reconocimientoEstado = function(self,estado)
	local cantPuntos = #estado
	for i,vi in ipairs(estado) do
		local j = 1 + i % cantPuntos
		vj = estado[j]
		if vi.punto.match and 
		   vj.punto.match and
		   self.tablaAristasPoligonos[vi.punto.match] and 
		   self.tablaAristasPoligonos[vi.punto.match][vj.punto.match] then
			estado.match = self.tablaAristasPoligonos[vi.punto.match][vj.punto.match]
			estado.j = j --guardo j para tener un lugar de donde empezar a acomodar el estado
			--guardo el indice del punto j en el estado real [es decir el match]
			estado.jReal = -1
			for jReal,sReal in ipairs(estado.match) do
				if vj.punto.match.gid == sReal.gid then
					estado.jReal = jReal
				end
			end
			--no lo actualizo en el mapa por si necesito el estado viejo
			return --ya hice match del estado asi que termino
		end
	end
end

Mapa.coincidenceIndex= function(aIDs1,aIDs2)
	--tomo primer y ultimo id de cada arista
	local ids11,ids12 = aIDs1[1],aIDs1[#aIDs1]
	local ids21,ids22 = aIDs2[1],aIDs2[#aIDs2]
	
	--si el ultimo es mas chico, cambio el orden aumentando el primero en modulo K.cantPuntos
	if ids12 < ids11 then
		ids11,ids12 = ids12, K.cantPuntos + ids11
	end
	if ids21 < ids22 then
		ids21,ids22 = ids22, K.cantPuntos + ids21
	end
	
	--reviso cuantos ids de las aristas coincidence
	--si ninguno coincide devuelvo un numero menor o igual a 0 que indica a que distancia se encuentran los segmentos (modularmente)
	local cant1, cant2 = 1 + ids12 - ids11, 1 + ids22 - ids21
	local total = 1 + math.max(ids12,ids22) - math.min(ids11,ids21)
	local index = (cant1 + cant2 - total)/2
	if index < -K.cantPuntos/2 then
		return index + K.cantPuntos/2
	end
	return index
end

Mapa.matchAristaImportante= function(self,segmentos)
	--giro arista importante para verla en coords locales (segun headdir viejo o aproximacion)
	local titaImportante = self.aristaImportante.tita - self.headdir
	titaImportante = utils.truncarAngulo(titaImportante)
	idsImportante = self.aristaImportante.ids
	
	self.matchTable.importante = {self.aristaImportante.gid}
	
	--variables para buscar arista observada con mejor coincidencia
	local coincidencia = -K.cantPuntos
	local matchArista
	
	for k,v in ipairs(segmentos) do
		local angdif = math.abs(v.tita-titaImportante)
		if angdif > math.pi then angdif = 2*math.pi - angdif end
		
		if angdif < K.maxAngDif then
			local ci = Mapa.coincidenceIndex(v.ids,idsImportante)
			if ci > coincidencia then
				coincidencia = ci
				matchArista = v
				self.matchTable.importante[2] = v.gid
			end
		end
	end
	return matchArista,coincidenceIndex
end

Mapa.matchTodas= function(self,segmentos,estado)
	--identifico todas las aristas y calculo delta tita para cada arista, luego corrijo conexiones. Finalmente devuelvo tabla de delta titas
	local deltaTitas = {}
	local toleranciaZ = K.toleranciaProyZMin + self.nivel
	local cantSegmentos = #segmentos

	for k,v in ipairs(segmentos) do	
		local proyI = (self.pos+v.puntos[1].coords)*v.vec
		local proyD = (self.pos+v.puntos[2].coords)*v.vec
		
			
		
		--creo lista de ids en el hash para buscar
		local idHash = Mapa.conversor(v.tita)
		
		local checkList = {idHash}
		for i=1,K.gradosTolerancia do
			table.insert(checkList,1+((idHash+i-1)%360))
			table.insert(checkList,1+((idHash-i-1)%360))
		end
		
		
		-- if globalIndex == 221 and k==4 then
			-- print("k",k)
			-- print("proyID", proyI,proyD)
			-- print("idHash",idHash)
			-- print("puntos",self.pos+v.puntos[1].coords,self.pos+v.puntos[2].coords)
			-- print("v.vec",v.vec)
		-- end
		
		for _,i in ipairs(checkList) do
			--tanto key como values son lo mismo en hashAngulo
			if v.match then break end
			for aPosible in pairs(self.hashAngulo[i]) do
				local angdif = math.abs(aPosible.tita - v.tita)
				if angdif > math.pi then angdif = 2*math.pi - angdif end
				
				local proyZ1 = aPosible.perpen*(self.pos+v.puntos[1].coords)
				local proyZ2 = aPosible.perpen*(self.pos+v.puntos[2].coords)
				
				-- if globalIndex == 221 and k == 4 then
					-- print("angdif",angdif)
					-- print("proyz12ari",proyZ1,proyZ2,aPosible.z)
					-- print("proyIDa",aPosible.proyV1,aPosible.proyV2)
				-- end
				
				if angdif < K.toleranciaAngulo then --esto es innecesario posiblemente
					if ((proyI > aPosible.proyV1 -K.toleranciaProyV  and
						 proyI < aPosible.proyV2 +K.toleranciaProyV) or
						(proyD > aPosible.proyV1 -K.toleranciaProyV  and
						 proyD < aPosible.proyV2 +K.toleranciaProyV)) and
						(math.abs(proyZ1-aPosible.z)<toleranciaZ or
						 math.abs(proyZ2-aPosible.z)<toleranciaZ) then
						 
						 -- if globalIndex == 221 and k == 4 then
							-- print("hice match")
						-- end
						 
						 v.match = aPosible
						 self.matchTable[#self.matchTable+1] = aPosible.gid
						 v.puntos[1].match = aPosible.puntos[1]
						 v.puntos[2].match = aPosible.puntos[2]		
						 local dTita = utils.truncarAngulo(v.match.tita - v.tita)
						 table.insert(deltaTitas,dTita)
						 
						 
						 
						 if v.ant then
							v.ant.puntos[2].match = aPosible.puntos[1]
						 end
						 
						 --matcheo todo lo que puedo usando la conexion:
						local puntero = v
						while puntero.sig and puntero.match.sig do
							puntero.sig.match = puntero.match.sig
							self.matchTable[#self.matchTable+1] = puntero.match.sig.gid
							puntero.sig.puntos[1].match = puntero.match.sig.puntos[1]
							puntero.sig.puntos[2].match = puntero.match.sig.puntos[2]
							puntero= puntero.sig
							local dTita = utils.truncarAngulo(puntero.match.tita - puntero.tita)
							table.insert(deltaTitas,dTita)
						end
						
						if puntero.sig then
							puntero.sig.puntos[1].match = puntero.match.puntos[2]
						end
						break	
					end
						
				end
			end
			
		end
	end
	
	--arreglo conexiones
	for i,segi in ipairs(segmentos) do
		local segj = segmentos[1+ i%cantSegmentos]
		--me fijo si tengo dos aristas consecutivas matcheadas
		if segi.match and segj.match then
			--me fijo si las conexion en el mapa difiere de la conexion local
			if not segi.sig and segi.match.sig == segj.match then
				--estan conectados en el mapa pero no en la vista local, conecto local
				--print('entre',globalIndex)
				segi.conectado = true
				segi.sig = segj
				segj.ant = segi
				
				--me quedo con un solo punto
				local aux = segi.puntos[2]
				segi.puntos[2] = segj.puntos[1]
				--si el punto esta en el poligono de estado lo remuevo
				
				if DOSTATES then
					local removeIndex = nil
					for kP,vP in ipairs(estado) do
						if vP.punto.lid == aux.lid then
							removeIndex = kP
							--estado[kP].punto = aux
							break
						end		
					end
					if removeIndex then table.remove(estado,removeIndex) end
				end
				
				--segmentos.puntos[aux] = nil

				--hallo interseccion, seteo error, recalculo las proyecciones 
				local inter = Intersectar.zetaPerpen(segi.z,segi.perpen,segj.z,segj.perpen)
				segi.puntos[2].coords = inter
				segi.puntos[2].error = 0
				segi.puntos[2].esEsquina = true
				
				segi.puntos[2].aristas={segi,segj}
			
				segi.proyV2 = inter*segi.vec
				segj.proyV1 = inter*segj.vec
	
			elseif segi.sig and not segi.match.sig then
				--estan conectados localmente pero no globalmente, conecto global
				if globalIndex == 9 then
					print('segi',i)
				end
				self:eliminarAliasPunto(segi.match,segj.match,segj.puntos[1])
				
				
				-- segi.match.sig = segj.match
				-- segj.match.ant = segi.match
				-- segi.match.conectado = true
				
				-- --me quedo con un solo punto pero hay que decidir con que error quedarse --se elige el primer punto y el minimo de los errores
				-- local inter = Intersectar.zetaPerpen(segi.match.z,segi.match.perpen,segj.match.z,segj.match.perpen)
				-- segi.match.puntos[2].coords = inter
				-- segi.match.puntos[2].error = math.min(segi.match.puntos[2].error,segj.match.puntos[1].error)
				-- segi.match.puntos[2].esEsquina = true
				-- segi.match.puntos[2].aristas = {segi.match,segj.match}
				-- --debo arreglar los estados que utilizaban el punto segj.match.puntos[1]
				-- if segj.match.puntos[1].estados then
					-- for kS,vS in ipairs(segj.match.puntos[1].estados) do
						-- local p1ID,p2ID = -1,-1
						-- for iK,iP in ipairs(vS) do
							-- if iP.gid == segj.match.puntos[1].gid then
								-- p1ID = iK
							-- elseif iP.gid == segi.match.puntos[2].gid then
								-- p2ID = iK
							-- end
						-- end	
						-- if p2ID ~= -1 then
							-- --encontre los dos puntos, elimino al punto del estado y agrego una entrada con el punto anterior y el nuevo punto en la posicion p1I
							-- table.remove(vS,p1ID)
							-- local pAnt,pSig = vS[1 + (p1ID-2)%#vS] , vS[1 + (p1ID-1)%#vS]
							-- self.tablaAristasPoligonos[pAnt][pSig] = vS
						-- else
							-- --solo estaba el punto1, reemplazo por el punto2 y agrego aristas a la tablaAristasPoligonos
							-- table.remove(vS,p1ID)
							-- table.insert(vS,p1ID,segi.match.puntos[2])
							-- if not segi.match.puntos[2].estados then
								-- segi.match.puntos[2].estados = {}
							-- end
							-- segi.match.puntos[2].estados[#segi.match.puntos[2].estados+1] = vS
							
							-- if not self.tablaAristasPoligonos[segi.match.puntos[2]] then
								-- self.tablaAristasPoligonos[segi.match.puntos[2]] = {}
							-- end
							-- local siguientPunto = vS[1 + p1ID % #vS] --tomo el siguiente punto en el poligono
							-- local anteriorPunto = vS[1 + (p1ID-2) %#vS]
							-- self.tablaAristasPoligonos[segi.match.puntos[2]][siguientPunto] = vS --agrego entrada que la arista dada por esos puntos pertenece al poligono vS
							-- self.tablaAristasPoligonos[anteriorPunto][segi.match.puntos[2]] = vS
							-- vS[segi.match.puntos[2]] = true
						-- end
					-- end
				-- end
				-- segj.match.puntos[1] = segi.match.puntos[2]
				-- --
				
				-- segi.match.proyV2 = inter*segi.match.vec
				-- segj.match.proyV1 = inter*segj.match.vec
				
				

			end	
		end
	end
	
	return deltaTitas
	
end

Mapa.eliminarAliasPunto = function(self,aristai,aristaj,puntoj1) --el otro punto es utilizado por si hay que arreglar la tabla de match el unir puntos
	--D.print('eliminandoAlias ')
	aristai.sig = aristaj
	aristaj.ant = aristai
	aristai.conectado = true
	
	--me quedo con un solo punto pero hay que decidir con que error quedarse --se elige el primer punto y el minimo de los errores
	local inter = Intersectar.zetaPerpen(aristai.z,aristai.perpen,aristaj.z,aristaj.perpen)
	aristai.puntos[2].coords = inter
	aristai.puntos[2].error = math.min(aristai.puntos[2].error,aristaj.puntos[1].error)
	aristai.puntos[2].esEsquina = true
	aristai.puntos[2].aristas = {aristai,aristaj}
	if puntoj1 then
		puntoj1.match = aristai.puntos[2]
	end
	if DOSTATES then
	--debo arreglar los estados que utilizaban el punto segj.match.puntos[1]
		if aristaj.puntos[1].estados then
			for kS,vS in ipairs(aristaj.puntos[1].estados) do
				local p1ID,p2ID = -1,-1
				for iK,iP in ipairs(vS) do
					if iP.gid == aristaj.puntos[1].gid then
						p1ID = iK
					elseif iP.gid == aristai.puntos[2].gid then
						p2ID = iK
					end
				end	
				if p2ID ~= -1 then
					--encontre los dos puntos, elimino al punto del estado y agrego una entrada con el punto anterior y el nuevo punto en la posicion p1I
					table.remove(vS,p1ID)
					local pAnt,pSig = vS[1 + (p1ID-2)%#vS] , vS[1 + (p1ID-1)%#vS]
					self.tablaAristasPoligonos[pAnt][pSig] = vS
				else
					--solo estaba el punto1, reemplazo por el punto2 y agrego aristas a la tablaAristasPoligonos
					table.remove(vS,p1ID)
					table.insert(vS,p1ID,aristai.puntos[2])
					if not aristai.puntos[2].estados then
						aristai.puntos[2].estados = {}
					end
					aristai.puntos[2].estados[#aristai.puntos[2].estados+1] = vS
					
					if not self.tablaAristasPoligonos[aristai.puntos[2]] then
						self.tablaAristasPoligonos[aristai.puntos[2]] = {}
					end
					local siguientPunto = vS[1 + p1ID % #vS] --tomo el siguiente punto en el poligono
					local anteriorPunto = vS[1 + (p1ID-2) %#vS]
					self.tablaAristasPoligonos[aristai.puntos[2]][siguientPunto] = vS --agrego entrada que la arista dada por esos puntos pertenece al poligono vS
					self.tablaAristasPoligonos[anteriorPunto][aristai.puntos[2]] = vS
					vS[aristai.puntos[2]] = true
				end
			end
		end
	end
	aristaj.puntos[1] = aristai.puntos[2]
	--
	
	aristai.proyV2 = inter*aristai.vec
	aristaj.proyV1 = inter*aristaj.vec



end


Mapa.posicionar = function(self,segmentos)
	local posicionesX = {}
	local posicionesY = {}
	local incerteza = {}
	for i=1,(#segmentos-1) do
		local segi = segmentos[i]
		if segi.match then
			for j=i+1,#segmentos do
				local segj = segmentos[j]
				if segj.match and math.abs(segi.vec*segj.vec) < K.minAngIntersectar then
					local interLocal = Intersectar.zetaPerpen(segi.z,segi.perpen,segj.z,segj.perpen)
					local interReal  = Intersectar.zetaPerpen(segi.match.z,segi.match.perpen,segj.match.z,segj.match.perpen)
					local pos = interReal - interLocal
					table.insert(posicionesX,pos[1])
					table.insert(posicionesY,pos[2])
				end
			end
		end
	end
	if #posicionesX == 0 then
		for k,v in ipairs(segmentos.puntos) do
			if v.match and v.esEsquina and v.match.esEsquina then
				local pos = v.match.coords - v.coords
				table.insert(posicionesX,pos[1])
				table.insert(posicionesY,pos[2])
			end
		end
	end
	
	--esto se puede eliminar???
	for k,v in ipairs(segmentos.puntos) do
		if v.match and v.esEsquina and v.match.esEsquina then
			table.insert(incerteza,v.match.error + v.error)
		end
	end
	
	--calculo la posicion--se puede variar la forma
	table.sort(posicionesX)
	table.sort(posicionesY)
	table.sort(incerteza)
	if #posicionesX == 0 then return nil end
	local top,bot = math.ceil(#posicionesX/2+0.5),math.floor(#posicionesX/2+0.5)
	if globalIndex == 7 then
		print(globalIndex,top,bot,#posicionesX)
		print(posicionesX[top],posicionesX[bot])
		print(posicionesY[top],posicionesY[bot])
	end
	local pos = Vector((posicionesX[top]+posicionesX[bot])/2,
					   (posicionesY[top]+posicionesY[bot])/2)
	return pos, incerteza[1] and incerteza[1] or 0
end

--Funcion para ajustar puntos cuando hay una nueva interseccion en el mapa
Mapa.ajustarPunto= function(self,punto,aIzq,aDer)
	punto.coords = Intersectar.zetaPerpen(aIzq.z,aIzq.perpen,aDer.z,aDer.perpen)
	punto.esEsquina = true
	punto.error = self.nivel
	punto.aristas = {aIzq,aDer}
	aIzq.proyV2 = punto.coords*aIzq.vec
	aIzq.conectado = true
	aDer.proyV1 = punto.coords*aDer.vec
end

Mapa.integrarInformacion = function(self,segmentos,estado)
	self.aristaImportante = segmentos.mejor.match or segmentos.mejor
	self.aristaImportante.ids = segmentos.mejor.ids
	
	--Si reconoci el estado, me fijo si debo agregar puntos
	--if globalIndex ~= 193 then
	--D.print('integrandoEstado ')
	local testIndex = -1
	-- if globalIndex == testIndex then
		-- print('\ncambiando')
		-- for k,v in ipairs( self.estados[1]) do
			-- print(v,v.coords)
		-- end
	-- end
	
	if DOSTATES then
		if estado.match then
			-- if globalIndex == 11 then
				-- print('estado match',estado.match.gid)
			-- end
			local i = estado.j
			local iReal = estado.jReal
			for _=1,#estado-2 do --el estado ya tiene al menos los puntos estado.i,estado.j
				local j = 1 + i % #estado
				local jReal = 1 + iReal % #estado.match
				--print('jotas',j,jReal)
				--reviso si el punto j es nuevo, o si todavia no se encuentra agregado en el estado, en cuyo caso agrego haciendo los arreglos pertinentes (tablaAristasPoligonos, indices)
				if not estado[j].punto.match or not estado.match[estado[j].punto.match] then --
					--print('entre')
					local puntoAagregar = estado[j].punto.match or estado[j].punto --si el punto existe agrego el match, si no existe agrego al mismo (ya que sera insertado en la tabla de puntos)
					--quizas habria que hacerlo con el angulo en vez de con la distancia (usando la pos actual como referencia)
					--local deltaV = puntoAagregar.coords - estado.match[iReal].coords
					local coordsRelativasI = estado.match[iReal].coords - self.pos
					local coordsRelativasJ = puntoAagregar.coords - self.pos
					--local distanciaIJ = deltaV*deltaV
					local anguloI = math.atan2(coordsRelativasI[2],coordsRelativasI[1])
					local anguloJ = math.atan2(coordsRelativasJ[2],coordsRelativasJ[1])
					local distAnguloIJ = anguloJ - anguloI
					if distAnguloIJ < 0 then distAnguloIJ = distAnguloIJ + 2*math.pi end
					--busco lugar donde insertar el punto, para ello reviso quien esta mas cerca del punto i, si el realJ esta mas cerca, entonces avanzo el realJ
					while true do
						local coordsRelativas = estado.match[jReal].coords - self.pos
						local angulo = math.atan2(coordsRelativas[2],coordsRelativas[1])
						local distAngulo = angulo - anguloI
						if distAngulo < 0 then distAngulo = distAngulo + 2*math.pi end
					
						--local deltaV = estado.match[jReal].coords - estado.match[iReal].coords
						--local dist = deltaV*deltaV
						--if dist < distanciaIJ then --aumento jReal
						if distAngulo < distAnguloIJ then
							jReal = 1 + jReal % #estado.match
						else
							break
						end
					end
					--agrego el punto en la posicion jReal y acomodo tablaAristasPoligonos
					table.insert(estado.match,jReal,puntoAagregar)
					estado.match[puntoAagregar] = true
					if not self.tablaAristasPoligonos[puntoAagregar] then
						self.tablaAristasPoligonos[puntoAagregar] = {}
					end
					local pAnterior  = estado.match[1 + (jReal - 2) % #estado.match]
					local pSiguiente = estado.match[1 + jReal % #estado.match]
					self.tablaAristasPoligonos[pAnterior][puntoAagregar] = estado.match
					self.tablaAristasPoligonos[puntoAagregar][pSiguiente] = estado.match
					if not puntoAagregar.estados then
						puntoAagregar.estados = {}
					end
					puntoAagregar.estados[#puntoAagregar.estados+1] = estado.match
				else
					--el punto ya estaba agregado, busco su jReal
					for kP,vP in ipairs(estado.match) do
						if vP.gid == estado[j].punto.match.gid then
							jReal = kP
							break
						end
					end
				end
				i = j
				iReal = jReal
			end
			self.estado = estado.match		
		else
			
			local estadoNuevo = {}
			self.estados[#self.estados+1] = estadoNuevo
			self.estado = estadoNuevo
			estadoNuevo.gid = #self.estados
			for kP,vP in ipairs(estado) do
				local puntoNuevo = vP.punto.match or vP.punto
				
				estadoNuevo[#estadoNuevo+1] = puntoNuevo
				estadoNuevo[puntoNuevo] = true
				if not puntoNuevo.estados then
					puntoNuevo.estados = {}
				end
				puntoNuevo.estados[#puntoNuevo.estados + 1] = estadoNuevo
				local pSiguiente = estado[1 + kP % #estado].punto
				pSiguiente = pSiguiente.match or pSiguiente
				if not self.tablaAristasPoligonos[puntoNuevo] then
					self.tablaAristasPoligonos[puntoNuevo] = {}
				end
				self.tablaAristasPoligonos[puntoNuevo][pSiguiente] = estadoNuevo
			end
		end
	end
	-- if globalIndex == testIndex then
		-- print('\ncambiando')
		-- for k,v in ipairs( self.estados[1]) do
			-- print(v,v.coords)
		-- end
	-- end
	
	--end
	
	--local ajustarPuntos = {}
	
	--agrego toda arista y todo punto que no haya sido matcheado
	--D.print('modificandoMapa ')
	for k,v in ipairs(segmentos) do
		if not v.match then
			self.aristas[#self.aristas+1] = v
			local gid = #aristasGlobales + 1
			aristasGlobales[gid] = v
			v.gid = gid
			v.match = v
			self.hashAngulo[Mapa.conversor(v.tita)][v] = v
			
			if v.sig and v.sig.match then
				v.sig = v.sig.match
			end
			if v.ant and v.ant.match then
				v.ant = v.ant.match
			end
			
			if v.puntos[1].match then
				v.puntos[1] = v.puntos[1].match
				self:ajustarPunto(v.puntos[1],v.ant.match,v)
			else
				self.puntos[#self.puntos+1] = v.puntos[1]
				local gid = #puntosGlobales + 1
				puntosGlobales[gid] = v.puntos[1]
				v.puntos[1].gid = gid
				v.puntos[1].match = v.puntos[1]
				v.puntos[1].error = self.nivel + v.puntos[1].error
				--quito marcas que dependen de la posicion
				v.puntos[1].ocluido = nil
				v.puntos[1].oclusor = nil 
				
			end
			if v.puntos[2].match then
				v.puntos[2] = v.puntos[2].match
				self:ajustarPunto(v.puntos[2],v,v.sig.match)
			else
				self.puntos[#self.puntos+1] = v.puntos[2]
				local gid = #puntosGlobales + 1
				puntosGlobales[gid] = v.puntos[2]
				v.puntos[2].gid = gid
				v.puntos[2].match = v.puntos[2]
				v.puntos[2].error = self.nivel + v.puntos[2].error
				if v.puntos[2].aristas[2] and v.puntos[2].aristas[2].match then 
					v.puntos[2].aristas[2] = v.puntos[2].aristas[2].match 
				end	
				--quito marcas que dependen de la posicion
				v.puntos[2].ocluido = nil
				v.puntos[2].oclusor = nil
			
			end
			
		else
			--modifico proyV1?
			--cond1: aparecio el segmento con el que intersecta
			--si la arista con la intersecta es nueva, esta condicion se cubre en 
			-- la parte anterior, sino se cubre en el reconocimiento de aristas
			--cond2: no hay anterior: si no es esquina, la
			if #v.match.puntos[1].aristas~=2 then
				local incerteza1 = self.nivel + v.puntos[1].error
				
				if not v.match.puntos[1].esEsquina  or incerteza1 < v.match.puntos[1].error then
					local proyV1 = v.puntos[1].coords * v.match.vec
					if proyV1 < v.match.proyV1 then
						v.match.proyV1 = proyV1
						v.match.puntos[1].coords = proyV1 * v.match.vec + v.match.z * v.match.perpen
					end	
					v.match.puntos[1].esEsquina = v.match.puntos[1].esEsquina or v.puntos[1].esEsquina
				end
				
				if incerteza1 < v.match.puntos[1].error then
					v.match.puntos[1].error = incerteza1
				end
			end
			
			--modifico proyV2?
			if #v.match.puntos[2].aristas~=2 then
				local incerteza2 = self.nivel + v.puntos[2].error
				
				if not v.match.puntos[2].esEsquina or incerteza2 < v.match.puntos[2].error then
					local proyV2 = v.puntos[2].coords * v.match.vec
					if proyV2 > v.match.proyV2 then
						v.match.proyV2 = proyV2
						v.match.puntos[2].coords = proyV2*v.match.vec + v.match.z*v.match.perpen
					end
					v.match.puntos[2].esEsquina = v.match.puntos[2].esEsquina or v.puntos[2].esEsquina
				end
				if incerteza2 < v.match.puntos[2].error then
					v.match.puntos[2].error = incerteza2
				end
				
			end
			
			--modifico conectado, sig o ant?
			v.match.conectado = v.match.conectado or v.conectado
			v.match.ant = v.match.ant or (v.ant and (v.ant.match or v.ant))
			v.match.sig = v.match.sig or (v.sig and (v.sig.match or v.sig))
			
			
		end
	end
	
	-- for k,v in pairs(segmentos.puntos) do
		-- if not v.match then
			-- self.puntos[v] = v
			-- table.insert(puntosGlobales,v)
			-- v.match = v
			-- v.error = self.nivel + v.error
			-- if v.aristas[1] then v.aristas[1] = v.aristas[1].match end
			-- if v.aristas[2] then v.aristas[2] = v.aristas[2].match end		
		-- end
	-- end
	
	-- if globalIndex == testIndex then
		-- print('\ncambiando')
		-- for k,v in ipairs( self.estados[1]) do
			-- print(v,v.coords)
		-- end
	-- end
	
	--luego de hacer todo, reviso aliases en el estado 
	--(es decir puntos que sean el mismo pero hayan sido vistos como diferentes)
	--D.print('arrglandoAliases ')
	if DOSTATES then
		local i = 1
		--if globalIndex ~= 13 then
		while true do
			local j = 1 + i % #self.estado
			local pi = self.estado[i]
			local pj = self.estado[j]
			local deltaV = pj.coords - pi.coords
			if deltaV*deltaV < 0.04 then --si distancia es menor a 0.2m asumo son el mismo punto
				local aristai,aristaj
				if pi.aristas[1] then --pi es el punto derecha de la arista y pj el izquierda
					aristai,aristaj = pi.aristas[1],pj.aristas[2]
				else
					aristai,aristaj = pj.aristas[1],pi.aristas[2]
				end
				self:eliminarAliasPunto(aristai,aristaj)		
				--aristai y aristaj se intersectan
			end
			i = 1 + (j-1) % #self.estado --a i le asigno j revisando que con el cambio no este fuera de rango
			
			if i==1 then
				break
			end	
		end
		--end
		
		--arreglo el estado por si al modificarse dejo de ser convexo
		local fixedState = StateFinder.findState(self.estado,{},true,self.pos)
		if #fixedState ~= #self.estado then
			--print('encontre diferente',#fixedState,#self.estado)
			for i=1,#self.estado do
				local punto = table.remove(self.estado,1) --remuevo los puntos del estado
				self.estado[punto] =nil --quito el indicador del estado
				
				--busco y saco el estado del punto:
				local index = -1
				for k,v in ipairs(punto.estados) do
					if v == self.estado then
						index = kP
					end
				end
				if index ~= -1 then
					table.remove(punto.estados,index)
				else
					print('error no encontre el estado dentro del punto')
				end
				
				--remuevo las entradas del punto en la tabla que apunten a este estado
				local referencias = self.tablaAristasPoligonos[punto]
				local indexes = {}
				--print('refs',referencias)
				for k,v in pairs(referencias) do
					--print(v.gid,self.estado.
					if v.gid == self.estado.gid then
						indexes[#indexes+1] = k
					end
				end
				for k,v in ipairs(indexes) do
					referencias[v] = nil
				end	
			end

			--termine de vaciar el estado y arreglar sus referencias, cargo el estado modificado
			--print('printing')
			--printTA(self)
			
			for i,v in ipairs(fixedState) do
				j = 1 + i % #fixedState
				self.estado[#self.estado+1] = v.punto
				self.estado[v.punto] = true
				v.punto.estados[#v.punto.estados+1] = self.estado
				self.tablaAristasPoligonos[v.punto][fixedState[j].punto] = self.estado
			end
			
		end
		
	end
	
	
end

Mapa.update= function(self,segmentos,estado)
	--D.print('aca ')
	self.matchTable = {}
	self.localice = self:reconocimiento(segmentos,estado)
	
	--D.print('reconoci ')
	if self.localice then
		--if globalIndex~= 471 then
			self:integrarInformacion(segmentos,estado)
		--end
	else
		--asumo siempre matcheo la mejor salvo quizas al principio
		self.aristaImportante = segmentos.mejor.match or segmentos.mejor
	end
	--D.print('sali ')
end

Mapa.saveResult = function(self,lab)
	
	local mapaPath = "C:\\Program Files (x86)\\V-REP3\\V-REP_PRO_EDU\\luascripts\\Resultados\\mapa" .. D.timeMark
	os.execute("mkdir \"" .. mapaPath .. "\"")
	puntosFile = io.open(mapaPath .. '\\puntos.txt','w')
	aristasFile = io.open(mapaPath .. '\\aristas.txt','w')
	estadosFile = io.open(mapaPath .. '\\estados.txt','w')
	labNameFile = io.open(mapaPath .. '\\labName.txt','w')
	for k,v in ipairs(self.puntos) do
		puntosFile:write(v.coords[1] .. ';' .. v.coords[2] .. ';\n')
	end
	for k,v in ipairs(self.aristas) do
		aristasFile:write(v.puntos[1].gid .. ';' .. v.puntos[2].gid .. ';\n')
	end
	for k,v in ipairs(self.estados) do
		for kP,vP in ipairs(v) do
			estadosFile:write(v.gid..';')
		end
		estadosFile:write('\n')
	end
	labNameFile:write(lab ..'\n')
	puntosFile:close()
	aristasFile:close()
	labNameFile:close()
	estadosFile:close()
	
	--guardo iteraciones 
	posFile		= io.open(mapaPath .. '\\pos.txt','w')
	posRealFile = io.open(mapaPath .. '\\posReal.txt','w')
	hdFile 		= io.open(mapaPath .. '\\hd.txt','w')
	hdRealFile	= io.open(mapaPath .. '\\hdReal.txt','w')
	for k,v in ipairs(self.iteracion) do
		posFile:write(v.pos[1] ..';'..v.pos[2]..';\n')
		posRealFile:write(v.posReal[1] ..';'..v.posReal[2]..';\n')
		hdFile:write(v.hd .. ';\n')
		hdRealFile:write(v.hdReal .. ';\n')
	end
	
	
end

Mapa.saveIteracion = function(self,hd,pos)
	local id = #self.iteracion + 1
	self.iteracion[id] = {}
	self.iteracion[id].hdReal = hd
	self.iteracion[id].hd = self.headdir
	self.iteracion[id].posReal = Vector(pos[1],pos[2])
	self.iteracion[id].pos = Vector(self.pos[1],self.pos[2])
	
end



return Mapa