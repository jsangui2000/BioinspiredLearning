-- AX12 module Version 3
-- By Marcelo Gancio Montero, 2012
-- This module implements functions to control the Dinamixel AX12 actuators. 
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- Change log:
--		  v 3: added full stty settings to ensure proper comm port config.
--        v 2: implements non blocking reads, change baudrate functions.
--				return values are nil on errors, added noack to errors table.
--        v 1: verify checksum and retries up to 3 times.
--				final function added to close comm port.
--        v 0: initial release.

local folderDir = (...):match("(.-)[^%/]+$")
require(folderDir..'strict')
local A={}

-- file descriptors to send and receive commands, and configure comm port
A.fsnd, A.frcv = nil, nil

-- debug flag
A.debug = nil

-- error indicators
A.errors={
  ['voltage']=false,
  ['angle']=false,
  ['overheat']=false,
  ['range']=false,
  ['checksum']=false,
  ['overload']=false,
  ['instruction']=false,
  ['error']=false,
  ['noack']=false
}      

-- fills the errors table
function A.fillerrors(e)
  -- print('fillerrors('..e..')')
  A.errors.error=(e ~= 0)
  A.errors.voltage=( (e % 2) ~= 0)
  e=math.floor(e / 2)
  A.errors.angle=( (e % 2) ~= 0)
  e=math.floor(e / 2)
  A.errors.overheat=( (e % 2) ~= 0)
  e=math.floor(e / 2)
  A.errors.range=( (e % 2) ~= 0)
  e=math.floor(e / 2)
  A.errors.checksum=( (e % 2) ~= 0)
  e=math.floor(e / 2)
  A.errors.overload=( (e % 2) ~= 0)
  e=math.floor(e / 2)
  A.errors.instruction=( (e % 2) ~= 0)
end

-- returns a string with the errors found in the errors table
function A.geterrors()
	local s=''
	for i,v in pairs(A.errors) do
		if v then s=s..', '..i end
	end
	return s
end
  
-- calculates checksum
function A.checksum(s)
  local sum=0
  for i=1,s:len() do
    sum=sum+s:byte(i)
  end
  sum=255-math.fmod(sum,256)
  return sum
end

-- send a packet to the actuators
-- format of packet: 0xFF 0xFF ID LENGTH INSTRUCTION PARAMETER_1 ... PARAMETER_N CHECKSUM
-- parameters:   id: ID
--              cmd: INSTRUCTION
--              ...: PARAMETER_1 ... PARAMETER_N
function A.send(id,cmd,...)
  local param=string.char(...)
  local pkt=string.char(id,param:len()+2,cmd)..param
  local spkt=string.char(0xFF,0xFF)..pkt..string.char(A.checksum(pkt))

  local ret=A.fsnd:write(spkt)
  A.fsnd:flush()
  --local consume=A.frcv:read(spkt:len()) --ignoro acks, solo tomo paquetes de read
	  

end

-- receive a packet from actuators
-- format of return packet: 0xFF 0xFF ID LENGTH ERROR PARAMETER_1 PARAMETER_2...PARAMETER_N CHECKSUM
-- returns string with packet without xFF xFF CHECKSUM or nil on error
function A.receive()
  local pkt=A.frcv:read(4)
  local pktp=nil
  if pkt and pkt:len()==4 then
    pktp=A.frcv:read(pkt:byte(4))
    if pktp and pktp:len()==pkt:byte(4)  then
      -- skips header and checksum
    	pkt=pkt:sub(3,4)..pktp:sub(1,-2)
    	if A.checksum(pkt) ~= pktp:byte(-1,-1) then
    		return nil
    	end
    else
    	return nil
    end
  else
    return nil  
  end
  return pkt
end

-- opens comm port and configure it
-- parameters: commdev: absolute path of comm device (default:'/dev/ttyS0')
--                 vel: communication baud rate (default: 1000000)
--                 dbg: flag to activate debug, (print data sended/received)
function A.init(commdev,vel,dbg)
  local ttyUSBFile = io.popen('ls /dev/ | grep ttyUSB','r')
  
  commdev= '/dev/'..ttyUSBFile:read() --or commdev or --'/dev/ttyUSB0'
  ttyUSBFile:close()
  vel=vel or 1000000
  -- vel, N81, no lock read, timeout 0.1 second, no xon xoff flow control
  assert(os.execute('stty -F '..commdev..' '..vel..' cs8 -parenb -cstopb -icanon min 0 time 1 -ixon -parodd hupcl cread -clocal -crtscts -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -iuclc -ixany -imaxbel -iutf8 -opost -olcuc -ocrnl -onlcr -onocr -onlret -ofill -ofdel nl0 cr0 tab0 bs0 vt0 ff0 -isig -iexten -echo -echoe -echok -echonl -noflsh -xcase -tostop -echoprt -echoctl -echoke'))
  A.fsnd=assert(io.open(commdev,'w')) 
  A.frcv=assert(io.open(commdev,'r'))
end

-- closes comm port
function A.final() 
	A.fsnd:close()
	A.frcv:close()
end

-- PING instruction code 01, params 0
-- No action. Used for obtaining a Status Packet to fill the errors table
function A.ping(id)
  A.send(id,1)
  return A.receive()

end

-- READ_DATA instruction code 02, params 2
-- Reading values in the Control Table
-- parameters:    id: id of actuator to read
--              rpos: starting address to read
--              rlen: number of values to read
function A.read_data(id,rpos,rlen)
  A.send(id,2,rpos,rlen)
  local rpkt = A.receive()
  return rpkt:byte(4,3+rlen)
end
  
-- WRITE_DATA instruction code 03, params 2+
-- Writing values to the Control Table
-- parameters:    id: id of actuator to write
--              wpos: starting address to write
--               ...: values to write
function A.write_data(id,wpos,...)
  A.send(id,3,wpos,...)
end

-- REG_WRITE instruction code 04, params 2+
-- Similar to WRITE_DATA, but stays in standby mode until the ACION instruction is given
-- parameters:    id: id of actuator to write
--              wpos: starting address to write
--               ...: values to write
function A.reg_write(id,wpos,...)
  A.send(id,4,wpos,...)
end

-- ACTION instruction code 05 params 0
-- Triggers the action registered by the REG_WRITE instruction
-- parameters: id of actuator to write
function A.action(id)
  A.send(id,5)
end

-- RESET instruction code 06 params 0
-- Changes the control table values of the Dynam ixel actuator to the Factory Default Value settings
-- parameters: id of actuator to reset
function A.reset(id)
  A.send(id,6)
end

-- SYNC_WRITE instruction code 0x83 params 4+
-- Used for controlling many Dynamixel actuators at the same time
-- parameters: wpos: starting address of writing
--              len: length of each parameter data group
--           params: table of parameters to write
function A.sync_write(wpos,len,params)
  A.send(0xFE,0x83,wpos,len,unpack(params))
end

-- Converts a 16 bits value in a 8 bit values pair
-- Values over 0xFFFF are stripped to 16 LSB
function A.word2byte(w)
  local h=math.floor((w % 65536) /256)
  local l=w % 256
  return l,h
end

---------------------------------
-- Functions for get values

function A.get_model(id)
  local l,h= A.read_data(id,0,2)
  if not l then 
     return nil 
  end
  return (h*256)+l
end

function A.get_firmware_version(id)
  local l= A.read_data(id,2,1)
  if not l then 
     return nil 
  end
  return l
end
  
function A.get_id(id)
  local l= A.read_data(id,3,1)
  if not l then 
     return nil 
  end
  return l
end
  
function A.get_baud_rate(id)
  local l= A.read_data(id,4,1)
  return l
end

function A.get_return_delay_time(id)
  local l= A.read_data(id,5,1)
  if not l then 
     return nil 
  end
  return l+l
end

function A.get_cw_angle_limit(id)
  local l,h= A.read_data(id,6,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_ccw_angle_limit(id)
  local l,h= A.read_data(id,8,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_high_limit_temp(id)
  local l= A.read_data(id,11,1)
  if not l then 
     return nil 
  end
  return l
end

function A.get_low_limit_voltage(id)
  local l= A.read_data(id,12,1)
  if not l then 
     return nil 
  end
  return l/10
end

function A.get_high_limit_voltage(id)
  local l= A.read_data(id,13,1)
  if not l then 
     return nil 
  end
  return l/10
end

function A.get_max_torque(id)
  local l,h= A.read_data(id,14,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_status_return_level(id)
  local l= A.read_data(id,16,1)
  return l
end

function A.get_alarm_led(id)
  local l= A.read_data(id,17,1)
  return l
end

function A.get_alarm_shutdown(id)
  local l= A.read_data(id,18,1)
  return l
end

function A.get_down_calibration(id)
  local l,h= A.read_data(id,20,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_up_calibration(id)
  local l,h= A.read_data(id,22,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_torque_enable(id)
  local l= A.read_data(id,24,1)
  return l
end

function A.get_led(id)
  local l= A.read_data(id,25,1)
  return l
end

function A.get_cw_compliance_margin(id)
  local l= A.read_data(id,26,1)
  return l
end

function A.get_ccw_compliance_margin(id)
  local l= A.read_data(id,27,1)
  return l
end

function A.get_cw_compliance_slope(id)
  local l= A.read_data(id,28,1)
  return l
end

function A.get_ccw_compliance_slope(id)
  local l= A.read_data(id,29,1)
  return l
end

function A.get_goal_position(id)
  local l,h= A.read_data(id,30,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_moving_speed(id)
  local l,h= A.read_data(id,32,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_torque_limit(id)
  local l,h= A.read_data(id,34,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_present_position(id)
  local l,h= A.read_data(id,36,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

function A.get_present_speed(id)
  local l,h= A.read_data(id,38,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

-- returns cw = true if load is cw, and load value
function A.get_present_load(id)
  local l,h= A.read_data(id,40,2)
  if not l then 
     return nil 
  end
  local cw=(h > 1)
  local lv =(l+256*h) % 0x1FF
  return cw, lv
end

function A.get_present_voltage(id)
  local l= A.read_data(id,42,1)
  if not l then 
     return nil 
  end
  return l/10
end

function A.get_present_temp(id)
  local l= A.read_data(id,43,1)
  return l
end

function A.get_registered_instruction(id)
  local l= A.read_data(id,44,1)
  return l
end

function A.get_moving(id)
  local l= A.read_data(id,46,1)
  return l
end

function A.get_lock(id)
  local l= A.read_data(id,47,1)
  return l
end

function A.get_punch(id)
  local l,h= A.read_data(id,48,2)
  if not l then 
     return nil 
  end
  return l+256*h
end

----------------------------------
-- Functions for set values

function A.set_id(id,nid)
  if (nid >= 0) and (nid < 254) then
    local l= A.write_data(id,3,nid)
    return l
  else
    return nil,'ID out of range (0...253) '
  end
end

-- see ax12 manual for spd values  
function A.set_baud_rate(id,spd)
  return A.write_data(id,4,spd)
end

function A.set_return_delay_time(id,d)
  return A.write_data(id,5,math.floor(d/2))
end

function A.set_cw_angle_limit(id,al)
  local l,h= A.word2byte(al)
  return A.write_data(id,6,l,h)
end

function A.set_ccw_angle_limit(id,al)
  local l,h= A.word2byte(al)
  return A.write_data(id,8,l,h)
end

function A.set_high_limit_temp(id,t)
  return A.write_data(id,11,t)
end

function A.set_low_limit_voltage(id,v)
  return A.write_data(id,12,v*10)
end

function A.set_high_limit_voltage(id,v)
  return A.write_data(id,13,v*10)
end

function A.set_max_torque(id,t)
  local l,h= A.word2byte(t)
  return A.write_data(id,14,l,h)
end

function A.set_status_return_level(id,r)
  return A.write_data(id,16,r)
end

function A.set_alarm_led(id,l)
  return A.write_data(id,17,l)
end

function A.set_alarm_shutdown(id,s)
  return A.write_data(id,18,s)
end

function A.set_torque_enable(id,te)
  return A.write_data(id,24,te)
end

function A.set_led(id,l)
  return A.write_data(id,25,l)
end

function A.set_cw_compliance_margin(id,m)
  return A.write_data(id,26,m)
end

function A.set_ccw_compliance_margin(id,m)
  return A.write_data(id,27,m)
end

function A.set_cw_compliance_slope(id,s)
  return A.write_data(id,28,s)
end

function A.set_ccw_compliance_slope(id,s)
  return A.write_data(id,29,s)
end

function A.set_goal_position(id,gp)
  local l,h= A.word2byte(gp)
  return A.write_data(id,30,l,h)
end

function A.set_moving_speed(id,ms)
  local l,h= A.word2byte(ms)
  return A.write_data(id,32,l,h)
end

function A.set_torque_limit(id,tl)
  local l,h= A.word2byte(tl)
  return A.write_data(id,34,l,h)
end

function A.set_lock(id,l)
  return A.write_data(id,47,l)
end

function A.set_punch(id,p)
  local l,h= A.word2byte(p)
  return A.write_data(id,48,l,h)
end

------------------------------------
-- Functions reg version (activates with action function)

function A.reg_cw_angle_limit(id,al)
  local l,h= A.word2byte(al)
  return A.reg_write(id,6,l,h)
end

function A.reg_ccwangle_limit(id,al)
  local l,h= A.word2byte(al)
  return A.reg_write(id,8,l,h)
end

function A.reg_torque_enable(id,te)
  return A.reg_write(id,24,te)
end

function A.reg_goal_position(id,gp)
  local l,h= A.word2byte(gp)
  return A.reg_write(id,30,l,h)
end

function A.reg_moving_speed(id,ms)
  local l,h= A.word2byte(ms)
  return A.reg_write(id,32,l,h)
end

--------------------------------------

return A

