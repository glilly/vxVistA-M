VFDPXSN2 ;CFS - VALADATE SnoMed codes ;05/15/2013
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**1**;08 Aug 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;NOTE:
 ;	For future enhancements, this routine can be copied, pasted and renamed.
 ;  Then modification can be made to fit the vxVistA CPRS tab.
 ;
 ;	Other routines that can be copied, pasted and renamed, or looked at for
 ;  examples are:
 ;		PXAIPOVV
 ;		PXAICPTV
 ;		PXAIPEDV
 ;		PXAIXAMV
 ;		PXAIHFV
 ;		PXAIIMMV
 ;		PXAISKV
 ;
 Q
 ;
VAL ;--VALIDATE ENOUGH DATA
 I $G(PXAA("VFDSNO CODE"))']"" D  Q:$G(STOP)
 .S STOP=1
 .S PXAERRF=1
 .S PXADI("DIALOG")=8390001.001  ;Use vxVistA Error Message Dialog
 .S PXAERR(9)="VFDSNO CODE"
 .S PXAERR(11)=""
 .S PXAERR(12)="You must have a valid SnoMed code."
 ;
 I $G(PXAA("USAGE"))]"",$G(PXAA("USAGE"))'["D",$G(PXAA("USAGE"))'["P" D  Q:$G(STOP)
 .S STOP=1
 .S PXAERRF=1
 .S PXADI("DIALOG")=8390001.001
 .S PXAERR(9)="USAGE"
 .S PXAERR(11)=$G(PXAA("USAGE"))
 .S PXAERR(12)="Valid entries for SnoMed Usage are 'D' for Diagnosis or 'P' for Procedure."
 ;
 ;
 Q
VAL04 ;---PROVIDER NARRATIVE
 S STOP=1
 S PXAERRF=1
 S PXADI("DIALOG")=8390001.001  ;Use vxVistA Error Message Dialog
 S PXAERR(9)="NARRATIVE"
 S PXAERR(11)=$G(PXAA("NARRATIVE"))
 S PXAERR(12)="We are unable to retrive a narrative from the PROVIDER NARRATIVE file #9999999.27"
 Q
VAL45 ;---PROVIDER NARRATIVE CATEGORY
 S STOP=0
 S PXAERRF=1
 S PXADI("DIALOG")=8390001.002
 S PXAERR(9)="CATEGORY"
 S PXAERR(11)=$G(PXAA("CATEGORY"))
 S PXAERR(12)="We are unable to retrieve a narrative from the PROVIDER NARRATIVE file #9999999.27"
 Q
