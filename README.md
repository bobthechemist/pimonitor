#pimonitor#
_Display log information on the RPi LCDPlate from Adafruit_

##Introduction##
I've been running in to some problems with my computer fans; they seem to
be running high and low at unusual times.  I'm running SpeedFan and it's
clear that I don't have the settings adjusted properly.  

To help diagnose the problem, I wanted a temp and fan speed monitor that
was viewable while playing a game.  This project is my implementation of
the SpeedFan log monitor.

##My Setup##
I have a Raspberry Pi (Model B) with an Adafruit LCDPiPlate connected
to my network via WiFi.  The RPi has access to the SpeedFan log of my 
PC through a mounted share.  I use an earlier project of mine (rpi-lcdlink)
to interface with the LCDPiPlate through _Mathematica_. 

##What it does so far##
After initializing, the program starts a `ScheduledTask` which grabs the
last line of the SpeedFan log every `n` seconds.  The log reports the time
along with the core, case and GPU temps, followed by the cpu and case fan
speeds.  This information is directed to the LCDPiPlate.  Since I have an 
RGB version of the display, the temperature check routing (`pmCheck`) 
checks to see if the CPU temp exceeds a user-defined threshold and, if so,
changes the screen color (also user defined).

##What I want it to do##
 - More automation.  Presently startup requires:
    <<pimonitor`
    initPiMonitor[pmGenLogname[]];
    pmStartMonitor[pmGenLogname[],5];
    (* when done *)
    StopScheduledTask[First@ScheduledTasks[]];

 - Make a graph, cpu temp vs. time, for example

 - Take advantage of the buttons for user input.  
 
