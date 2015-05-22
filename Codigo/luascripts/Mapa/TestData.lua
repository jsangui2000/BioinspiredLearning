local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require (folderDir.."Utils/Vector")
local utils = require (folderDir.."Utils/Utils")


local TestData = {}

TestData.loadVar = function(fileName)
	local ans = {}
	io.input(fileName)
	for line in io.lines() do
		local loaded = Vector()
		for s in string.gmatch(line,"([^;]+)") do
			loaded[#loaded+1] = s
		end
		ans[#ans+1] = #loaded > 1 and loaded or loaded[1]
	end
	return ans
end

TestData.loadData = function(id)
	id = id or '1425329797'
	
	if id:byte(1) == 66 then
		TestData.ring = TestData.loadVar('../Debug/ring'..id..'.txt');
		TestData.headdir = TestData.loadVar('../Debug/hd'..id..'.txt');
		TestData.pos = TestData.loadVar('../Debug/pos'..id..'.txt');
		TestData.posPI = TestData.loadVar('../Debug/posPI'..id..'.txt');
		TestData.headdirPI = TestData.loadVar('../Debug/hdPI'..id..'.txt');
		
	else
		TestData.ring = TestData.loadVar('../Debug/reales'..id..'.txt');
		TestData.headdir = TestData.loadVar('../Debug/headdir'..id..'.txt');
		TestData.pos = TestData.loadVar('../Debug/pos'..id..'.txt');
	end
	
	
	
	TestData.ringCart = {}
	TestData.ringCartRotados ={}
	
	TestData.ringP = {}
	TestData.ringCartP = {}
	TestData.ringCartRotadosP = {}
	
	
	
	for k,v in ipairs(TestData.ring) do
		TestData.ringCart[k] = utils.toCartessian(TestData.ring[k])
		TestData.ringCartRotados[k] = utils.rotarPuntos(TestData.ringCart[k],TestData.headdir[k])
		
		TestData.ringP[k] = TestData.filtroPicos(TestData.ring[k])
		TestData.ringCartP[k] = utils.toCartessian(TestData.ringP[k])
		TestData.ringCartRotadosP[k] = utils.rotarPuntos(TestData.ringCartP[k],TestData.headdir[k])
		
	end
	
end

function TestData.filtroPicos(distancias)
	local filtrado = Vector()
	for i=1,#distancias do
		local i1 = 1 + (i % #distancias)
		local i2 = 1 + ((i+1) % #distancias)
		filtrado[i1] = (math.abs(distancias[i2]-distancias[i]) < 0.1) and ((distancias[i2]+distancias[i])/2) or distancias[i1]
	end

	return filtrado
end

return TestData