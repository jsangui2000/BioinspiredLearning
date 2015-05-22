local folderDir = (...):match("(.-)[^%/]+$")
local Normal = {}

Normal.sample = function (mu,d_estandar)
	mu = mu or 0
	d_estandar = d_estandar or 1
	local x1 = math.random()
	local x2 = math.random()
	return d_estandar*(math.sqrt(-2*math.log(x1))*math.cos(2*math.pi*x2) + mu)
	
end

Normal.pdf = function (x,mu,d_estandar)
	mu = mu or 0
	d_estandar = d_estandar or 1
	return math.exp( -(x-mu)*(x-mu)/(2*d_estandar*d_estandar))/(d_estandar*math.sqrt(2*math.pi))
end

--[[
math.randomseed(os.time())
--print(math.random())
for i=-1,7,0.01 do
	print(""..i.." "..Normal.pdf(i,3,2))
end
--]]
return Normal