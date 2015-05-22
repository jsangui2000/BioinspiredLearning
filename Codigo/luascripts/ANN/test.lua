local folderDir = (...):match("(.-)[^%/]+$")
r = require (folderDir.."RedAdap")
r.placeCells.threshold = 0.2
w = {}
w[0] = 4
w[math.pi/6]=7
w[-math.pi/6]=3

local sum = 0
for i=1,1000 do
	if r.update(math.pi/6,w,3,-math.pi/2) then
		sum = sum + 1
	end
end
print(sum)