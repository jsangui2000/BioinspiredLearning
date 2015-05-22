local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require ("Utils/Vector")

local Intersectar = {}

--calculo interseccion usando punto y pendiente
Intersectar.puntoPendiente = function(p1,m1,p2,m2)
	local c,d = v1[2]-m1*v1[1] ,  v2[2]-m2*v2[1]
	return Vector((d-c)/(m1-m2), (m1*d - m2*c)/(m1-m2))
	
end

--calculo interseccion usando zeta y perpen
--obs: perpen = (a,b) -> ax+by = z
Intersectar.zetaPerpen = function(z1,p1,z2,p2)
	local det = p1[1]*p2[2] - p1[2]*p2[1]
	local x = (p2[2]*z1-p1[2]*z2)/det
	local y = (p1[1]*z2-p2[1]*z1)/det
	return Vector(x,y)

end


return Intersectar