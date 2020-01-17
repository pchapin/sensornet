Setup: 
1. Load the "basestation" program onto one tmote.
	a. When installing "basestation" on a tmote, use the following command:" make telosb reinstall.0"
	b. This sets the tmote running the "basestation" program to nodeid=0. 

2. Load the "node" program onto as many tmote as desired.
	a. Set different nodeids for each tmote running the "node" application.
		i. Example: "make telosb reinstall.5" "make telosb reinstall.10" "make telosb reinstall.15"

3. Have the tmote running the "basestation" program plugged into your computer.

4. Now, run the following command "java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSB0:115200"
	a. If this fails, run command "motelist"	
	b. Re-run the initial command with the proper USB port. 
		i. Example: "java net.tinyos.tools.PrintfClient -comm serial@/dev/ttyUSB5:115200"


