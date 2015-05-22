local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require ("Utils/Vector")
local utils = require ("Utils/Utils")
local K = require (folderDir .. "MapaConstantes")
local Reglin = require (folderDir .. "Reglin")
local Intersectar = require (folderDir .. "Intersectar")


--segmentar 3
--procesarSegmentos2
--esquinas

local Segmentacion = {}

Segmentacion.segmentar = function(datos)

end

Segmentacion.segmentacionInicial = function(puntos,dbg)
--K.conexion K.maxError  K.minDist

	--distancias guarda el cuadrado de la distancia al siguiente punto, se usa el cuadrado para no tener que aplicar la raiz
	local distancias = {}  
	for i = 2,#puntos do
		local delta = puntos[i] - puntos[i-1]
		distancias[i-1] = delta*delta
	end
	local delta = puntos[K.cantPuntos] - puntos[1]
	distancias[#distancias+1] = delta*delta

	

	local ultimoID = 1
	while (distancias[ultimoID] < K.conexion) do
		ultimoID = ultimoID + 1
	end
	
	local i = 1 + (ultimoID % K.cantPuntos)
	
	local segmentos = {}
	segmentos[0] = {} --variable dummy, no se usa salvo por conveniencia
	segmentos[0].conectado = false
	
	local ids = {i}
	
	local z
	local perpen
	local dp
	local maxD
	
	
	while i~= ultimoID do
		j = 1 + (i % K.cantPuntos)
		if dbg and (i>=99 or i<=3) then print(i) end
		if distancias[i] < K.conexion then
			if #ids ==1 then
				ids[2] = j
				z,perpen = Reglin.regression(puntos,ids)
				if dbg and (i>=99 or i<=3) then print(z,perpen) end
			else 
			
				local z2 = puntos[j]*perpen
				if dbg and (i>=99 or i<=3) then print(z,z2) end
				if math.abs(z2-z) > K.maxError then
					ids[#ids+1] = j
					z,perpen,maxD = Reglin.regression(puntos,ids,true)
					table.remove(ids,#ids)
					--ids[#ids] = nil
					z2 = z + maxD
					if dbg and (i>=99 or i<=3) then print(z,z2,maxD) end
				end
				
				if math.abs(z2-z) < K.maxError then
					ids[#ids+1] = j
				else
					local deltaV = puntos[ids[#ids]] - puntos[ids[1]]
					local dist = deltaV*deltaV
					
					local nuevoSegmento = {["ids"]=ids}
					
					if #ids >= K.minPuntos and dist > K.minDist then
						if segmentos[#segmentos].conectado == nil then
							segmentos[#segmentos].sig = nuevoSegmento
							nuevoSegmento.ant = segmentos[#segmentos]
							segmentos[#segmentos].conectado = true
						end
						segmentos[#segmentos+1] = nuevoSegmento
						--se podria hacer j = i para que empiece del mismo punto
						ids = {j}
					elseif #ids >2 then
						j = ids[#ids]
						table.remove(ids,1)
						z,perpen = Reglin.regression(puntos,ids)
					else
						ids = {i,j}
						z,perpen = Reglin.regression(puntos,ids)
					end
				
				
				end
				
			
			end
		else
			local deltaV = puntos[ids[#ids]] - puntos[ids[1]]
			local dist = deltaV*deltaV
			
			local nuevoSegmento = {["ids"]=ids}
			
			if #ids >= K.minPuntos and dist > K.minDist then
				if segmentos[#segmentos].conectado == nil then
					segmentos[#segmentos].sig = nuevoSegmento
					nuevoSegmento.ant = segmentos[#segmentos]
					segmentos[#segmentos].conectado = true
				end
				segmentos[#segmentos+1] = nuevoSegmento
				segmentos[#segmentos].conectado = false
			elseif segmentos[#segmentos].conectado == nil then
				segmentos[#segmentos].conectado = false		
			end
			
			ids = {j}
		
		end
		i = j
	end
	
	local deltaV = puntos[ids[#ids]] - puntos[ids[1]]
	local dist = deltaV*deltaV
	local nuevoSegmento = {["ids"]=ids}
	
	if #ids >= K.minPuntos and dist > K.minDist then
		if segmentos[#segmentos].conectado == nil then
			segmentos[#segmentos].sig = nuevoSegmento
			nuevoSegmento.ant = segmentos[#segmentos]
			segmentos[#segmentos].conectado = true
		end
		segmentos[#segmentos+1] = nuevoSegmento
		segmentos[#segmentos].conectado = false
	elseif segmentos[#segmentos].conectado == nil then
		segmentos[#segmentos].conectado = false	
	end
		
	return segmentos

end

Segmentacion.procesarSegmentos = function(segmentos,puntos)
	local procesados = {} --segmentos procesados
	local procesando = segmentos[1] --segmento siendo procesado
	
	for i =2,#segmentos do
		elementos = segmentos[i].ids
		
		--obtengo direccion del segmento i
		local delta = puntos[elementos[#elementos]] - puntos[elementos[1]]
		local dir = math.atan2(delta[2],delta[1])
		
		--obtengo direccion del segmento procesando
		delta = puntos[procesando.ids[#procesando.ids]] - puntos[procesando.ids[1]]
		local dirActual = math.atan2(delta[2],delta[1])
		
		--obtengo diferencia entre direcciones
		local dif = math.abs(dirActual - dir)
		if dif > math.pi then dif = 2*math.pi - dif end
		
		--Obtengo distancia entre ultimo y primer punto del segmento procesando con el i respectivamente
		delta = puntos[elementos[1]] - puntos[procesando.ids[#procesando.ids]]
		local dist = delta*delta
		
		
		if dist < K.conexion and dif < K.anguloJuntar then
			for _,elem in ipairs(elementos) do
				table.insert(procesando.ids,elem)
			end
			procesando.conectado = segmentos[i].conectado
			procesando.sig = segmentos[i].sig
		else
			if procesando.sig then
				segmentos[i].ant = procesando
			end
			table.insert(procesados,procesando)
			procesando = segmentos[i]
		end
	end
	table.insert(procesados,procesando)
	return procesados
end

Segmentacion.esEsquina = function(puntos,idPunto)
	local punto = puntos[idPunto]
	for _,i in ipairs({-1,1}) do
		local id = 1 + ((idPunto+i-1) % #puntos)
		local delta = puntos[id] - punto
		if delta*delta < K.radioEsquinas then
			return true
		end	
	end
	return false
end

--dir es +1 si es esquina derecha, -1 si es esquina izquierda
--idealmente deberia devolver el error maximo
--sin embargo devuelve la distancia (cuadrada) de los dos ultimos puntos
--del segmento
Segmentacion.errorEsquina = function(puntos,idPunto,dir)
	local punto = puntos[idPunto]
	local id = 1 + ((idPunto-dir-1) % #puntos)
	local delta = puntos[id] - punto
	return math.sqrt(delta*delta)
end

Segmentacion.esquinas = function(puntos,segmentos)
	local cantPuntos = #puntos
	
	--agrego una tabla de puntos a segmentos
	segmentos.puntos = {}
	
	--aca se guardara el segmento con mayor actividad
	--inicializo al primer segmento
	segmentos.mejor = segmentos[1]
	
	for i,seg in ipairs(segmentos) do
		seg.z, seg.perpen = Reglin.regression(puntos,seg.ids) --le seteo el valor z y 
		seg.vec = Vector(seg.perpen[2],-seg.perpen[1]) --seteo la direccion del segmento (que es perpendicular a la parpendicular del segmento)
		seg.tita = math.atan2(seg.vec[2],seg.vec[1])
		seg.actividad = seg.ids[#seg.ids]-seg.ids[1] --indica la cantidad de indices entre el primer y ultimo punto del segmento
		seg.actividad = ((seg.actividad > 0) and 1 or (cantPuntos + 1)) + seg.actividad --corrijo si la actividad es negativa (sino solo falta sumar 1 por el primer id)
		
		--guardo el segmento con mayor actividad
		if seg.actividad > segmentos.mejor.actividad then
			segmentos.mejor = seg
		end
		
		seg.puntos = {} --guardara referencia a las esquinas
		
		
	end
	
	for i,segi in ipairs(segmentos) do
		local j = 1 + (i % #segmentos)
		segj = segmentos[j]
		local angdif = math.abs(math.atan(segi.perpen[2]/segi.perpen[1]) - 
								math.atan(segj.perpen[2]/segj.perpen[1]))
		if angdif > math.pi/2 then
			angdif = math.pi - angdif
		end
		if segi.conectado then
			segi.conectado = segi.conectado and angdif > K.angParalelas
			if not segi.conectado then
				segi.sig = nil
				segj.sig = nil
			end
		end
		
		if segi.conectado then
			local inter = Intersectar.zetaPerpen(segi.z,segi.perpen,segj.z,segj.perpen)
			local punto = {["esEsquina"] = true,["coords"]=inter,["error"]=0} --el punto guarda si es o no una esquina, sus coordenadas y el "error" (esta claro no es real)
			segi.puntos[2] = punto
			segj.puntos[1] = punto
			
			segi.proyV2 = inter*segi.vec
			segj.proyV1 = inter*segj.vec
			
			--segmentos.puntos[punto] = punto
			segmentos.puntos[#segmentos.puntos+1] = punto
			
			punto.aristas = {segi,segj}
			
		else
			
			segi.proyV2 = puntos[segi.ids[#segi.ids]]*segi.vec
			segj.proyV1 = puntos[segj.ids[1]]*segj.vec
			
			segi.puntos[2] = {["coords"]= (segi.z*segi.perpen + segi.proyV2*segi.vec)}
			segj.puntos[1] = {["coords"]= (segj.z*segj.perpen + segj.proyV1*segj.vec)}
			
			segi.puntos[2].error = Segmentacion.errorEsquina(puntos,segi.ids[#segi.ids],1)
			segj.puntos[1].error = Segmentacion.errorEsquina(puntos,segj.ids[1],-1)
			

			local oclusion = (1 + (segj.ids[1] - segi.ids[#segi.ids])% K.cantPuntos) < 4
			if oclusion then
				if segi.puntos[2].coords * segi.puntos[2].coords < segj.puntos[1].coords * segj.puntos[1].coords then
					segi.puntos[2].esEsquina = segi.puntos[2].error < K.radioEsquinas
					segi.puntos[2].oclusor = true
					segj.puntos[1].esEsquina = false
					segj.puntos[1].ocluido = true
				else
					segi.puntos[2].ocluido = true
					segi.puntos[2].esEsquina = false
					segj.puntos[1].esEsquina = segj.puntos[1].error < K.radioEsquinas
					segj.puntos[1].oclusor = true
				end
			else
				segi.puntos[2].esEsquina = segi.puntos[2].error < K.radioEsquinas
				segj.puntos[1].esEsquina = segj.puntos[1].error < K.radioEsquinas
			end
			
			--segmentos.puntos[segi.puntos[2]] = segi.puntos[2]
			--segmentos.puntos[segj.puntos[1]] = segj.puntos[1]
			segmentos.puntos[#segmentos.puntos+1] = segi.puntos[2]
			segmentos.puntos[#segmentos.puntos+1] = segj.puntos[1]
			
			segi.puntos[2].aristas ={segi}
			segj.puntos[1].aristas ={[2]=segj}

		end
	
	end
	
	return --no devuelvo nada, las modificaciones se hicieron en segmentos
	

end

--funcion para debuggeo -- hace deep copy de los segmentos salidos de esquinas
Segmentacion.copyS3 = function(s3)
	local p = s3.puntos
	s3.puntos = nil
	local idMejor = 0
	for k,v in ipairs(s3) do
		if s3.mejor == v then
			idMejor = k
		end
	end
	s3.mejor = nil
	
	local copy = utils.deepCopy(s3)
	s3.puntos = p
	s3.mejor = s3[idMejor]
	
	utils.acomodarConexion(copy)
	copy.puntos = {}
	copy.mejor = copy[idMejor]
	for i,segi in ipairs(copy) do
		segi.puntos = {}
	end
	for i,segi in ipairs(copy) do
		local j = 1 + i % #copy
		local segj = copy[j]
		
		if segi.conectado then
			local inter = {}
			inter.esEsquina = true
			inter.error = 0
			inter.aristas = {segi,segj}
			inter.coords = utils.deepCopy(s3[i].puntos[2].coords)
			
			segi.puntos[2] = inter
			segj.puntos[1] = inter
			
			copy.puntos[#copy.puntos + 1] = inter
			
		else
			local pi2 = {}		
			local pj1 = {}
			
			pi2.esEsquina = s3[i].puntos[2].esEsquina
			pj1.esEsquina = s3[j].puntos[1].esEsquina
			
			pi2.error = s3[i].puntos[2].error
			pj1.error = s3[j].puntos[1].error
			
			pi2.aristas = {segi}
			pj1.aristas = {[2]=segj}
			
			pi2.coords = utils.deepCopy(s3[i].puntos[2].coords)
			pj1.coords = utils.deepCopy(s3[j].puntos[1].coords)
			
			segi.puntos[2] = pi2
			segj.puntos[1] = pj1
			copy.puntos[#copy.puntos + 1] = pi2
			copy.puntos[#copy.puntos + 1] = pj1
			
			pi2.ocluido = s3[i].puntos[2].ocluido
			pi2.oclusor = s3[i].puntos[2].oclusor
			pj1.ocluido = s3[j].puntos[1].ocluido
			pj1.oclusor = s3[j].puntos[1].oclusor
			
		
		end
		
	end
	return copy

end









return Segmentacion