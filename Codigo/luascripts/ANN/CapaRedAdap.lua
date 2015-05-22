local folderDir = (...):match("(.-)[^%/]+$")
local CapaRedAdap = {}
CapaRedAdap.__index = CapaRedAdap

local Neurona = require 'Neurona'

--requiere haber inicializado los numeros randomicos
function CapaRedAdap.new(cantEntradas,n) -- n^2 es la cantidad de neuronas
	n = n or 10
	local self = setmetatable({},CapaRedAdap)
	self.n = n
	
	self.neurona = {}
	for i = 1,n do
		self.neurona[i] = {}
		for j = 1,n do
			self.neurona[i][j]=Neurona.new(cantEntradas)
		end
	end
	
	return self
end

function CapaRedAdap.update(self,entrada)

	--inicializo vector de salida
	local salidas = {}
	for i=1,self.n do
		for j=1,self.n do
			salidas[self.n*(i-1) + j] = 0
		end
	end
	
	
	--inicializo primer y ultima fila tabla auxiliar en 0 
	local salidasAux = {}
	salidasAux[0] = {}
	salidasAux[self.n+1] = {}
	for i=0,self.n+1 do
		salidasAux[0][i] = 0
		salidasAux[self.n+1][i] = 0
	end
	
	--termino de inicializar el borde de la tabla auxiliar en 0
	--y al interior le seteo los valores de las neuronas
	--los bordes en 0 se usan para uniformizar la busqueda local del siguiente paso
	--es decir para no controlar los casos especiales i,j==1,n
	for i=1,self.n do
		salidasAux[i]={}
		salidasAux[i][0]=0
		salidasAux[i][self.n+1] = 0
		for j=1,self.n do
			salidasAux[i][j] = self.neurona[i][j]:activar(entrada)
		end
	end
	
	--busco los maximos locales, cuando encuentro grabo la salida y actualizo peso
	for i=1,self.n do
		for j=1,self.n do
			local maxlocal = true
			for k=i-1,i+1 do
				for l=j-1,j+1 do
					maxlocal = maxlocal and (salidasAux[i][j]>= salidasAux[k][l])
				end
			end
			if maxlocal then
				salidas[(i-1)*self.n+j] = salidasAux[i][j]
				self.neurona[i][j]:update()
			end
		end
	end
	
	return salidas
end
	
return CapaRedAdap