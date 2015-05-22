local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ";" ..folderDir .."../?.lua"
local ax12 	= require("AX12/ax12")
local motorIds 	= require(folderDir .. "AX12/motorIds")
local laser	= require(folderDir .. "Laser")

ax12.init()

local Laser360 = {}

Laser360.pos0 = 340 --posicion que debe estar el motor de abajo para estar en 0
Laser360.cant = 100 --cantidad de medidas

--tabla de posicion para medir cada direccion
--dir van de 1 a 100 y 
Laser360.tablaDirecciones = {}
for i=1,Laser360.cant do
	local dir = 360/Laser360.cant * (i-1)
	if dir <= 300 then
		local dirId = math.floor(dir/300*1023 + 0.5)
		Laser360.tablaDirecciones[i] = {Laser360.pos0,dirId}
	else
		local dirId = math.floor((dir - 300)/300*1023 + 0.5)
		Laser360.tablaDirecciones[i] = {Laser360.pos0 + dirId,1023}
	end
end

Laser360.getDistance = function(dir) 
	local positions
	ax12.set_goal_position(motorIds.bot,Laser360.tablaDirecciones[dir][1])
	ax12.set_goal_position(motorIds.top,Laser360.tablaDirecciones[dir][2])
	return laser.getDistance()
end


return Laser360
