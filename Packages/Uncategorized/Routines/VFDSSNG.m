VFDSSNG ;DSS/WLC - SSN NUMBER GENERATOR AND MRN UPDATE ; 02/15/2011 21:55
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ; ICR#  Supported Description
 ;-----  ----------------------------------------------------------
 ;       $$GET^XPAR
 ;       ^%ZTLOAD
 ;       ^DIE: FILE, UPDATE
 ;       $$GET1^DIQ
 ;       Updating SSN (#.09) field in the PATIENT file (#2)
 ;
 ;Line tag QUE is called from a traditional M cross reference (AVFDSSN)
 ;on the .01 field of the PATIENT file (#2).  Business rules:
 ;  1. Always generate a SSN value if the .09 field (SSN) is null
 ;  2. 3 params control behavior as to whether or not MRN is auto-gen
 ;  3. The ADT filer should never create its own pseudo-SSN
 ;
 Q
QUE ; Queue job
 ; called from the AVFDSSN traditional index on the .01 field of the
 ; Patient file (#2)
 N ZTDESC,ZTDTH,ZTRTN,ZTSAVE,ZTIO
 S ZTDESC="Auto-generate MRN",ZTDTH=$H,ZTIO="",ZTRTN="GEN^VFDSSNG"
 S ZTSAVE("DA")=""
 D ^%ZTLOAD
 Q
 ;
 ; Sub-routine to generate MRN's / psuedo-SSN's.
 ; Variables:
 ;   PSSN = Boolean, 1:existing SSN=gen_ssn; 0:does not equal
 ;    SSN = generated SSN
 ;    MRN = Patient Alternate ID from sub-file 21600 (Field .02)
 ; If PSSN exists:
 ;    If PSSN = SSN, then no update.
 ;    If 'PSSN, then SSN update.
 ;    If MRN, MRN=SSN, then no MRN update performed.
 ;    If MRN,MRN'=SSN, change MRN type to OMRN, add SSN into Alternate
 ;       ID sub-file as type MRN.
 ;
GEN ; taskman entry point from QUE above
SSN ;
 N A,I,X,Y,Z,VFDPARM
 D PARMS Q:VFDPARM("SSN")=-1
 F A=1:1:100 L +^DPT(DA,0):3 I  D GMRN,GSSN Q
 L -^DPT(DA,0)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
GMRN ; generate a medical record number (mrn)
 Q:'VFDPARM("AUTOGEN")
 ; patient may be given a new MRN even though they have an existing one
 ; since the vxVistA-gen MRN should always be the same, then a
 ; replacement MRN should only occur if the patient never had an
 ; auto-gen vxVistA MRN
 N I,J,X,Y,Z,DEF,MRN,STOP
 S (I,J,STOP)=0 M Z=VFDPARM(21600)
 F  S I=$O(Z("MRN",I)) Q:'I  I Z("MRN",I)=VFDPARM("MRN") S STOP=1 Q
 Q:STOP
 ; do not have auto-gen MRN in altid multiple
 ; convert any old MRNs to OMRN types
 N X,Y,VFDA,VFDER,VIEN
 S I=0 F  S I=$O(VFDPARM("MRN",I)) Q:'I  D
 .K X,Y,VFDA,VFDER,VIEN,VFDPARM("MRN",I),VFDPARM("DEF",I)
 .S VIEN=I_","_DA_"," N I,DA
 .I VFDPARM("DEFAULT") S VFDA(2.0216,VIEN,.04)=0
 .S VFDA(2.0216,VIEN,.05)="OMRN"
 .D FILE^DIE(,"VFDA","VFDER")
 .Q
 ; if any altids left marked as default, then reset if necessary
 I VFDPARM("DEFAULT") S I=0 F  S I=$O(VFDPARM("DEF",I)) Q:'I  D
 .K VFDA,VFDER,VIEN,VFDPARM("DEF",I)
 .S VIEN=I_","_DA_","
 .S VFDA(2.0216,VIEN,.04)=0
 .N I,DA D FILE^DIE(,"VFDA","VFDER")
 .Q
 ; now file auto-gen MRN to altid multiple
 K VFDA,VFDER
 S VIEN="+2,"_DA_","
 S VFDA(2.0216,VIEN,.01)=+$$SITE^VASITE
 S VFDA(2.0216,VIEN,.02)=VFDPARM("MRN")
 S VFDA(2.0216,VIEN,.04)=+VFDPARM("DEFAULT")
 S VFDA(2.0216,VIEN,.05)="MRN"
 N DA D UPDATE^DIE(,"VFDA",,"VFDER")
 Q
 ;
GSSN ; generate pseudo-ssn
 ; only generate a pseudo-ssn if the current record does not have a SSN
 ; exception, if auto-file mrn to ssn is true and ssn is not mrn, then
 ;   update SSN
 I VFDPARM("SSN")'="",'VFDPARM("AUTOFILE") Q
 I VFDPARM("SSN")=VFDPARM("MRN") Q
 N VFDA,VFDER,VIEN
 S VIEN=DA_",",VFDA(2,VIEN,.09)=VFDPARM("MRN")
 D FILE^DIE(,"VFDA","VFDER")
 Q
 ;
PARMS ; get kernel parameter values AND auto-gen values
 S VFDPARM("AUTOGEN")=$$GET^XPAR("SYS","VFD AUTO-GENERATE MRN")
 S VFDPARM("AUTOFILE")=$$GET^XPAR("SYS","VFD AUTO-FILE MRN TO SSN")
 S VFDPARM("DEFAULT")=$$GET^XPAR("SYS","VFD AUTO-MRN IS DEFAULT")
 S (VFDPARM("MRN"),VFDPARM("SSN"))=-1
 Q:$G(DA)<1  Q:$G(^DPT(DA,0))=""  S VFDPARM("SSN")=$P(^(0),U,9)
 S VFDPARM("MRN")=$$TZ(DA)
 N A,I S I=0 F  S I=$O(^DPT(DA,21600,I)) Q:'I  S A=^(I,0) D
 .S VFDPARM(21600,I)=A
 .I $P(A,U,5)="MRN" S VFDPARM(21600,"MRN",I)=$P(A,U,2)
 .I $P(A,U,4)=1 S VFDPARM(21600,"DEF",I)=""
 .Q
 Q
 ;
TZ(IEN) ; timezone code used to gen an pseudo-ssn
 ; called from ^VFDSSNC
 ; attempt to address the problem of multiple users using the same
 ; vxVistA database but in fact are different facilities and ones which
 ; span across multiple timezones.  This was tied to the attempt of
 ; changing a process' timezone in Cache whenever a process started UP
 ; up.
 ;
 ; Modified 2/14/2011 by RAC  To check if SSN already exists on three levels
 ;  1st using 800000000+DFN
 ;  2nd using 900000000+DFN
 ;  3rd set SSN to 666000000+DFN
 ; 
 N X,Y,TZ
 S Y=800000000+IEN,X=$O(^DPT("SSN",Y,0)) I 'X Q Y
 S Y=900000000+IEN,X=$O(^DPT("SSN",Y,0)) I 'X Q Y
 S Y=666000000+IEN
 Q Y
 ; use following code on Cache systems
 I $ZV'["Cache" Q Y
 S TZ=$SYSTEM.SYS.TimeZone()
 ; ET=300 (1), CT=360 (2), MT=420 (3), PT=480 (4)
 S X=TZ\60 S:X>9 X=X#10 S:X>4&(X<9) X=X-4 ; map timezone to [0,9]
 Q (8_X)*10000000+IEN
 Q
 ; SGM - lines below deprecated as of 11/22/2010
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
 S SSN="8"_B_$E(100000000+IEN,3,9),(SFLG,MFLG)=0
 ;
SSNCK(VFDSN,VFDUDT,VFDQ,VFDR)  ;
 ; /RAC  2/15/11
 ; Loop through Patient file, if SSN=null find a pseudo SSN that works
 ;
 ; VFDSN - req - Boolean flag indicating which SSNs to update
 ;   0: only assign a pseudo-SSN if the current SSN is null
 ;   1: same as 0 plus if any existing SSNs are a pseudo format but not
 ;      not in the current format, then replace the current SSN with a
 ;      new pseudo-SSN.
 ;
 ; VFDUDT - opt - Boolean flag indicating whether to run in test mode
 ;   or to actually do the update.  Default to 0
 ;   0: test mode, no data changes, but report what it would have done
 ;   1: actually perform any appropriate database updates
 ;
 ; VFDQ - opt - Boolean flag indicating whether to do writes or not
 ;   0: no WRITEs (default value)
 ;   1: write to current device
 ;
 ; VFDR - opt - named array to return findings
 ;   @vfdr@(dfn)=name^current SSN^new SSN
 ;
 Q:'$D(VFDSN)
 S VFDUDT=$G(VFDUDT),VFDQ=$G(VFDQ),VFDR=$G(VFDR)
 N X,X0,Y,CNT,DFN,NAM,NSSN,OSSN
 D MES("L1"),MES("L2")
 S (CNT,DFN)=0
 F  S DFN=$O(^DPT(DFN)) Q:'DFN  S X0=$G(^(DFN,0)) D
 .Q:$P(X0,U)=""  S NAM=$P(X0,U),OSSN=$P(X0,U,9) Q:OSSN'=""
 .S CNT=CNT+1,NSSN=$$TZ(DFN)
 .I VFDR'="" S @VFDR@(DFN)=NAM_U_OSSN_U_NSSN
 .D MES(DFN,NAM,OSSN,NSSN)
 .Q:'VFDUDT
 .N VFDA,VFDER S X=DFN_",",VFDA(2,X,.09)=NSSN
 .D FILE^DIE(,"VFDA","VFDER")
 .Q
 D MES(CNT)
 Q
 ;
MES(X1,X2,X3,X4) ;
 ;;  DFN          NAME                        OLD SSN    NEW SSN
 ;;--------  ------------------------------  ---------  ---------
 ;;No patient records found which had no SSN value
 Q:'VFDQ  N T
 I $G(X2)="" D
 .I X1="L1"!(X1="L2") S T=$P($T(MES+$E(X1,2)),";",3) Q
 .I 'X1 S T=$TR($T(MES+3),";"," ") Q
 .S T=X1_" patient SSNs "_$S('VFDUDT:"would have been",1:"were")_" changed"
 .Q
 E  S T=$J(X1,8)_"  "_X2,$E(T,43)=X3,$E(T,54)=X4
 D MES^XPDUTL(T)
 Q
