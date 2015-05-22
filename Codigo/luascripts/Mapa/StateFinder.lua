local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require ("Utils/Vector")
local utils = require ("Utils/Utils")
local K = require(folderDir .. "MapaConstantes")

local StateFinder = {}
local kAnguloPlano = 3/180*math.pi
kAnguloPlano = 8/180*math.pi
local kDistPlano = 0.12

StateFinder.angleType = function(punto1,punto2,punto3) --dice si punto2 es [-1] no convexo, [0] convexo llano o [1] convexo no llano
	local v1 = punto2.coords - punto1.coords
	local v2 = punto3.coords - punto2.coords
	local dir1 = math.atan2(v1[2],v1[1])
	local dir2 = math.atan2(v2[2],v2[1])
	local angDif = utils.truncarAngulo(dir2-dir1)
	if  angDif > kAnguloPlano and angDif < math.pi - kAnguloPlano then
		return 1 --angulo convexo y no plano
	elseif angDif < - kAnguloPlano and angDif > -math.pi + kAnguloPlano then
		return -1 -- angulo no convexo
	end
	return 0 --angulo plano
end

StateFinder.angleTypeConConexion = function(punto1,punto2,punto3) --igual que angleType pero ademas usa la conexion para clasificar puntos como no convexos --se usa al marcar por primera vez
	-- if globalIndex == 156 and punto2.lid == 11 then
		-- print('lid11')
	-- end
	if #punto2.aristas == 2 then
		return StateFinder.angleType(punto1,punto2,punto3)
	-- elseif punto2.oclusor then
		-- return StateFinder.angleType(punto1,punto2,punto3)
	-- elseif punto2.ocluido then
		-- return 1
	end 
	
	-- if globalIndex == 156 and punto2.lid == 11 then
		-- print('lid11','no esquina')
	-- end
	if #punto2.aristas <2 then
		local perpen,a1,a2,zeta
	
		if punto2.aristas[1] then
			a1 = punto2.aristas[1]
			a2 = punto3.aristas[2]
			perpen = a1.perpen
			zeta = a1.z
			--idsRevision = {a1.ids[#a1.ids],1+(a2.ids[1]-2) % K.cantPuntos}
			
			
			--[[
			--es el punto de la derecha de la arista
			local ids = punto2.aristas[1].ids
			local idPunto = ids[#ids]
			
			--Si el siguiente punto no tiene una medida erronea (como 30m) lo uso
			local punto3potencial = StateFinder.puntosReales[1 +idPunto %StateFinder.cantReales]
			if math.sqrt(punto3potencial * punto3potencial) < 10 then
				punto3 = punto3potencial
			end
			
			-- if globalIndex == 156 and punto2.lid == 11 then
				-- print('lid11','a1D')
			-- end
			--]]
			
		else
			a2 = punto2.aristas[2]
			a1 = punto1.aristas[1]
			perpen = a2.perpen
			zeta = a2.z
			--[[
			--es el puto de la izquierda de la arista 2
			local ids = punto2.aristas[2].ids
			local idPunto = ids[1]
			
			--Si el siguiente punto no tiene una medida erronea (como 30m) lo uso
			local punto1potencial = StateFinder.puntosReales[1 + (idPunto-2)%StateFinder.cantReales]
			if math.sqrt(punto1potencial*punto1potencial) < 10 then
				punto1 = punto1potencial
			end
			-- if globalIndex == 156 and punto2.lid == 11 then
				-- print('lid11','a2I')
			-- end
			--]]
			
		end
		
		
		local i =a1.ids[#a1.ids]
		local lastCheck = a2.ids[1]
		--if globalIndex == 1030 and punto2.lid == 3 then print('\npunto',punto2.lid,i,lastCheck,perpen) end
		while true do
			local puntoCheck = StateFinder.puntosReales[i]
			if math.sqrt(puntoCheck*puntoCheck) < 10 then
				local dist = puntoCheck*perpen - zeta
				--if globalIndex == 1030 and punto2.lid == 3 then print(i,dist) end
				if dist < -kDistPlano then
					return -1
				end
			end
			if i == lastCheck then return 1 end
			i = 1 + i % K.cantPuntos
		end
		
		
		
	end
	
	print('error codigo')
	local v1 = punto2.coords - (punto1.coords or punto1)
	local v2 = (punto3.coords or punto3) - punto2.coords
	local dir1 = math.atan2(v1[2],v1[1])
	local dir2 = math.atan2(v2[2],v2[1])
	local angDif = utils.truncarAngulo(dir2-dir1)
	-- if globalIndex == 156 and punto2.lid == 11 then
		-- print('lid11',angDif/math.pi*180)
	-- end
	if globalIndex == 951 then -- and punto2.lid == 12 then
		print('angdif',punto2.lid,angDif/math.pi*180)
	end
	if  angDif > kAnguloPlano then
		return 1 --angulo convexo y no plano
	elseif angDif < - kAnguloPlano then
		return -1 -- angulo no convexo
	end
	return 0 --angulo plano
end

StateFinder.marcarPuntos = function(puntos,funcionMarcado,pos) --marca si es convexo o no. Si lo es, ademas marca siguiente no convexo y si el angulo al siguiente es mayor o menor a 180 (o
	local marcados = {}
	local noConvexos = {}
	local cantPuntos = #puntos
	for j=1,cantPuntos do
		i = 1 + (j-2)%cantPuntos
		k = 1 + j%cantPuntos
		marcados[j] = {}
		marcados[j].punto = puntos[j].punto
		marcados[j].tipo = funcionMarcado(puntos[i].punto,puntos[j].punto,puntos[k].punto)
		marcados[j].id = puntos[j].id
		if marcados[j].tipo == -1 then
			noConvexos[#noConvexos + 1] = marcados[j]
			noConvexos[#noConvexos].ncID =#noConvexos
		end
		marcados[j].coordsRelativas = marcados[j].punto.coords - pos
	end
	
	local puntoSalto = nil
	if #noConvexos > 1 then
		for i=1,#noConvexos do
			j=1 + i % #noConvexos
			local tita1 = math.atan2(noConvexos[i].coordsRelativas[2],noConvexos[i].coordsRelativas[1])
			local tita2 = math.atan2(noConvexos[j].coordsRelativas[2],noConvexos[j].coordsRelativas[1])
			noConvexos[i].sigMenosDe180 = utils.truncarAngulo(tita2-tita1) > 0 --si esta a mas de 180 el angulo tita2 relativo a tita1 va a dar menor a 0
			if not noConvexos[i].sigMenosDe180 then puntoSalto = noConvexos[i] end
			noConvexos[i].sig = noConvexos[j]
			noConvexos[j].ant = noConvexos[i]
		end
	else
		puntoSalto = noConvexos[1]
	end
	return marcados,noConvexos,puntoSalto
end


StateFinder.findState = function(puntosOriginales,puntosReales,fixState,pos)
	local pos = pos or Vector(0,0)
	--encapsulo puntos originales
	StateFinder.puntosReales = puntosReales
	StateFinder.cantReales = #puntosReales
	local puntosEncapsulados = {}
	for k,v in ipairs(puntosOriginales) do
		--if not v.ocluido then
			local nId = #puntosEncapsulados + 1
			puntosEncapsulados[nId] = {["punto"]=v,["id"]=nId}
			v.lid = k
		--end
		-- if globalIndex == 10 and not fixState then
			-- print('oclusion',v.lid,v.ocluido,v.oclusor)
		-- end
	end
	
	--marco puntos por primera vez usando StateFinder.angleTypeConConexion
	local marcados,noConvexos,puntoSalto
	if fixState then
		marcados,noConvexos,puntoSalto = StateFinder.marcarPuntos(puntosEncapsulados,StateFinder.angleType,pos)
	else
		marcados,noConvexos,puntoSalto = StateFinder.marcarPuntos(puntosEncapsulados,StateFinder.angleTypeConConexion,pos)
	end
	
	-- print('marcas',globalIndex)
	-- for k,v in ipairs(marcados) do
		-- print(v.tipo)
	-- end
	
	--si hay un salto de 180, recorto recursivamente el poligono que empiece en el salto
	--cada vez que recorto reviso de que lado queda el centro
	while true do
		if not fixState and globalIndex ==308 then
			print('itero',globalIndex)
			print('noConvexos:',#noConvexos)
			for k,v in ipairs(noConvexos) do print(v.punto.lid) end
		end
	
		while puntoSalto do
			-- if globalIndex == 250 and not fixState then
				-- print 'hay salto'
			-- end
			--primero limito el ultimo angulo acorde a los otros puntos no convexos ya que podrian no permitir que el poligono se cierre
			--observar el primer punto a agregar (sin ser el no convexo, no puede ser un punto ocluido)
			local nextID = 1 + puntoSalto.id % #marcados
			-- while marcados[nextID].punto.ocluido do
				-- nextID = 1 + nextID % #marcados
			-- end
			local primerPunto = marcados[nextID] 
			local minLastAng = -kAnguloPlano
			local deltaV = primerPunto.punto.coords - puntoSalto.punto.coords
			local titaV1 = math.atan2(deltaV[2],deltaV[1])
			for k,v in ipairs(noConvexos) do
				if v.ncID ~= puntoSalto.ncID then
					local deltaV = puntoSalto.punto.coords - v.punto.coords
					local tita = math.atan2(deltaV[2],deltaV[1])
					minLastAng = math.max(minLastAng,utils.truncarAngulo(titaV1-tita)-kAnguloPlano)
				end
			end
			
			--ahora encuentro poligono
			--nextID = 1 + nextID % #marcados
			local poligono = {puntoSalto,primerPunto}--,marcados[nextID]} --empiezo con al menos un triangulo - >lo quite porque no hace falta
			
			--si solo hay un no convexo paro a lo sumo al llegar
			local lastId = -1
			if #noConvexos == 1 then
				lastId = 1 + (puntoSalto.id - 2) % #marcados
			else
				lastId = puntoSalto.sig.id
				--print('lastID',lastId)
			end
			while nextID ~=  lastId do --mientras ultimo agregado no haya sido el ultimo que podia agregar
				--print('ejecuto')
				nextID = 1 + nextID % #marcados
				-- if globalIndex == 250 and not fixState then
					-- print('next:',marcados[nextID].punto.lid)
				-- end
				--reviso convexidad de ultimo, nuevo, primero
				if StateFinder.angleType(poligono[#poligono].punto,marcados[nextID].punto,poligono[1].punto)==-1 then
					--print('ultimo,nuevo,primero no convexo')
					break
				end
				-- if globalIndex == 250 and not fixState then
					-- print('pase prueba 1')
				-- end
				--reviso angulo relativo al primero sea mayor al minimo calculado
				local deltaV = poligono[1].punto.coords - marcados[nextID].punto.coords
				local tita = math.atan2(deltaV[2],deltaV[1])
				-- if globalIndex == 250 and not fixState then
					-- print('tita',tita/math.pi*180,titaV1/math.pi*180,minLastAng/math.pi*180)
				-- end
				local deltaV1Tita = utils.truncarAngulo(titaV1 - tita)
				if deltaV1Tita < minLastAng and deltaV1Tita > -math.pi +kAnguloPlano then
					--print('relativo menor al min',minLastAng,utils.truncarAngulo(titaV1 - tita))
					break
				end
				
				--si paso las dos pruebas lo agrego al poligono
				poligono[#poligono+1] = marcados[nextID]
			end
			
			-- if globalIndex == 250 and not fixState then
				-- print('\npoligono encontrado:')
				-- for k,v in ipairs(poligono) do
					-- print(v.punto.lid)
				-- end
			-- end
			
			
			--al finalizar la construccion del poligono revizo a ver si encierra al origen: para ello reviso el angulo abarcado sea mayor a 180 (es decir que el relativo sea menor a 0
			local titaIni = math.atan2(poligono[1].coordsRelativas[2],poligono[1].coordsRelativas[1])
			local titaFin = math.atan2(poligono[#poligono].coordsRelativas[2],poligono[#poligono].coordsRelativas[1])
			if utils.truncarAngulo(titaFin - titaIni) < 0 and #poligono > 2 then
				--poligono es el poligono que busco
				return poligono
			end
			if not fixState and globalIndex==250 then
				print('poligono descartado:')
				for k,v in ipairs(poligono) do print(v.punto.lid) end
			end
			
			
			
			--obs: por ahora estoy asumiendo no hay puntos entre los no convexos
			--recorto lo que sobra y vuelvo a empezar, eso es, me quedo con los no convexos mas los puntos en el salto a partir de lo cortado			
			local idAgregar = poligono[#poligono].id
			local idUltimo = noConvexos[1 + poligono[1].ncID % #noConvexos].id
			local nextPos = poligono[1].ncID+1
			while idAgregar ~= idUltimo do
				table.insert(noConvexos,nextPos, marcados[idAgregar])
				nextPos = nextPos + 1
				idAgregar = 1 + idAgregar % #marcados
			end
			-- if not fixState and globalIndex ==9 then
				-- print('\npoligono restante:',#noConvexos)
				-- for k,v in ipairs(noConvexos) do print(v.punto.lid) end
			-- end
			
			for k,v in ipairs(noConvexos) do v.id = k end
			marcados,noConvexos,puntoSalto = StateFinder.marcarPuntos(noConvexos,StateFinder.angleType,pos)
			
			-- if not fixState and globalIndex ==11 then
				-- print('noConvexos:',#noConvexos)
				-- for k,v in ipairs(noConvexos) do print(v.punto.lid) end
			-- end
			
		end

		--si no hay salto recorto recursivamente hasta que no pueda mas y devuelvo lo que quede
		if #noConvexos > 0  then
		--while #noConvexos > 0 do
			for k,v in ipairs(noConvexos) do v.id = k end
			marcados,noConvexos,puntoSalto = StateFinder.marcarPuntos(noConvexos,StateFinder.angleType,pos)
		else
		--end
			return marcados
		end
	end

	
	--si esta dentro de ese poligono devuelvo poligono, sino recorto y vuelvo a empezar
	

end


StateFinder.copyState =function (myState)
	local copy = {}
	for k,v in ipairs(myState) do
		copy[#copy+1] = v.punto.lid
	end
	return copy
end


return StateFinder
