local folderDir = (...):match("(.-)[^%/]+$")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require( "iuplua_pplot" )
require "socket"

local folderDir = (...):match("(.-)[^%/]+$")
package.path = package.path .. ';'..folderDir..'../?.lua'
local Vector = require (folderDir.."Utils/Vector")
local utils = require (folderDir.."Utils/Utils")

local strX = Vector()
local normalSize = 0.1
strX[1] = normalSize*Vector(math.cos(math.pi/4),math.cos(math.pi/4))
strX[2] = -strX[1]
strX[3] = normalSize*Vector(-math.cos(math.pi/4),math.cos(math.pi/4))
strX[4] = -strX[3]



local MapaPlotter = {}
MapaPlotter.dialogue = {}

MapaPlotter.drawX = function(center,size)
	local size = size or 1
	gl.Begin("LINES")
		for k,v in ipairs(strX) do
			gl.Vertex(center + size*v)
		end
	gl.End()
end


iup.key_open()
MapaPlotter.newDialogue = function(titulo,lab)
	local cnv = iup.glcanvas{buffer="DOUBLE", rastersize = "640x480"}
	cnv.lab = lab -- MapaPlotter[lab or "lab8"]()
	cnv.index = 1
	cnv.speed = 0.01
	cnv.play = false
	cnv.cmd = ""
	
	cnv.drawFunctions = {}
	cnv.addDraw = function (functor)
		cnv.drawFunctions[#cnv.drawFunctions+1] = functor
	end
	
	cnv.addDraw(MapaPlotter.drawLAB)
	
	--window
	cnv.x1 = 1.1 * lab.minx -- -2.8
	cnv.x2 = 1.1 * lab.maxx -- 2.8
	cnv.y1 = 1.1 * lab.miny -- -2.8
	cnv.y2 = 1.1 * lab.maxy -- 2.8
	
	cnv.setOrigen = function (origen,x1,x2,y1,y2)
		for k,v in ipairs(cnv.lab.aristas) do
			v.puntos[1] = v.puntos[1] - origen
			v.puntos[2] = v.puntos[2] - origen
			--p[1],p[2] = p[1] - origen[1],p[2]-origen[2]
		end
		cnv.x1 = (x1 or cnv.x1) - origen[1]
		cnv.x2 = (x2 or cnv.x2) - origen[1]
		cnv.y1 = (y1 or cnv.y1) - origen[2]
		cnv.y2 = (y2 or cnv.y2) - origen[2]
		cnv.origen = origen
	end
	
	
	function cnv:resize_cb(width, height)
	  iup.GLMakeCurrent(self)
	  gl.Viewport(0, 0, width, height)
	  gl.MatrixMode('PROJECTION')   -- Select The Projection Matrix
	  gl.LoadIdentity()             -- Reset The Projection Matrix
	  if height == 0 then height = 1 end       -- Avoid division by zero
	  glu.Perspective(80, width / height, 1, 5000) -- Calculate The Aspect Ratio And Set The Clipping Volume
	  gl.MatrixMode('MODELVIEW')    -- Select The Model View Matrix
	  gl.LoadIdentity()             -- Reset The Model View Matrix
	end
	
	function cnv:action(x,y)
		iup.GLMakeCurrent(self)
		gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT') -- Clear Screen And Depth Buffer
		gl.MatrixMode("PROJECTION")
		gl.LoadIdentity()
		gl.Ortho(self.x1,2*self.x2 - self.x1,self.y1,2*self.y2-self.y1,-1,1) --left,right,bot,top,near,far
		gl.MatrixMode("MODELVIEW")
		gl.LoadIdentity()
		
		for k,v in ipairs(self.drawFunctions) do
			v(self)
		end
		
		MapaPlotter.drawPos(self)
		MapaPlotter.drawSegmentosFinales(self)
		MapaPlotter.drawMapa(self)
		MapaPlotter.drawAmarilla(self)
		
		iup.GLSwapBuffers(self)
		
		self.oldIndex = self.index
		if self.play and self.seg3 and tonumber(self.index) < #self.seg3 then
			self.index = self.index + 1
		end
		
		socket.select(nil,nil,self.speed)
	end
	
	function cnv:map_cb()
	  iup.GLMakeCurrent(self)
	  gl.ShadeModel('SMOOTH')            -- Enable Smooth Shading
	  gl.ClearColor(0.5, 0.5, 0.5, 0.5)        -- White Background
	  gl.ClearDepth(1.0)                 -- Depth Buffer Setup
	  gl.Enable('DEPTH_TEST')            -- Enables Depth Testing
	  gl.DepthFunc('LEQUAL')             -- The Type Of Depth Testing To Do
	  gl.Enable('COLOR_MATERIAL')
	  gl.Hint('PERSPECTIVE_CORRECTION_HINT','NICEST')
	end
	
	function cnv:k_any(c)
		if c == iup.K_q or c == iup.K_ESC then
			return iup.CLOSE
		elseif c == iup.K_F1 then
			if fullscreen then
			  fullscreen = false
			  dlg.fullscreen = "No"
			else
			  fullscreen = true
			  dlg.fullscreen = "Yes"
			end
		iup.SetFocus(cnv)
		elseif c == iup.K_l then
			local index= tonumber(self.index)
			print("index:",self.index)
			print("match:")
			print(unpack(self.mapas[index].matchTable))
			print("importante:")
			print(unpack(self.mapas[index].matchTable.importante))	
			print("hash:")
			for k,v in ipairs(self.mapas[index].hash) do
				if #v ~=0 then
					print("ang",k)
					print(unpack(v))
				end
			end
		elseif (iup.K_a <= c and c<=iup.K_z and c~=iup.K_p) or (iup.K_0 <= c and c<=iup.K_9)  or K_period == c then
			self.cmd = self.cmd .. string.char(c)
			print(self.cmd)
		elseif c == iup.K_p then
			self.play = not self.play
			print("play:",self.play)
		elseif c == iup.K_LEFT then
			self.index = math.max(self.index -1,1)
			print("index:", self.index)
		elseif c == iup.K_RIGHT then
			self.index = math.min(self.index +1,#self.seg3)
			print("index:", self.index)
		elseif c == iup.K_CR then
			--evaluo comando
			local cc = self.cmd:sub(1,1)
			local rest = self.cmd:sub(2)
			local cnum = tonumber(rest)
			if cc == "s" then
				if cnum then
					self.speed = cnum
					if self.speed > 1 then self.speed = 1 end
					print("speed:", self.speed)
				end
			elseif cc=="i" then
				if cnum then
					if cnum >=1 and cnum <=#self.seg3 then
						self.index = cnum
					end
					print("index:", self.index)
				end
			elseif cc=="a" then
				self.amarilla = cnum
				print("amarilla:",cnum)
			else
				print("no existe comando")
			end
			self.cmd = ""
		elseif c == iup.K_UP then
			self.speed = self.speed /2 --el speed realmente es un timer por tanto para ir mas rapido menos timer
			print("speed:", self.speed)
		elseif c == iup.K_DOWN then
			self.speed = self.speed*2
			print("speed:", self.speed)
		end
	end

	local dlg = iup.dialog{cnv,TITLE=titulo}
	MapaPlotter.dialogue[titulo] = dlg
	dlg.canvas = cnv
	dlg.refresh = function()
		dlg.canvas:action()
		iup.LoopStep()
	end
	dlg.close = iup.Close
	iup.ShowXY(dlg,iup.RIGHT,110)
	dlg:show()
	cnv.rastersize = nil 
	
	
end


MapaPlotter.drawLAB = function(cnv)
	for i=1,4 do
		gl.LoadIdentity()
		if i == 4 then
			gl.Translate(cnv.x2 - cnv.x1,0,0)
		elseif i==1 then
			gl.Translate(0,cnv.y2 - cnv.y1,0)
		elseif i ==2 then
			gl.Translate(cnv.x2 - cnv.x1,cnv.y2 - cnv.y1,0)
		end
	
		gl.Color(0,0,0,1)
		-- gl.Begin("LINE_STRIP")
		-- for _,p in ipairs(cnv.lab) do
			-- gl.Vertex(p)
		-- end
		-- gl.End()
		gl.Begin("LINES")
			for k,v in ipairs(cnv.lab.aristas) do
				gl.Vertex(v.puntos[1])
				gl.Vertex(v.puntos[2])
			end
		gl.End()
	end
end


MapaPlotter.drawData = function(cnv)
	if cnv.puntos and cnv.pos and cnv.headdir and cnv.index then
		for _,i in ipairs({1,2}) do
			gl.LoadIdentity()
			if i == 4 then
				gl.Translate(cnv.x2 - cnv.x1,0,0)
			elseif i==1 then
				gl.Translate(0,cnv.y2 - cnv.y1,0)
			elseif i ==2 then
				gl.Translate(cnv.x2 - cnv.x1,cnv.y2 - cnv.y1,0)
			end
		
			local index= tonumber(cnv.index)
			gl.Begin("LINE_STRIP")
			gl.Color(0,1,0,1)
			
			local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
			local giroY = {-giroX[2],giroX[1]}
			
			for _,p in ipairs(cnv.puntos[index]) do
				--gl.Vertex(p[1] + cnv.pos[1] ,p[2] + cnv.pos[2] )
				gl.Vertex({p*giroX,p*giroY} + cnv.pos[index] )
			end
			gl.End()
			
			gl.Color(0,1,0,1)
			for _,p in ipairs(cnv.puntos[index]) do
				--gl.Vertex(p[1] + cnv.pos[1] ,p[2] + cnv.pos[2] )
				local centro = {p*giroX,p*giroY} + cnv.pos[index]
				MapaPlotter.drawX(centro)
			end
		end
		
		
		
	end
end


MapaPlotter.drawSegmentosIniciales = function(cnv)
	gl.LoadIdentity()
	gl.Translate(cnv.x2 - cnv.x1,cnv.y2 - cnv.y1,0)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos then
		local index = tonumber(cnv.index)
		local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
		local giroY = {-giroX[2],giroX[1]}
	
		gl.LineWidth(3)
		for k,v in ipairs(cnv.seg3[index]) do
			if k % 3 == 0 then
				gl.Color(1,0,0,1)
			elseif k%3 ==1 then
				gl.Color(0,0,1,1)
			else
				gl.Color(1,1,0,1)
			end
			gl.Begin("LINE_STRIP")
			for i,id in ipairs(v.ids) do
				local p= cnv.puntos[index][id]
				gl.Vertex({p*giroX,p*giroY} + cnv.pos[index])
			end
			gl.End()
		end
		gl.LineWidth(1)
	end
end

MapaPlotter.lab8 = function()
	local lado = 0.5
	local mitad = lado / 2
	local largo = 2
	local apotema = mitad / math.tan(22.5*math.pi/180)
	local lab = { {apotema,-mitad},{apotema + largo,-mitad},{apotema+largo,mitad},{apotema,mitad}}
	for i=1,7 do
		for j=2,4 do
			lab[#lab+1] = {math.cos(45*i/180*math.pi)*lab[j][1]-math.sin(45*i/180*math.pi)*lab[j][2],
							   math.sin(45*i/180*math.pi)*lab[j][1]+math.cos(45*i/180*math.pi)*lab[j][2]}
		end
	end
	return lab
end

MapaPlotter.drawPos= function(cnv)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos then
		local index = tonumber(cnv.index)
		
		for i=1,4 do
			gl.LoadIdentity()
			if i == 4 then
				gl.Translate(cnv.x2 - cnv.x1,0,0)
			elseif i==1 then
				gl.Translate(0,cnv.y2 - cnv.y1,0)
			elseif i ==2 then
				gl.Translate(cnv.x2 - cnv.x1,cnv.y2 - cnv.y1,0)
			end
		
			gl.Color(0,0,0,1)
			MapaPlotter.drawX(cnv.pos[index],1.5)
			
		end
		
		
	end
end


MapaPlotter.drawSegmentosFinales = function(cnv)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos and cnv.mapas then
		local index = tonumber(cnv.index)
		
		gl.LoadIdentity()
		gl.Translate(cnv.x2 - cnv.x1,0,0)
		
		local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
		local giroY = {-giroX[2],giroX[1]}
		
		local hdGiroX = {math.cos(cnv.mapas[index].headdir),-math.sin(cnv.mapas[index].headdir)}
		local hdGiroY = {-hdGiroX[2],hdGiroX[1]}
	
		
		for k,v in ipairs(cnv.seg3[index]) do
			gl.Color(0,0,1,1)
			gl.LineWidth(2)
			gl.Begin("LINES")
			for i,p in ipairs(v.puntos) do
				gl.Vertex({p.coords*giroX,p.coords*giroY} + cnv.pos[index])
			end
			gl.End()
			
			-- gl.Color(1,1,0,1)
			-- gl.LineWidth(1)
			-- gl.Begin("LINES")
			-- for i,p in ipairs(v.puntos) do
				-- gl.Vertex({p.coords*hdGiroX,p.coords*hdGiroY} + cnv.mapas[index].pos)
			-- end
			-- gl.End()
			
			gl.Color(1,1,0,1)
			gl.LineWidth(1)
			gl.Begin("LINES")
			for i,p in ipairs(v.puntos) do
				gl.Vertex({p.coords*hdGiroX,p.coords*hdGiroY} + cnv.pos[index])
			end
			gl.End()
			
			
			for i,p in ipairs(v.puntos) do
				if p.esEsquina then 
					gl.Color(1,0,0,1)
				else
					gl.Color(0,0,1,1)
				end
				MapaPlotter.drawX({p.coords*giroX,p.coords*giroY} + cnv.pos[index])
			end
			
		end
		gl.LineWidth(1)
		
		
		
		
	end

end

MapaPlotter.drawMapa = function(cnv)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos and cnv.mapas then
		local index = tonumber(cnv.index)
		
		gl.LoadIdentity()
		
		--local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
		--local giroY = {-giroX[2],giroX[1]}
	
		
		for k,v in ipairs(cnv.mapas[index].aristas) do
			gl.LineWidth(1)
			gl.Color(0,0,1,1)

			gl.Begin("LINES")
			for i,p in ipairs(v.puntos) do
				gl.Vertex(p.coords)
			end
			gl.End()
			
			
			gl.LineWidth(1)
			for i,p in ipairs(v.puntos) do
				if p.esEsquina then 
					gl.Color(1,0,0,1)
				else
					gl.Color(0,0,1,1)
				end
				MapaPlotter.drawX(p.coords)
			end
			
		end
		
		MapaPlotter.drawRealState(cnv)
		
		
		gl.Color(1,0,0,1)
		MapaPlotter.drawX(cnv.mapas[index].pos,1.5)
		
		
		
		
	end

end


MapaPlotter.drawAmarilla = function(cnv)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos and cnv.mapas and cnv.amarilla then
		local index = tonumber(cnv.index)
		local indexAma = tonumber(cnv.amarilla)
		if  indexAma<= #cnv.mapas[index].aristas then
			
			
			gl.LoadIdentity()
			
			--local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
			--local giroY = {-giroX[2],giroX[1]}
			
			gl.LineWidth(2)
			gl.Color(1,1,0,1)
			gl.Begin("LINES")
				local aamarilla = cnv.mapas[index].aristas[indexAma]
				gl.Vertex(aamarilla.puntos[1].coords)
				gl.Vertex(aamarilla.puntos[2].coords)
			gl.End()		
			gl.LineWidth(1)		
		end
		
	end

end

MapaPlotter.drawState = function (cnv)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos and cnv.mapas and cnv.states then
		local index = tonumber(cnv.index)
		local estado = cnv.states[index]
		if estado then
			gl.LoadIdentity()
			gl.Translate(cnv.x2 - cnv.x1,0,0)
			
			local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
			local giroY = {-giroX[2],giroX[1]}		
			
			gl.LineWidth(3)
			gl.Color(0,0.5,0.5,0.3)
			gl.Begin("POLYGON")
				local miString = ""
				--print('coords')
				for k,v in ipairs(estado) do
					miString=miString..v..'/'
					local p = cnv.seg3[index].puntos[v]
					gl.Vertex({p.coords*giroX,p.coords*giroY} + cnv.pos[index])
				end
				--print(miString)
			gl.End()
			gl.LineWidth(1)
		else
			--print(index, 'no state') 
		end
		
		
	
	end

end

MapaPlotter.drawRealState = function(cnv)
	if cnv.seg3 and cnv.puntos and cnv.index and cnv.headdir and cnv.pos and cnv.mapas and cnv.states then
		--print('entre')
		local index = tonumber(cnv.index)
		local estado = cnv.states[index]
		if estado then
			gl.LoadIdentity()
			--gl.Translate(cnv.x2 - cnv.x1,0,0)
			
			--local giroX = {math.cos(cnv.headdir[index]),-math.sin(cnv.headdir[index])}
			--local giroY = {-giroX[2],giroX[1]}		
			
			gl.LineWidth(3)
			gl.Enable("BLEND")
			gl.BlendFunc("SRC_ALPHA","ONE_MINUS_SRC_ALPHA")
			gl.Color(0.5,0.5,0,0.7)
			gl.Begin("POLYGON")
				local miString = ""
				--print('coords')
				for k,v in ipairs(cnv.mapas[index].estado) do
					--miString=miString..v..'/'
					--local p = cnv.seg3[index].puntos[v]
					--gl.Vertex({p.coords*giroX,p.coords*giroY} + cnv.pos[index])
					gl.Vertex(v.coords)
				end
				--print(miString)
			gl.End()
			gl.LineWidth(1)
			gl.Disable("BLEND")
		else
			--print(index, 'no state') 
		end
		
		
	
	end
end



-- local plot = iup.pplot{
  -- TITLE = "Simple Line",
  -- MARGINBOTTOM="65",
  -- MARGINLEFT="65",
  -- AXS_XLABEL="X",
  -- AXS_YLABEL="Y",
  -- LEGENDSHOW="YES",
  -- LEGENDPOS="TOPLEFT",
-- }

-- iup.PPlotBegin(plot, 0)
-- iup.PPlotAdd(plot, 0, 0)
-- iup.PPlotAdd(plot, 1, 1)
-- iup.PPlotEnd(plot)

-- d = iup.dialog{plot, size="200x100", title="PPlot"}
-- d:show()



return MapaPlotter








--return MapaPlotter