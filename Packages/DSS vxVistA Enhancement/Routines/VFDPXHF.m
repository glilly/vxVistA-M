VFDPXHF ;DSS/WLC - HEALTH FACTOR RPC ROUTINES ;24 Mar 2011 17:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine will be the main entry point into all of the VFDPXHF*
 ;routines.  Starting Mar 1, 2006 all new DSS applications should only
 ;call line labels in this routine.  As this routine will potentially
 ;have many entry points, detailed documentation for entry point will
 ;be in the VFDPXIM* routine that is invoked.
 ;
 ;All Integration Agreements for VFDPXIM*
 ;DBIA#  Supported Reference
 ;-----  ----------------------------------------------------
 ;
 ;1889-F ENCEVENT^PXAPI (Apply for Controlled Subscription)
 ;       FIND1^DIC
 ;       ACTIVE^ORWPCE
 ;       ACTIVE^ORWPS
 ;
 Q
 ;
RETVAL(VFDHF,DFN,NAME)  ; RPC:  VFD PXHF GET VAL
 D RETVAL^VFDPXHF1(.VFDHF,DFN,NAME)
 Q
 ;
