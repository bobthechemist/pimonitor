BeginPackage["pimonitor`"]
(* Public constants *)
(* Default values can be overwritten *)

$pmTempOK = 7;
$pmTempWarning = 1;
$pmTempThreshold = 55;

initPiMonitor::usage = "initPiMonitor[<lcdlink>] initializes the \
  monitor.  <lcdlink> must be the file path to the Mathlink code that\
  interfaces with the Adafruit RGB LCD panel."

pmConfig::usage = "usage file for pmconfig"
pmCheck::usage = "usage file for pmCheck"
pmGenLogname::usage = "Usage file for pmGenLogname"
pmStartMonitor::usage = "Usage file for pmStartMonitor"

Begin["`Private`"]

(* ==initPiMonitor== *)

  Clear[initPiMonitor];
  initPiMonitor[logfile_String, panellink_:"/home/pi/mywiringPi/rpi-lcdlink/lcdlink"]:= 
    Module[{},
      <<"!gpio load i2c";
      link = Install[panellink];

      (* Welcome screen *)
      lcdlink`lcdClear[];
      lcdlink`lcdPuts[0,0,"PiMonitor"];
      lcdlink`lcdPuts[0,1," initialized."];
      Pause[1];
      pmConfig[logfile];
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
  pmCheck[log_String]:=Module[{data,stream, s1,s2},
    (* My log file is tab separated line of seconds, core, case, gpu *)
    (*  temps followed by cpu and case fan speeds *)
    (* use tail to grab the last line of the log file, which will save *)
    (*  a little bit of time.*)
    data = Import["!tail -n 1 "<>log,"TSV"][[1]];
    s1 = ToString/@Round/@data[[2;;4]];
    s2 = ToString/@Round/@data[[5;;6]];
    lcdlink`lcdClear[];
    (* Change background color if Core temp is too high *)
    If[data[[2]]>$pmTempThreshold,
      lcdlink`lcdColor[$pmTempWarning];,
      lcdlink`lcdColor[$pmTempOK];];
    lcdlink`lcdPuts[0,0,StringJoin["T:", Riffle[s1," "]]];
    lcdlink`lcdPuts[0,1,StringJoin["S:", Riffle[s2," "]]];
  ]

(* ==pmGenLogname== *)
(* Alter this function to create a string corresponding to your *)
(*   logfile path *)

  pmGenLogname[base_String:""]:=Module[{tmp},
    (* If I haven't included an argument for base, assume the following *)
    tmp = If[base == "",
      Switch[First@StringSplit[$SystemID, "-"],
        "Windows","C:\\Program Files (x86)\\SpeedFan\\SFLog<DATE>.csv",
        "Linux", "/mnt/speedfan/SFLog<DATE>.csv",
        _, $Failed],
      base];
    StringReplace[tmp, "<DATE>"->DateString[{"Year","Month","Day"}]]
  ]

(* ==pmStartMonitor== *)
(* Creates a scheduled task to update the LCD screen *)
  Clear[pmStartMonitor];
  pmStartMonitor[file_String, time_Integer]:=Module[{t},
    t = CreateScheduledTask[pmCheck[file],time, 
      "EpilogFunction":>(
        lcdlink`lcdClear[];
        lcdlink`lcdPuts[0,0,"Finished"];)]; 
    StartScheduledTask[t];
    t (* Return the task so it can be stopped *)
    ]

    

 
End[]
EndPackage[]

