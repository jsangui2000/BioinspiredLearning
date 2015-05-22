#! /usr/bin/env lua

M=require('ax12')

id=0xFE
lastcmd='h'
seguir=true
print('AX12 library control & test.')
M.init('/dev/ttyUSB1',1000000)
while seguir do
  print('Command:')
  repeat
  	cmd=io.read()
  until cmd ~= ''
  if cmd=='h' then
    print('Help')
    print('Low Level:')
    print('	init device speed  : configures comm device')
    print('	reset              : reset function')
    print('	ping               : ping function')
    print('	read pos len       : read_data function')
    print('	write pos data     : write_data function')
    print('	write2 pos data    : write_data function, data is 2 bytes')
    print('	regwrite pos data  : reg_write function')
    print('	action             : action function')
    print('	syncwrite pos list : sync_write function')
    print('Mid Level:')
    print('	gid		: get id')
    print('	gcw		: get CW Angle limit')
    print('	gccw		: get CCW Angle limit')
    print('	gmt		: get max torque')
    print('	gte		: get torque enable')
    print('	gtl		: get torque limit')
    print('	gpl		: get present load')
    print('	gpp		: get present position')
    print('	ggp		: get goal position')
    print('	gm		: get moving')
    print('	gms		: get moving speed')
    print('  Set:')
    print('	sid		: set id')
    print('	scw		: set CW Angle limit')
    print('	sccw		: set CCW Angle limit')
    print('	smt		: set max torque')
    print('	ste		: set torque enable')
    print('	stl		: set torque limit')
    print('	sl		: set led')
    print('	sgp		: set goal position')
    print('	sms		: set moving speed')
    print('Others:')
    print('	h	:this help')
    print('	q	:quit')
    print('	r	:repeat last cmd')
    print('	i 	:set working id and repeat last cmd')
    print('	d	:toggle debug mode')
  elseif cmd=='d' then
    M.debug= not M.debug
    if M.debug then
    	print('Debug ON')
    else
    	print('Debug off')
    end
    print('Repeating '..lastcmd..'...')
    cmd=lastcmd
  elseif cmd=='q' then
    seguir=false
  elseif cmd=='r' then
    print('Repeating '..lastcmd..'...')
    cmd=lastcmd
  elseif cmd=='i' then
    print('>> Old id:'..id..' New id:')
    id=io.read('*n')
    print('Repeating '..lastcmd..'...')
    cmd=lastcmd
  end
-- Low level commands
  if cmd=='init' then
    print('Device:')
    local dev=io.read()
    if dev=='' then
	dev='/dev/ttyUSB0'
    end
    print('Baud rate:')
    local br=io.read('*n')
    M.final()
    M.init(dev,br)
  elseif cmd=='reset' then
    print('Reset '..id)
    print(M.reset(id))
  elseif cmd=='ping' then
    print('Ping '..id)
    print(M.ping(id))
  elseif cmd=='read' then
    print('Position:')
    local pos=io.read('*n')
    print('Length:')
    local len=io.read('*n')
    print('Read data of '..id..' at position '..pos..' length '..len)
    print(M.read_data(id,pos,len))
  elseif cmd=='write' then
    print('Position:')
    local pos=io.read('*n')
    print('Length:')
    local len=io.read('*n')
    print('Data:')
    local v=io.read('*n')
    if len > 1 then
      local l,h=M.word2byte(v)
      print('Write data to '..id..' at '..pos..' with '..l..','..h)
      print(M.write_data(id,pos,l,h))
    else
      print('Write data to '..id..' at '..pos..' with '..v)
      print(M.write_data(id,pos,v))
    end
  elseif cmd=='write2' then
    print('Position:')
    local pos=io.read('*n')
    print('Data (16 bit only):')
    local v=io.read('*n')
    local l,h=M.word2byte(v)
    print('Write data to '..id..' at '..pos..' with '..l..','..h)
    print(M.write_data(id,pos,l,h))
  elseif cmd=='regwrite' then
    print('Position:')
    local pos=io.read('*n')
    print('Length:')
    local len=io.read('*n')
    print('Data:')
    local v=io.read('*n')
    if len > 1 then
      local l,h=M.word2byte(v)
      print('RegWrite data to '..id..' at '..pos..' with '..l..','..h)
      print(M.reg_write(id,pos,l,h))
    else
      print('RegWrite data to '..id..' at '..pos..' with '..v)
      print(M.reg_write(id,pos,v))
    end
  elseif cmd=='action' then
    print('Action '..id)
    print(M.action(id))
  elseif cmd=='syncwrite' then
    print('Position:')
    local pos=io.read('*n')
    print('Data: Number of actuators:')
    local ng=io.read('*n')
    print("Data: Length of each actuator's group:")
    local lg=io.read('*n')
    print('Data: (enter each value separated by space, enter terminates a group):')
    local v={}
    local p=1
    for i=1,ng do
      print('Data: Actuator '..i..', Id:')
      v[p]=io.read('*n')
      p=p+1
      print('Data: Values:')
      for j=1,lg do
	v[p]=io.read('*n')
	p=p+1
      end
    end
    print('Sync_Write data at '..pos..' with '..lg..' data per actuator:')
    for i,j in ipairs(v) do io.write(j..' ') end print('')
    print(M.sync_write(pos,lg,v))
    
-- Mid level commands
  elseif cmd=='gid' then
    print('ID of '..id..' is:')
    print(M.get_id(id))
  elseif cmd=='gcw' then
    print('CW Angle limit of '..id..' is:')
    print(M.get_cw_angle_limit(id))
  elseif cmd=='gccw' then
    print('CCW Angle limit of '..id..' is:')
    print(M.get_ccw_angle_limit(id))
  elseif cmd=='gmt' then
    print('Max torque of '..id..' is:')
    print(M.get_max_torque(id))
  elseif cmd=='gte' then
    print('Torque enable of '..id..' is:')
    print(M.get_torque_enable(id))
  elseif cmd=='gtl' then
    print('Torque limit of '..id..' is:')
    print(M.get_torque_limit(id))
  elseif cmd=='gpl' then
    print('Present Load of '..id..' is:')
    local cw,v=M.get_present_load(id)
    if cw then    
	print('Clockwise direction load: '..v)
    else
	print('CounterClockwise direction load: '..v)
    end
  elseif cmd=='gpp' then
    print('Present Position of '..id..' is:')
    print(M.get_present_position(id))
  elseif cmd=='ggp' then
    print('Goal Position of '..id..' is:')
    print(M.get_goal_position(id))
  elseif cmd=='gm' then
    print('Moving of '..id..' is:')
    print(M.get_moving(id))
  elseif cmd=='gms' then
    print('Present Moving Speed of '..id..' is:')
    print(M.get_present_speed(id))
-- Set comands
  elseif cmd=='sid' then
    print('New ID of '..id..' (0 - 253):')
    local v=io.read('*n')
    M.set_id(id,v)
  elseif cmd=='scw' then
    print('New CW Angle Limit of '..id..' (0 - 1023):')
    local v=io.read('*n')
    M.set_cw_angle_limit(id,v)
  elseif cmd=='sccw' then
    print('New CCW Angle Limit of '..id..' (0 - 1023):')
    local v=io.read('*n')
    M.set_ccw_angle_limit(id,v)
  elseif cmd=='smt' then
    print('New Max Torque of '..id..' (0 - 1023):')
    local v=io.read('*n')
    M.set_max_torque(id,v)
  elseif cmd=='ste' then
    print('New Torque Enable of '..id..' (0 - 1):')
    local v=io.read('*n')
    M.set_torque_enable(id,v)
  elseif cmd=='stl' then
    print('New Torque Limit of '..id..' (0 - 1023):')
    local v=io.read('*n')
    M.set_torque_limit(id,v)
  elseif cmd=='sl' then
    print('New Led of '..id..' (0 - 1):')
    local v=io.read('*n')
    M.set_led(id,v)
  elseif cmd=='sgp' then
    print('New Goal Position of '..id..' (0 - 1023):')
    local v=io.read('*n')
    M.set_goal_position(id,v)
  elseif cmd=='sms' then
    print('New Moving Speed of '..id..' (0 - 1023):')
    local v=io.read('*n')
    M.set_moving_speed(id,v)

  elseif cmd~='h' and cmd~='q' then
      print('Bad command, h for help, q for quit.')
  end
  if cmd~='h' and cmd~='q' and M.errors.error then
    print('Errors:')
    for i,v in pairs(M.errors) do
      if v and i~='error' then 
	  print(' ',i)
      end
    end
    print('')
  else
    print('Ok.')    
  end
  lastcmd=cmd
end
print('Bye!')
