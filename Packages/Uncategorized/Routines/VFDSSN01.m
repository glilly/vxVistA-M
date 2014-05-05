VFDSSN01 ;DSS/SGM - CONTINUATION OF VFDSSN ; 02/02/2012 14:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; this routine should only be invoked via the VFDSSN routine
 ;ICR #  SUPPORTED DESCRIPTION
 ;-----  ----------------------------------------------------
 ;       ^DIE: FILE, UPDATE
 ;       $$SITE^VASITE
 ;       $$GET^XPAR
 ;       Direct global read
 ;         ^DPT(dfn,0), ^DPT(dfn,21600)
 ;
 ;DESCRIPTION OF KEY LOCAL VARIABLES
 ;----------------------------------
 ; VFDPARM("AUTOGEN") - Boolean to determine to auto-generate a MRN
 ; VFDPARM("AUTOFILE")- Boolean to determine whether to file MRN to SSN
 ; VFDPARM("DEFAULT") - Boolean whether auto-gen MRN is to be default
 ; VFDPARM("GEN")     - generated MRN (used as pseudoSSN) if needed
 ; VFDPARM("SSN")     - current SSN value
 ; VFDPARM("MRN")     - current AltID marked as MRN
 ; VFDPARM("MRN",0)   - current AltID marked as default
 ; VFDPARM("MRN",MRN,I) = Boolean default flag
 ;
 ;-------  Called From New Style AVFDIDX Index on Patient File  -------
XREF ;
 ; do not change SSN if it exists
 N A,I,X,Y,Z,DFN,VFDPARM
 S DFN=$G(DA) N DA Q:'$$IEN(DFN)
 ; get current values, see vfdparm() above
 ; vfdparm("gen") is a generated MRN/SSN if needed
 D CUR(DFN,.VFDPARM)
 ; generate a MRN and/or pseudo-SSN if necessary
 F A=1:1:100 L +^DPT(DFN,0):3 I  D MRN(DFN),FSSN(DFN) Q
 L -^DPT(DFN,0)
 Q
 ;
 ;=======================  PRIVATE SUBROUTINES  =======================
CUR(DFN,VFDPARM) ;  Get Current MRN and SSN
 ; IEN - opt - file 2 ien (if not passed assume DA)
 ; Return: VFDPARM() - see above
 N A,I,T,X,Y,DEF,MRN,MRNX
 S DFN=$G(DFN) S:DFN="" DFN=$G(DA) Q:'$$IEN(DFN)
 ;  Get Kernel Parameter Values
 S VFDPARM("AUTOGEN")=$$GETXPAR("VFD AUTO-GENERATE MRN")
 S VFDPARM("AUTOFILE")=$$GETXPAR("VFD AUTO-FILE MRN TO SSN")
 S VFDPARM("DEFAULT")=$$GETXPAR("VFD AUTO-MRN IS DEFAULT")
 F T="GEN","MRN","SSN" S VFDPARM(T)=""
 S VFDPARM("MRN",0)=""
 S VFDPARM("SSN")=$$CURSSN(DFN) ; current SSN
 S VFDPARM("GEN")=$$GSSN(DFN) ;         gen a MRN (pesudo-SSN)
 ; get current MRNs
 S (I,T,Y,DEF(0),MRN(0))=0
 F  S I=$O(^DPT(DFN,21600,I)) Q:'I  S A=^(I,0) D
 .S MRNX=$P(A,U,2),DEF=$P(A,U,4) Q:MRNX=""
 .I DEF S DEF(0)=1+DEF(0),DEF(MRNX)=I
 .I $P(A,U,5)="MRN" S MRN(0)=1+MRN(0),MRN(MRNX,I)=DEF
 .Q
 I DEF(0)=1!(MRN(0)=1) S VFDPARM("MRN",0)=$O(DEF(0))
 I MRN(0)=1 S VFDPARM("MRN")=$O(MRN(0))
 I $G(MRN(0))>1 M VFDPARM("MRN")=MRN
 Q
 ;
CURSSN(DFN) ; return current SSN value
 N X,Y S Y="" S:$G(DFN)>0 Y=$P(^DPT(DFN,0),U,9) Q Y
 ;
FILE(VFDA) ; FILE^DIE
 ; .IN = FDA array
 ; return 1 if successful, else -1^msg
 N X,Y,DIERR,VFDER
 I $O(VFDA(0))="" Q "-1^No input values received"
 D FILE^DIE(,"VFDA","VFDER")
 S X=1 I $D(DIERR) S X="-1^"_$$MSG^VFDCFM("VE",,,,"VFDER")
 Q X
 ;
GETXPAR(NM) Q $$GET^XPAR("SYS",NM)
 ;
FSSN(DFN,VAL,OVER) ; File Pseudo-SSN to Patient's Record
 ;  DFN - req - file 2 ien
 ; OVER - opt - Boolean, if 1 file SSN, ignore business rules
 ;  VAL - opt - new SSN to file, if not passed use VFDPARM("GEN")
 ; Business Rules:
 ; 1. If VAL="" & VFDPARM("GEN")="" Q
 ; 2. If 'OVER & VFDPARM("SSN")'="" & 'VFDPARM("AUTOFILE") Q
 ; 3. If VFDPARM("SSN")=VAL Q
 ;
 N X,Y,Z,AUTO,DA,GEN,SSN,VFDA
 I '$$IEN($G(DFN)) Q
 S:$G(VAL)="" VAL=$G(VFDPARM("GEN")) I VAL="" Q
 S OVER=$G(OVER),AUTO=$G(VFDPARM("AUTOFILE"))
 S SSN=$G(VFDPARM("SSN")) I SSN=VAL Q
 ; val is valued, ssn may or may not be null, ssn'=val
 I 'OVER,'AUTO,SSN'="" Q
 S VFDA(2,DFN_",",.09)=VAL
 S X=$$FILE(.VFDA)
 Q
 ;
GSSN(DFN) ; Generate A Pseudo-SSN (aka MRN)
 ; Pseudo-SSN is an invalid HHS SSN - number+DFN
 ; 1st - 800000000+DFN; 2nd - 900000000+DFN; 3rd - 666000000+DFN
 N IX,Y,SSN,TZ
 S DFN=$G(DFN) S:'DFN DFN=$G(DA) I DFN'>0 Q ""
 S SSN="" F I=800000000,900000000,666000000 D  Q:SSN
 .S Y=I+DFN,X=$O(^DPT("SSN",Y,0)) I X=DFN!'X S SSN=Y
 .Q
 Q SSN
 ;
IEN(DFN) N T S T=0 S:+$G(DFN) T=(^DPT(DFN,0)'="") Q T
 ; 
ISGEN(DFN,VAL) ; is a MRN or SSN value a vxVistA generated value?
 ; extrinsic function returns null if invalid input
 ; 0 if val is not a vxvista gen'd value and does not match 9N
 ; 1 if val is a vxvista gen'd mrn/ssn
 ; 2 if val?9N.1U and val is not a vxvista gen'd mrn/ssn
 N I,X,Y,Z,Y
 I $G(DFN)<1!($G(VAL)="") Q ""
 S Y=0 F I=800000000,900000000,666000000 I VAL=(I+DFN) S Y=1 Q
 I 'Y,VAL?9N.1U S Y=2
 Q Y
 ;
MRN(DFN) ; Generate a Medical Record Number (MRN)
 ; DFN - req - file 2 ien
 N I,J,X,Y,Z,DA,DEF,DEFAUTO,GEN,MRN,MRNX,VFDA
 Q:'$G(VFDPARM("AUTOGEN"))  Q:'$$IEN($G(DFN))
 S GEN=$G(VFDPARM("GEN")) ; gen'd MRN, may be current also
 S MRN=$G(VFDPARM("MRN")) ; current mrn
 S DEF=$G(VFDPARM("MRN",0)) ; current default MRN
 S DEFAUTO=$G(VFDPARM("DEFAULT")) ; gen'd is to be default also
 I GEN'="",GEN=MRN Q
 I MRN'="",$$ISGEN(DFN,MRN) Q  ; current is gen'd vxvista one
 I GEN="" Q  ; should not happen, did not gen a new MRN
 ;
 ; there should be one and only one MRN, convert existing to OMRN
 S MRNX=0 F  S MRNX=$O(VFDPARM("MRN",MRNX)) Q:MRNX=""  S I=0 D
 . F  S I=$O(VFDPARM("MRN",MRNX,I)) Q:'I  D
 . . S Y=I_","_DFN_","
 . . S VFDA(2.0216,Y,.05)="OMRN"
 . . S:DEFAUTO VFDA(2.0216,Y,.04)=0
 . . Q
 . Q
 I $D(VFDA) S X=$$FILE(.VFDA)
 ; add new MRN to AltID multiple
 K VFDA S Y="+1,"_DFN_","
 S VFDA(2.0216,Y,.01)=+$$SITE^VASITE
 S VFDA(2.0216,Y,.02)=GEN
 S:DEFAUTO VFDA(2.0216,Y,.04)=1
 S VFDA(2.0216,Y,.05)="MRN"
 D UPD(.VFDA)
 Q
 ;
UPD(VFDA) ; UPDATE^DIE
 ; .VFDA - req - standard Fileman FDA array
 N I,J,X,Y,Z,DIERR,VFDER
 I $O(VFDA(0))'="" D UPDATE^DIE(,"VFDA",,"VFDER")
 Q
 ;----------------------  OLD DECPRECATED CODE  -----------------------
 ; use following code on Cache systems
 I $ZV'["Cache" Q Y
 S TZ=$SYSTEM.SYS.TimeZone()
 ; ET=300 (1), CT=360 (2), MT=420 (3), PT=480 (4)
 S X=TZ\60 S:X>9 X=X#10 S:X>4&(X<9) X=X-4 ; map timezone to [0,9]
 Q (8_X)*10000000+DA
 Q
 ;
TXOLD ; SGM - lines below deprecated as of 11/22/2010
 ; Code inactivated as part of Open Source VFD VXVISTA UPDATE 2010.1.1
 ; Use current namespace to calculate second digit of number (1st digit
 ; always 8), followed by the DFN padded with zeroes out to 7 digits.
 ; i.e. 840000010 for DFN = 10 on the east coast.
 ; 6th char of Nmsp  Time Zone  SSN digit indicator (piece 2)
 ; ----------------  ---------  -------------------
 ;       P            Pacific        1
 ;       M            Mountain       2
 ;       C            Central        3
 ;       E            Eastern        4
 ; DSS/LM - Default MRN timezone from ^%ZVFD("MRN TZ")
 S A=$E($$CUR^VFDVMOS,7),VFDTZ=$G(^%ZVFD("MRN TZ"))
 I VFDTZ]"",'("^P^M^C^E^"[(U_A_U)) S A=VFDTZ Q:A=""
 ; DSS/LM - End modification
 I "PMCE"'[A Q  ; time-zone not defined in name space
 S B=$F("PMCE",A)-1
 S SSN="8"_B_$E(100000000+DA,3,9),(SFLG,MFLG)=0
 Q
