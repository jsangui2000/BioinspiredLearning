local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local utils = require ( "Utils/Utils")
local Vector = require ( "Utils/Vector")
local D = require ("Utils/Debug")

require "socket" --para medir tiempos

maxVel=2*math.pi*1
velGiro = maxVel*0.2

simExtK3_setVelocity(-velGiro,velGiro)
speed = {} 
nAverage = 0

posHandle = simGetObjectHandle("Dummy")
dirHandle = simGetObjectHandle("Dummy0") 

pdum = simGetObjectPosition(posHandle,-1)
pdum2 = simGetObjectPosition(dirHandle,-1)
t0 = socket.gettime()
tita0 = math.atan2(pdum2[2]-pdum[2],pdum2[1]-pdum[1])	
socket.select(nil,nil,0.01)
for i=1,100 do
	pdum = simGetObjectPosition(posHandle,-1)
	pdum2 = simGetObjectPosition(dirHandle,-1)
	t1 = socket.gettime()
	tita1 = math.atan2(pdum2[2]-pdum[2],pdum2[1]-pdum[1])
	table.insert(speed,utils.truncarAngulo(tita1-tita0)/(t1-t0))
	t0 = t1
	tita0 = tita1
	nAverage = utils.nAverage(nAverage,speed[#speed],#speed)
	--D.print(nAverage..'\n')
	socket.select(nil,nil,0.01)
end
	
local average = utils.average(speed)
D.addFile('simRobotAngularSpeed')
D.printFile('simRobotAngularSpeed',{nAverage})
D.printFile('simRobotAngularSpeed',speed)
