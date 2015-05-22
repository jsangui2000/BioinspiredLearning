local mtcp = require "TCPController"

local joystick = mtcp.new()
local robot = mtcp.new()

joystick:init("terminal","localhost",10201)
robot:init("terminal","robot.local",10001)

while true do
	joystick:send("getAxis")
	axis = joystick:receive()
	
	axis[1],axis[2] = tonumber(axis[1]),tonumber(axis[2])
	local speed = math.max(math.abs(axis[1]), math.abs(axis[2]))
	speed = speed*speed
	speed = math.floor(1023*speed+0.5)
	
	local tita = math.atan2(axis[2],axis[1])
	if tita > 3*math.pi /4 or tita < -3*math.pi/4 then
		print(1)
		v2 = speed
		v1 = -speed
	elseif tita > math.pi/4 then
		print(2)
		v1 = speed
		v2 = speed
	elseif tita > -math.pi/4 then
		print(3)
		v2 = -speed
		v1 = speed
	else
		print(4)
		v1 = -speed
		v2 = -speed
	end
	
	print(v1,v2)
	robot:send(v1,v2,"vel")
	
end