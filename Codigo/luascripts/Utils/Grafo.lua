local folderDir = (...):match("(.-)[^%/]+$")

local Grafo = {}
Grafo.__index = Grafo

local Nodo = require (folderDir.."Nodo")

function Grafo.new()
	local self = setmetatable({},Grafo)
	self.nodos = {}
	self.nodos[0] = {}
	self.nodos[0].add = function(self) end
	return self
end

function Grafo.addNodo(self,x,y,adyacentes)
	local nodo = Nodo.new(x,y,adyacentes)
	self.nodos[#self.nodos+1] = nodo
	self.nodos[nodo] = #self.nodos
end

--esta funcion deberia estar deprecated
function Grafo.addArista(self,id1,id2)
	self.nodos[id1]:add(self.nodos[id2])
end

function Grafo.printAristas(self)
	for k,v in ipairs(self.nodos) do
		for k2,v2 in ipairs(v.adyacentes) do
			if k <= self.nodos[v2[1]] then
				print(k,self.nodos[v2[1]],v2[2])
			end
		end
	end
end

return Grafo