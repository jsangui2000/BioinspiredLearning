local folderDir = (...):match("(.-)[^%/]+$")
require("iuplua")
require("iupluagl")
require("luagl")
require("luaglu")
require( "iuplua_pplot" )

iup.key_open()

local cnv = iup.glcanvas{buffer="DOUBLE", rastersize = "640x480"}

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

package.path = package.path .. ';'..folderDir..'../?.lua'
local G = require("Utils/Grafo")
cnv.data = G.new()
cnv.activa = 1
cnv.ring = {}

local lado = 0.5
local mitad = lado / 2
local largo = 2
local apotema = mitad / math.tan(22.5*math.pi/180)
cnv.lab = { {apotema,-mitad},{apotema + largo,-mitad},{apotema+largo,mitad},{apotema,mitad}}
for i=1,7 do
	for j=2,4 do
		cnv.lab[#cnv.lab+1] = {math.cos(45*i/180*math.pi)*cnv.lab[j][1]-math.sin(45*i/180*math.pi)*cnv.lab[j][2],
						   math.sin(45*i/180*math.pi)*cnv.lab[j][1]+math.cos(45*i/180*math.pi)*cnv.lab[j][2]}
	end
end
cnv.x1 = -2.8
cnv.x2 = 2.8
cnv.y1 = -2.8
cnv.y2 = 2.8
cnv.setOrigen = function (origen,x1,x2,y1,y2)
	for _,p in ipairs(cnv.lab) do
		p[1],p[2] = p[1] - origen[1],p[2]-origen[2]
	end
	cnv.x1 = (x1 or cnv.x1) - origen[1]
	cnv.x2 = (x2 or cnv.x2) - origen[1]
	cnv.y1 = (y1 or cnv.y1) - origen[2]
	cnv.y2 = (y2 or cnv.y2) - origen[2]
end


--cnv.data = require("Radial") --test

function cnv:action(x, y)
  iup.GLMakeCurrent(self)
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT') -- Clear Screen And Depth Buffer
  gl.MatrixMode("PROJECTION")
  gl.LoadIdentity()
  gl.Ortho(cnv.x1,cnv.x2,cnv.y1,cnv.y2,-1,1) --left,right,bot,top,near,far
  gl.MatrixMode("MODELVIEW")
  gl.LoadIdentity()
  gl.PointSize(8)
  gl.Color(1,0,0,1)
  
  for k,v in ipairs(cnv.data.nodos) do
	gl.Begin("LINES")
	for k2,v2 in ipairs(v.adyacentes) do
		if k <= cnv.data.nodos[v2[1]] then
			--gl.Vertex(v.x,v.y)
			--gl.Vertex(v2[1].x,v2[1].y)
			gl.Vertex(v.centroid)
			gl.Vertex(v2[1].centroid)
		end
	end
	gl.End()
	
	gl.Begin("POINTS")
	--gl.Vertex(v.x,v.y)
	gl.Vertex(v.centroid)
	gl.End()
  end
  
  gl.Color(0,0,0,1)
  gl.Begin("LINE_STRIP")
  for _,p in ipairs(cnv.lab) do
		gl.Vertex(p)
  end
  
  gl.End()
  
  gl.Color(0,0,1,1)
  
  local v = nil
  if #cnv.data.nodos >=tonumber(cnv.activa)then
	v = cnv.data.nodos[tonumber(cnv.activa)]
  end
  if v then
	gl.Begin("POINTS")
		--gl.Vertex(v.x,v.y)
		gl.Vertex(v.centroid)
	gl.End()
  end
  
  if cnv.pos then
	gl.Color(0,1,0,1)
	gl.Begin("POINTS")
		gl.Vertex(cnv.sense and cnv.sense.posVieja or cnv.pos)
	gl.End()
  end
  
  gl.Begin("LINE_STRIP")
  gl.Color(0,1,0,1)
  for _,p in ipairs(cnv.ring) do
	gl.Vertex(p[1] + cnv.pos[1] ,p[2] + cnv.pos[2] )
  end
  gl.End()
  gl.Color(0,0.8,0.3,1)
  gl.Begin("POINTS")
	if cnv.centroid then
		gl.Vertex(cnv.centroid)
	end
  gl.End()
  
  gl.Begin("POINTS")
  
  if cnv.sense then
	  if cnv.sense.integration1 then
		gl.Color(1,0,1,1)
		gl.Vertex(cnv.sense.integration1)
	  end
  end
  gl.End()
  
  
  iup.GLSwapBuffers(self)
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
  end
end

dlg = iup.dialog{cnv,TITLE="Grafo"}
dlg.canvas = cnv
dlg.refresh = function()
	dlg.canvas:action()
	iup.LoopStep()
end
dlg.close = iup.Close
iup.ShowXY(dlg,iup.RIGHT,110)
dlg:show()
cnv.rastersize = nil -- reset minimum limitation

	
--[[	
local plot = iup.pplot{
  TITLE = "Simple Line",
  MARGINBOTTOM="65",
  MARGINLEFT="65",
  AXS_XLABEL="X",
  AXS_YLABEL="Y",
  LEGENDSHOW="YES",
  LEGENDPOS="TOPLEFT",
}

iup.PPlotBegin(plot, 0)
iup.PPlotAdd(plot, 0, 0)
iup.PPlotAdd(plot, 1, 1)
iup.PPlotEnd(plot)

d = iup.dialog{plot, size="200x100", title="PPlot"}
d:show()
--]]					
					

return dlg
--usar iup:


--Codigo para cuando se corre sin vrep
-- if (not iup.MainLoopLevel or iup.MainLoopLevel()==0) then
  -- iup.MainLoop()
-- end
