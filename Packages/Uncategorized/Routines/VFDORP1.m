VFDORP1 ;DSS/LM - Free Text Prescription Print ; 3/18/2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
ONE(VFDRSLT,VFDORD) ;[Private] Process one ORDER
 ;
 ; VFDRSLT=$NAME of array to APPEND Rx Print data
 ; VFDORD=ORDER# (File 100 IEN)
 ; 
 I $G(VFDORD),$$ISFTRX(VFDORD) N VFDDATA
 E  Q
 ; PATIENT LOCATION is a variable pointer in the ORDER file.
 N VFDPL S VFDPL=$$GET1^DIQ(100,+VFDORD,6,"I") Q:'VFDPL  ;PATIENT LOCATION
 N VFDHL S VFDHL=$S($P(VFDPL,";",2)="SC(":+VFDPL,1:"") Q:'VFDHL  ;HOSP LOCATION
 N VFDAD S VFDAD=$$ADR^VFDADR(44,VFDHL) Q:VFDAD<0  ;VFD ADDRESS IEN
 S @VFDRSLT@(1)="$START FREE TEXT RX"
 D VFDADR($NA(VFDDATA),VFDAD) ;Populate (site) address fields
 D APPEND($NA(@VFDRSLT),$NA(VFDDATA)) K VFDDATA
 ; OBJECT OF ORDER is a variable pointer in the ORDER file.
 N VFDOBJ S VFDOBJ=$$GET1^DIQ(100,+VFDORD,.02,"I") Q:$P(VFDOBJ,";",2)'="DPT("
 N VFDFN S VFDFN=+VFDOBJ ;PATIENT IEN=DFN
 D PATDEM($NA(VFDDATA),VFDFN) ;Patient Demographics
 D APPEND($NA(@VFDRSLT),$NA(VFDDATA)) K VFDDATA
 ; PROVIDER is ORDER field #1 CURRENT AGENT/PROVIDER
 N VFDPRV S VFDPRV=$$GET1^DIQ(100,+VFDORD,1,"I")
 D PRVDAT($NA(VFDDATA),VFDPRV) ;Provider Data
 D APPEND($NA(@VFDRSLT),$NA(VFDDATA)) K VFDDATA
 D SUPROV($NA(VFDDATA),VFDPRV,VFDHL) ;DPS# and Associated Provider data
 D APPEND($NA(@VFDRSLT),$NA(VFDDATA)) K VFDDATA
 ; Free Text Prescription
 S @VFDRSLT@($O(@VFDRSLT@(""),-1)+1)="$START TEXT"
 D RSPTXT($NA(VFDDATA),VFDORD)
 D APPEND($NA(@VFDRSLT),$NA(VFDDATA)) K VFDDATA
 S @VFDRSLT@($O(@VFDRSLT@(""),-1)+1)="$END TEXT"
 ; Order Diagnoses
 D ODX($NA(VFDDATA),VFDORD)
 D APPEND($NA(@VFDRSLT),$NA(VFDDATA)) K VFDDATA
 S @VFDRSLT@($O(@VFDRSLT@(""),-1)+1)="$END FREE TEXT RX"
 Q
ISFTRX(VFDA) ;[Private] Return '1' if an only if ORDER IEN=VFDA
 ;                      is a Free Text Prescription. Else return '0'
 ;                      
 I $G(VFDA) N VFDODG,VFDOOD,VFDNDG,VFDNOD ;Old, New .. Display Group, Order Dialog
 E  Q 0
 S VFDODG=$$FIND1^DIC(100.98,,"X","NURSING","B")
 S VFDOOD=$$FIND1^DIC(101.41,,"X","OR GXTEXT WORD PROCESSING ORDER","AB")_";ORD(101.41,"
 S VFDNDG=$$FIND1^DIC(100.98,,"X","FREE TEXT PRESCRIPTION","B")
 S VFDNOD=$$FIND1^DIC(101.41,,"X","ORZ GXTEXT WORD PROCESSING","AB")_";ORD(101.41,"
 ;
 N VFDDG,VFDOD,VFDZ ;Current ORDER Display Group and Order Dialog
 S VFDZ=$G(^OR(100,VFDA,0))
 I $P(VFDZ,U,5)=VFDNOD,$P(VFDZ,U,11)=VFDNDG Q 1 ;NEW type
 ;
 I $P(VFDZ,U,5)=VFDOOD,$P(VFDZ,U,11)=VFDODG ;Possible OLD type
 E  Q 0 ;Not a Free Text Prescription Order
 ;
 N VFDI,VFDY S (VFDI,VFDY)=0 ;Test RESPONSES(m),TEXT to confirm if OLD type
 F  S VFDI=$O(^OR(100,VFDA,4.5,VFDI)) Q:'VFDI!VFDY  D
 .S VFDY=($P($G(^OR(100,VFDA,4.5,VFDI,2,1,0)),"~",2)="99_ZZGenericFreeTextOutpatientPharmOrder")
 .Q
 Q VFDY
 ;
VFDADR(VFDRSLT,VFDAIEN) ;[Private] VFD ADDRESS fields
 ;
 ; VFDRSLT=[Required] $NAME of return data array
 ; VFDAIEN=[Required] VFD ADDRESS file IEN
 ;
 I $L($G(VFDRSLT)),$G(VFDAIEN) N VFDGETS
 E  Q
 D GETS^DIQ(21612,VFDAIEN,"*",,$NA(VFDGETS))
 N VFDR S VFDR=$NA(VFDGETS(21612,VFDAIEN_",")) D
 .S @VFDRSLT@("CNAME")=@VFDR@(.01)
 .S @VFDRSLT@("CPNAME")=@VFDR@(.03) ;1.0*2 (T1)
 .S @VFDRSLT@("CADD1")=@VFDR@(.111)
 .S @VFDRSLT@("CADD2")=@VFDR@(.112)
 .S @VFDRSLT@("CADD3")=@VFDR@(.113)
 .S @VFDRSLT@("CPHONE #")=@VFDR@(.131) ;PHONE (1)
 .S @VFDRSLT@("CPHONE1 #")=@VFDR@(.131) ;PHONE (1) ;1.8*2 (T1)
 .S @VFDRSLT@("CPHONE2 #")=@VFDR@(.132) ;PHONE (2) ;1.8*2 (T1)
 .S @VFDRSLT@("CPHONE3 #")=@VFDR@(.133) ;PHONE (3) ;1.8*2 (T1)
 .S @VFDRSLT@("CZIP")=@VFDR@(.116)
 .S @VFDRSLT@("CCITY")=@VFDR@(.114)
 .S @VFDRSLT@("CSTATE")=@VFDR@(.115)
 .Q
 Q
PATDEM(VFDRSLT,DFN) ;[Private] Patient Demographic fields
 ; [Based on SGM modification to ^VFDPOAF.  See also PAT^VFDPSUTL]
 ; 
 ; VFDRSLT=[Required] $NAME of return data array
 ; DFN=[Required] PATIENT file IEN
 ;
 I $L($G(VFDRSLT)),$G(DFN) N X,Y,VFDTMP
 E  Q
 D DEM^VFDCDPT(.VFDTMP,DFN)
 S @VFDRSLT@("PAT NAME")=VFDTMP(1)
 S @VFDRSLT@("PAT AD L1")=VFDTMP(11)
 S @VFDRSLT@("PAT AD L2")=VFDTMP(12)
 S @VFDRSLT@("PAT AD L3")=VFDTMP(13)
 S @VFDRSLT@("PAT AD CITY")=VFDTMP(14)
 S X=$P(VFDTMP(15),U,3) S:X]"" @VFDRSLT@("PAT AD STATE")=X
 S X=$P(VFDTMP(16),U,2) S:X]"" @VFDRSLT@("PAT AD ZIP")=X
 S @VFDRSLT@("PAT DOB")=$P(VFDTMP(3),";",2)
 S @VFDRSLT@("PHONE #")=VFDTMP(18)
 Q
PRVDAT(VFDRSLT,VFDDUZ) ;[Private] Provider Data (Licenses, etc.)
 ; 
 ; VFDRSLT=[Required] $NAME of return data array
 ; VFDDUZ=[Required] NEW PERSON file IEN
 ; VFDHLOC=[Required] HOSPITAL LOCATION IEN
 ;
 I $L($G(VFDRSLT)),$G(VFDDUZ)
 E  Q
 S @VFDRSLT@("DEA #")=$$DEA^VFDPSUTL(VFDDUZ)
 S @VFDRSLT@("NPI #")=$$NPI^VFDPSUTL(VFDDUZ)
 S @VFDRSLT@("PSBN")=$$GET1^DIQ(200,VFDDUZ_",",20.2)
 S @VFDRSLT@("PSBT")=$$GET1^DIQ(200,VFDDUZ_",",20.3)
 ; If no signature block name, return formatted #.01 name
 I '$L(@VFDRSLT@("PSBN")) S @VFDRSLT@("PROV NAME")=$$NAMEFMT^VFDPSUTL(VFDDUZ)
 Q
SUPROV(VFDRSLT,VFDDUZ,VFDHLOC) ;[Private] Supervisory Provider Data
 ; Based on SUPROV^VFDPOAF1
 ; 
 ; VFDRSLT=[Required] $NAME of return data array
 ; VFDDUZ=[Required] NEW PERSON file IEN
 ; VFDHLOC=[Required] HOSPITAL LOCATION IEN
 ;
 ; 
 ; KEYWORD      DATA
 ; 
 ; AP nn DEA #  Associated provider nn DEA #
 ; AP nn NPI #  Associated provider nn NPI #
 ; AP nn DPS #  Associated provider nn DPS #
 ; AP nn SBN    Associated provider nn signature block name
 ; AP nn SBT    Associated provider nn signature block title
 ; AP nn NAME   Associated provider nn formatted name (iff SBN not available)
 ; 
 I $L($G(VFDRSLT)),$G(VFDDUZ),$G(VFDHLOC) N VFDXPAR
 E  Q
 D  ;Compute VFD CPRS RX PRINT ATTENDING parameter value by precedence
 .S VFDXPAR=$$GET^XPAR("USR.`"_VFDDUZ,"VFD CPRS RX PRINT ATTENDING") Q:VFDXPAR]""
 .N VFDINST
 .S VFDXPAR=$$GET^XPAR("LOC.`"_VFDHLOC,"VFD CPRS RX PRINT ATTENDING") Q:VFDXPAR]""
 .S VFDINST=$$GET1^DIQ(44,VFDHLOC_",",3,"I") Q:'VFDINST
 .S VFDXPAR=$$GET^XPAR("DIV.`"_VFDINST,"VFD CPRS RX PRINT ATTENDING")
 .Q
 ;
 S @VFDRSLT@("PRT ATT")=VFDXPAR
 N VFDA,VFDI,VFDJ,VFDK,VFDLST,VFDZ
 ; DPS number of prescribing provider
 D ID^VFDDUZ(.VFDLST,VFDDUZ)
 F VFDJ=1:1 Q:'$D(VFDLST(VFDJ))!$D(@VFDRSLT@("DPS #"))  D
 .I VFDLST(VFDJ)?1"DPS".E S @VFDRSLT@("DPS #")=$P(VFDLST(VFDJ),U,2)
 .Q
 ; Associated Provider
 S (VFDI,VFDK)=0 F  S VFDI=$O(^VA(200,VFDDUZ,21601,VFDI)) Q:'VFDI  D
 .S VFDZ=$G(^(VFDI,0)) Q:'VFDZ!'$P(VFDZ,U,2)
 .K VFDLST D ID^VFDDUZ(.VFDLST,+VFDZ) Q:'$D(VFDLST)
 .Q:$G(VFDLST(1))<0  S VFDK=VFDK+1,VFDA="AP "_VFDK_" "
 .F VFDJ=1:1 Q:'$D(VFDLST(VFDJ))  D
 ..S @VFDRSLT@(VFDA_$P(VFDLST(VFDJ),U)_" #")=$P(VFDLST(VFDJ),U,2)
 ..Q
 .S @VFDRSLT@(VFDA_"SBN")=$$GET1^DIQ(200,+VFDZ,20.2)
 .S @VFDRSLT@(VFDA_"SBT")=$$GET1^DIQ(200,+VFDZ,20.3)
 .I '$L(@VFDRSLT@(VFDA_"SBN")) S @VFDRSLT@(VFDA_"NAME")=$$NAMEFMT^VFDPSUTL(+VFDZ)
 .Q
 Q
RSPTXT(VFDRSLT,VFDOIEN) ;[Private] RESPONSE,TEXT (Free Text Prescription)
 ;
 ; VFDRSLT=[Required] $NAME of return data array
 ; VFDOIEN=[Required] ORDER file IEN
 ;
 I $L($G(VFDRSLT)),$G(VFDOIEN) N VFDGETS
 E  Q
 D GETS^DIQ(100,VFDOIEN,"4.5*",,$NA(VFDGETS))
 N VFDIENS,VFDJ,VFDR S VFDR=$NA(VFDGETS(100.045))
 S VFDIENS="" F  S VFDIENS=$O(@VFDR@(VFDIENS)) Q:'VFDIENS  D
 .S VFDJ=0 F  S VFDJ=$O(@VFDR@(VFDIENS,2,VFDJ)) Q:'VFDJ  D
 ..S @VFDRSLT@($O(@VFDRSLT@(""),-1)+1)=@VFDR@(VFDIENS,2,VFDJ)
 ..Q
 .Q
 Q
ODX(VFDRSLT,VFDOIEN) ;[Private] ORDER diagnoses
 ;
 ; VFDRSLT=[Required] $NAME of return data array
 ; VFDOIEN=[Required] ORDER file IEN
 ;
 I $L($G(VFDRSLT)),$G(VFDOIEN) N VFDGETS
 E  Q
 D GETS^DIQ(100,VFDOIEN,"5.1*",,"VFDGETS")
 N VFDJ,VFDR,VFDX S VFDR=$NA(VFDGETS(100.051))
 S VFDIENS="" F VFDJ=1:1 S VFDIENS=$O(@VFDR@(VFDIENS)) Q:'VFDIENS  D
 .S VFDX=@VFDR@(VFDIENS,.01) ;Dx description
 .S @VFDRSLT@("DIAGNOSIS "_VFDJ)=VFDX_U_VFDGETS(100.051,VFDIENS,1)
 .I $L(VFDX) S $P(@VFDRSLT@("DIAGNOSIS "_VFDJ),U,4)=$P($$ICD9^VFDCDRG(,VFDX,,,,1),U,4)
 .Q
 Q
APPEND(VFDOUT,VFDINP) ;Append data to result in KEYWORD^VALUE format
 ;
 ; VFDOUT=[Required] $NAME of return data array
 ; VFDINP=[Required] $NAME of input data array
 ;
 I $L($G(VFDOUT)),$L($G(VFDINP)) N VFDI,VFDX S VFDI=+$O(@VFDOUT@(""),-1)
 E  Q
 S VFDX="" F  S VFDX=$O(@VFDINP@(VFDX)) Q:VFDX=""  D
 .S VFDI=VFDI+1,@VFDOUT@(VFDI)=VFDX_"^"_@VFDINP@(VFDX)
 .Q
 Q
