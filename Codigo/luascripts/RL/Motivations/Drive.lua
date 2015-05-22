local folderDir = (...):match("(.-)[^%/]+$")
local Drive = {}
Drive.__index = Drive

Drive.new = function(initVal,appetitive,dmin,dmax,alfa)
	local self = {}
	setmetatable(self,Drive)
	self.val = initVal	
	self.appetitive = appetitive
	if appetitive then
		self.updateSelective = Drive.updateAppetitive
	else
		self.updateSelective = Drive.updateAversive
	end
	self.dmin = dmin
	self.dmax = dmax
	self.alfa = alfa
	self.estimuloAnterior = 0
	self.normalizado = (self.val - self.dmin) / (self.dmax - self.dmin)
	return self
end

Drive.update = function(self,estimulo,condicion)
	self:updateSelective(estimulo,condicion)
	if 		self.val < self.dmin then self.val = self.dmin
	elseif 	self.val > self.dmax then self.val = self.dmax
	end	
	self.normalizado = (self.val - self.dmin) / (self.dmax - self.dmin)
	return self.normalizado,self.val
end

Drive.updateAppetitive = function (self,estimulo,condicion)
	local deltaEstimulo = estimulo - self.estimuloAnterior
	self.estimuloAnterior = estimulo
	self.val = self.val
			 + self.alfa * (self.dmax - self.val)
			 - condicion * (self.val - self.dmin)
			 + deltaEstimulo * (self.dmax - self.val)

end

Drive.updateAversive = function (self,estimulo,condicion)
	local deltaEstimulo = estimulo - self.estimuloAnterior
	self.estimuloAnterior = estimulo
	
	self.val = self.val
			 - self.alfa * (self.val - self.dmin)
			 - condicion * (self.dmax - self.val)
			 + deltaEstimulo * (self.dmax - self.val)
end

return Drive
