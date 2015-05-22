local folderDir = (...):match("(.-)[^%/]+$")
local fear = {}

fear = {}
fear.appetitive = false
fear.dmin = 0 --computational convenience
fear.dmax = 5 --big enough to overcome hunger
fear.initVal = fear.dmax/2
fear.alfa = 0.1 --big enough so that fear fecreasses quickly

--Constantes de RL
fear.gamma = 0.01 --small egnough to not propagate aversive stimuli more than one or two nodes back
fear.K = 3.5 --Aproximately one quarter of the edge length in the linear maze so that fear everwhelms hunger at the halfway point

return fear