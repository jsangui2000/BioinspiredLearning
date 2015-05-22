local folderDir = (...):match("(.-)[^%/]+$")
local Debug = {}

Debug.timeMark = os.time()

if simAuxiliaryConsoleOpen then
	Debug.console = {}
	Debug.console.handle = simAuxiliaryConsoleOpen("Debug",4,1+4,{945,0},{640,50})
	Debug.console.print = function (...) simAuxiliaryConsolePrint(Debug.console.handle,...) end
	Debug.print = Debug.console.print
else
	Debug.print = print
end

--archivos de impresion
Debug.file = {}
Debug.path = "C:\\Program Files (x86)\\V-REP3\\V-REP_PRO_EDU\\luascripts\\Debug\\"
function Debug.addFile(filename)
	Debug.file[filename] = io.open(Debug.path..filename .. Debug.timeMark .. ".txt",'w')
end
function Debug.printFile(filename,debugvar,istable)
	io.output(Debug.file[filename])
	if istable then
		for k,v in pairs(debugvar) do
			io.write(k,' ',v,'\n')
		end
	else
		for k,v in ipairs(debugvar) do
			io.write(v,';')
		end
	end
	io.write('\n')
end

Debug.print('mark: ' .. Debug.timeMark ..'\n')
--Debug.console.in = 
return Debug