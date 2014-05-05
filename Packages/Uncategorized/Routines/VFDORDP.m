VFDORDP ;DSS/WLC - ARRA PHARMACY ORDERS DUMP ; 05/31/2011 10:17
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
EN(VFD) ;  Enter point to prompt for dates
 N I,X,Y,Z,END,START,VFD1
 Q:$$DATE^VFDCFM(.START,.END,1)<1
 D DUMP(.VFD,START,END)
 Q
 ;
DUMP(VFDRET,VFDSDT,VFDEDT,VFDFILN,VFDPATH)  ; VFD PHARMACY DUMP
 N X,Y,Z,CNT,DLG,DLGS,DGLX,ID,IENS,ITMP,P5068,PSNUM,QDT
 N SCRIPT,VFD,VFD1,VFDDTS,VFDX
 I $G(VFDFILN)="" S VFDFILN="PT_MEDS.CSV"
 I $G(VFDPATH)="" S VFDPATH=$$PWD^%ZISH
 S VFDX=$NA(^TMP("VFDORDP",$J)) K @VFDX
 S X=$$DATE^VFDRPARU($G(VFDSDT),$G(VFDEDT)) I +X=-1 S VFDRET=X Q
 S DFN=0,CNT=1,@VFDX@(1)="PT_IEN^RXNORM^ST_DT^ED_DT^OR_TYPE"
 F  S DFN=$O(^DPT(DFN)) Q:'DFN  D
 . K VFD1 D ACTIVE^ORWPS(.VFD1,DFN)
 . S ITMP=0 F  S ITMP=$O(VFD1(ITMP)) Q:'ITMP  D
 . . Q:$E(VFD1(ITMP))'="~"  ; start of new order
 . . N ORD,PSDRUG,RX0,RXNORM,STAT,TYP,VFDY,VIENS
 . . S STAT=$P(VFD1(ITMP),U,10)
 . . ;I STAT["DISCONTINUED" Q
 . . I STAT["PENDING" Q
 . . S RX0=$G(VFD1(+ITMP))
 . . S TYP=$E($P(RX0,U,1),2,3)
 . . N ORD,VFDY,VIENS
 . . S VIENS=+$P(RX0,U,2) ;         pharmacy context sensitive ifn
 . . S VIENS(1)=VIENS_","_DFN_"," ; iens for Inpatient FM calls
 . . S ORD=+$P(RX0,U,9) ;           file 100 ifn
 . . I TYP="OP" D
 . . . D GETS(.VFDY,52,VIENS,"1;6;26","I")
 . . . S RXNORM=$$D1(VFDY(6)) ; vfdy(6) pointer to DRUG (#50)) file
 . . . D SET(VFDY(1),VFDY(26))
 . . . Q
 . . I TYP="UD" D
 . . . ; drug pointer in order number multiple.  Get the first drug in
 . . . ; multiple only
 . . . S PSDURG=0,X=$O(^PS(55,DFN,5,VIENS,1,0)) S:X PSDRUG=+^(X,0)
 . . . S RXNORM="" I PSDRUG S RXNORM=$$D1(PSDRUG)
 . . . D GETS(.VFDY,55.06,VIENS(1),"10;34","I")
 . . . D SET(VFDY(10),VFDY(34))
 . . . Q
 . . I TYP="IV" D
 . . . ; multiple fields with pointers to the DRUG file.  Take the
 . . . ; additive in the multiple
 . . . S X=$O(^PS(55,DFN,"IV",VIENS,"AD",0)) Q:'X  S X=+^(X,0) Q:'X
 . . . S X=$$GET1(52.6,X_",",1,"I") Q:'X  ; 1st additive, get drug ptr
 . . . S RXNORM=$$D2(X)
 . . . D GETS(.VFDY,55.01,VIENS(1),".02;.03","I")
 . . . D SET(VFDY(.02),VFDY(.03))
 . . . Q
 . . I TYP="NV" D
 . . . N DOC,START,END S (DOC,END,START)=""
 . . . ; get first orderable item from ORDER entry
 . . . S RXNORM=$$D2(,ORD)
 . . . I '$O(^PS(55,DFN,"NVA",VIENS,0)) D
 . . . . D GETS(.VFDY,100,ORD,"21;22","I")
 . . . . S START=VFDY(21),END=VFDY(22)
 . . . . Q
 . . . E  I +VIENS(1) D
 . . . . D GETS(.VFDY,55.05,VIENS(1),"6;8;11","I")
 . . . . S END=VFDY(6),START=VFDY(8) S:'START START=VFDY(11)
 . . . . Q
 . . . D SET(START,END)
 . . . Q
 . . Q
 . Q
 S VFDDTS(0)=3,VFDDTS(1)=4
 D CSVOUT^VFDRPARI(VFDFILN,VFDX,U,U,.VFDDTS,VFDPATH)
 S VFDRET="1^"_VFDFILN
 Q
 ;
D1(IFN) ; return RXNORM code for a drug
 ;  IFN - req - internal entry number to file 50
 N X,Y,Z Q:$G(IFN)<1 ""
 S X=$$GET1(50,IFN,22,"I")
 Q $S(X<1:"",1:$$GET1(50.68,X,21601.01))
 ;
D2(IFN,ORX) ; return RXNORM code for an orderable item
 ;  IFN - opt - IEN to file 101.43
 ;  ORX - opt - IEN to file 100
 ; either IFN or ORX must be passed in
 N X,Y,Z
 I $G(IFN)<1,$G(ORX)<1 Q ""
 I $G(IFN)<1 S X="1,"_ORX_",",IFN=$$GET1(100.001,X,.01,"I") I 'IFN Q ""
 S Y=+$$GET1^DIQ(101.43,IFN_",",2,"I") ; pointer to DRUG (#50) file
 Q $S(Y<1:"",1:$$D1(Y))
 ;
GET1(FILE,VIENS,FLD,FLG) ; get one value from record
 ; extrinsic function
 ;  FILE - req - file or subfile number
 ; VIENS - req - record number or valid IENS string
 ;   FLD - req - field number in FILE
 ;   FLG - opt - default to "", return field external value
 ;                I - return field internal value
 ;
 N X,Y,Z,DIERR,VFDER
 I '$G(FILE)!'$G(VIENS)!'$G(FLD) Q ""
 I $E(VIENS,$L(VIENS))'="," S VIENS=VIENS_","
 S X=$$GET1^DIQ(FILE,VIENS,FLD,$G(FLG),,"VFDER")
 Q $S($D(DIERR):"",1:X)
 ;
GETS(VFDXR,FILE,VIENS,FLD,FLG) ; get one or more field values
 ; this is designed to only return field values for a single level
 ; For FILE,VIENS,FLD,FLG - see GET1       
 ; VFDRET - return array
 ;   if FLG=""!(FLG="I")!(FLG="E"), VFDRET(field)=value
 ;   if FLG="IE", VFDRET(field)=internal value^external value
 ;
 N X,XR,Y,Z,DIERR,VFDER,VFDA
 I '$G(FILE)!'$G(VIENS)!'$G(FLD) Q
 I $E(VIENS,$L(VIENS))'="," S VIENS=VIENS_","
 S FLG=$G(FLG) S:FLG="" FLG="E" S:FLG="EI" FLG="IE"
 D GETS^DIQ(FILE,VIENS,FLD,$G(FLG),"VFDA","VFDER")
 I '$D(DIERR) S FLD=0 F  S FLD=$O(VFDA(FILE,VIENS,FLD)) Q:'FLD  D
 .S X=$G(VFDA(FILE,VIENS,FLD,"I"))
 .S Y=$G(VFDA(FILE,VIENS,FLD,"E"))
 .S VFDXR(FLD)=$S(FLG="E":Y,1:X)
 .I FLG="IE" S $P(VFDXR(FLD),U,2)=Y
 .Q
 Q
 ;
SET(SD,ED) ;
 S CNT=CNT+1
 S ^TMP("VFDORDP",$J,CNT)=DFN_U_RXNORM_U_SD_U_ED_U_TYP
 Q
 ;
MEDS(VFDXR,DFN,BEG,END,FILTER) ; get medication history
 ;    DFN - req - pointer to patient file
 ;    BEG - opt - start date in FM format, default to END-<1 year>
 ;    END - opt - end date in FM format, default to today
 ;.FILTER - opt - 
 ; Return - VFDXR - named reference to return data [@vfdxr@()]
 ;          if name not passed in then set ^TMP("VFDORDP",$J)
 ;@VFDXR@(n) = p1^p2^...^pn where
 ;
 ;
 ;NOTES:
 ;S X0=$P(^TMP("PS",$J,n,0),X=$P(X0,U)
 ; I X["R" then reference data from ^PSRX(+X)
 ; I X["P" then reference data from ^PS(53.1,+X)
 ; I X["U" then reference data from ^PS(55,DFN,5,+X)
 ; I X["V" then reference data from ^PS(55,DFN,"IV",+X)
 N I,X,Y,Z,VIEW
 S VFDXR=$G(VFDXR) I VFDXR="" S VFDXR=$NA(^TMP("VFDORDP",$J))
 I $G(DFN)<1!'$D(^DPT(+$G(DFN),0)) D ERR(1) Q
 S:'$G(END) END=DT S:END'["." END=END+.24
 S BEG=$G(BEG) S:'BEG BEG=($E(BEG,1,5)-100)_"00"
 S VIEW=0
 D OCL^PSOORRL(DFN,BEG,END,VIEW)
 Q
 ;
ERR(N) ;
 ;;No patient DFN received
 S @VFDXR@(1)="-1^"_$P($T(ERR+N),";",3)
 Q
