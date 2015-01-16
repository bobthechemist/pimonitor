BeginPackage["pimonitor`"]

initPiMonitor::usage = "initPiMonitor[<lcdlink>] initializes the \
  monitor.  <lcdlink> must be the file path to the Mathlink code that\
  interfaces with the Adafruit RGB LCD panel."

pmConfig::usage = "usage file for pmconfig"
pmCheck::usage = "usage file for pmCheck"

Begin["`Private`"]

(* ==initPiMonitor== *)

  Clear[initPiMonitor];
  initPiMonitor[panellink_:"/home/pi/mywiringPi/rpi-lcdlink/lcdlink"]:= 
    Module[{},
      <<"!gpio load i2c";
      link = Install[panellink];

      (* Welcome screen *)
      lcdlink`lcdClear[];
      lcdlink`lcdPuts[0,0,"PiMonitor"];
      lcdlink`lcdPuts[0,1," initialized."];
      Pause[1];
    ]

(* ==pmConfig== *)
(* Accepts a set of options for monitoring.  Right now just needs the *)
(*  log filename and checks to make sure it is present *)

  Clear[pmConfig];
  pmConfig[log_String]:=Module[{},
    If[FileNames[log]=={},
      lcdlink`lcdClear[];
      lcdlink`lcdPuts[0,0,"Log File"];
      lcdlink`lcdPuts[0,1,"  not found."];,
      lcdlink`lcdClear[];
      lcdlink`lcdPuts[0,0,"Log found."];
    ]
  ]

(* ==pmCheck== *)
(* Assumes that pmConfig has been called and prints the last values *)
(*  of the log to the LCD screen *)

  Clear[pmCheck];
  pmCheck[log_String]:=Module[{data, s1,s2},
    data = Import[log,"TSV"]//Last;
    (* My log file is tab separated line of seconds, core, case, gpu *)
    (*  temps followed by cpu and case fan speeds *)
    s1 = ToString/@Round/@data[[2;;4]];
    s2 = ToString/@Round/@data[[5;;6]];
    lcdlink`lcdPuts[0,0,StringJoin["T:", Riffle[s1," "]]];
    lcdlink`lcdPuts[0,1,StringJoin["S:", Riffle[s2," "]]];
  ]


End[]
EndPackage[]

