local folderDir = (...):match("(.-)[^%/]+$")
local Grafo = require (folderDir.."Grafo")
local Vector = require (folderDir.."Vector")
local radial = Grafo.new()
radial:addNodo(Vector(0,0))

radial:addNodo(Vector(1,0))
radial:addNodo(Vector(-1,0))
radial:addNodo(Vector(0,-1))
radial:addNodo(Vector(0,1))

radial:addNodo(Vector(1,1))
radial:addNodo(Vector(-1,1))
radial:addNodo(Vector(1,-1))
radial:addNodo(Vector(-1,-1))


for i=2,9,1 do
	radial:addArista(1,i)
end

return radial