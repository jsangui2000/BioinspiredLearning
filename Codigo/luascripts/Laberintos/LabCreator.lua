local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require ("Utils/Vector")
local D = require ("Utils/Debug")

local LabCreator = {}

LabCreator.create = function(labname,folder)
	local folder = folder or folderDir
	local esquema = require(folder ..'\\'.. labname .. '\\' .. 'Esquema')
	local lab = {}
	lab.labname = labname
	lab.esquema = esquema
	lab.puntos = {} --esto me interesa para evaluacion
	lab.aristas = {} --esto me interesa para creacion en vrep, debe guardar direccion y longitud
	
	lab.minx,lab.maxx,lab.miny,lab.maxy = 1/0,0,1/0,0
	--creo aristas a ser dibujadas en v-rep
	for k,v in ipairs(esquema) do
		--print(k,v)
		lab.aristas[k] = {}
		local dx,dy = v.arista[3]-v.arista[1],v.arista[4]-v.arista[2]
		lab.aristas[k].dir = Vector(dx,dy) / math.sqrt(dx*dx,dy*dy)
		lab.aristas[k].perpen = Vector(-lab.aristas[k].dir[2],lab.aristas[k].dir[1])
		lab.aristas[k].longitud = math.sqrt(dx*dx+dy*dy)
		lab.aristas[k].tita = math.atan2(dy,dx)
		lab.aristas[k].centro = Vector((v.arista[3]+v.arista[1])/2,(v.arista[4]+v.arista[2])/2,1)
		
		lab.aristas[k].puntos = {}
		for i=1,2 do
			-- local long = lab.aristas[k].longitud/2
			-- if v.intersecciona then
				-- long = long -0.01
			-- end
			-- if i==1 or i == 4 then
				-- long = -long
			-- end
			-- local pLength = 0.005
			-- if i == 1 or i == 2 then
				-- pLength = -pLength
			-- end
			-- local centro = Vector(lab.aristas[k].centro[1],lab.aristas[k].centro[2])
			
			local punto = Vector(v.arista[2*(i-1) + 1],v.arista[2*(i-1)+2]) --centro + long*lab.aristas[k].dir + pLength*lab.aristas[k].perpen
			lab.aristas[k].puntos[i] = punto
			lab.minx = math.min(lab.minx,punto[1])
			lab.maxx = math.max(lab.maxx,punto[1])
			lab.miny = math.min(lab.miny,punto[2])
			lab.maxy = math.max(lab.maxy,punto[2])

			if v.puntos[i] then
				local id = #lab.puntos + 1
				lab.puntos[id] = punto
			end
		end
	end
	--traslado los puntos para que el laberinto este centrado:
	local labCenter = Vector(lab.maxx+lab.minx,lab.maxy+lab.miny)/2
	lab.center = labCenter
	local labCenter3 = Vector(labCenter[1],labCenter[2],0)
	for k,v in ipairs(lab.aristas) do
		for i=1,2 do
			v.puntos[i] = v.puntos[i] - labCenter
		end
		v.centro = v.centro - labCenter3
	end
	lab.minx,lab.miny = lab.minx - lab.center[1],lab.miny-lab.center[2]
	lab.maxx,lab.maxy = lab.maxx - lab.center[1],lab.maxy-lab.center[2]
	
	
	if simCreatePureShape then
		local props = 1+2+4+8+16
		for k,v in ipairs(lab.aristas) do
			local mhandle = simCreatePureShape(0,props,{v.longitud,0.0001,2},1)
			simSetObjectPosition(mhandle,-1,{0,0,4})
			simSetObjectOrientation(mhandle,-1,{0,0,v.tita})
			simSetObjectPosition(mhandle,-1,v.centro)
			simSetObjectSpecialProperty(mhandle,sim_objectspecialproperty_collidable +
												sim_objectspecialproperty_measurable +
												sim_objectspecialproperty_detectable_all + sim_objectspecialproperty_renderable)
			
		end
		--local handlesimCreatePureShape(0,0,{lab.maxx-lab.minx,lab.maxy-lab.miny,0.01},1)
	end
	--lab.posIni = Vector(0.25,0.25,0.0431) - labCenter3
	return lab
end

return LabCreator 