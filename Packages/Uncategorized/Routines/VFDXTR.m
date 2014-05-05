VFDXTR ;DSS/SGM - ROUTINE UTILITY MAIN DRIVER ; 07/28/2011 16:35
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is the main OPTION driver for all routine utilities.
 ;Each line tag is invoked via a MenuMan OPTION.
 ;
 Q
 ;
DEL ; option: VFD IT ROUTINE DELETE
 ;delete selected routines
 G DEL^VFDXTR01
 ;
NUM ; option: VFD IT ROUTINE UPDATE
 ;updated version of VA XTVNUM utility
 ;Date stamp 1st line, update version#, update patch list
 ;insert copyright statement
 G ^VFDXTR02
 ;
SIZE ; option: VFD IT ROUTINE SIZE
 ;display routine size per March 2007 VA Programming SAC
 ;20K total size, 15K executable code size, 5K comments
 ;Any line with a label or starts with " ;;" is counted as executable
 G ^VFDXTRSZ
 ;
SVRES ; option: VFD IT ROUTINE SAVE/RESTORE
 ;save routines to indiviudual HFS files
 ;restored routines from individual HFS files previously saved by this
 D ^VFDXTRS Q
 ;
 ;==============  APPLICATION PROGRAM INTERFACES (APIs)  ==============
 ;>>>>>  ASK FOR METHOD TO GET LIST OF ROUTINES
ASK(VFDR,NOINIT,SOURCE) ;
 ; select routines from routine selector or get from Build file
 Q $$ASK^VFDXTRU1
 ;
 ;>>>>>  ASK FOR FILENAME
ASKFILE() ;
 ;  file not verified as to whether it exists or not
 ;  return user input or (null or -n if problems)
 Q $$DIR^VFDXTR09(4)
 ;
 ;>>>>>  ASK FOR PATH OR DIRECTORY
ASKPATH(VPATH) ;
 ; syntax of path is not verified
 ; VPATH - opt - default path
 ; return user input or <null>
 Q $$ASKPATH^VFDXTRU1
