VFDPOAF1 ;DSS/WLC;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ;DSS/LM - Changes/Extensions to support order-list RPC
 ;         Other modifications as noted
 ;6/21/07  Copy of ^VFDPOAF with mods for order data wrapper RPC
 ;
LBLS(VFDRSLT,VFDORLST,VFDCMT) ;RPC: VFD PS LABELS BY ORDER LIST
 ; VFDRSLT=[name of] Global Array containing label data.
 ; VFDORLST=Array of order numbers to process
 ;          VFDORLST[1]=[Placer] order IEN
 ;          VFDORLST[2]=[Placer] order IEN
 ;          Etc.
 ; VFDCMT=[Optional] Comment indicating reason for reprinting
 ;
 S VFDRSLT=$NA(^TMP("VFDPOAF",$J)) K @VFDRSLT
 N I,VFDOXRF F I=1:1 Q:'$D(VFDORLST(I))  S VFDOXRF(+VFDORLST(I))=""
 I '$D(VFDOXRF) S @VFDRSLT@(0)="-1^No orders in list" Q
 N VFDFN,VFDERR,VFDX,VFDY
 S VFDX=$$GET1^DIQ(100,+VFDORLST(1),.02,"I"),VFDFN=+VFDX,VFDERR=0
 I 'VFDFN!'($P(VFDX,";",2)="DPT(") S @VFDRSLT@(0)="-1^Invalid object of order" Q
 S VFDX="" F  S VFDX=$O(VFDOXRF(VFDX)) Q:'VFDX!VFDERR  D
 .S VFDY="" F  S VFDY=$O(^PSRX("APL",VFDX,VFDY)) Q:'VFDY!VFDERR  D
 ..I $P($G(^PSRX(+VFDY,0)),U,2)=VFDFN S VFDOXRF(VFDX,VFDY)=""
 ..E  S VFDERR="-1^Invalid Rx patient ID"
 ..Q
 .Q
 I VFDERR S @VFDRSLT@(0)=VFDERR Q
 D LBL(VFDRSLT,VFDFN,.VFDOXRF)
 Q:$G(@VFDRSLT@(0))<0  ;Error from LBL
 N VFDFDA,VFDIENS,VFDR,VFDT S VFDT=$$NOW^XLFDT
 S VFDX="" F  S VFDX=$O(VFDOXRF(VFDX)) Q:'VFDX!VFDERR  D
 .S VFDY="" F  S VFDY=$O(VFDOXRF(VFDX,VFDY)) Q:'VFDY!VFDERR  D
 ..S VFDIENS="+1,"_VFDY_",",VFDR=$NA(VFDFDA(52.032,VFDIENS))
 ..S @VFDR@(.01)=VFDT,@VFDR@(1)=$$RXREF(VFDY),@VFDR@(3)=DUZ
 ..I $L($G(VFDCMT)) S @VFDR@(2)=VFDCMT
 ..D UPDATE^DIE(,"VFDFDA")
 ..Q
 .Q
 ; 
 Q
 ;
LBL(VFDPBA,DFN,VFDOXRF) ; Modified routine ^VFDPOAE to include DFN parameter
 ; Entry point to print commercial Pharmacy labels
 ; Input parameter:
 ;   VFDPBA - req - name of global array to return label values
 ;      DFN - req - Patient IEN
 ;  VFDOXRF - req - Order list as subscripted array
 ;                  VFDOXRF(ORDER_IEN_n)="" for n=1,2,3,4,...
 ;5/11/2009 - SGM
 ;Pretty massive rewrite and reconfiguration with no functional changes
 ;Much still needs to be done for this routine.  There appears to be
 ;duplicate functionality in VFDPOAF and/or VFDPSUTL.  For example,
 ;from this rewrite, SET^VFDPSUTL appears to be unecessary now.
 ;
 N I,J,K,X,CNT,DFNARR,ERROR,FACDEM,PATDEM,PSOLBL,SITE,VFDARR,VFDDEA
 N VFDDFN,VFDLLP,VFDLLP1,VFDLNO,VFDNAM,VFDNMC,VFDOBJ,VFDORD,VFDPRV
 N VFDPSD,VFDPSO,VFDPSOR,VFDREC,VFDREF,VFDRIEN,VFDSIG,VFDSITE,VFDUSR
 N VTMP
 ; DEFINITIONs of local variables
 ;  VFDORD = order number
 ; VFDOXRF = order/prescription list
 ;  VFDPSO = prescription ien
 ; 
 ;Results target location defined in LBLS
 Q:'($G(VFDPBA)?1"^TMP(".E) $$ERRMSG(1)
 I '$G(DFN) D ERRMSG(2,,VFDPBA) Q
 S VFDUSR=DUZ,ERROR=0
 I '$D(VFDOXRF) D ERRMSG(3,,VFDPBA) Q
 ; LM - 4/16/2007 Pre-check order and prescription status - Stop if any error
 ; Allow valid orders and prescriptions to be processed, while skipping
 ; those that have invalid status or are expired.
 D CULL I '$O(VFDOXRF("")) D ERRMSG(4,,VFDPBA) Q
 ; Traverse order IENs
 S VFDORD=0 F VFDORD=0:0 S VFDORD=$O(VFDOXRF(VFDORD)) Q:'VFDORD  D
 .; Override with order-specific OUTPATIENT SITE address
 .D ADR^VFDPSUTL(VFDORD,,$NA(FACDEM))
 .S VFDOBJ=$P(^OR(100,VFDORD,0),U,2) Q:$P(VFDOBJ,";",2)'="DPT("
 .S VFDPSD=+$P(VFDOBJ,";",1)
 .D PAT^VFDPSUTL(VFDPSD)
 .; Traverse prescription IENs 
 .S VFDPSO=0 F  S VFDPSO=$O(VFDOXRF(VFDORD,VFDPSO)) Q:'VFDPSO  D
 ..K PSOLBL,VTMP ;Prevent bleed-through
 ..D DATARX(VFDPSO,.VTMP) M PSOLBL=VTMP
 ..D RET
 ..Q
 .K ^XTMP("VFDPOA-PT",DFN,VFDORD)
 .Q
 K ^XTMP("VFDPOA-PT",DFN)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
CK1() I "^1^7^12^13^14^"[(U_$$GET1(100,ORD,5)_U) Q 5
 Q 0
 ;
CK2() ; check for valid order status
 N X,ACT
 S ACT=$$GET1(100,ORD,30,"E") I 'ACT Q 0
 S X=$P($G(^OR(100,ORD,8,ACT,0)),U,2) I "^DC^HD^"[(U_X_U) Q 6
 Q 0
 ;
CK3() ; check prescription status and expiration date
 N X,VDT
 I $$GET1(52,VRX,100)>0 Q 7
 S VDT=$$GET1(52,VRX,26) I VDT,VDT'>DT Q 8
 Q 0
 ;
CKONE(ORD,VRX) ;Check ONE order and/or PRESCRIPTION
 ; ORD - Order IEN
 ; VRX - Prescription IEN
 ; Return 0 if OK, else return -1^Error message
 N X S ORD=$G(ORD),VRX=$G(VRX)
 I ORD S X=$$CK1 I 'X S X=$$CK2
 I VRX S X=$$CK3
 Q $S('X:0,1:$$ERRMSG(X))
 ;
CULL ;Cull orders and prescriptions for validity
 ; Assumes variable VFDOXRF has list of order, prescription IENs
 N ORD,VRX S ORD=0
 F  S ORD=$O(VFDOXRF(ORD)) Q:'ORD  D
 .I $$CKONE(ORD) K VFDOXRF(ORD) Q
 .S VRX=0 F  S VRX=$O(VFDOXRF(ORD,VRX)) Q:'VRX  D
 ..I $$CKONE(,VRX) K VFDOXRF(ORD,VRX) Q
 ..Q
 .K:'$O(VFDOXRF(ORD,"")) VFDOXRF(ORD)
 .Q
 Q
 ;
DATARX(VRX,VRET) ; return prescription data
 ; VRX - req - prescription file ien
 ; Return VRET(label)=value or '$D(VRET) [vret passed by reference]
 ;5/11/2009 - allow bleed thru of some local variable names
 N I,J,K,X,Y,Z,DIERR,FLDS,IEN,NODE,VFDAT,VFDER
 K VRET Q:'$G(VRX)
 S FLDS=".01;2;4;6;7;8;9;114"
 D GETS^DIQ(52,VRX_",",FLDS,"IE","VFDAT","VFDER")
 S VRET("DATE")=$$FMTE^XLFDT(DT)
 Q:$D(DIERR)  K Z M Z=VFDAT(52,VRX_",")
 S VFDDFN=Z(2,"I")
 S VFDPRV=Z(4,"I")
 S VRET("DRUG")=Z(6,"E")
 S X=Z(6,"I")
 I X S Y=$$GET1(50,X,14.5,"E") I Y'="" S VRET("DISPENSE UNITS")=Y
 S X=Z(8,"E") I X'="" S VRET("DAYS SUPPLY")=X
 S X=Z(.01,"E") I X'="" S VRET("RX#")=X
 S VRET("COMMENTS")=Z(114,"E")
 S (X,VRET("QTY"))=Z(7,"E")
 I X=+X S VRET("QTY")=X_U_$$NUMTOTXT^VFDPSUTL(X)
 S VRET("REFILLS")=Z(9,"E")
 K VFDAT D PRV(VFDPRV,.VFDAT)
 S VRET("DEA #")=VFDAT("DEA #") ; dea expire date
 S VRET("NPI #")=VFDAT("NPI #")
 S VRET("PSBN")=VFDAT("SBN")
 S VRET("PSBT")=VFDAT("SBT")
 I VRET("PSBN")="" S VRET("PROV NAME")=VFDAT("NAME")
 M VRET("LICENSE")=VFDAT("LICENSE")
 D SUPROV(VFDPRV)
 ; get rx sig and pharmacy instructions
 ;**** LLOYD **** - why did you FOR loop 1:1 instead of $ORDER?
 K K,NODE S NODE(1)="SIG1",K(1)="SIG"
 S NODE(2)="INS1",K(2)="INST"
 S NODE(3)="PI",K(3)="PH INST"
 F K=1,2,3 S NODE=NODE(K),(I,J)=0 D
 .F  S I=$O(^PSRX(VRX,NODE,I)) Q:'I  S (X,Z)=^(I,0) D
 ..I K<3 S Y=$F(X,"BY BY") I Y S Z=$E(X,1,Y-4)_$E(X,Y,99)
 ..S J=J+1,VRET(K(K),J)=Z
 ..Q
 .; copy Provider Comments to end of SIG. J and K(K) is retained from previous loop
 .I K=1,$$GET^XPAR("SYS","VFD PSO PROVIDER COMMENTS")=2 D
 ..S I=0 F  S I=$O(^PSRX(VRX,"PRC",I)) Q:'I  S (X,Z)=^(I,0) D
 ...S Y=$F(X,"BY BY") I Y S Z=$E(X,1,Y-4)_$E(X,Y,99)
 ...S J=J+1,VRET(K(K),J)=Z
 ...Q
 ..Q
 .Q
 Q
 ;
ERRMSG(A,T,R) ; return error message
 N Y,Z I A=1 S Z="Invalid target for results"
 I A=2 S Z="No patient DFN received"
 I A=3 S Z="No orders received"
 I A=4 S Z="No active prescriptions found"
 I A=5 S Z="Order #"_ORD_" has an invalid status."
 I A=6 S Z="Order #"_ORD_" has an invalid action."
 I A=7 S Z="Prescription IEN #"_VRX_" has an invalid status."
 I A=8 S Z="Prescription IEN #"_VRX_" has expired."
 S Y="-1^"_Z I $G(R)'="" S @R@(0)=Y Q
 Q Y
 ;
GET1(F,I,FL,EXT) N X,DIERR Q $$GET1^DIQ(F,I,FL,$G(EXT,"I"))
 ;
GXPAR(ENT,PAR) N VAL Q $$GET^XPAR(ENT,PAR)
 ;
LIC(PRV,VRET) ; return license data
 N I,X,Y,Z,LIC D LICENSE^VFDPSUTL(.LIC,PRV)
 F I=1:1 Q:'$D(LIC(I))  S VRET("LICENSE",I)=LIC(I)
 Q
 ;
PRECK() ;Pre-check order and prescription status fields
 ; Return 0 if ALL are okay; Else return -1^Error message
 ; Assumes variable VFDOXRF has list of order, prescription IENs
 N X,ORD,VRX
 S (X,ORD)=0 F  S ORD=$O(VFDOXRF(ORD)) Q:'ORD  D  Q:+X
 .S X=$$CKONE(ORD) Q:+X
 .S VRX=0 F  S VRX=VFDOXRF(ORD,VRX) Q:'VRX  S X=$$CKONE(,VRX) Q:+X
 .Q
 Q X
 ;
PRV(PRV,VPROV,SUP) ; return provider data
 ;   PRV - req - pointer to file 200
 ;.VPROV - return array
 ;      ("DEA #") = DEA#
 ;      ("NPI #") = NPI#
 ;      ("SBN")   = signature block name (#20.2)
 ;      ("SBT")   = signature block title (#20.3)
 ;      ("NAME")  = name (.01)
 ;   SUP - opt - Boolean flag to indicate whether to return supervisor
 ;               data for this provider
 N X,Y,Z,LIC
 S VPROV("SBN")=$$GET1(200,PRV,20.2,"E")
 S VPROV("SBT")=$$GET1(200,PRV,20.3,"E")
 S VPROV("NAME")=$$NAMEFMT^VFDPSUTL(PRV)
 Q:+$G(SUP)
 S VPROV("DEA #")=$$DEA^VFDPSUTL(PRV) ; dea expire date
 S VPROV("NPI #")=$$NPI^VFDPSUTL(PRV)
 D LICENSE^VFDPSUTL(.LIC,PRV)
 F I=1:1 Q:'$D(LIC(I))  S VPROV("LICENSE",I)=LIC(I)
 Q
 ;
RXREF(IEN) ;Value to put in RX REFERENCE sub-field
 ; VFDRXIEN - req - PRESCRIPTION file IEN
 ;Return the next number for the #times script has been [re]printed.
 ;If never reprinted, return 0
 S IEN=+$G(IEN) Q:IEN'>0 ""
 N X,Y,Z S (X,Y)=0
 F  S X=$O(^PSRX(IEN,"L",X)) Q:'X  S Z=$P(^(X,0),U,2) S:Z>Y Y=Z
 Q $S(Y:Y+1,1:0)
 ;
RET ; return data to the calling RPC
 N I,J,X,Y,Z,ND,VCNT,VFD
 S VCNT=$O(@VFDPBA@("A"),-1)
 M ^ZZ("PATDEM",$J)=PATDEM,^ZZ("FACDEM",$J)=FACDEM ;DEBUG
 D SET("$START PSOLABEL")
 S J="" F  S J=$O(PATDEM(J)) Q:J=""  D SET(J_U_PATDEM(J))
 S J="" F  S J=$O(FACDEM(J)) Q:J=""  D SET(J_U_FACDEM(J))
 S J="" F  S J=$O(PSOLBL(J)) Q:J=""  D
 .I "^INST^LICENSE^PH INST^SIG^"'[(U_J_U) D SET(J_U_PSOLBL(J))
 .Q
 F K="INST","SIG","PH INST","LICENSE" D
 .S J="" F  S J=$O(PSOLBL(K,J)) Q:'J  D SET(K_U_PSOLBL(K,J))
 .Q
 ; add order diagnoses
 D
 .N I,ND D GETS^DIQ(100,VFDORD,"5.1*",,"VFD")
 .Q
 S J="" F  S J=$O(VFD(100.051,J)) Q:'J  D
 .S X=VFD(100.051,J,.01),Y=VFD(100.051,J,1) D SET("DIAGNOSIS^"_X_U_Y)
 .I $L(X) D SET($P($$ICD9^VFDCDRG(,X,,,,1),U,4),4)
 .Q
 D SET("$END PSOLABEL")
 Q
 ;
SET(X,P) ; 5/11/2009
 S VCNT=VCNT+1 I '$G(P) S @VFDPBA@(VCNT)=X
 E  S $P(@VFDPBA@(VCNT),U,P)=X
 Q
 ;
SUPROV(VFDDUZ) ;Add supervisory provider data w/assoc info (DEA#, etc.)
 ; VFDDUZ - req - Provider ien for whom supervisory providers are requested
 ; Local variables expected:
 ;    VFDPSO - prescription ien
 ;
 ; KEYWORD      DATA
 ; -----------  -------------------------------------------------------------
 ; AP nn DEA #  Assoc prov nn DEA #
 ; AP nn NPI #  Assoc prov nn NPI #
 ; AP nn DPS #  Assoc prov nn DPS #
 ; AP nn SBN    Assoc prov nn signature block name
 ; AP nn SBT    Assoc prov nn signature block title
 ; AP nn NAME   Assoc prov nn formatted name (iff SBN not available)
 ;
 Q:'$G(VFDDUZ)
 N I,J,K,X,Y,Z,INST,LOC,VAL,VFDA,VFDI,VFDJ,VFDK,VFDLST,VFDZ
 S VAL=$$GXPAR("USR.`"_VFDDUZ,"VFD CPRS RX PRINT ATTENDING") I 'VAL D
 .Q:'$G(VFDPSO)  S LOC=$$GET1(52,VFDPSO_",",5) Q:'LOC
 .S VAL=$$GXPAR("LOC.`"_LOC,"VFD CPRS RX PRINT ATTENDING") Q:VAL
 .S INST=$$GET1(44,LOC_",",3) Q:'INST
 .S VAL=$$GXPAR("DIV.`"_INST,"VFD CPRS RX PRINT ATTENDING")
 .Q
 S PSOLBL("PRT ATT")=VAL
 ;
 ;**********************************
 ;LLOYD - the only changes I made below are to change $$GET1^DIQ calls
 ;to $$GET1
 ;**********************************
 ; 9/22/2008 - Add DPS number of prescribing provider
 D ID1^VFDCDUZ(.VFDLST,VFDDUZ)
 F J=1:1 Q:'$D(VFDLST(J))!$D(PSOLBL("DPS #"))  D
 .I VFDLST(J)?1"DPS".E S PSOLBL("DPS #")=$P(VFDLST(J),U,2)
 .Q
 ; 5/8/2009 - Add other prescribing provider IDs
 N VFDIDTYP F VFDJ=1:1 Q:'$D(VFDLST(VFDJ))  D
 .Q:VFDLST(VFDJ)?1"DPS".E  ;Already recorded
 .S VFDIDTYP=$P(VFDLST(VFDJ),U) ;5/27/2009 - Need ID type for next
 .S:VFDIDTYP="LIC" VFDIDTYP=VFDIDTYP_" "_$P(VFDLST(VFDJ),U,3) ;Append License sub-type
 .S PSOLBL("PP "_VFDIDTYP_" #")=$P(VFDLST(VFDJ),U,2)
 .Q
 ; End 5/8/2009 insert
 S (I,K)=0 F  S I=$O(^VA(200,VFDDUZ,21601,I)) Q:'I  D
 .S VFDZ=$G(^(I,0)) Q:'VFDZ!'$P(VFDZ,U,2)
 .K VFDLST D ID1^VFDCDUZ(.VFDLST,+VFDZ) Q:'$D(VFDLST)
 .Q:$G(VFDLST(1))<0  S K=K+1,VFDA="AP "_K_" "
 .F J=1:1 Q:'$D(VFDLST(J))  D
 ..S VFDIDTYP=$P(VFDLST(J),U) ;5/27/2009 - Need ID type for next
 ..S:VFDIDTYP="LIC" VFDIDTYP=VFDIDTYP_" "_$P(VFDLST(J),U,3) ;Append License sub-type
 ..S PSOLBL(VFDA_VFDIDTYP_" #")=$P(VFDLST(J),U,2)
 ..Q
 .K VAL D PRV(+VFDZ,.VAL,1)
 .S PSOLBL(VFDA_"SBN")=VAL("SBN")
 .S PSOLBL(VFDA_"SBT")=VAL("SBT")
 .I VAL("SBN")="" S PSOLBL(VFDA_"NAME")=VAL("NAME")
 .Q
 Q
