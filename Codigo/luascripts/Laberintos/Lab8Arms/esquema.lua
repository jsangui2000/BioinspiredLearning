local esquema = {}

local lado = 0.5
local mitad = lado / 2
local largo = 2
local apotema = mitad / math.tan(22.5*math.pi/180)

esquema[1] = {}
esquema[1].arista = {apotema,-mitad,apotema + largo,-mitad}
esquema[1].puntos = {true,false}

esquema[2] = {}
esquema[2].arista = {apotema + largo,-mitad,apotema+largo,mitad}
esquema[2].puntos = {true,false}

esquema[3] = {}
esquema[3].arista = {apotema+largo,mitad,apotema,mitad}
esquema[3].puntos = {true,false}

for i=1,7 do
	for j=1,3 do
		local id = #esquema + 1
		local x2 = math.cos(45*i/180*math.pi)*esquema[j].arista[3]-math.sin(45*i/180*math.pi)*esquema[j].arista[4]
		local y2 = math.sin(45*i/180*math.pi)*esquema[j].arista[3]+math.cos(45*i/180*math.pi)*esquema[j].arista[4]
		esquema[id] = {}
		esquema[id].arista = {esquema[id-1].arista[3],esquema[id-1].arista[4],x2,y2}
		esquema[id].puntos = {true,false}
	end
end

return esquema