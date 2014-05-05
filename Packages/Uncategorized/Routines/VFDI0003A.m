VFDI0003A ;DSS/SGM - PRE/POST INSTALL VXCPRS ; 12/13/2012 11:18
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
CK ;;3/23/2012
 ; Line tag check invoked from TEMPCPRS^VFDI0000 to see if it should
 ;  call line POST in this routine.
 ;  Added vxBCMA checks for RPCs since vxBCMA does not have its own VFD
 ;   menu context.
 ;
ENV ; environmental check routine
 Q
 ;
PRE ; pre-install
 Q
 ;
POST ; post-install
 N I,J,X,Y,RPC,SUP,VFDATA,VFDMES,VXS
 ; add RPCs to menu context(s) if they are missing
 ;   DSIC rpcs will not exist in vxVistA OS
 F I=1:1:1 S X=$P($T(@("T"_I)),";",3) D
 . F J=1:1 S Y=$P($T(@("T"_I_"+"_J)),";;",2,99) Q:Y=""  D
 . . S SUP=$P(Y,";")="S",RPC=$P(Y,";")
 . . I RPC'="" S VFDATA(X,RPC)=""
 . . Q
 . Q
 D ADDRPC^VFDI0000(.VFDMES,,,.VFDATA)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
 ; T# line label ;;<name of OPTION to add RPCs to>
 ; T#+offset ;;<<S>;name of RPC to add
 ;     ;S should only be set if this RPC is for supported accounts only
 ; 
T1 ;;PSB GUI CONTEXT - USER
 ;;VFD PT ONE ID
 ;;VFD BCMA EVENT
 ;;VFDC XPAR GET VALUE
 ;;VFDC DDR GETS ENTRY DATA
 ;
