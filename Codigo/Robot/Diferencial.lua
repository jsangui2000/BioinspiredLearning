local folderDir = (...):match("(.-)[^%/]+$")
local ax12 = require(folderDir.."AX12/ax12")
local motorIds = require(folderDir.. "AX12/motorIds")

--debug
st = require "socket"

ax12.init()

local Diferencial = {}

Diferencial.vel = function(v1,v2) --0-1023 ccw, 1024-... cw
	v1,v2 = tonumber(v1),tonumber(v2)
	if v1 < 0 then
		v1 = 1024 - v1
	end
	v2 = -v2
	if v2 < 0 then
		v2 = 1024 - v2
	end 	
	ax12.set_moving_speed(motorIds.izq,v1)
	ax12.set_moving_speed(motorIds.der,v2)
end

Diferencial.stop = function()
	ax12.set_moving_speed(motorIds.izq,0)
	ax12.set_moving_speed(motorIds.der,0)
end

Diferencial.girar = function(vel)
	Diferencial.vel(-vel,vel)
end

Diferencial.avanzar = function(vel)
	Diferencial.vel(vel,vel)
end


return Diferencial


