local folderDir = (...):match("(.-)[^%/]+$")
local redAdap = {}
local tamano = 10
local cantCellsFeatures = tamano*tamano
local cantEntradas = 100
local Capa = require (folderDir.."CapaRedAdap")

D.addFile("distancia")
D.addFile("headdir")
D.addFile("dir")

redAdap.sigmaAnguloDir    = 0.5 -- sigma gaussiana para coarse code angulos dir cabeza
redAdap.sigmaAnguloMark   = 0.5 -- sigma gaussiana para coarse code angulos de home base
redAdap.sigmaDistancia = 0.5 -- sigma gaussiana para coarse cide distancias
redAdap.sigmaRing = 0.5 -- sigma para calcular el ring de distancias -- solo si no se usa laser
local distmin = 0  -- distancia minima a codificar
local distmax = 5 -- distancia maxima a codificar


local Coarse = require (folderDir.."../Utils/CoarseCode")

--Feature Detectors
redAdap.head = Capa.new(cantEntradas,tamano)
redAdap.walls	= Capa.new(cantEntradas,tamano)
redAdap.mark = Capa.new(cantEntradas*2,tamano)

--place cells
redAdap.placeCells = require (folderDir.."CapaPlaceCells")


function concatArrays(...)
	local concatenated = {}
	for _,v in ipairs(arg) do
		for _,v2 in ipairs(v) do
			concatenated[#concatenated+1] = v2
		end
	end
	return concatenated
end


--headin es angulo cabeza
--wallsin es tabla de pares angulo distancia -- se cambia cuando se logre usar laser ya que no es necesario crear un ring mediante coarse code
--markdistin es distancia a la marca
--markangle es el angulo a la marca
function redAdap.update(headin,wallsin,markdistin,markangle)
	local headcode = Coarse.angle(headin,cantEntradas,redAdap.sigmaAnguloDir)
	--local wallcode = Coarse.RingDistance(wallsin,cantEntradas,redAdap.sigmaRing)
	local wallcode = wallsin
	local dcode = Coarse.distance(markdistin,distmin,distmax,cantEntradas,redAdap.sigmaDistancia)
	local acode = Coarse.angle(markangle,cantEntradas,redAdap.sigmaAnguloMark)
	local markcode = concatArrays(dcode,acode)
	
	
	D.printFile('distancia',dcode)
	D.printFile('dir',acode)
	D.printFile('headdir',headcode)

	local salFeatures = concatArrays(
					redAdap.head:update(headcode),
					redAdap.walls:update(wallcode),
					redAdap.mark:update(markcode))

	for i=1,300 do
		if salFeatures[i] > 1 and i < 201 then
			D.print('feature '..i..' '..salFeatures[i]..'\n')
		end
	end
	
	return redAdap.placeCells.update(salFeatures)
end
return redAdap