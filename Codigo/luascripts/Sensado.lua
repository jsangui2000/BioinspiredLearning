local folderDir = (...):match("(.-)[^%/]+$")
local Sensado = {}
local Vector = require (folderDir.."Utils/Vector")
local utils = require (folderDir.."Utils/Utils")

--valores importantes
Sensado.distancias = {} --tabla del 1 al 100 de los sensores laser
--Sensado.distmax  -- maximo valor de las entradas laser
--Sensado.distsuma -- suma de las entradas de los laser
--Sensado.pos [1=x 2=y]
--Sensado.headdir

--USO
--Primero llamar a setSimulacion o setKhepera una sola vez(dependiendo si robot real o simulacion)
--en cada iteracion llamar a sensar para que se carguen los valores definidos anteriormente
--en cada iteracion llamar a sensar para que se carguen los valores definidos anteriormente
--si se desea obtener la distancia normalizada usar Sense.distanciaNormalizada
--si se la pasa como parametro el valor true normaliza entre el maximo, 
--de lo contrario entre la suma de las distancias

Sensado.maxSenseDistance = 1.5


-- se usa esta para inicializar los valores de la tabla vrep
Sensado.setSimulacion = function ()
	--cargo sensores laser
	Sensado.laser = {}
	for i=0,99 do
		Sensado.laser[i+1] = simGetObjectHandle("Laser"..i)
		if Sensado.laser[i+1] == nil then 
			D.print('\n error nil')
		end
	end
	
	--cargo info necesaria para obtener posicion y direccion
	Sensado.posHandle = simGetObjectHandle("Dummy")
	Sensado.dirHandle = simGetObjectHandle("Dummy0") 
	Sensado.origin 	  = simGetObjectPosition(simGetObjectHandle("Origen"),-1)

	--Inicializo valores
	local pdum = simGetObjectPosition(Sensado.posHandle,-1)
	local pdum2 = simGetObjectPosition(Sensado.dirHandle,-1)
	
	Sensado.integration1 = Vector(0,0)
	-- D.addFile('reales')
	-- D.addFile('headdir')
	-- D.addFile('pos')
	Sensado.sensarConditional = function()
		local pdum = simGetObjectPosition(Sensado.posHandle,-1)
		local pdum2 = simGetObjectPosition(Sensado.dirHandle,-1)
	
		Sensado.pos = Vector(pdum[1]-Sensado.origin[1],pdum[2]-Sensado.origin[2])
		Sensado.dir = Vector(pdum2[1]-pdum[1],pdum2[2]-pdum[2])
		Sensado.headdir = math.atan2(pdum2[2]-pdum[2],pdum2[1]-pdum[1])	
		local cantnil = 0
		Sensado.distancias = Vector()
		Sensado.reales = Vector()
		_,Sensado.dNueva = simReadProximitySensor(Sensado.laser[1]) 
		Sensado.dNueva = Sensado.dNueva or 1/0
		for i=0,99 do
			_,Sensado.distancias[i+1] = simReadProximitySensor(Sensado.laser[i+1])
			_,Sensado.reales[i+1] = simReadProximitySensor(Sensado.laser[i+1])
			Sensado.reales[i+1] = Sensado.reales[i+1] or 30
			if Sensado.distancias[i+1] == nil or Sensado.distancias[i+1] > 1.5 then
				cantnil = cantnil + 1
				Sensado.distancias[i+1] = Sensado.maxSenseDistance  -- pongo el max valor si da nil
			end
		end
		if DBGSENSADO then
			D.printFile('ringB',Sensado.reales)
			D.printFile('hdB',{Sensado.headdir})
			D.printFile('posB',Sensado.pos)
		end
		Sensado.ringCartessian = nil
			
	end
	
	--inicializo valores
	Sensado.sensarConditional()
	Sensado.rotadas = utils.rotar(Sensado.distancias,Sensado.headdir)
	Sensado.rotadas = Sensado.filtroPicos(Sensado.rotadas)
	Sensado.distancias = utils.rotar(Sensado.rotadas,-Sensado.headdir)
	Sensado.dAnterior = Sensado.dNueva
	Sensado.ultimoDelta = 0.01
	Sensado.medianDelta = 0.01
	Sensado.cantDelta = 1
	
	Sensado.cantDelta2 = 3
	Sensado.deltas = Vector.value(0,Sensado.cantDelta2)
	Sensado.index = 1
end

-- se usa esta para inicializar los valores de la tabla en vrep
Sensado.setKhepera = function ()
	Sensado.sensarConditional = function ()
	end
end

Sensado.sensar = function()

	
	--guardo valores viejos
	Sensado.viejas = Sensado.rotadas
	
	--obtengo valores nuevos
	Sensado.sensarConditional()
	local signal = simGetIntegerSignal('moving')
	local dir = signal > 0 and 1 or -1
	if math.abs(signal)==1 then
		local delta = (Sensado.dNueva - Sensado.dAnterior)
		if math.abs(delta) < 0.05 and dir*delta > 0 then
			Sensado.integration1 = Sensado.integration1 +  delta*Sensado.dir
			Sensado.ultimoDelta = delta
			
			Sensado.medianDelta = utils.nAverage(Sensado.medianDelta,math.abs(delta),Sensado.cantDelta)
			Sensado.cantDelta = Sensado.cantDelta + 1
			
			Sensado.deltas[Sensado.index] = math.abs(delta)
			Sensado.index = 1 + Sensado.index  % Sensado.cantDelta2
			D.print('m '..utils.median(Sensado.deltas)..'\n')
			
		else
			Sensado.integration1 = Sensado.integration1 + dir*utils.median(Sensado.deltas)*Sensado.dir
		end
		--D.print(
	end
	
	Sensado.dAnterior = Sensado.dNueva
	
	--proceso los valores nuevos	
	Sensado.rotadas = utils.rotar(Sensado.distancias,Sensado.headdir)
	Sensado.rotadas = Sensado.filtroBalance(Sensado.rotadas,Sensado.viejas)
	Sensado.rotadas = Sensado.filtroPicos(Sensado.rotadas)	
	Sensado.distancias = utils.rotar(Sensado.rotadas,-Sensado.headdir)
	
	
	--Seteo para que se recalculen en caso de ser necesario:
	Sensado.rotadasCartessian = nil
	Sensado.distanciasCartessian = nil
	Sensado.centroid = nil
	Sensado.centroidRotated = nil
	Sensado.drives = {}
	
	Sensado.distmax = 0
	Sensado.distsuma = 0
	
	--busco suma y max
	Sensado.distmax = 0
	Sensado.distsuma = 0
	
	for i=1,100 do
		Sensado.distmax = math.max(Sensado.distancias[i],Sensado.distmax)
		Sensado.distsuma = Sensado.distsuma + Sensado.distancias[i]
	end
	
	Sensado.posVieja = Sensado.pos
	--Sensado.pos = Sensado.integration1
	
end

--Setters y getters para PI
if simReadProximitySensor then
	Sensado.setDistance = function()
		_,Sensado.dNueva = simReadProximitySensor(Sensado.laser[1]) 
	end
	Sensado.getDeltaDistance = function()
		_,newReading = simReadProximitySensor(Sensado.laser[1])
		return newReading - Sensado.dNueva
	end
	Sensado.getPosHD = function()
		local pdum = simGetObjectPosition(Sensado.posHandle,-1)
		local pdum2 = simGetObjectPosition(Sensado.dirHandle,-1)
		return Vector(pdum[1]-Sensado.origin[1],pdum[2]-Sensado.origin[2]),math.atan2(pdum2[2]-pdum[2],pdum2[1]-pdum[1])
		--Sensado.dir = 
		--Sensado.headdir = math.atan2(pdum2[2]-pdum[2],pdum2[1]-pdum[1])	
	end
end


--Obtencion de informacion Procesada
Sensado.getRingCartessian = function()
	if not Sensado.ringCartessian then
		Sensado.ringCartessian = utils.toCartessian(Sensado.reales)
	end
	return Sensado.ringCartessian
end

Sensado.getDistanciasCartessian = function()
	if not Sensado.distanciasCartessian then
		Sensado.distanciasCartessian = utils.toCartessian(Sensado.distancias)
	end
	return Sensado.distanciasCartessian
end
Sensado.getRotadasCartessian = function()
	if not Sensado.rotadasCartessian then
		Sensado.rotadasCartessian = utils.toCartessian(Sensado.rotadas)
	end
	return Sensado.rotadasCartessian
end

Sensado.getCentroid = function()
	if not Sensado.centroid then
		Sensado.centroid = utils.poligonCentroid(Sensado.getDistanciasCartessian())
	end
	return Sensado.centroid
end
Sensado.getCentroidRotated = function()
	if not Sensado.centroidRotated then
		Sensado.centroidRotated = utils.poligonCentroid(Sensado.getRotadasCartessian())
	end
	return Sensado.centroidRotated
end

Sensado.driveParameters = {}
Sensado.driveParameters["hunger"] = function()
	local condicion = 0.2 --d_hunger_max / 10, reward for one time step
	local estimulo  = condicion/2 --must be less than c_hunger for consistancy
	return estimulo,condicion
end
Sensado.driveParameters["fear"] = function()
	local estimulo,condicion = 0,-5 --no stimulus, condition maximizes value
	return estimulo,condicion
end

function Sensado.distanciaNormalizada(notgirada,divisor)
	
	local normalizada = Vector.copy(notgirada and Sensado.distancias or Sensado.rotadas)
	
	if divisor == 'distmax' then
		for i=1,100 do
			normalizada[i] = normalizada[i]/ Sensado.distmax
		end
	elseif divisor == 'distsuma' then
		for i=1,100 do
			normalizada[i] = normalizada[i]/ Sensado.distsuma
		end
	end
	return normalizada
end



--FILTROS:
Sensado.timer = Vector.value(0,100)
function Sensado.filtroBalance(nuevas,viejas)
	local filtrado = Vector()

	local sectores = {}
	local encontre = false
	local cantSec = 0
	local cant = 0
	
	for i=1,100 do
		if math.abs(nuevas[i] - viejas[i]) > 0.15 then
			if encontre then
				cant = cant + 1
				sectores[cantSec][cant] = i
			else
				encontre = true
				cantSec = cantSec + 1
				sectores[cantSec] = Vector(i)
				cant = 1		
			end
		else
			if encontre then
				encontre = false
			end
		end
		
	end
	
	if cantSec > 1 and encontre and sectores[1][1] == 1 then
		sectores[1] = sectores[1] .. sectores[cantSec]
		sectores[cantSec] = nil
	end
	
	for _,sector in ipairs(sectores) do
		if #sector > 2 then
			for _,index in ipairs(sector) do
				if Sensado.timer[index] == 0 then
					Sensado.timer[index] = 4
				end
			end
		end
	end
	
	for i=1,100 do
		Sensado.timer[i] = math.max(Sensado.timer[i]-1,0)
		filtrado[i] = Sensado.timer[i]>0 and viejas[i] or nuevas[i]
	end
	
	return filtrado
end

function Sensado.filtroPicos(distancias)
	local filtrado = Vector()
	for i=1,98 do
		filtrado[i+1] = (math.abs(distancias[i+2]-distancias[i]) < 0.1) and ((distancias[i+2]+distancias[i])/2) or distancias[i+1]
	end
	
	filtrado[1] = (math.abs(distancias[100]-distancias[2]) < 0.1) and ((distancias[100]+distancias[2])/2) or distancias[1]
	filtrado[100] = (math.abs(distancias[99]-distancias[1]) < 0.1) and ((distancias[99]+distancias[1])/2) or distancias[100]

	return filtrado
end






return Sensado