VFDVXFR ;DSS/WLC - Utilities supporting vxVistA prescription processing ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 148
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  Supported Description
 ;-----  --------------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2056  ^DIQ: $$GET1, GETS
 ;10060  Fileman read of fields in file 200
 ;10112  SITE^VASITE
 ;       Fileman read of all fields in files:
 ;10060    200
 ;10090      4
 Q
 ;
ACCT(VFDP)  ; RPC:  VFD PSO ACCT INFO
 ; RPC to return address and phone information for NewCrop interface
 ;  INPUT:
 ;
 ;   NONE.
 ;
 ;  OUTPUT:
 ;
 ; VFDP, where:
 ;
 ;    VFDP(1)=Location IEN
 ;    VFDP(2)=Location Name
 ;    VFDP(3)=Institution Site ID
 ;    VFDP(4)=Institution Address Line 1
 ;    VFDP(5)=Institution Address Line 2
 ;    VFDP(6)=Institution City
 ;    VFDP(7)=Institution State
 ;    VFDP(8)=Institution Zip (base 5)
 ;    VFDP(9)=Institution Zip (ext 4)
 ;    VFDP(10)=Institution Country (default US)
 ;    VFDP(11)=Institution Primary phone
 ;    VFDP(12)=Institution Primary FAX
 ;
 N I,J,VFDINST,VFDFLDS
 S VFDFLDS=".01;.05;4.01;4.02;4.03;4.04;4.05;21612.01"
 S VFDINST=+$$SITE^VASITE I 'VFDINST S VFDP(1)="Site not found." Q
 D GETS^DIQ(4,VFDINST_",",VFDFLDS,"EI","INSTL") S VFDAIEN=INSTL(4,VFDINST_",",21612.01,"I")
 N VFDADR D GETS^DIQ(21612,VFDAIEN_",","*",,$NA(VFDADR))
 N VFDR S VFDR=$NA(VFDADR(21612,VFDAIEN_",")) D
 .S VFDP(1)=VFDINST
 .S VFDP(2)=INSTL(4,VFDINST_",",.01,"E")
 .S VFDP(3)=INSTL(4,VFDINST_",",.05,"E")
 .S VFDP(4)=INSTL(4,VFDINST_",",4.01,"E")
 .S VFDP(5)=INSTL(4,VFDINST_",",4.02,"E")
 .S VFDP(6)=INSTL(4,VFDINST_",",4.03,"E")
 .S VFDP(7)=INSTL(4,VFDINST_",",4.04,"E")
 .S VFDP(8)=$E(INSTL(4,VFDINST_",",4.05,"E"),1,5)
 .S VFDP(9)=$P(INSTL(4,VFDINST_",",4.05,"E"),"-",2)
 .S I=$$GET1^DIQ(21612,VFDAIEN_",",.117,"I"),VFDP(10)=$$GET1^DIQ(779.004,I_",",1.2)
 .S VFDP(11)=$$GET1^DIQ(21612,VFDAIEN_",",.131)
 .S VFDP(12)=$$GET1^DIQ(21612,VFDAIEN_",",.134)
 Q
 ;
VFDNCROP(VFDP,VFDLOC)  ; RPC:  VFD PSO NEWCROP LOC
 ; RPC to return address and phone information for NewCrop interface
 ;  INPUT:
 ;
 ;   VFDLOC:  Location IEN ^ VFDPROV: Provider IEN
 ;
 ;  OUTPUT:
 ;
 ; VFDP, where:
 ;
 ;    VFDP(1)=Location IEN
 ;    VFDP(2)=Location Name
 ;    VFDP(3)=Location Site ID
 ;    VFDP(4)=Location Address Line 1
 ;    VFDP(5)=Location Address Line 2
 ;    VFDP(6)=Location City
 ;    VFDP(7)=Location State
 ;    VFDP(8)=Location Zip (base 5)
 ;    VFDP(9)=Location Zip (ext 4)
 ;    VFDP(10)=Location Country (default US)
 ;    VFDP(11)=Provider Primary phone
 ;    VFDP(12)=Provider Alternate Phone #1
 ;    VFDP(13)=Provider Alternate Phone #2
 ;    VFDP(14)=Provider Primary FAX
 ;
 N I,J,VFDARR,VFDLC,VFDPRV,VFDAIEN,VFDDEFP,VFDINT
 S VFDLOC=$G(VFDLOC) I +VFDLOC=0 S VFDP(1)="-1^No location pointer sent." Q
 I +$P(VFDLOC,U,2)=0 S VFDP(1)="-1^No Provider IEN sent." Q
 S VFDLC=+VFDLOC,VFDPRV=$P(VFDLOC,U,2)
 I '$D(^VA(200,VFDPRV)) S VFDP(1)="-1^Provider IEN not found." Q
 S VFDINST=$$GET1^DIQ(44,VFDLC,3,"I") I 'VFDINST S VFDP(1)="No Institution file pointer in Location file." Q
 S VFDAIEN=$O(^VFD(21612,"D",VFDINST,"ERX",""))
 I 'VFDAIEN D  Q:+$G(VFDP(1))<0
 . S VFDAIEN=$$GET1^DIQ(4,VFDINST,21612.01,"I") ;Rx VFD ADDRESS IEN
 . I 'VFDAIEN S VFDP(1)="-1^No RX PRINT ADDRESS defined." Q
 D GETS^DIQ(4,VFDINST_",",".01;.05","E","INSTL")
 N VFDADR D GETS^DIQ(21612,VFDAIEN_",","*",,$NA(VFDADR))
 N VFDR S VFDR=$NA(VFDADR(21612,VFDAIEN_",")) D
 .S VFDP(1)=VFDLC
 .S VFDP(2)=$$GET1^DIQ(44,VFDLC_",",.01,"E")
 .S VFDP(3)=INSTL(4,VFDINST_",",.05,"E")
 .S VFDP(4)=@VFDR@(.111)
 .S VFDP(5)=@VFDR@(.112)
 .S VFDP(6)=@VFDR@(.114)
 .S I=@VFDR@(.115),J=$O(^DIC(5,"B",I,0)),VFDP(7)=$$GET1^DIQ(5,J_",",1)
 .S VFDP(8)=$E(@VFDR@(.116),1,5)
 .S VFDP(9)=$P(@VFDR@(.116),"-",2)
 .S I=$$GET1^DIQ(21612,VFDAIEN_",",.117,"I"),VFDP(10)=$$GET1^DIQ(779.004,I_",",1.2)
 .S VFDP(11)=$$GET1^DIQ(200,VFDPRV_",",.132,"E")
 .S VFDP(12)=$$GET1^DIQ(200,VFDPRV_",",.133,"E")
 .S VFDP(13)=$$GET1^DIQ(200,VFDPRV_",",.134,"E")
 .S VFDP(14)=$$GET1^DIQ(200,VFDPRV_",",.136,"E")
 .S:@VFDR@(.131)]"" VFDP(11)=@VFDR@(.131)  ; override with default
 .S:@VFDR@(.132)]"" VFDP(12)=@VFDR@(.132)  ; override with default
 .S:@VFDR@(.133)]"" VFDP(13)=@VFDR@(.133)  ; override with default
 .S:@VFDR@(.134)]"" VFDP(14)=@VFDR@(.134)  ; override with default
 Q
 ;
ACCEPT(VFDR,VFDL)  ; RPC:  VFD PSO NEWCROP ACCEPT
 N ARR,DATA,ENDDT,I,NODE,ORDIALOG,ORVP,ORNP,ORL,DLG,ORDG
 N ORIT,ORIFN,ORDEA,ORAPPT,ORSRC,OREVTDF,REC,STR,STRT,TRANS,X,Y,ZX1,X2
 S VFDR="1^Success"
 F I=1:1 S X=$T(VALS+I) Q:X=" ;;;"!(X="")  D
 . S DATA=$T(VALS+I),NODE=$E($P(DATA,U,1),4,99)
 . S TRANS(NODE)=$P(DATA,U,2),LOG(NODE)=$P(DATA,U,3)
 F I=1:1 Q:'$D(VFDL(I))  D
 . S ARR($TR($P(VFDL(I),U),"<>",""))=$P(VFDL(I),U,2)
 K ORDIALOG
 S I="" F  S I=$O(ARR(I)) Q:I=""  D
 . Q:'$D(TRANS(I))
 . S X=ARR(I) D:$G(LOG(I))]"" @LOG(I)
 . S ORDIALOG(TRANS(I),1)=$G(ARR(I))
 ;S ORDIALOG(6,1)=ORDIALOG(6,1)
 S STR="STDATEC,DRUG,PROV,PAT,LOC,DISP,ROUTE,FREQ"
 F I=1:1 Q:$P(STR,",",I)=""  D @$P(STR,",",I)
 S DLG="OR GXTEXT WORD PROCESSING ORDER"  ; default order dialog
 S ORDG=49  ; default display group to "OR GXTEXT WORD PROCESSING ORDER"
 S (ORIFN,ORIT,ORDEA,ORAPPT,ORSRC,OREVTDF)=""  ; optional parameters 
 ;S ORDIALOG(6,1)=$$NOW^XLFDT  ; START DATE
 S ORDIALOG("WP",385,1,1,0)=ORDIALOG(385,1)  ; S ORDIALOG(385,1)="ORDIALOG(""WP"",385,1,1,0)"  ; fix SIG
 S X1=ORDIALOG(6,1),X2=ORDIALOG(387,1)+(ORDIALOG(387,1)*(ORDIALOG(150,1))) D C^%DTC S ORDIALOG(24,1)=$P(X,".",1)_".2399"  ; STOP DATE
 I +VFDR<0 D  ; OR Word Processing Text Order
 . ; Generate text from order
 . S ORDIALOG("WP",15,1,1,0)="~99_ZZGenericFreeTextOutpatientPharmOrder~"_ORDIALOG(991,1)
 . S ORDIALOG("WP",15,1,2,0)=ORDIALOG("WP",385,1,1,0)
 . S ORDIALOG("WP",15,1,3,0)="Quantity: "_ORDIALOG(149,1)_" Refills: "_ORDIALOG(150,1)_"~$START PSOTXTLBL~DRUG"_U_ORDIALOG(995,1)
 . S ORDIALOG("WP",15,1,4,0)="~DOSE"_U_ORDIALOG(149,1)_ORDIALOG(994,1)_"~QTY"_U_ORDIALOG(149,1)_"~REFILLS"_U_ORDIALOG(150,1)_"~DAYS SUPPLY"_U_ORDIALOG(387,1)_"~SCHED"_U_ORDIALOG(170,1)
 . S ORDIALOG("WP",15,1,5,0)="~ROUTE"_U_ORDIALOG(137,1)_"~COMMENTS"_U_$G(ORDIALOG(990,1))_" "_$G(ORDIALOG(996,1))_"~SIG"_U_$G(ORDIALOG(385,1))
 . S ORDIALOG("WP",15,1,6,0)="~STOP PSOTXTBL"
 . S ORDIALOG(15,1)="ORDIALOG(""WP"",15,1)"
 . S ORDIALOG(4,1)=-1
 . S DLG="OR GXTEXT WORD PROCESSING ORDER",ORDG=13,ORIT=49
 . S ORDIALOG(148,1)="W",ORDIALOG(7,1)=9
 . S ORDIALOG("ORCHECK")=0,ORDIALOG("ORTS")=0,OREVTDF=0
 . S STRT=ORDIALOG(6,1),ENDDT=ORDIALOG(24,1)  ; save off start and stop dates
 . K ORDIALOG(6,1),ORDIALOG(24,1)  ; kill off start and stop dates
 . S VFDR="1^Success"
 S ORDIALOG(1358,1)="ORDIALOG(""WP"",15,1)"  ; fix Patient Instructions
 S ORDIALOG(385,1)="ORDIALOG(""WP"",385,1,1,0)"
 D SAVE^ORWDX(.REC,ORVP,ORNP,ORL,DLG,ORDG,ORIT,ORIFN,.ORDIALOG,ORDEA,ORAPPT,ORSRC,OREVTDF)
 N ES,ORWLST,ORWREC,XS S ORWREC(1)=+$P(REC(1),"~",2)_";1^1^1^E",XS=$P(^VA(200,ORNP,20),U,4),ES=$$ENCRYP^XUSRB1(XS)
 S ORWLST="" D SEND^ORWDX(.ORWLST,ORVP,ORNP,ORL,ES,.ORWREC) ; sign order
 S $P(^OR(100,+ORWREC(1),3),U,3)=100  ; override status
 S $P(^OR(100,+ORWREC(1),0),U,8)=STRT  ; adjust start date
 S $P(^OR(100,+ORWREC(1),0),U,9)=ENDDT  ; adjust Stop date
 S ^OR(100,+ORWREC(1),4)=ORDIALOG(993,1)_";"_ORDIALOG(999,1)_";"_"eRx;NCP"
 Q
 ;
VALS  ;
 ;;DrugID^4^
 ;;Route^137
 ;;Dispense^149
 ;;Refills^150
 ;;DosageFrequencyDescription^170
 ;;PharmacistNotes^15
 ;;Strength^384
 ;;PatientFriendlySIG^385
 ;;DosageForm^386^
 ;;DaysSupply^387
 ;;DrugName^389
 ;;DrugInfo^991
 ;;ExternalPatientID^997^
 ;;ExternalPhysicianID^998^
 ;;LocationName^992
 ;;DispenseNumberQualifier^994
 ;;DrugName^995
 ;;PrescriptionNotes^996
 ;;PharmacistNotes^990
 ;;PrescriptionGuid^993
 ;;OrderGUID^999
 ;;PrescriptionTimestamp^6^STDATEC
 ;;;
STDATEC  ; convert date to FILEMAN date/time
 S X=$TR($P($P(ARR("PrescriptionTimestamp"),"T",1)_"."_$P($P(ARR("PrescriptionTimestamp"),"T",2),"-",1),".",1,2),":-","")
 S ORDIALOG(6,1)=$E(X,1,4)-1700_$E(X,5,8)_"."_$P(X,".",2)
 Q
 ;
PAT  ; find Patient
 S ORVP=ORDIALOG(997,1)
 Q
 ;
PROV  ; Provider
 S ORNP=ORDIALOG(998,1)
 Q
 ;
LOC  ; Ordering Location
 S ORL=$O(^SC("B",ORDIALOG(992,1),0)) I 'ORL S VFDR="-1^Ordering Location not found." Q
 Q
 ;
DOSE  ; Dosing
 N X S X=$O(^PS(50.607,"B",$E(ORDIALOG(386,1),1,30),0)) S:'X VFDR="-1^Invalid dose" Q
 S ORDIALOG(386,1)=X
 Q
 ;
DISP ; Display Group
 Q:+VFDR<0  S ORDG=$P(^ORD(101.43,ORDIALOG(4,1),0),U,5)
 Q
 ;
ROUTE  ; Route
 N X S X=$E(ORDIALOG(137,1),1,30)
 I $D(^PS(51.2,"B",X)) S ORDIALOG(137,1)=$O(^PS(51.2,"B",X,0)) Q
 I $D(^PS(51.2,"B",$$UPPER(X))) S ORDIALOG(137,1)=$O(^PS(51.2,"B",X,0)) Q
 S VFDR="-1^Cannot locate Route mapping."
 Q 
 ;
FREQ  ; Frequency
 N X
 S X=$E(ORDIALOG(170,1),1,30)
 I $D(^PS(51.1,"B",X)) S ORDIALOG(170,1)=$O(^PS(51.1,"B",X,0)) Q
 I $D(^PS(51.1,"B",$$UPPER(X))) S ORDIALOG(170,1)=$O(^PS(51.1,"B",X,0)) Q
 S VFDR(0)="-1^Cannot map Frequency:  "_ORDIALOG(170,1)
 Q
 ;
UPPER(X)  ; Convert to upper-case
 Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
DRUG  ; find drug orderable item
 N DRUG506,DRUG5068,DRG5068I,DRUG50,DRUG507,DRUG10143,DRUGORG
 S DRUGORG=ORDIALOG(4,1)
 S DRG5068I=$O(^PSNDF(50.68,"AVFD1",DRUGORG,0)) I 'DRG5068I S VFDR="-1^Cannot find First DataBank ID number" Q
 S DRUG5068=$P(^PSNDF(50.68,DRG5068I,21601),U,2)
 S DRUG50=$O(^PSDRUG("AND",DRUG5068,0))  I 'DRUG50 S VFDR="-1^Cannot find DRUG (#50) file entry." Q
 S DRUG10143=$O(^ORD(101.43,"ID",DRUG50_";99PSP",0)),ORDIALOG(4,1)=DRUG10143
 Q
 ;
TOTRPT  ; Total Prescriptions for date range report
 N BRK,DIR,DLG,ERR,FILE,NEWC,ODT,ORD,ORDER,PERC,PROV,PSI,PRINT,PSO,PT,QX,TOT,WORD,X,Z
 S (PSI,PSO,QX,WORD,NEWC,TOT)=0
 ; Date range
 K Z S Z(0)="D",Z("A")="Begin at Date" D  Q:X<1
 . S Z("B")="T-30",X=$$DIR(.Z) S VFDSDT=0 S:X>0 VFDSDT=X
 . Q
 K Z S Z(0)="D",Z("A")="Through Date" D  Q:X<1
 . S Z("B")="T",X=$$DIR(.Z) S VFDEDT=0 S:X>0 VFDEDT=X
 . Q
 K Z S Z(0)="F^1:1",Z("A")="(E)xcel or (P)rint" D  Q:X="-1"
 . S Z("B")="E",X=$$DIR(.Z) S PRINT=X
 . Q
 S PROV=$NA(^TMP("VFDVXFR",$J)) K @PROV U IO
 ; go through ORDERS (#100) file and pull different types of orders for providers
 S PT=""  F  S PT=$O(^OR(100,"AC",PT)) Q:PT=""  D
 . S ODT=0 F  S ODT=$O(^OR(100,"AC",PT,ODT)) Q:'ODT  D
 . . S NDT=+$P(9999999-ODT,".",1) Q:NDT<VFDSDT  Q:NDT>VFDEDT
 . . S ORD=0 F  S ORD=$O(^OR(100,"AC",PT,ODT,ORD)) Q:'ORD  D
 . . . K ORDER D GETS^DIQ(100,ORD_",","**","IE","ORDER","ERR")
 . . . S X=$G(ORDER(100,ORD_",",5,"I")) I X'=100,X'=6 Q  ; written or active status
 . . . S DLG=$G(ORDER(100,ORD_",",2,"E")) I DLG'["OR GXTEXT WORD",DLG'="PSO OERR",DLG'["PSJI OR PAT FLUID",DLG'["PSJ OR PAT OE" Q  ; accepted Pharmacy dialogs
 . . . S PRV=$G(ORDER(100,ORD_",",3,"I"))
 . . . I DLG["WORD PROCESSING" D ADD("NEWC") Q
 . . . I DLG["PSO OERR" D ADD("PSO") Q
 . . . I DLG["PSJI OR PAT FLUID" D ADD("INPT") Q
 . . . I DLG["PSJ OR PAT OE" D ADD("INPT") Q
 D ACCUM
 I PRINT="E" D EXCEL D CLOSE^%ZISH Q
 D TABS
 Q
 ;
ADD(SUB)  ;
 S @PROV@(PRV,SUB,0)=$G(@PROV@(PRV,SUB,0))+1
 S @PROV@(PRV,SUB,ORD)=""
 Q
 ;
ACCUM  ; accumulate totals for report
 N I,J,K,TOTN,TOTP
 S (TOTN,TOTP)=0
 S I=0 F  S I=$O(@PROV@(I)) Q:'I  D
 . S (PERC(I),TOT(I))=0 S J="" F  S J=$O(@PROV@(I,J)) Q:J=""  D
 . . S BRK(I,J)=+$G(@PROV@(I,J,0))
 . . S TOT(I)=TOT(I)+BRK(I,J)
 . S J="" F  S J=$O(BRK(I,J)) Q:'J  D
 . . S PERC(I)=BRK(I,J)/TOT(I)*100
 S I=0 F  S I=$O(@PROV@(I)) Q:'I  D
 . S (TOTP,TOTN)=0
 . F J="PSO","INPT" S:$D(@PROV@(I,J)) TOTP=TOTP+1
 . I $D(@PROV@(I,"NEWC")) S TOTN=TOTN+1
 Q
 ;
EXCEL  ;
 N V,TOTAL
 S V=",",TOTAL=$G(TOT("INPT"))+$G(TOT("NEWC"))+$G(TOT("PSO"))
 W !,"PROVIDER"_V_"INPAT"_V_"NEWCROP"_V_"OUTPT"_V_"TOTAL"
 S I=0 F  S I=$O(TOT(I))  Q:'I  D
 . S TOTAL=0 N J F J="INPT","NEWC","PSO" S TOT(I,J)=$G(TOT(I,J))+$G(@PROV@(I,J,0)),TOTAL=TOTAL+$G(TOT(I,J))
 . W !!,$TR($$GET1^DIQ(200,I_",",.01),",",";")_V_+$G(TOT(I,"INPT"))_V_+$G(TOT(I,"NEWC"))_V_+$G(TOT(I,"PSO"))_V_TOTAL
 . W !,"Percentage (%)"_V_+$$PRC("INPT")_V_+$$PRC("NEWC")_V_+$$PRC("PSO")_V_"100"
 Q
 ;
PRC(XXX)  ; percentage calculation
 Q $S(+$J(TOT(I,XXX)/TOTAL+.005*100\1,5,2)'=0:+$J(TOT(I,XXX)/TOTAL+.005*100\1,5,2),1:"")
 ;
TABS  ;
 N V,TOTAL
 S V=",",TOTAL=$G(TOT("INPT"))+$G(TOT("WORD"))+$G(TOT("NEWC"))+$G(TOT("PSO"))
 W !,"PROVIDER",?30,$J("INPAT",10),?40,$J("NEWCROP",10),?50,$J("OUTPT",10),?60,$J("TOTAL",10)
 S I=0 F  S I=$O(TOT(I))  Q:'I  D
 . S TOTAL=0 N J F J="INPT","NEWC","PSO" S TOT(I,J)=$G(TOT(I,J))+$G(@PROV@(I,J,0)),TOTAL=TOTAL+$G(TOT(I,J))
 . W !!,$TR($E($$GET1^DIQ(200,I_",",.01),1,25),",",";"),?30,$J(+$G(TOT(I,"INPT")),10),?40,$J(+$G(TOT(I,"NEWC")),10),?50,$J(+$G(TOT(I,"PSO")),10),?60,$J(TOTAL,10)
 . W !,"Percentage (%)",?30,$J(+$$PRC("INPT")_"%",10),?40,$J(+$$PRC("NEWC")_"%",10),?50,$J(+$$PRC("PSO")_"%",10),?60,$J($J(TOT(I)/TOTAL*100,5,2)_"%",10)
 Q
 ;
DIR(DIR) ;
 N X,Y,DIROUT,DIRUT,DTOUT,DUOUT
 W ! D ^DIR I $D(DTOUT)!$D(DUOUT) S Y=-1
 Q Y
 ;
