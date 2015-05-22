local folderDir = (...):match("(.-)[^%/]+$")
local wg = {}
local utils = require (folderDir.."Utils/Utils")

--Creo grafo vacio
local G = require((folderDir.."Utils/Grafo"))
wg.graph = G.new()
wg.idNodoAnterior = 1
wg.idNodoActual = 1
wg.ring = {}

function wg.usarAdap()
	--Cargo la red del WG y seteo parametros:
	wg.red = require (folderDir.."ANN/RedAdap")
	--threshold para crear celulas nuevas
		wg.red.placeCells.threshold = 0.005
	--sigma = maxamplitud/2 * porcentaje
		wg.red.sigmaAnguloDir = (2*math.pi)/2*1
		wg.red.sigmaAnguloMark = (2*math.pi)/2*0.05
		wg.red.sigmaDistancia = 5/2*0.2*0.1
	--este sigma es distinto porque no codifica un numero
		wg.red.sigmaRing = 0.3  -- ver grafica
		
	wg.contador      =0 --cuenta la cantidad de neuronas en la ultima capa = #nodos grafo
	
	wg.iter = 0
	
	wg.update = function (headdir,walls,pos)
		wg.iter = wg.iter + 1
		wg.idNodoAnterior = wg.idNodoActual
		
		local polar = utils.toPolar(pos)
		if wg.red.update(headdir,walls,utils.toPolar(pos),polar[1],polar[2]) then
			if MESSAGES then D.printFile('messages',{'creo',wg.iter}) end
			wg.contador = wg.contador + 1
			D.print("neurona "..wg.contador..'\n')
			wg.graph:addNodo(pos[1],pos[2])
		end
		wg.idNodoActual = wg.red.placeCells.idActiva
		
		if (wg.idNodoAnterior ~= wg.idNodoActual) then
			if MESSAGES then D.printFile('messages',{'activa',wg.idNodoActual,wg.iter}) end
			D.print("nueva activa "..wg.idNodoActual .. '/'..wg.contador..'\n')
		end
		wg.graph:addArista(wg.idNodoAnterior,wg.idNodoActual)
		--wg.dialogue.canvas.activa = wg.idNodoActual
		--wg.dialogue.refresh()
	end
	
end

function wg.usarKNN()
	wg.k_similitud = 1.2 	 --similitud entre patrones  --1.2 bien
	wg.k_integracion = 0.3	 --cada que distancia minima promedio patron 0.3
	wg.k_integracion_dcentroide = 0.8 --si el centroide cambia mucho entonces que no lo integre 0.8
	wg.k_radio_busqueda = 1.5--maxima distancia a la que se puede encontrar un nodo 1.5
	wg.k_cobertura = 0.65	 --radio minimo que cubre un nodo desde su centroide 0.5

	
	wg.iter = 0

	wg.updateInicial = function (data)
		wg.iter = 1		
		local headdir = data.headdir
		local pos = data.pos
		local walls = data.rotadas
		local wallsCart = data.getRotadasCartessian()
		
		if MESSAGES then D.printFile('messages',{'creo',wg.iter}) end
		
		local centroid = utils.poligonCentroid(wallsCart)
		centroid[1],centroid[2] = centroid[1]+pos[1],centroid[2]+pos[2]
		
		wg.graph:addNodo(centroid)
		wg.idNodoActual = 1
		wg.idNodoAnterior = 1
		wg.nodo = wg.graph.nodos[1]
		wg.anterior = wg.nodo
		
		wg.nodo.headdir = headdir
		wg.nodo.walls = walls
		wg.nodo.wallsCart = wallsCart
		wg.nodo.observacion = {pos}
		
		
		wg.update = wg.updateNormal
		return true
	end
	
	wg.updateNormal = function (data)
		local headdir = data.headdir
		local pos = data.pos
		local walls = data.rotadas
		local wallsCart = data.getRotadasCartessian()
		local centroid = data.getCentroidRotated() + pos
	
		wg.iter = wg.iter + 1
		wg.idNodoAnterior = wg.idNodoActual	
		wg.anterior = wg.nodo
		wg.nodo = nil
		
		local res = {}
		res.visible = {}
		
		local mindist = 1/0 
		local dcentroide = 1/0
		local id = 0
		
		for nodoId,n in ipairs(wg.graph.nodos) do
			res.visible[nodoId] = n:alcanzado(pos,walls)
		end
		
		local fail = "fail"
		
		for nodoId,n in ipairs(wg.graph.nodos) do
			if utils.allValue(res.visible, {nodoId} ,{-1,true})  then --me fijo tanto el nodo como sus adyacentes sean alcanzables, sino descarto el nodo
				local cercaniaCentroides = utils.distance2(centroid,n.centroid)
				local dist = n:minDistance(pos)
				if (utils.poligonDifference(walls,wallsCart,n.walls,n.wallsCart) < wg.k_similitud and dist < wg.k_radio_busqueda ) or  cercaniaCentroides < wg.k_cobertura then 
					local distPosCentroid = utils.distance2(pos,n.centroid)
					if  distPosCentroid <  mindist then
						id = nodoId
						mindist = distPosCentroid
						dcentroide = cercaniaCentroides
					else
						if nodoId == wg.idNodoAnterior then
							D.print("fallo3\n")
						end
						fail = fail .. "3,"
					end
				else
					if nodoId == wg.idNodoAnterior then
						D.print("fallo2\n")
					end
					fail = fail .. "2,"
				end	
				
			else
				if nodoId == wg.idNodoAnterior then
					D.print("fallo1\n")
				end
				fail = fail .. "1,"
			end
		end
		
		
			
		--D.print('aca')	
		--D.print('nodos'..#wg.nodos..'\n')
		--D.print('dist '..mindis..'\n')
		local returnVal = false
		if id == 0 then
			--Guardo un nuevo patron
			D.print(fail..'\n')
			if FAIL then D.printFile('fail',{fail}) end
			if MESSAGES then D.printFile('messages',{'creo',wg.iter}) end
			wg.idNodoActual = #wg.graph.nodos+1
			wg.graph:addNodo(centroid)
			wg.nodo = wg.graph.nodos[wg.idNodoActual]
			
			wg.nodo.headdir = headdir
			wg.nodo.walls = walls
			wg.nodo.wallsCart = wallsCart
			wg.nodo.observacion = {pos}
			returnVal = true
			
			
		else
			--Solo cambio nodo actual
			wg.idNodoActual = id
			wg.nodo = wg.graph.nodos[id]
			if not wg.nodo:observacionCercana(pos,wg.k_integracion) and 
					dcentroide < wg.k_integracion_dcentroide then
				
				local n = #wg.nodo.puntos
				wg.nodo:addPoint(centroid)
				wg.nodo.observacion[#wg.nodo.observacion+1] = pos
				
				--promedio patrones
				wg.nodo.walls 	 = utils.nAverage(wg.nodo.walls,walls,n)
				wg.nodo.wallsCart = utils.nAverage(wg.nodo.wallsCart,wallsCart,n)
				wg.nodo.headdir 	 = utils.nAverage(wg.nodo.headdir,headdir,n)

			end
		end
		
		if (wg.idNodoAnterior ~= wg.idNodoActual) then
			if MESSAGES then D.printFile('messages',{'activa',wg.idNodoActual,wg.iter}) end
			D.print("nueva activa "..wg.idNodoActual .. '/'..#wg.graph.nodos..'\n')
		end
	
	
		wg.graph:addArista(wg.idNodoAnterior,wg.idNodoActual)
		--[[ esto lo saque porque pienso es mejor de la otra forma
		for id,v in ipairs(res.visible) do
			if v then wg.graph:addArista(id,wg.idNodoActual) end
		end
		--]]
		return returnVal
		
	end
	
	wg.update = wg.updateInicial
	
end



return wg