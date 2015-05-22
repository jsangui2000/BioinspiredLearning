local folderDir = (...):match("(.-)[^%/]+$")
local EligibilityTrace = {}

EligibilityTrace.new = function(decayType,parameters) --tabla parameters para cosas extra
	local self = setmetatable({},EligibilityTrace)
	self.traces = {}
	if decayType == 'expo1' then
		self.decayRate = parameters.decayRate
		self.decay = EligibilityTrace.decayExpo1
		self.addTrace = EligibilityTrace.addTraceExpo1
	elseif decayType == 'timeExpo' then
		self.decayRate = -parameters.decayRate  -- f = e^(-k*(t-t0))
		self.decay = EligibilityTrace.decayTimeExpo
		self.addTrace = EligibilityTrace.addTraceTimeExpo
		self.t0 = {}
		self.T = require (folderDir.."socket")
	else
		assert(false,"error traza")
	end
	return self
end

EligibilityTrace.decayExpo1 = function(self,id)
	for i in pairs(self.traces) do
		self.traces[i] = self.decayRate*self.traces[i]
		if self.traces[i] < 0.001 then self.traces[i] = 0 end
	end
	self.traces[id] = 1
end
EligibilityTrace.addTraceExpo1 = function(self,val)
	self.traces[#self.traces+1] = val or 0
end

EligibilityTrace.decayTimeExpo = function(self,id)
	local t = self.T.gettime()
	self.t0[id] = t
	for i in pairs(self.traces) do
		self.traces[i] = math.exp(self.decayRate*(t-self.t0[i]))
	end
end
EligibilityTrace.addTraceTimeExpo = function(self)
	self.traces[#self.traces+1] = 0
	self.t0[#self.t0+1] = -1/0
end

return EligibilityTrace


