local folderDir = (...):match("(.-)[^%/]+$") or ""
local steering = require(folderDir.."Diferencial")

local Robot ={}
Robot.tcp = require(folderDir.."TCPController")

Robot.main = function()
	Robot.tcp.init("robot")
	while true do
		local fun,params = Robot.tcp.receiveFunction()
		Robot[fun](unpack(params))
	end
	
end

--cargo funciones generales
Robot.exit = function()
	Robot.stop()
	Robot.tcp.close()
	os.exit()
end



--cargo funciones de movimiento
Robot.vel = steering.vel
Robot.stop = steering.stop
Robot.girar = steering.girar
Robot.avanzar = steering.avanzar

--cargo funciones de lectura de distancia
Robot.getDistance = function(dir) end --por ahora dummy


Robot.main()
