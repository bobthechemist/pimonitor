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
 - Once the the appropriate path is set for $pmlcdlink, Load the package with `<<pimonitor\``
 - Initialize the monitor with `InitPiMonitor[]`
 - Start the monitor with `pmStartmonitor[]` which will provide the default update interval of 5 seconds.
 - If the CPU temp exceeds $pmThreshold, the LCD screen will change colors.
 - Enjoy monitoring for a whole 5 minutes(*)!
 - The basic operation outlined above generates five-minute monitoring routine during which the LCD display will report the temperatures, fan speeds and provide a plot of how the CPU temperature has varied over the last minute. When finished, the LCD screen will report as much.  It is possible to end the monitoring prematurely with the function `pmAbort[]` which will inform you through the LCD screen that the task has finished through an abort signal.

##What's next##
 - Process management. I've noticed that orphaned WolframLinks and tails linger after monitoring is complete.  I haven't done much error checking in this code at all, and these two problems should be a high priority.
 - Enhanced configuration: what variable gets plotted.  Also included in this request is a customizeable or smart range determination routine for the plot.
 - Button access.  Leverage the 5-button interface of the LCDPiPlate to provide additional features (abort, start, switch plot, etc).
 - Flexibility - Generalize to allow for easy modifications, such as log file format.

 
