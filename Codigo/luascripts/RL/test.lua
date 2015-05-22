local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'

mprint = function(tabla,isArray)
	if type(tabla) == 'table' then
		local f = isArray and ipairs or pairs
		for k,v in f(tabla) do print(k,v) end
	else print(tabla) end
end

Vector = require "Utils/Vector"
D = require "Utils/Debug"
D.print("hola mundo\n")
math.randomseed(os.time())

radial = require "Utils/Radial"
hunger = require "Motivations/Hunger"
driveList = {}
driveList["hunger"] = hunger

dialogue = require("plotting/plotter")
dialogue.canvas.data = radial
dialogue.canvas.setOrigen(Vector(0,0),-1.2,1.2,-1.2,1.2)
--Archivos de debug
--MESSAGES = true
--DebugLaser = true
--PWALLS = true
--VELCAMBIO = true
if DebugLaser then D.addFile('laser') end
if MESSAGES then D.addFile('messages') end
if PWALLS then D.addFile('patronwall') end
if VELCAMBIO then D.addFile('velcambio') end
--D.addFile('fail') 

function dUpdate(activa)
	dialogue.canvas.activa = activa
	dialogue.canvas.pos = radial.nodos[activa].centroid
	dialogue.refresh()
end
function dClose()
	dialogue.close()
end 
dUpdate(9)

movimientos = {{},{},{},{},{},{},{},{},{}}
for i=1,100 do
	for j=1,6 do
		movimientos[1][j] = 3
		movimientos[1][101-j]=3
	end
	for j=1,12 do
		movimientos[1][19+j] = 4
		movimientos[1][44+j] = 2
		movimientos[1][69+j] = 5
	end
	for j=1,13 do
		movimientos[1][6+j] =9
		movimientos[1][31+j] = 8
		movimientos[1][56+j] = 6
		movimientos[1][81+j] = 7
	end
end
for i=2,9 do
	if i~=8 then
		for j =1,100 do
			movimientos[i][j] = movimientos[1][1+(j-1+50)%100] == i and 1 or i
		end
	end
end
for j=1,100 do
	movimientos[8][j] = movimientos[1][1+(j-1+50)%100] == 8 and 1 or 8
end

RL = require "RL"
data = {["pos"]=Vector(-1,-1)}
r = RL.new()
r:init(data,driveList)
r.WG.graph = radial
for i=1,9 do r:newWGNode() end
r.WG.idNodoActual = 9
r.WG.idNodoAnterior = 9
r.WG.nodo = r.WG.graph.nodos[9]
r.WG.anterior = r.WG.graph.nodos[9]



dirElegida = -1
cond = false
data.driveParameters = {}
data.driveParameters.hunger = function()
	local est  =  (r.WG.idNodoActual == 1 or r.WG.idNodoActual==8 )and 0.1 or 0
	cond = (r.WG.idNodoAnterior == 8) and dirElegida > 31 and dirElegida <= 44
	return est,cond and 0.2 or 0
end


sim = function ()
	r.WG.idNodoAnterior = r.WG.idNodoActual
	r.WG.idNodoActual = movimientos[r.WG.idNodoAnterior][dirElegida]
	r.WG.nodo = r.WG.graph.nodos[r.WG.idNodoActual]
	r.WG.anterior = r.WG.graph.nodos[r.WG.idNodoAnterior]
	data.pos = r.WG.nodo.centroid
	dUpdate(r.WG.idNodoActual)
end

restart = function ()
	total = 0
	r.WG.idNodoActual = 9
	r.WG.idNodoAnterior = 9
	r.WG.nodo = r.WG.graph.nodos[9]
	r.WG.anterior = r.WG.graph.nodos[9]
	for k in ipairs(r.wgTraces.traces) do
		r.wgTraces.traces[k] = 0
	end
	r.wgTraces.traces[9] = 1
	r.wgLastPos = r.WG.nodo.centroid
	data.pos = r.WG.nodo.centroid
	dirElegida = -1
	cond = false
	for i=1,9 do
		r.lastCC[i] = nil
	end
	
	dUpdate(r.WG.idNodoActual)
end

step = function()
	dirElegida = r:update(data)
	--print(dirElegida)
	sim()
end

mrun = function (cant)
	--local nextStop = false
	for i=1,cant do 
		step() 
		--if r.WG.idNodoAnterior ~= r.WG.idNodoActual then
			--print(cond, "cambio ",r.WG.idNodoAnterior,' a ',r.WG.idNodoActual,dirElegida)
		--end
		if cond then
			return i
		end
		--nextStop = cond
	end
	return -1
end

experiment = function(cant)
	for i=1,cant do 
		restart()
		print(i,mrun(1/0),total,'\n')
	end
end

mc = function()
	mprint(r.wgCritic.hunger)
end

p1 = function()
	dirElegida = r:update(data)
	mc()
	
end
	

mp = function(i)
	mprint(r.wgPolicy.hunger[i])
end

mt =function()
	mprint(r.wgTraces.traces)
end

mstep = function()
	if cond then 
		restart() 
		nextPrint=true 
		antes = {} 
	end
	mid = r.WG.idNodoAnterior
	for i=1,9 do 
		antes[i] = r.wgPolicy.hunger[i].suma
	end
	step()
	-- if nextPrint or cond then 
		-- print('actualizo', mid,r.WG.idNodoAnterior,r.WG.idNodoActual)
		-- print('mc:')
		-- mc()
		-- print('suma:')
		-- for i=1,9 do
			-- print(i, antes[i],r.wgPolicy.hunger[i].suma)
		-- end
		-- print('cond', cond)
	-- end
	-- if nextPrint then nextPause = true end
	-- nextPrint = r.WG.idNodoAnterior ~= r.WG.idNodoActual


end

function pMatrix()
	prob = {}
	rew = 0
	for i =1,9 do
		prob[i] = Vector.value(0,9)
		for j =1,100 do
			prob[i][movimientos[i][j]] = prob[i][movimientos[i][j]] + r.wgPolicy.hunger[i][j] / r.wgPolicy.hunger[i].suma
		end
	end
	for j = 32,44 do
		rew = rew + r.wgPolicy.hunger[8][j] / r.wgPolicy.hunger[8].suma
	end
	print('prob',1,2,3,4,5,6,7,8,9)
	for i=1,9 do
		print(i,prob[i][1],prob[i][2],prob[i][3],prob[i][4],prob[i][5],prob[i][6],prob[i][7],prob[i][8],prob[i][9])
	end
	print(rew)	
end

