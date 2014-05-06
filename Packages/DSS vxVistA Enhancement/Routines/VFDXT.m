VFDXT ;DSS/SGM - MAIN DRIVER FOR IT UTILITIES ; 06/20/2011 17:40
 ;;2011.1;DSS,INC VXVISTA OPEN SOURCE;;20 May 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;=============================  OPTIONS  =============================
 ;
DEL ; option: VFD IT ROUTINE DELETE
 ; delete selected routines
 G DEL^VFDXTR01
 ;
BROKSTRT ; option: VFD XWB START LISTENER
 ; manually start the new style Broker not using Taskman
 G STRT^VFDXWB
 ;
BROKSTOP ; option: VFD XWB STOP LISTENER
 ; manually stop the new style Broker not using Taskman
 G STOP^VFDXWB
 ;
FINDD ; option: VFD IT DD-NAME-NUMBERSPACE
 ; gets fields and namespaces from the data dictionary.
 G EN^VFDXTDD1
 ;
FOIAZ ; option: VFD IT INIT CACHE.DAT
 ; initialize a Cache.dat file for baseline VistA functions
 G ^VFDVFOIZ
 ;
FOIAZC ; option: VFD IT CLONE A CACHE.DAT FILE
 ; Clone a Cache.dat File
 G CLONE^VFDVFOIZ
 ;
NUM ; option: VFD IT ROUTINE UPDATE
 ; updated version of VA XTVNUM utility
 ; Date stamp 1st line, update version#, update patch list
 ; insert copyright statement
 G ^VFDXTR02
 ;
SIZE ; option: VFD IT ROUTINE SIZE
 ; display routine size per March 2007 VA Programming SAC
 ; 20K total size, 15K executable code size, 5K comments
 ; Any line with a label or starts with " ;;" is counted as executable
 G SIZEOLD^VFDXTR01
 ;
SVRES ; option: VFD IT ROUTINE SAVE/RESTORE
 ; save routines to indiviudual HFS files
 ; restored routines from individual HFS files previously saved by this
 D ^VFDXTRS Q
 ;
 ;========================  REMOTE PROCEDURES  ========================
 ;
 ;=============  APPLICATION PROGRAMMER INTERFACES (APIs)  ============
 ;
MEDIAN(VFDAR) ; Return median value for a list of numbers
 Q:$G(VFDAR)="" ""  Q:$O(@VFDAR@(""))="" ""  Q $$MEDIAN^VFDXTMTH(VFDAR)
