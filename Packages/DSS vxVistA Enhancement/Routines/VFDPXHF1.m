VFDPXHF1 ;DSS/WLC - HEALTH FACTOR RPC ROUTINES ; May 23, 2011 14:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
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
 ;  DFN - req - pointer to the patient file
 ; NAME - req - name of the Health Factor (NO KNOWN XXXXX)
 ;VFDHF - return string
 ;        -1 or -1^message
 ;        0 - HF not assigned to patient AND no active XXXXX
 ;        1 - HF assigned to patient AND no active XXXXX
 ;        2 - HF assigned to patient AND active XXXXX
 ;               or no HF assigned AND active XXXXX
 ;   where XXXXX is medication, problem
 N TEXT,IDESC,HFIEN,J,X,Y,VFD,VFDA,VFDH,VFDRRET,VHFIEN,VISIT
 N I,J,X,Y,Z,TYPE,VFD,VFDA,VFDH,VFDM
 S NAME=$G(NAME) I NAME']"" D ERR(1) Q
 S DFN=$G(DFN) I 'DFN D ERR(2) Q
 I '$D(^DPT(DFN)) D ERR(3) Q
 S HFIEN=$$FIND1^DIC(9999999.64,,,NAME) I 'HFIEN D ERR(4) Q
 S (VFD,VFDA,VFDH,VFDHF,VFDM)=0
 S TYPE=$P(NAME," ",3)
 ; 4/24/2011 - only support no known xxxxx types
 I TYPE="MEDICATION" S TYPE="MED"
 I TYPE="PROBLEM" S TYPE="PR"
 I "^MED^PR^"'[(U_TYPE_U) D ERR(5) Q
 ; if patient has active entries, set VFD(key)=0 or 1
 I TYPE="MED" S VFD("MED")=$$GETPS
 I TYPE="PR" S VFD("PR")=$$GETPROB
 S VFD("HF")=$$HASFAC
 ; check for no HF and no active
 I 'VFD("HF"),'VFD(TYPE) S VFDHF=0 Q
 ; check for HF exists but no active
 I 'VFD(TYPE) S VFDHF=1 Q
 ; at this point we have active and may or may not have HF, return 2 in either case
 ; if no HF then quit, otherwise delete HF
 S VFDHF=2 Q:'VFD("HF") 
 ; delete no known HF since have active and HF
 D DELHF
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ERR(A) ;
 ;;No Health Factor name received
 ;;No patient received
 ;; is not a valid patient record
 ;; health factor not defined
 ;; type of health factor is not supported
 ;;
 N T S VFDHF=-1,A=$G(A) I A<1!(A>3)!(A'?1N) Q
 S T=$P($T(ERR+A),";",3)
 I A>2 S T=$S(A=3:DFN,1:NAME_T)
 S VFDHF="-1^"_T
 Q
 ;
GETPROB()  ; get active problems
 N ORPROB,ORPROBIX,ORPRCNT,TYPE,VFDG
 I '$G(ORDATE) N ORDATE S ORDATE=DT
 S VFDG=$NA(^TMP("IB",$J,"INTERFACES","GMP SELECT PATIENT ACTIVE PROBLEMS"))
 K @VFDG
 D DSELECT^GMPLENFM  ;DBIA 1365
 S (ORPRCNT,ORPROBIX)=0
 F  S ORPROBIX=$O(@VFDG@(ORPROBIX)) Q:'ORPROBIX  D
 .S ORPROB=$P(@VFDG@(ORPROBIX),U,2,3)
 .I $E(ORPROB,1)="$" S ORPROB=$E(ORPROB,2,255)
 .I '$D(ORPROB(ORPROB)) D
 ..S ORPROB(ORPROB)="",ORPRCNT=ORPRCNT+1
 ..S $P(@VFDG@(ORPROBIX),U,2,3)=ORPROB
 ..Q
 .E  K @VFDG@(ORPROBIX)
 .Q
 Q ORPRCNT>0
 ;
GETPS()  ; get active medications
 N TYPE D ACTIVE^ORWPS(.VFDRRET,DFN)
 Q $D(VFDRRET(1))>0
 ;
HASFAC()  ; Does patient have the Health Factor assigned to a Visit?
 Q $S($D(^PXRMINDX(9000010.23,"PI",DFN,HFIEN)):1,1:0)
 ;
DELHF  ; Delete Health Factor from V HEALTH FACTORS (#9000010.23) file.
 N I,J,DA,DATA2,DIK,ERR,ERRD,VHFIEN,VISIT
 S VFDG=$NA(^AUPNVHF("AA",DFN,HFIEN)),VSTOP=$E(VFDG,1,$L(VFDG)-1)_","
 F  S VFDG=$Q(@VFDG) Q:VFDG=""  Q:VFDG'[VSTOP  D
 .N LP,LP1,VISIT
 .S VHFIEN=$QS(VFDG,5),VISIT=$P(^AUPNVHF(VHFIEN,0),U,3)
 .S J=$$DELVFILE^PXAPI("HF",VISIT)
 .Q
 Q
