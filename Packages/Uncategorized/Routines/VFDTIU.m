VFDTIU ;DSS/SGM - TIU OBJECT FRONT DOOR ; 08/16/2013 17:30
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**6**;16 Aug 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine should be the entry point for all TIU Objects.  To save
 ; space in this routine, any extensive TIU Object documentation will
 ; be in the called routine
 ;
SS(DFN) ;current smoking status
 Q $$SS^VFDTIU1($G(DFN))
 ;
CLABS(DFN,SDATE,EDATE) ;Last 24 hrs critical labs
 Q $$CLABS^VFDTIU1($G(DFN),$G(SDATE),$G(EDATE))
 ;
RLABS(DFN,EDATE) ;LABS - LAST 7 DAYS (EXCLUDE MI & AP)
 Q $$RLABS^VFDTIU1(DFN,EDATE)
