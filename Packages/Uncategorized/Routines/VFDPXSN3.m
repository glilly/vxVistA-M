VFDPXSN3 ;CFS - Gather SnoMed data.  Follow the convention established by PXBGCPT. ;05/15/2013
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**1**;08 Aug 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;NOTE:
 ;	For future enhancements, this routine can be copied, pasted and renamed.
 ;  Then modification can be made to fit the vxVistA CPRS tab.
 ;
 ;	Other routines that can be copied, pasted and renamed, or looked at for
 ;  examples are:
 ;		PXBGPOV
 ;		PXBGCPT
 ;		PXBGPED
 ;		PXBGXAM
 ;		PXBGHF
 ;		PXBGIMM
 ;		PXBGSK
 ;
 Q
 ;
VFDSNO(VISIT,PXBCNT) ;Gather the entries in the V SnoMed file.
 N DA,DIC,DIQ,DR,IEN
 ;
 K ^TMP("PXBU",$J)
 I $D(^VFD(21640.01,"AD",VISIT)) D
 . S IEN=0
 . F  S IEN=$O(^VFD(21640.01,"AD",VISIT,IEN)) Q:IEN'>0  D
 .. S ^TMP("PXBU",$J,"VFDSNO",IEN)=""
 ;
 N ENCDT,ENCPRV,HFCTR,NARR,PATIENT,SNOCTR,TEMP,USAGE,VFDSNO
 I $D(^TMP("PXBU",$J,"VFDSNO")) D
 . S IEN=0
 . F  S IEN=$O(^TMP("PXBU",$J,"VFDSNO",IEN)) Q:IEN'>0  D
 .. K TEMP
 .. S DIC=21640.01,DA=IEN
 .. S DR=".01;.02;.04;.05;1201;1204;811"  ;Set according to vxVistA V file ^DD(21640.01
 .. S DIQ="TEMP(",DIQ(0)="E"
 .. D EN^DIQ1
 .. S VFDSNO=$G(TEMP(21640.01,DA,.01,"E"))
 .. S PATIENT=$G(TEMP(21640.01,DA,.02,"E"))
 .. S NARR=$G(TEMP(21640.01,DA,.04,"E"))
 .. S USAGE=$G(TEMP(21640.01,DA,.05,"E"))
 .. S ENCDT=$G(TEMP(21640.01,DA,1201,"E"))
 .. S ENCPRV=$G(TEMP(21640.01,DA,1204,"E"))
 .. S SNOCTR(VFDSNO,IEN)=VFDSNO_U_PATIENT_U_NARR_U_USAGE_U_ENCDT_U_ENCPRV
 ;
 N PXBC,VFDSNO
 S PXBC=0
 I $D(SNOCTR) D
 . S VFDSNO=""
 . F  S VFDSNO=$O(SNOCTR(VFDSNO)) Q:VFDSNO=""  D
 .. S IEN=0
 .. F  S IEN=$O(SNOCTR(VFDSNO,IEN)) Q:IEN=""  D
 ... S PXBC=PXBC+1
 ... S PXBKY(VFDSNO,IEN)=SNOCTR(VFDSNO,IEN)
 ... S PXBSAM(PXBC)=SNOCTR(VFDSNO,IEN)
 ... S PXBSKY(PXBC,IEN)=SNOCTR(VFDSNO,IEN)
 ;
 K ^TMP("PXBU",$J)
 S PXBCNT=PXBC
 Q
