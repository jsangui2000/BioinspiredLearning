--configuro interfaz
local folderDir = ""
if (...) ~= nil then 
	folderDir = (...):match("(.-)[^%/]+$")
end
ax12 = require(folderDir.."ax12")
ax12.init('/dev/ttyUSB1',1000000)
ms = require "socket"


ids = require(folderDir.."motorIds")


--OPCIONES
--set CW, CWW angle limit
--set torque max, enable, limit
--set led
--set goal position, moving speed
--set voltage

--MAXSPEED = 114 RPM = 1.9 RPS = 1R / 0.52s  (equivale a 1023)

--reset motors:
for k,v in pairs(ids) do
	ax12.reset(v)
	ms.select(nil,nil,3)
	ax12.set_id(1,v)
	ms.select(nil,nil,0.05)
	ax12.set_cw_angle_limit(v,0)
	ms.select(nil,nil,0.05)
	ax12.set_ccw_angle_limit(v,1023)
	ms.select(nil,nil,0.05)
	ax12.set_low_limit_voltage(v,9)
	ms.select(nil,nil,0.05)
	ax12.set_moving_speed(v,0) --es el maximo para el voltaje
	ms.select(nil,nil,0.05)
	ax12.set_torque_enable(v,1)
	ms.select(nil,nil,0.05)
	ax12.set_status_return_level(v,1)
	ms.select(nil,nil,0.05)
end

--seteo motores movimiento a endless turn
ax12.set_ccw_angle_limit(ids.izq,0)
ms.select(nil,nil,0.05)
ax12.set_ccw_angle_limit(ids.der,0)
ms.select(nil,nil,0.05)


