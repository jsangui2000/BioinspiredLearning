local folderDir = (...):match("(.-)[^%/]+$")
local PlaceLayer = {}
local Neurona = require (folderDir.."Neurona")
PlaceLayer.threshold = 1/100
PlaceLayer.neurona = {}

function PlaceLayer.nuevaNeurona(entradas)
	local numeroNeurona = #PlaceLayer.neurona+1
	PlaceLayer.neurona[numeroNeurona] = Neurona.new(#entradas)
	local suma = 0
	
	local nonzero = 0
	for i=1,#entradas do	
		if entradas[i] > 0 then
			nonzero = nonzero + 1
		end
	end
	for i=1,#entradas do
		if entradas[i] > 0 then 
			PlaceLayer.neurona[numeroNeurona].peso[i] = 1/nonzero
		else
			PlaceLayer.neurona[numeroNeurona].peso[i] = 0
		end
	end
	
	PlaceLayer.neurona[numeroNeurona].update = function () end
	
	--[[
	for i=1,#entradas do
		PlaceLayer.neurona[numeroNeurona].peso[i] = entradas[i]*PlaceLayer.neurona[numeroNeurona].peso[i]
		suma = suma + PlaceLayer.neurona[numeroNeurona].peso[i]
	end
	for i=1,#entradas do
		PlaceLayer.neurona[numeroNeurona].peso[i] = PlaceLayer.neurona[numeroNeurona].peso[i] / suma
	end
	--]]
	PlaceLayer.neuronaActiva = PlaceLayer.neurona[numeroNeurona]
	PlaceLayer.idActiva = numeroNeurona
	PlaceLayer.neuronaActiva:activar(entradas)
end

function PlaceLayer.updateGeneral(entradas)

	--actualizo las neuronas y busco la que tenga mayor activacion
	PlaceLayer.neuronaActiva = PlaceLayer.neurona[1]
	PlaceLayer.idActiva = 1
	for k,n in ipairs(PlaceLayer.neurona) do
		n:activar(entradas)
		n:update()
		if n.salida > PlaceLayer.neuronaActiva.salida then
			PlaceLayer.neuronaActiva = n
			PlaceLayer.idActiva = k
		end
	end
	
	
	--si activacion no pasa el threshold creo una neurona nueva
	if PlaceLayer.neuronaActiva.salida < PlaceLayer.threshold then
		--print('creo porque '..PlaceLayer.neuronaActiva.salida)
		PlaceLayer.nuevaNeurona(entradas)
		return true --devuelvo que se creo una neurona nueva
	end
	return false
end

function PlaceLayer.updateInicial(entradas)
	PlaceLayer.nuevaNeurona(entradas)
	PlaceLayer.update = PlaceLayer.updateGeneral
	return true --devuelvo que se creo una neurona nueva
end

--al empezar la capa esta vacía, por lo que solo tengo que crear una neurona nueva
PlaceLayer.update = PlaceLayer.updateInicial

return PlaceLayer