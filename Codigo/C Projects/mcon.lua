local socket = require "socket"
host, port = "localhost", 10301
tcp = socket.tcp()
tcp:connect(host,port)

--TCPController.tcp:receive()