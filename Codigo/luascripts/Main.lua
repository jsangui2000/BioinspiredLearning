local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local utils = require ( "Utils/Utils")
local Vector = require ( "Utils/Vector")
local StateFinder = require ("Mapa/StateFinder")
require "socket" --para medir tiempos
local getTime = simGetSimulationTime or getTime

--abro random, ya no se usa pero por las dudas
math.randomseed(os.time())
DOSTATES = false
--levanto el laberinto:
local labCreator = require "Laberintos/LabCreator"
local labNames = {'Lab8Arms','Lab10Parallel','Lab10ParallelExtended'}
local lab = labCreator.create(labNames[3])

--Debug utility y variables
D = require "Utils/Debug"
--DBGMESSAGES = true
DBGSENSADO = true
iter = 0
if DBGMESSAGES then D.addFile('messages') end
if DBGSENSADO then 
	D.addFile('posB') 
	D.addFile('hdB')
	D.addFile('ringB')
	D.addFile('posPIB')
	D.addFile('hdPIB')
end


--Abro utilidad de sensado
sense = require (folderDir.. 'Sensado')
sense.setSimulacion()

--Creo o levanto un mapa
local Mapa = require (folderDir.."Mapa/Mapa")
local loadedMap = Mapa.new(sense.pos,sense.headdir) --seteo pos y dir inicial
local Segmentacion = require (folderDir .. "Mapa/Segmentacion")


--Inicializo dibujos del dialogo
Dialogos = require (folderDir.. "plotting/MapaPlotter")
Dialogos.newDialogue("mapa",lab) --segundo parametro es el lab, lab8 por defecto
Dialogos.dialogue["mapa"]:show()
mcnv = Dialogos.dialogue["mapa"].canvas
--mcnv.lab = {} doy puntero al laberinto
--mcnv.setOrigen(sense.origin)
mcnv.mapa = loadedMap


--
if simGetSimulationState then
	continuar = function()
		return simGetSimulationState()~=sim_simulation_advancing_abouttostop
	end
else
	continuar = function()
		return true
	end
end

iter = 0
while continuar() do
	iter = iter + 1
	D.print(iter .. '\n')

	
	--Sensar
	sense.sensarConditional()
	local dp = sense.pos - loadedMap.pos
	local dh = sense.headdir - loadedMap.headdir
	--D.print(dp:__tostring())
	--D.print(dh)
	
	
	
	--Hago segmentacion de cloud point data --hay algo mal, si intercambio seg y segCopy da cosas diferentes
	seg = {}
	segCopy = {}
	seg = Segmentacion.segmentacionInicial(sense.getRingCartessian())
	seg = Segmentacion.procesarSegmentos(seg,sense.getRingCartessian())
	Segmentacion.esquinas(sense.getRingCartessian(),seg)
	
	
	--hacer copiado de seg3 para mostrar en el mapa
	segCopy = Segmentacion.copyS3(seg)
	
	
	
	--calculo estado actual:
	local state, stateCopy
	if DOSTATES then
		state = StateFinder.findState(segCopy.puntos,sense.getRingCartessian())
		if #state < 3 then
			D.print("Error: bad state")
		end
		stateCopy = StateFinder.copyState(state)
	end
	
	--Actualizar mapa
	if DBGSENSADO then
		D.printFile('hdPIB',{loadedMap.headdir})
		D.printFile('posPIB',loadedMap.pos)
	end
	loadedMap:update(segCopy,state)
	loadedMap:saveIteracion(sense.headdir,sense.pos)
	
	
	
	--Setear Variables para dibujo (ring,seg3, pos, headdir, headdirReal)
	mcnv.ring = sense.getRingCartessian()
	mcnv.seg3 = seg
	mcnv.pos = sense.pos
	mcnv.headdir = sense.headdir
	if DOSTATES then
		mcnv.state = stateCopy
	end
	
	
	Dialogos.dialogue["mapa"].refresh()
	
	--Algoritmo de control
	lastState = ' '
	newState = ' '
	lastT = getTime()
	newT = lastT
	sense.setDistance()
	local posActual = Vector(loadedMap.pos[1],loadedMap.pos[2])
	local hdActual = loadedMap.headdir
	local angularSpeed = 0.58
	local robotSpeed = 0.130
	--D.print('\n')
	while continuar()  do
		if simGetSimulatorMessage then
			message,auxiliaryData=simGetSimulatorMessage()
			while message~=-1 do
				if (message==sim_message_keypress) then
					--D.print(auxiliaryData[1],auxiliaryData[2],auxiliaryData[3],auxiliaryData[4])
					if (auxiliaryData[1]==string.byte('a')) then
						--D.print("a")
						velIzq = -velGiro
						velDer = velGiro
						newState = 'a'
					elseif (auxiliaryData[1]==string.byte('s')) then
						--D.print("s")
						velIzq = -maxVel
						velDer = -maxVel
						newState = 's'
					elseif (auxiliaryData[1]==string.byte('d')) then
						--D.print("d")
						velIzq = velGiro
						velDer = -velGiro
						newState = 'd'
					elseif (auxiliaryData[1]==string.byte('w')) then
						--D.print("w")
						velIzq = maxVel
						velDer = maxVel
						newState = 'w'
					elseif (auxiliaryData[1]==string.byte(' ')) then
						velIzq = 0
						velDer = 0
						newState = ' '
					elseif (auxiliaryData[1]==string.byte('m')) then
						velIzq = 0
						velDer = 0
						newState = 'm'
					elseif (auxiliaryData[1]==string.byte('p')) then
						--D.print("p")
						simPauseSimulation()
					elseif (auxiliaryData[1]==string.byte('q')) then
						--D.print("q")
						terminar = true	
					end
				end
				message,auxiliaryData=simGetSimulatorMessage()
			end
		else
		end
		
		if lastState ~= newState then
			simExtK3_setVelocity(0,0)
			newT = getTime()
			mcnv.pos,mcnv.headdir = sense.getPosHD()
			deltaT = newT - lastT
			if lastState == 'a' then
				--calculo delta angulo y lo resto
				local deltaAngulo = deltaT*angularSpeed
				loadedMap.headdir = utils.truncarAngulo(hdActual + deltaAngulo)
				hdActual = loadedMap.headdir
			elseif lastState =='d' then
				local deltaAngulo = deltaT*angularSpeed
				loadedMap.headdir = utils.truncarAngulo(hdActual - deltaAngulo)
				hdActual = loadedMap.headdir
			elseif lastState == 's' or lastState == 'w' then
				local deltaPos = 0
				if lastState == 's' then
					deltaPos = -(getTime()- lastT)*robotSpeed
				else
					deltaPos = (getTime()- lastT)*robotSpeed
				end
				loadedMap.pos = posActual + deltaPos*Vector(math.cos(hdActual),math.sin(hdActual))
				posActual = Vector(loadedMap.pos[1],loadedMap.pos[2])
			end
		
			sense.setDistance()
			simExtK3_setVelocity(velIzq,velDer)
			lastT = getTime()
			lastState = newState
			
		else
			if lastState == 'a' then
				--calculo delta angulo y lo resto
				local deltaAngulo = (getTime()- lastT)*angularSpeed
				mcnv.pos,mcnv.headdir = sense.getPosHD()
				loadedMap.headdir = utils.truncarAngulo(hdActual + deltaAngulo)
			elseif lastState =='d' then
				local deltaAngulo = (getTime()- lastT)*angularSpeed
				mcnv.pos,mcnv.headdir = sense.getPosHD()
				loadedMap.headdir = utils.truncarAngulo(hdActual - deltaAngulo)
			elseif lastState == 's' or lastState == 'w' then
				local deltaPos = 0
				if lastState == 's' then
					deltaPos = -(getTime()- lastT)*robotSpeed
				else
					deltaPos = (getTime()- lastT)*robotSpeed
				end
				--D.print(deltaPos .. '\n')
				mcnv.pos,mcnv.headdir = sense.getPosHD()
				loadedMap.pos = posActual + deltaPos*Vector(math.cos(hdActual),math.sin(hdActual))
			else
				mcnv.pos,mcnv.headdir = sense.getPosHD()
			end
		
		end
		
		
			
		Dialogos.dialogue["mapa"].refresh()
		if newState == 'm' or terminar then 
			break 
		end
		
	end
	if terminar then break end
end
Dialogos.dialogue["mapa"].close()
loadedMap:saveResult('lab8')
simStopSimulation()