# pimonitor
Use Wolfram on a RPi equipped with an Adafruit LCDPiPlate to monitor a status log

Ideas

I am reading a log containing information about the speed of my Windows PC fans and the temperature
of the CPU and GPU.  The idea is to read the log and print that information to the LCD on the RPi.

Presently, an interactive wolfram session is needed to set the log file name and then one can run
pmCheck to get the core, case and GPU temps on the top line and the CPU and Case fan speeds on the 
bottom line.  It's a bit slow because it is reading a long file.  Preferable would be to grab just
the last line of the file, if possible.
