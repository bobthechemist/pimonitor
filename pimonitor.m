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

(* Will eventually be private - sandboxing here *)

pmMakeRow[m_List,r_Integer]:=
  Table[2^Range[4,0,-1].# &/@Take[m,{8r+1,8r+8},{5x+1,5x+5}],{x,0,3}];

pmPlot[i_List]:=Join[pmMakeRow[i,0], pmMakeRow[i,1]];

pmDefinePlotChars[l_]:=MapIndexed[lcdlink`lcdCharDef[First@#2-1, #1] &,l]

pmPutPlot[j_:3]:= Module[{},
  Table[lcdlink`lcdPutc[i+4 j,0,i],{i,0,3}];
  Table[lcdlink`lcdPutc[i+4 j, 1, i+4],{i,0,3}];
  ];

pmClearPlot[j_:3]:=Module[{},
  Table[lcdlink`lcdPutc[i+4j,0,32],{i,0,3}];
  Table[lcdlink`lcdPutc[i+4,j,1,32],{i,0,3}];
  ];

pmPlotImage[data_List]:=1-Normal@SparseArray[
  Flatten@MapIndexed[Table[{i,First@#2}->1,{i,#1}]&,
  (Round@Rescale[#,{49,52},{16,1}]&/@data)],{16,20}];



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
    data = Import["!tail -n 20 "<>log,"TSV"];
    s1 = ToString/@Round/@data[[-1,2;;4]];
    s2 = ToString/@Round/@data[[-1,5;;6]];
    lcdlink`lcdClear[];
    (* Change background color if Core temp is too high *)
    If[data[[2]]>$pmTempThreshold,
      lcdlink`lcdColor[$pmTempWarning];,
      lcdlink`lcdColor[$pmTempOK];];
    lcdlink`lcdPuts[0,0,StringJoin["T:", Riffle[s1," "]]];
    lcdlink`lcdPuts[0,1,StringJoin["S:", Riffle[s2," "]]];
    (* Include Plot *)
    pmDefinePlotChars@pmPlot@pmPlotImage[data[[1;;20,2]]];
    pmPutPlot[];

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
    t = CreateScheduledTask[pmCheck[file],{time, 20}, 
      "EpilogFunction":>(
        lcdlink`lcdClear[];
        lcdlink`lcdPuts[0,0,"Finished"];)]; 
    StartScheduledTask[t];
    t (* Return the task so it can be stopped *)
    ]

    

 
End[]
EndPackage[]

