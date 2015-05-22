local folderDir = (...):match("(.-)[^%/]+$")
local Disposicion = {}

laserDebugFile = io.open("C:\\Program Files (x86)\\V-REP3\\V-REP_PRO_EDU\\luascripts\\Debug\\laserRing" .. os.time() .. ".txt",'w')

--si las cosas estan fuera del alcance de medicion sensores, asigno la maxima distancia
Disposicion.maxDistInfra = 0.3
Disposicion.maxDistUltra = 0.3

--negativo es a la derecha, positivo a la izquierda

Disposicion.infra = {}
Disposicion.infra[1] = 80 *math.pi/180
Disposicion.infra[2] = 45 *math.pi/180
Disposicion.infra[3] = 14*math.pi/180
Disposicion.infra[4] = -14*math.pi/180
Disposicion.infra[5] = -45*math.pi/180
Disposicion.infra[6] = -80*math.pi/180
Disposicion.infra[7] = -140*math.pi/180
Disposicion.infra[8] = -180*math.pi/180
Disposicion.infra[9] = 140*math.pi/180

Disposicion.ultra = {}
Disposicion.ultra[1] = 90*math.pi/180
Disposicion.ultra[2] = 40*math.pi/180
Disposicion.ultra[3] = 0*math.pi/180
Disposicion.ultra[4] = -40*math.pi/180
Disposicion.ultra[5] = -90*math.pi/180


Disposicion.laser = {}
for i=0,99 do
	Disposicion.laser[i+1] = simGetObjectHandle("Laser"..i)
	if simGetObjectHandle == nil then 
	D.print('\n error nil')
	end
end

Disposicion.getWalls = function()
	local walls = {}
	
	for i=1,9 do
		walls[Disposicion.infra[i]] = math.min(simExtK3_getInfrared(i-1),Disposicion.maxDistInfra)
	end
	for i=1,5 do
		walls[Disposicion.ultra[i]] = math.min(simExtK3_getUltrasonic(i-1),Disposicion.maxDistUltra)
	end
	return walls
end 

Disposicion.getWallsLaser = function()
	local walls = {}
	
	local valmax = 0
	local suma = 0
	local cantnil = 0
	for i=0,99 do
		_,walls[i+1] = simReadProximitySensor(Disposicion.laser[i+1])
		if walls[i+1] == nil then
			cantnil = cantnil + 1
			walls[i+1] = 5
			D.print('Da 0: '..i ..'\n')
		end
		valmax = math.max(walls[i+1],valmax)
		suma = suma + walls[i+1]
	end
	if cantnil > 0 then 
		D.print('\n error nil ' .. cantnil ..'\n')
	end
	io.output(laserDebugFile)
	for i=0,99 do
		--walls[i+1] = walls[i+1]/valmax
		walls[i+1] = walls[i+1]/suma
		io.write(walls[i+1]..';')
	end
	io.write('\n')
	return walls,suma,valmax

end 




return Disposicion