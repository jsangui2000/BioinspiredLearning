local esquema = {}
esquema[1] = {}
esquema[1].arista = {0,0,2,0}
esquema[1].puntos = {true,true}
--esquema[1].intersecciona = {false,false,true,true}

esquema[2] = {}
esquema[2].arista = {0,0,0,9.5}
esquema[2].puntos ={false,false}
--esquema[2].intersecciona = {true,true,false,false}

esquema[3] = {}
esquema[3].arista = {2,0,2,9.5}
esquema[3].puntos = {false,false}
--esquema[3].intersecciona = {false,false,true,true}

esquema[4] = {}
esquema[4].arista = {0,9.5,2,9.5}
esquema[4].puntos = {true,true}
--esquema[4].intersecciona = {true,true,false,false}

for i=1,9 do
	local id1 = #esquema+1
	local altura1 = 0.5 + 1*(i-1)
	local altura2 = altura1 + 0.5
	esquema[id1] = {}
	esquema[id1+1] = {}
	esquema[id1+2] = {}
	if i % 2 == 1 then
		esquema[id1].arista = {0,altura1,1.5,altura1}
		esquema[id1+1].arista = {1.5,altura1,1.5,altura2}
		esquema[id1+2].arista = {0,altura2,1.5,altura2}
	else
		esquema[id1].arista = {0.5,altura1,2,altura1}
		esquema[id1+1].arista = {0.5,altura1,0.5,altura2}
		esquema[id1+2].arista = {0.5,altura2,2,altura2}
	end
	esquema[id1].puntos = {true,true}
	esquema[id1+1].puntos = {false,false}
	esquema[id1+2].puntos = {true,true}
end

return esquema