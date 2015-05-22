--Creo una tabla para usar como metatabla para vectores, tambien doy un constructor
local folderDir = (...):match("(.-)[^%/]+$")
local Vector = {}
Vector.subtipo = "vector"

Vector.new = function(tabla,...)
	local v = nil
	local arg = {...}
	if false and arg[1] and type(arg[1]) == 'table' then
		v = {}
		for i=1,#arg[1] do
			v[i] = Vector()
		end
		for _,argi in ipairs(arg) do
			for i,vi in ipairs(argi) do
				v[i] = v[i] .. vi
			end
		end
	else 
		v = {...}
	end
	setmetatable(v,Vector)
	return v
end

Vector.value = function(value,dim1,dim2,...)
	local v = Vector()
	if dim2 then
		for i=1,dim1 do
			v[i] = Vector.value(value,dim2,...)
		end
	else
		for i =1,dim1 do
			v[i] = value
		end
	end
	return v
end

Vector.copy = function(v1)
	if type(v1) == 'number' then
		return v1
	end
	local res = Vector()
	for k,v in ipairs(v1) do
		res[k] = Vector.copy(v)
	end
	return res
end
		

setmetatable(Vector,{__call = Vector.new}) 

Vector.__index = Vector

Vector.__unm = function(rhs)
	res = Vector()
	for i in ipairs(rhs) do
		res[i] = -rhs[i]
	end
	return res
end

Vector.__add = function (lhs,rhs)
	res = Vector()
	if type(lhs) == 'number' then
		for i in ipairs(rhs) do
			res[i] = lhs + rhs[i]
		end
	elseif type(rhs) == 'number' then
		for i in ipairs(lhs) do
			res[i] = lhs[i] + rhs
		end
	else
		assert(#lhs == #rhs,"diferentes longitudes")
		for i in ipairs(lhs) do
			res[i] = lhs[i] + rhs[i]
		end
	end
	return res
end

Vector.__sub = function (lhs,rhs) 
	res = Vector()
	if type(lhs) == 'number' then
		for i in ipairs(rhs) do
			res[i] = lhs - rhs[i]
		end
	elseif type(rhs) == 'number' then
		for i in ipairs(lhs) do
			res[i] = lhs[i] - rhs
		end
	else
		assert(#lhs == #rhs,"diferentes longitudes")
		for i in ipairs(lhs) do
			res[i] = lhs[i] - rhs[i]
		end
	end
	return res
end

Vector.__mul = function(lhs,rhs)
	local res = nil
	if type(lhs) == 'number' then
		res = Vector()
		for i in ipairs(rhs) do
			res[i] = lhs * rhs[i]
		end
	elseif type(rhs) == 'number' then
		res = Vector()
		for i in ipairs(lhs) do
			res[i] = lhs[i]*rhs
		end
	elseif type(lhs[1]) == 'number' then
		if type(rhs[1]) == 'number' then -- son dos vectores
			assert(#lhs == #rhs,"diferentes longitudes")
			res = 0
			for i in ipairs(lhs) do
				res = res + lhs[i]*rhs[i]
			end
		else	--izquierdo es vector (fila) y derecha es tabla
			assert( #lhs == #rhs[1],"diferentes longitudes")
			res = Vector()
			for j=1,#rhs do
				res[j] = 0
				for k=1,#lhs do
					res[j] = res[j] + lhs[k]*rhs[k][j]
				end
			end
		end
	elseif type(rhs[1]) == 'number' then --zquierda es tabla y derecha es vector
		assert(1 == #lhs[1],"diferentes longitudes")
		res = Vector()
		for i=1,#lhs do
			res[i] = Vector()
			for j=1,#rhs do
				res[i][j] = lhs[i][1]*rhs[j]
			end
		end
		
	else --asumo se quiere el producto matricial y ambas son tabals
		res = Vector()
		assert(#lhs[1] == #rhs,"diferentes longitudes")
		
		--inicializo el resultado
		for i = 1, #lhs do
			res[i] = Vector()
			for j = 1, #lhs[1] do
				res[i][j] = 0
			end
		end
		
		--calculo el resultado
		for i=1,#lhs do
			for j=1,#rhs[1] do
				for k=1,#lhs[1] do
					res[i][j] = res[i][j] + lhs[i][k]*rhs[k][j]
				end
			end
		end
					
	end
	return res
end

Vector.__div = function(lhs,rhs) 
--division por escalar o escalar divido matriz, o operaciones punto a punto 
	res = Vector()
	if type(lhs) == 'number' then
		for i in ipairs(rhs) do
			res[i] = lhs / rhs[i]
		end
	elseif type(rhs) == 'number' then
		for i in ipairs(lhs) do
			res[i] = lhs[i] / rhs
		end
	else
		assert(#lhs == #rhs,"diferentes longitudes")
		for i in ipairs(lhs) do
			res[i] = lhs[i] / rhs[i]
		end
	end
	return res
end

Vector.__mod = function(lhs,rhs)
--division por escalar o escalar divido matriz, o operaciones punto a punto 
	res = Vector()
	if type(lhs) == 'number' then
		for i in ipairs(rhs) do
			res[i] = lhs % rhs[i]
		end
	elseif type(rhs) == 'number' then
		for i in ipairs(lhs) do
			res[i] = lhs[i] % rhs
		end
	else
		assert(#lhs == #rhs,"diferentes longitudes")
		for i in ipairs(lhs) do
			res[i] = lhs[i] % rhs[i]
		end
	end
	return res
end

--Vector.__pow = function(lhs,rhs)
--end

Vector.__concat = function(lhs,rhs)
	local res = Vector()
	if type(lhs) == 'number' then
		res[1] = lhs
		for i in ipairs(rhs) do
			res[i+1] = Vector.copy( rhs[i])
		end
	elseif type(rhs) == 'number' then
		for i in ipairs(lhs) do
			res[i] = Vector.copy(lhs[i])
		end
		res[#res+1] = rhs
	else 
		if type(lhs[1]) == 'number' then
			res = Vector.copy(lhs)
			for _,v in ipairs(rhs) do
				res[#res+1] = v
			end
		else
			for i,v in ipairs(lhs) do
				res[i] =  v .. rhs[i]
			end				
		end
	end
	return res
end

Vector.__eq = function(lhs,rhs)
	assert(#lhs == #rhs,"diferentes longitudes")
	for i in ipairs(lhs) do
		if lhs[i]~=rhs[i] then
			return false
		end
	end
	return true
end

Vector.__tostring = function(lhs)
	local res = "("
	if lhs[1] then
		res = res..tostring(lhs[1])
	end
	for i =2,#lhs do
		res = res..","..tostring(lhs[i])
	end
	res = res .. ")"
	return res
end

Vector.transpose =  function(self)
	local res = Vector()
	if type(self[1]) == 'number' then
		for k,v in ipairs(self) do
			res[k] = Vector(v)
		end
	elseif #self[1]==1 then
		for k,v in ipairs(self) do
			res[k] = v[1]
		end
	else
		dim1,dim2 = self:dim()
		res = Vector.value(0,dim2,dim1)
		for i,v in ipairs(res) do
			for j in ipairs(v) do
				res[i][j] = self[j][i]
			end
		end
	end
	return res
end

Vector.dim = function(self)
	if type(self[1])=='table' then
		return #self,Vector.dim(self[1])
	end
	return #self
end

return Vector

--__newindex

