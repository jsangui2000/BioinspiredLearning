local folderDir = (...):match("(.-)[^%/]+$")
local Neurona = {}
Neurona.__index = Neurona

function Neurona.new(n,tipo)
	tipo = tipo or {["name"]="hebbian",["alfa"]=0.1} --valores predeterminados
	local self = setmetatable({},Neurona)
	self.salida = 0
	self.entrada = nil
	self.peso = {}
	self.n = n
	local total = 0
	for i=1,n do
		self.peso[i] = math.random()
		total = total + self.peso[i]
	end
	for i=1,n do
		self.peso[i] = self.peso[i] / total
	end
	self.signal = math.random()
	if tipo.name == 'hebbian' then
		self.update = self.hebbianUpdate
		self.alfa = tipo.alfa
	end
	return self
end

function Neurona.RandomSignal(self)
	return 0 --self.signal o math.random()
end

function Neurona.activar(self,entrada)
	self.entrada = entrada
	self.salida = self:RandomSignal()
	for i=1,self.n do
		self.salida = self.salida + self.peso[i]*entrada[i]
	end
	return self.salida
end



function Neurona.hebbianUpdate(self)
	local total = 0
	for i=1,self.n do
		self.peso[i] = self.peso[i]*(1+self.alfa * self.entrada[i] * self.salida)
		total = total + self.peso[i]
	end
	for i=1,self.n do
		self.peso[i] = self.peso[i]/total
	end
end

return Neurona