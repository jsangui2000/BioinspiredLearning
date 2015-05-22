local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require ("Utils/Vector")

local Reglin = {}


Reglin.twoPointRegression = function(puntos,ids,calcZ)
	local deltaP = puntos[ids[2]] - puntos[ids[1]]
	local perpen = Vector(-deltaP[2],deltaP[1]) / math.sqrt(deltaP*deltaP)
	local z = puntos[ids[1]]*perpen
	local errorMax = 0 
	if calcZ then
		for i =3,#ids do
			errorMax = math.max(errorMax,math.abs(puntos[ids[i]]*perpen - z))
		end
	end
	return z,perpen,errorMax
end


Reglin.medianRegression = function(puntos,ids,calcZ)
		local titas = {}
		local deltaV = puntos[ids[2]] - puntos[ids[1]]
		local tita0 = math.atan2(deltaV[2],deltaV[1])
		
		local cant = #ids
		

		for j=2,cant do
			for i=1,j-1 do
				deltaV = puntos[ids[j]] - puntos[ids[i]]
				local tita = math.atan2(deltaV[2],deltaV[1]) - tita0
				if tita > math.pi then
					tita = tita - 2*math.pi
				elseif tita <= -math.pi then
					tita = tita + 2*math.pi
				end				
				titas[#titas + 1] = tita				
			end
		end	
		
		table.sort(titas)
		local bot =math.floor( #titas / 2+0.5)
		local top =math.ceil(#titas/2+0.5)
		local dir = (titas[top]+titas[bot])/2 + tita0
		local perpen = Vector(-math.sin(dir),math.cos(dir))
		
		local zetas = {}
		for _,id in ipairs(ids) do
			zetas[#zetas+1] = puntos[id]*perpen
		end
		
		
		table.sort(zetas)
		bot = math.floor(#zetas/2+0.5)
		top = math.ceil(#zetas/2+0.5)
		z = (zetas[bot] + zetas[top])/2
		
		local errorMax = 0
		if calcZ then
			for _,mz in ipairs(zetas) do
				errorMax = math.max(errorMax,math.abs(mz-z))
			end
		end
		return z,perpen,errorMax

end

maxD = 0.5
Reglin.regression = function(puntos,ids,calcZ)
	if #ids <= 5 then
		if #ids >= 4 then
			local delta = puntos[ids[#ids]]-puntos[ids[1]]
			local mean = math.sqrt(delta*delta)/(#ids-1)
			local std = 0
			for i=1,#ids-1 do
				local dist = puntos[ids[i+1]]-puntos[ids[i]]
				dist = math.sqrt(dist*dist)
				std = std + (mean-dist)*(mean-dist)
			end
			std = math.sqrt(std/(#ids-1))
			if globalIndex == 166 then
				if ids[1] == 75 and ids[#ids] ==78 then
					print('std mean',std,mean)
				end
			end
			if globalIndex == 170 then
				if ids[1] == 80 and ids[#ids] ==83 then
					print('std mean',std,mean)
				end
			end
				
			if std < 0.005*mean then--delta*delta > maxD*maxD then
				return Reglin.medianRegression(puntos,ids,calcZ)
			end
		end
		return Reglin.twoPointRegression(puntos,ids,calcZ)
	else
		return Reglin.medianRegression(puntos,ids,calcZ)
	end
end


return Reglin