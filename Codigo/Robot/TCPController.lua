local socket = require "socket"

local TCPController = {}
TCPController.__index = TCPController

TCPController.new = function()
	local self = {}
	setmetatable(self,TCPController)
	return self
end
	
TCPController.init = function (self,side,host,port)
	if side == "robot" then
		self.server = assert(socket.bind("*",10001))
		self.tcp = TCPController.server:accept()
	elseif side == "terminal" then
		local host, port = host or "robot.local", port or 10001
		self.tcp = assert(socket.tcp())
		self.tcp:connect(host, port)
		print ("Vamos a escribir terminal")
		print (self.tcp)
	else
		assert(false,'error, no existe dispositivo')
	end
end


TCPController.split = function (line)
	local ans = {}
	for s in string.gmatch(line,"([^#]+)") do
		ans[#ans+1] = s
	end
	return ans
end


-- El formato es: param 1 # param 2 # param 3 # ... param n 
TCPController.send = function(self,...)
	local args = {...}
	self.tcp:send(table.concat(args, "#") .. "\n")
end


TCPController.receive = function(self)
	local line = self.tcp:receive()
	local params = TCPController.split (line)
	return params
end


-- El formato es: param 1 # param 2 # param 3 # ... param n # fun
TCPController.receiveFunction = function (self)
	local params = self.receive()
	local fun = params[#params]
	params[#params] = nil
	return fun, params
end

TCPController.close = function (self)
	self.tcp:close()
end

return TCPController
