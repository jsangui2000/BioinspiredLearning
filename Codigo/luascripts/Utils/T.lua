local folderDir = (...):match("(.-)[^%/]+$")
local Grafo = require (folderDir.."Grafo")
local Vector = require (folderDir.."Vector")
local T = Grafo.new()
T:addNodo(Vector(0,0))
T:addNodo(Vector(1,0))
T:addNodo(Vector(-1,0))
T:addNodo(Vector(0,-1))

T:addArista(1,2)
T:addArista(1,3)
T:addArista(1,4)

return T