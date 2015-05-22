local esquema = {}
esquema[1] = {}
esquema[1].arista = {0,0,2,0}
esquema[1].puntos = {true,true}
--esquema[1].intersecciona = {false,false,true,true}

esquema[2] = {}
esquema[2].arista = {0,0,0,5}
esquema[2].puntos ={false,false}
--esquema[2].intersecciona = {true,true,false,false}

esquema[3] = {}
esquema[3].arista = {2,0,2,5}
esquema[3].puntos = {false,false}
--esquema[3].intersecciona = {false,false,true,true}

esquema[4] = {}
esquema[4].arista = {0,5,2,5}
esquema[4].puntos = {true,true}
--esquema[4].intersecciona = {true,true,false,false}

for i=5,13 do
	esquema[i] = {}
	local altura = 0.5*(i-4)
	if i % 2 == 1 then
		esquema[i].arista = {0,altura,1.5,altura}
	else
		esquema[i].arista = {0.5,altura,2,altura}
	end
	esquema[i].puntos = {true,true}
end

return esquema