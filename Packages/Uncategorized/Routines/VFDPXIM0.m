VFDPXIM0 ;DSS/WLC - MAIN ENTRY TO VFDPXIM ROUTINES ;04/19/2011 9:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine will be the main entry point into all of the VFDPXIM*
 ;routines.  Starting Mar 1, 2006 all new DSS applications should only
 ;call line labels in this routine.  As this routine will potentially
 ;have many entry points, detailed documentation for entry point will
 ;be in the VFDPXIM* routine that is invoked.
 ;
 ;All Integration Agreements for VFDPXIM*
 ;DBIA#  Supported Reference
 ;-----  ----------------------------------------------------
 ;
GETORD(VFDIM,DFN)  ;  RPC:  VFD PXIM GET IMM ORDERS
 D GETORD^VFDPXIM1(.VFDIM,DFN)
 Q
 ;
GETLOTS(VFDIM,ORN)  ; RPC:  VFD PXIM GET LOTS
 D GETLOTS^VFDPXIM1(.VFDIM,ORN)
 Q
 ;
GETIMM(VFDIM)  ; RPC:  VFD PXIM GET IMMUN
 D GETIMM^VFDPXIM1(.VFDIM)
 Q
 ;
STORLOT(VFDIM,VFDRAY) ;RPC:  VFD PXIM STORE LOT
 D STORLOT^VFDPXIM1(.VFDIM,VFDRAY)
 Q
 ;
ADMIN(VFDIM,VFDRAY) ;RPC:  VFD PXIM ADMIN
 D ADMIN^VFDPXIM2(.VFDIM,VFDRAY)
 Q
