AX12 Lua Library README

This Library lets you control the Robotis Dynamixel AX12 motors from a Lua program, without others auxiliar libraries, 
only the OS command "stty" is needed for proper comm port configuration.
The control options includes all operations described in the AX12 users manual from Robotis.
and a set of functions to operate the actuator, to get their status and setting delayed operations.
Also an error control is implemented, including communication issues.  


INSTALLATION

Just drop the files 
ax12.lua 
strict.lua 
in the folder of your project  where you need to control the actuators.
Also check the presence os the stty command (almost linux distro and unixes already have one).


USAGE

1. Include a line to load the library:
ax12=require('ax12')

2. Call the initialization function whit communication port and transmission baudrate.
ax12.init('/dev/ttyS0',19200)

3. Call the desired functions to control the actuator with at low level or use the high level function for ease of use.
Examples:
Getting led status:
    ax12.read_data(1, 25, 2)         -- low level read the led status of actuator 1
    ax12.get_led(1)                  -- high level read of led status of actuator 1
Setting goal position:
    ax12.write_data(1, 30, 4, 1)     -- low level setting of position 0x0104 for the actuator 1
    ax12.set_goal_position(1,0x0104) -- high level position setting
 
4. (optional) Check the error status of last command with
ax12.errors.error
Its true upon any ax12 error or comm error, you can check for an individual error with
ax12.errors.<error to check>, for example ax12.errors.overload will be true if a overload condition was detected in last command. 
 
5. Call the finalization function to proper close the comm device.
ax12.final()

See the ax12test.lua file for a full working example.


IMPLEMENTATION NOTES

The library was developed in a layer fashion:

Layer1: works the serial communication protocol, packet assembly desaessembly, error checking and registration. The initialization uses the stty command for commport configuration:
stty -F '..commdev..' '..vel..' cs8 -parenb -cstopb -icanon min 0 time 1 -ixon ...
where commdev is the comm device (absolute path required), vel indicates the comm baudrate, 'min 0 time 1' set timeout (1 second) for data reception, 
and the others configures the comm port with N81 as required by the ax12 actuators.
The send function consumes the data just sended before receiving new data due a the use of one wire serial comm for data transmission. Also retries up to 3 times the 
sendig of data if error conditions appear like packet corruption or no data reception. 
If the packet was succesfully sended, the response is received and returned to the caller function, eliminating the need of a read call for the response capture.

Layer 2: implements the basic operations as described in the ax12 manual: write_data, read_data, reg_write, action, ping, reset and syncwrite.

Layer 3: offers the easy to use functions to control the actuators and get their status. Basically these are wrappers for reading/writing the memory positions of  the ax12 actuator.
There are 3 sets: get functions of all positions, set functions for those positions where write is posible, and a subset of set functions using the reg_write operation
to perform delayed operations, executed when an action operatios is send.

Also a debug option is present (call the init function with that parameter set to true) to debug data send/received by the comm port.

