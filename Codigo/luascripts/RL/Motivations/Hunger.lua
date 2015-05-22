local folderDir = (...):match("(.-)[^%/]+$")
local hunger = {}

hunger = {}
hunger.appetitive = true
hunger.dmin = 0 --computational convenience
hunger.dmax = 2 --Smaller than fear for fear to overcome hunger
hunger.initVal = hunger.dmax/2
hunger.alfa = 0.000025 --small enough so that it does not significantly increase over a 2s simulation

--Constantes de RL
hunger.gamma = 0.9 --Large enough to propagate hunger rewards back to early nodes
hunger.K = 100 --small enough that hunger policies are effective over large distances

return hunger