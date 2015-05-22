local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local RL = {}
RL.__index = RL
local Vector = require (folderDir.."Utils/Vector")
local Drive = require (folderDir.."Motivations/Drive")
local utils = require (folderDir.."Utils/Utils")
local ET = require (folderDir.."EligibilityTrace")
local CC = require (folderDir.."Utils/CoarseCode")


RL.new = function()
	local self = {}
	setmetatable(self,RL)
	return self
end

--inicializacion
RL.init = function(self,data,driveList,file)
	self.wgLastPos = data.pos
	self.TAMLastPos = data.pos

	if file then --cargo desde file
		
	else
		--inicio nueva corrida
		self.run = 1 --numero de corrida
		self.experiment =1 -- numero de experimento
		self.drives = {}
		self.gamma = {}
		self.K = {}
		self.cantDrives = 0
		for k,v in pairs(driveList) do
			self.drives[k] = Drive.new(v.initVal,v.appetitive,v.dmin,v.dmax,v.alfa)
			self.gamma[k] = v.gamma
			self.K[k] = v.K
			self.cantDrives = self.cantDrives + 1
		end
	end
	self:initWG(file)
	self:initTAM(file)
	
	self.uniform = Vector.value(1/100,100)  --un valor para no calcular siempre
	
end
RL.initWG = function(self,file)
	--levanto el modulo WorldGraph y seteo propiedades
	self.WG = require (folderDir.."../WorldGraph")
	self.WG.usarKNN()
	self.wgBeta = 0.3
	self.wgNu = 0.2
	
	--decido si empezar de 0 o cargar un mapa existente
	if file then --cargo info necesaria del algoritmo
	
	else
		self.wgCritic = {}
		self.wgPolicy = {}
		self.amplitud = {}
		self.wgTraces = ET.new('expo1',{["decayRate"]=0.5*self.wgBeta})
		for k in pairs(driveList) do
			self.wgCritic[k] = {}
			self.wgCritic[k][0] = 0
			self.wgPolicy[k] = {}
			self.amplitud[k] = {}
		end
	end
	self.lastCC = {}
end

RL.initTAM = function(self,file)
	self.TAMgamma = 0.5 --Large enough to propagate hunger rewards three or four nodes back enough
	self.TAMbeta = 0.1 --Determines rate of state value changes – the model becomes unstable when this value is too large. Set lower than bWG to ensure that the influence of the WG dominates action selection.
	self.TAMnu = 0.01 --Determines the rate of node policy changes – the model becomes unstable when this value is larger than bTAM

	if file then --cargo info necesaria del algoritmo
	else --creo el algoritmo de 0
	end
end

--Persistencia
RL.save = function(self,file)
	self:saveWG(file)
	self:saveTAM(file)
end
RL.saveWG = function(self,file)
end
RL.saveTAM = function(self,file)
end



--Actualizacion del algoritmo
RL.update = function(self,data)
	--actualizar drives
	
	self.rewards = {}
	self.rewardSum = 0
	estimulo = {}
	condicion = {}
	for k,drive in pairs(self.drives) do
		estimulo[k],condicion[k] = data.driveParameters[k]()
		self.rewards[k] = drive.normalizado*condicion[k]
		self.rewardSum = self.rewardSum + self.rewards[k]
	end
	self:updateWG(data)
	self:updateTAM(data)
	
	for k,drive in pairs(self.drives) do
		drive:update(estimulo[k],condicion[k])
	end
	
	
	ND = 0
	suma = 0
	for k,d in pairs(self.drives) do
		ND = ND + self.wgPolicy[k][self.WG.idNodoActual]
		suma = suma + self.wgPolicy[k][self.WG.idNodoActual].suma
	end
	--print(ND)
	msuma = 0
	for i=1,100 do 
		msuma = msuma + ND[i]
	end
	if msuma ~= suma then
		--print('errpr', msuma-suma)
	end
	local id = utils.discreteRandom(ND,suma)
	return id
	
end

function RL.updateWG(self,data)
	--hago update del mundo y si hay un nodo nuevo, creo politica y critico inicial
	if false then -- self.WG.update(data) then
		self:newWGNode(data)
	end
	if self.WG.idNodoAnterior == self.WG.idNodoActual and self.rewardSum == 0 then
		return
	end
	
	total = total + 1
	
	--creo un coarse population code del ultimo movimiento
	local deltaPos = self.WG.nodo.centroid - self.WG.anterior.centroid --data.pos - self.wgLastPos
	if deltaPos[1] == 0 and deltaPos[2] ==0 then 
		--self.lastCC[self.WG.idNodoAnterior] = self.uniform
		self.lastCC[self.WG.idNodoAnterior] = CC.angle(-math.pi+(dirElegida-1)*math.pi/50,100,math.pi/72)
	else
		self.lastCC[self.WG.idNodoAnterior] = CC.angle(math.atan2(deltaPos[2],deltaPos[1]),100,math.pi/72)
	end
	--self.wgLastPos = data.pos
	
	--para cada drive calculo el error del critico, el critico, y la politica
	local dist = utils.distance2(self.WG.nodo.centroid,self.WG.anterior.centroid)
	for k,drive in pairs(self.drives) do
		--calculo error del critico
		perror = self.rewards[k]
					  +drive.normalizado*
					  (math.pow(self.gamma[k],dist)*self.wgCritic[k][self.WG.idNodoActual] 
							-self.wgCritic[k][self.WG.idNodoAnterior])--,0)
		
		--if perror < 0 or perror > 1 then
			--print('waiting')
			-- print('error ',self.WG.idNodoAnterior,' ',self.WG.idNodoActual, ' ',perror, '\n')
			-- print('error ',self.gamma[k], ' ', drive.normalizado,' ',self.K[k], ' ',dist,' ',self.wgCritic[k][self.WG.idNodoActual], ' ', self.wgCritic[k][self.WG.idNodoAnterior], '\n')
			-- io.flush()
			-- io.read()
		--end
		
		--actualizo el critico y la politica
		viejas = {}
		escalar = {}
		for i in ipairs(self.WG.graph.nodos) do
			self.wgCritic[k][i] = self.wgCritic[k][i] + self.wgBeta*perror*self.wgTraces.traces[i]
			self:updateWGPolicy2(k,drive,i,perror,deltaPos)
			
			
		end
		
		self.wgTraces:decay(self.WG.idNodoActual)
	end	
end

function RL.newWGNode(self,data)
	self.wgTraces:addTrace()
	for k in pairs(self.drives) do
		self.wgCritic[k][#self.wgCritic[k]+1] = 0 --sino se le podria asignar el reward
		self.wgPolicy[k][#self.wgPolicy[k]+1] = Vector.value(0.01,100)
		self.wgPolicy[k][#self.wgPolicy[k]].suma = 1
	end
	self.wgTraces.traces[#self.wgTraces.traces] = #self.WG.graph.nodos == 1 and 1 or 0
end

function RL.updateWGPolicy1(self,k,drive,i,perror,deltaPos)
	viejas[i] = self.wgPolicy[k][i]
	escalar[i] = drive.normalizado*self.wgNu*self.wgCritic[k][i]*self.wgTraces.traces[i]
	if escalar[i] > 0 and self.lastCC[i] then --si la policy no es un vector no se puede restar dos PDFs
		local mmax, mmin = 0 ,1/0
		for index = 1,100 do 
			self.wgPolicy[k][i][index] = (self.wgPolicy[k][i][index] + 
								(escalar[i])*self.lastCC[i][index])--/(1+escalar[i])
			mmax = math.max(mmax,self.wgPolicy[k][i][index])
			mmin = math.min(mmin,self.wgPolicy[k][i][index])
		end
		if mmax ~= mmin then
			for index = 1,100 do 
				self.wgPolicy[k][i][index] = (self.wgPolicy[k][i][index] - mmin) / (mmax - mmin)
			end
			self.wgPolicy[k][i].suma = (1+escalar[i] - 100 * mmin) / (mmax -mmin)
		else
			for index = 1,100 do 
				self.wgPolicy[k][i][index] = 0.01
			end
			self.wgPolicy[k][i].suma = 1
		end				
	end
end

function RL.updateWGPolicy2(self,k,drive,i,perror,deltaPos)
	viejas[i] = self.wgPolicy[k][i]
	escalar[i] = drive.normalizado*self.wgNu*perror*self.wgTraces.traces[i]
	if self.lastCC[i] then --si la policy no es un vector no se puede restar dos PDFs
		local mmax, mmin = 0 ,1/0
		self.wgPolicy[k][i].suma = 0
		for index = 1,100 do 
			self.wgPolicy[k][i][index] = self.wgPolicy[k][i][index] * 
											math.exp((escalar[i])*self.lastCC[i][index])
			mmax = math.max(mmax,self.wgPolicy[k][i][index])
			mmin = math.min(mmin,self.wgPolicy[k][i][index])
			self.wgPolicy[k][i].suma = self.wgPolicy[k][i].suma + self.wgPolicy[k][i][index]
		end			
	end
end

function RL.updateWGPolicy3(self,k,drive,i,perror,deltaPos)
	viejas[i] = self.wgPolicy[k][i]
	escalar[i] = drive.normalizado*self.wgNu*self.wgCritic[k][i]*self.wgTraces.traces[i]
	if self.lastCC[i] then --si la policy no es un vector no se puede restar dos PDFs
		local mmax, mmin = 0 ,1/0
		self.wgPolicy[k][i].suma = 0
		for index = 1,100 do 
			self.wgPolicy[k][i][index] = self.wgPolicy[k][i][index] * 
											math.exp((escalar[i])*self.lastCC[i][index])
			mmax = math.max(mmax,self.wgPolicy[k][i][index])
			mmin = math.min(mmin,self.wgPolicy[k][i][index])
			self.wgPolicy[k][i].suma = self.wgPolicy[k][i].suma + self.wgPolicy[k][i][index]
		end			
	end
end


function RL.updateTAM(self,data)
end

return RL