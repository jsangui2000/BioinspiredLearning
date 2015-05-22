td = require "TestData"
seg = require "Segmentacion"
rl = require "Reglin"
mp = require "MapaPlotter"

SF = require "StateFinder"

local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require (folderDir.."Utils/Vector")
local utils = require (folderDir.."Utils/Utils")
local Mapa = require (folderDir.."Mapa")
require "socket"

local fileID = '1425329797'
-- fileID = 'B1430758462'
-- fileID = 'B1430855695'
-- fileID = 'B1430871298'
-- fileID = 'B1430915671'
-- fileID = 'B1430920088'
-- fileID = 'B1430922957'
-- fileID = 'B1430954080'
fileID = 'B1430975213'

DOSTATES = true

labId = 3
--miVar = 7
skipUpdateIndex=14

local mOrigen
mOrigen = {-1.7249999046326;-1.7249997854233}
if not tonumber(fileID) then
	mOrigen = {0,0}
else
	labId = 1
end


labCreator = require "Laberintos/LabCreator"
labNames = {'lab8Arms','lab10Parallel','lab10ParallelExtended'}
lab = labCreator.create(labNames[labId])

function printT(t,recursive)
	if type(t) == "table" then
		for k,v in pairs(t) do print(k,v) end
	else
		print(t)
	end
end

function printTA(mapa)
	for k,v in pairs(mapa.tablaAristasPoligonos) do
		for k2,v2 in pairs(v) do
			print(k.gid,k2.gid,v2.gid)
		end
	end
end

function printA(mapa,id)
	if id then
		printT(mapa.aristas[tonumber(id)])
	else
		for k,v in ipairs(mapa.aristas) do
			print(v.puntos[1].coords,v.puntos[2].coords)
		end
	end

end

function printP(mapa,id)
	for k,v in ipairs(mapa.puntos) do
		print(k,v.gid,v.coords)
	end
end

function printE(mapa,id)
	for k,v in ipairs(mapa.estados) do
		print('estado:',k)
		for k2,v2 in ipairs(v) do
			print(v2.gid)
		end
	end
end

function ce(t)
	local res=0
	for k,v in pairs(t) do
		res = res+1
	end
	return res
end

ps3 = function(id)
	for k,v in ipairs(seg3[id]) do
		print(v.puntos[1].coords,v.puntos[2].coords)
	end
end

ps2 = function(id)
	for k,v in ipairs(seg2[id]) do
		print(td.ringCartP[id][v.ids[1]],td.ringCartP[id][v.ids[#v.ids]])
	end
end



td.loadData(fileID)


copyS1 = function(s1)
	local copy = utils.deepCopy(s1)
	utils.acomodarConexion(copy)
	return copy
end

copyS2 = function(s2)
	return copyS1(s2)
end

copyS3 = function(s3)
	local p = s3.puntos
	
	--print(unpack(s3.puntos))
	
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

copyMap = function(map)
	local copy = {}
	copy.puntos = {}
	for k,v in ipairs(map.puntos) do
		copy.puntos[k] = {}
		copy.puntos[k].esEsquina =v.esEsquina
		copy.puntos[k].error  = v.error
		copy.puntos[k].coords = utils.deepCopy(v.coords)
		copy.puntos[k].gid = v.gid
	end
	
	copy.aristas = {}
	for k,v in ipairs(map.aristas) do
		copy.aristas[k] = {}
		copy.aristas[k].vec = utils.deepCopy(v.vec)
		copy.aristas[k].perpen = utils.deepCopy(v.perpen)
		copy.aristas[k].z = v.z
		copy.aristas[k].proyV1 = v.proyV1
		copy.aristas[k].proyV2 = v.proyV2
		copy.aristas[k].gid = v.gid
		copy.aristas[k].puntos = {}
		copy.aristas[k].puntos[1] = copy.puntos[v.puntos[1].gid]
		copy.aristas[k].puntos[2] = copy.puntos[v.puntos[2].gid]
		copy.aristas[k].tita = v.tita
		copy.aristas[k].conectado = v.conectado
	end
	for k,v in ipairs(map.aristas) do
		if v.ant then
			copy.aristas[k].ant = copy.aristas[v.ant.gid]
		end
		if v.sig then
			copy.aristas[k].sig = copy.aristas[v.sig.gid]
		end
	end
	copy.matchTable = utils.deepCopy(map.matchTable)
	copy.headdir = map.headdir
	copy.pos = utils.deepCopy(map.pos)
	copy.localice = map.localice
	
	copy.hash = {}
	for k,v in ipairs(map.hashAngulo) do
		copy.hash[k] = {}
		for k2,v2 in pairs(v) do
			copy.hash[k][#copy.hash[k]+1] = v2.gid
		end
	end
	
	--copio poligonos y tabla arista poligonos
	copy.estados = {}
	copy.tablaAristasPoligonos = {}
	if DOSTATES then
		for k,v in ipairs(map.estados) do
			copy.estados[k] = {}
			copy.estados[k].gid = k
			for kS,vS in ipairs(v) do
				copy.estados[k][kS] = copy.puntos[vS.gid]
				copy.estados[k][copy.puntos[vS.gid]] = true
				if not copy.puntos[vS.gid].estados then
					copy.puntos[vS.gid].estados = {}
				end
				table.insert(copy.puntos[vS.gid].estados,v)
			end
		end
		-- copy.estado = {}
		-- for k,v in ipairs(map.estado) do
			-- table.insert(copy.estado,copy.puntos[v.gid])
		-- end
		
		copy.estado = copy.estados[map.estado.gid]
		
		for p1,t in pairs(map.tablaAristasPoligonos) do
			copy.tablaAristasPoligonos[copy.puntos[p1.gid]] = {}
			for p2,s in pairs(t) do
				copy.tablaAristasPoligonos[copy.puntos[p1.gid]][copy.puntos[p2.gid]] = copy.estados[s.gid]
			end
		end
	end
	

	return copy

end

saveSegments3 = function(id,s3)
	local f1 = io.open('seg3/seg'.. id .. '.txt','w')
	io.output(f1)
	for k,v in ipairs(s3) do
		io.write(v.puntos[1].coords[1])
		io.write(';')
		io.write(v.puntos[1].coords[2])
		io.write(';')
		io.write(v.puntos[2].coords[1])
		io.write(';')
		io.write(v.puntos[2].coords[2])
		io.write(';\n')
	end
	io.close(f1)
	local f2 = io.open('seg3/vec' .. id .. '.txt','w')
	io.output(f2)
	for k,v in ipairs(s3) do
		io.write(v.vec[1])
		io.write(';')
		io.write(v.vec[2])
		io.write(';\n')
	end
	io.close(f2)
	local f3 = io.open('seg3/perpen' .. id .. '.txt','w')
	io.output(f3)
	for k,v in ipairs(s3) do
		io.write(v.perpen[1])
		io.write(';')
		io.write(v.perpen[2])
		io.write(';\n')
	end
	io.close(f3)
	local f4 = io.open('seg3/conex' .. id .. '.txt','w')
	io.output(f4)
	for k,v in ipairs(s3) do
		if v.conectado then io.write(1) else io.write(0) end
		io.write(';')
	end
	io.close(f4)
end
saveSeg3All = function(s3)
	for k,v in ipairs(s3) do
		print(k)
		saveSegments3(k,v)
	end		
end

saveIDS = function(s3)
	for k,v in ipairs(s3) do
		print(k)
		f = io.open('seg3/ids/ids'..k..'-cant.txt','w')
		io.output(f)
		io.write(#v)
		io.close(f)
		for k2,v2 in ipairs(v) do
			f = io.open('seg3/ids/ids'..k..'-'..k2..'.txt','w')
			io.output(f)
			for k3,v3 in ipairs(v2.ids) do
				io.write(v3,';')
			end
			io.close(f)
		end
	end
end

copyState =function (myState)
	local copy = {}
	for k,v in ipairs(myState) do
		copy[#copy+1] = v.punto.lid
	end
	return copy
end
		
--===================================================================================
--===================================================================================


globalIndex = 1
myfun = function(lastIndex)
	print(lastIndex)
	miMapa = Mapa.new(td.pos[1],td.headdir[1])
	--miMapa = Mapa.new(Vector(0,0),td.headdir[1])

	seg1,con1,seg2,con2,seg3,con3,mapas,states = {}, {}, {}, {},{}, {},{},{}
	mf,vs,sids,merror = {}, {}, {}, {}

	local testIndex = -1
	for index = 1,lastIndex do
		--print('\nel index', index)
		if index % 100 == 0 then print(index) end
		globalIndex = index
		seg1[index] =seg.segmentacionInicial(td.ringCartP[index])

		seg1copy = copyS1(seg1[index])

		seg2[index] = seg.procesarSegmentos(seg1copy,td.ringCartP[index])
		
		seg3[index] = copyS2(seg2[index])		
		seg.esquinas(td.ringCartP[index],seg3[index])
		
		-- for k,v in ipairs(seg3[index]) do
			-- if not v.puntos[1].aristas then
				-- print(k,1)
			-- end
			-- if not v.puntos[2].aristas then
				-- print(k,2)
			-- end
		-- end
		
		seg3copy = copyS3(seg3[index])
		
		-- for k,v in ipairs(seg3copy) do
			-- if not v.puntos[1].aristas then
				-- print(k,1)
			-- end
			-- if not v.puntos[2].aristas then
				-- print(k,2)
			-- end
		-- end
		
		if DOSTATES then
			if globalIndex~=0 then
				state = SF.findState(seg3copy.puntos,td.ringCartP[index])
				states[index] = copyState(state)
			else
				states[index] = {1,2,3}
			end
		end
		
		
		
		if fileID:byte(1) == 66 and globalIndex > 1 then
			miMapa.pos = td.posPI[index-1]
			miMapa.headdir = td.headdirPI[index-1]
			--print('mod pos,headdir')
		end
		
		
		
		if globalIndex ~= skipUpdateIndex and globalIndex ~= -1 then
			miMapa:update(seg3copy,state)
		end
		
		
		mapas[index] = copyMap(miMapa)
		
		if globalIndex == testIndex then
			print('\npuntos')
			for k,v in ipairs(mapas[4].estados[1]) do
				print(v,v.coords)
			end
		end

	end

	--index = 2
	--seg1[index],con1[index] =seg.segmentacionInicial(td.ringCartP[index],true)
	ms1 = seg1[lastIndex]
	ms2 = seg2[lastIndex]
	ms3 = seg3[lastIndex]


	-- print('cant puntos',#puntosGlobales)
	-- print('cant aristas',#aristasGlobales)
	-- print('\n')
	-- for k,v in ipairs(puntosGlobales) do
		-- print(v.coords)
	-- end
	-- print('\n')
	-- for k,v in ipairs(aristasGlobales) do
		-- print(v.puntos[1].coords,v.puntos[2].coords)
	-- end

end


--======================================================================================


doVideo = function(lastIndex,sleepCount)
	for i=1,lastIndex do
		mcnv.index = tonumber(i)
		mp.dialogue["data"].refresh()
		socket.select(nil,nil,sleepCount or 0.05)
	end

end


miVar = miVar or #td.headdir
DO_STATES = true
myfun(miVar)

mp.newDialogue("data",lab)
mcnv = mp.dialogue["data"].canvas
mcnv.setOrigen(mOrigen)
r2 = mp.dialogue["data"].refresh
mcnv.index =1
mcnv.seg3 = seg3
print(mcnv.seg3)
mcnv.headdir = td.headdir
mcnv.pos = td.pos
mcnv.puntos = td.ringCartP
mcnv.mapas = mapas
mcnv.states = states

mcnv.addDraw(mp.drawData)
mcnv.addDraw(mp.drawSegmentosIniciales)
mcnv.addDraw(mp.drawState)

calcError = function()
	local diffhd = {}
	local diffp  = {}
	for i,m in ipairs(mapas) do
		if m.localice then
			local dp = m.pos - td.pos[i]
			local dd = math.sqrt(dp*dp)
			diffp[#diffp+1] = dd
			local dh = math.abs(utils.truncarAngulo(m.headdir - td.headdir[i]))
			diffhd[#diffhd+1] = dh
		end
	end
	print("cantPosicionado",#diffhd)
	table.sort(diffhd)
	table.sort(diffp)
	local hdmean = utils.average(diffhd)
	local hdstd = utils.standardDev(diffhd)
	local pmean = utils.average(diffp)
	local pstd = utils.standardDev(diffp)
	
	print("errorHD (max,mean,std):")
	print(diffhd[#diffhd],hdmean,hdstd)
	print("errorP (max,mean,std):")
	print(diffp[#diffp],pmean,pstd)	
end

calcError()


play = function()
	while true do
		mp.dialogue["data"].refresh()
	end
end
play()


