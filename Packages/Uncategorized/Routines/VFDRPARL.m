VFDRPARL ;DSS/LM - ARRA VTE APIs ; 06/03/2011 11:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 Q
 ;
 ; Population : Patients admitted to and discharged from the hospital for inpatient acute care
 ;
POP(VFDRSLT,VFDSDT,VFDEDT) ;[Public] Population List
 ; VFDRSLT=[Required] $NAME of return list (Or array by reference)
 ; VFDSDT=[Required] Start date.time (Fileman format)
 ; VFDEDT=[Required] End date.time (Fileman format)
 ;
 I $G(VFDSDT),$G(VFDEDT) S:'$L($G(VFDRSLT)) VFDRSLT=$NA(VFDRSLT)
 E  Q  ;Invalid parameter
 ;
 ; Code here
 ;
 Q
 ;
GET(VFDRSLT,VFDSDT,VFDEDT,FLAG) ; get list of patient movements
 ; VFDRSLT - req - $NAME value of return list
 ;  VFDSDT - req - start date.time (FM)
 ;  VFDEDT - req -   end date.time (FM)
 ;    FLAG - opt - string of codes to determine which movements to get
 ;                 string [ A - admission movement
 ;                        [ D - discharge movement
 ;                        [ T - transfer movement (not specialty transfer)
 N I,J,X,Y,Z,DIERR,VFDSCR
 N VFDADT,VFDADX,VFDI,VFDR,VFDVIEN
 I $G(VFDSDT),$G(VFDEDT),$L($G(VFDRSLT))
 E  Q  ;Invalid or missing parameter
 ;
 S VFDR=$NA(^TMP("VFDAPARL",$J)) K @VFDR,@VFDRSLT
 S FLAG=$G(FLAG) S:FLAG="" FLAG="D"
 S VFDSCR="I (+^(0)>VFDEDT),"
 S X="" I FLAG["A" S X=1
 I FLAG["D" S X=X_3
 I FLAG["T" S X=X_2
 S VFDSCR="I (+^(0)'>VFDEDT),("_X_"[$P(^(0),U,2))"
 D MOVE
 D CLEAN^DILF
 Q
 ;
MOVE ; private
 ;DIS(VFDRSLT,VFDSDT,VFDEDT) ;[Public] Inpatient Discharges List
 ; VFDRSLT=[Required] $NAME of return list
 ; VFDSDT=[Required] Start date.time (Fileman format)
 ; VFDEDT=[Required] End date.time (Fileman format)
 ;
 ; Return array:  p1^p2^...^p8^P9 where
 ;   p1 = DFN - Patient IEN
 ;   p2 = Admission DT
 ;   p3 = Discharge DT (exists for admit/discharge moves only)
 ;   p4 = Admission visit IEN
 ;   p5 = Discharge movement IEN
 ;   P6 = Coded admit diagnosis
 ;   p7 = Movement IEN - may be admission move ien, or the same as p5
 ;   p8 = Movement transaction type (set of codes from ^DD(405,.02)
 ;   p9 = associated admission movement ien
 ;
 N X,Y,MVIEN,VFADM,VFDISCH,VFDZ,VSAVE
 S X="@;.01;.02;.03;.14;.17"
 D LIST^DIC(405,,X,"I","*",VFDSDT,,"B",VFDSCR,,VFDR)
 ; Build return array
 F VFDI=1:1:+$G(@VFDR@("DILIST",0)) D
 .K VFDZ M VFDZ=@VFDR@("DILIST","ID",VFDI)
 .S MVIEN=@VFDR@("DILIST",2,VFDI),VFADM=VFDZ(.14),VFDISCH=VFDZ(.17)
 .S VFDZ=VFDZ(.03)_U_U_VFDZ(.01)_U_U_U_U_MVIEN_U_VFDZ(.02)_U_VFADM
 .I VFDISCH S VFDZ(.17,0)=$$GET1^DIQ(405,VFDISCH,.01,"I")
 .S X=$G(VFDZ(.17,0)) I 'X,VFDZ(.02)=3 S X=VFDZ(.01)
 .I X S $P(VFDZ,U,3)=X
 .I VFDZ(.02)=3 S $P(VFDZ,U,5)=MVIEN
 .; get data from the admission movement
 .S X=$$GET1^DIQ(405,+VFADM,.01,"I") S $P(VFDZ,U,2)=X
 .S X=$$GET1^DIQ(405,+VFADM,.27,"I") S $P(VFDZ,U,4)=X
 .S X=$$GET1^DIQ(405,+VFADM,21600.01) S $P(VFDZ,U,6)=X
 .;S VFDADT=$$GET1^DIQ(405,+$G(@VFDR@("DILIST","ID",VFDI,.14)),.01,"I")
 .;S VFDVIEN=$$GET1^DIQ(405,+$G(@VFDR@("DILIST","ID",VFDI,.14)),.27,"I")
 .;S VFDADX=$$GET1^DIQ(405,+$G(@VFDR@("DILIST","ID",VFDI,.14)),21600.01)
 .;S X=$G(@VFDR@("DILIST","ID",VFDI,.03))_U_VFDADT
 .;S X=X_U_$G(@VFDR@("DILIST","ID",VFDI,.01))
 .;S X=X_U_VFDVIEN_U_$G(@VFDR@("DILIST",2,VFDI))_U_VFDADX
 .;S X=X_U_(+VFDI)_U_$G(@VFDR@("DILIST","ID",VFDI,.02))
 .;S @VFDRSLT@(VFDI)=$G(@VFDR@("DILIST","ID",VFDI,.03))_U_VFDADT_U_$G(@VFDR@("DILIST","ID",VFDI,.01))
 .;S @VFDRSLT@(VFDI)=@VFDRSLT@(VFDI)_U_VFDVIEN_U_$G(@VFDR@("DILIST",2,VFDI))_U_VFDADX
 .S @VFDRSLT@(VFDI)=VFDZ
 .Q
 Q
 ;
ISINTBL(VFDRSLT,VFDNPUT,VFDTABLE) ;[Public] Is input in table?
 ; VFDRSLT=[Required] $NAME of return list
 ;                    @VFDRSLT@(I)=1 if *ANY* VALUE found, 0 if *NO* VALUE not found
 ;
 ; VFDNPUT=[Required] $NAME of input list (Or array by reference)
 ;                    @VFDNPUT@(I)=VALUE^VALUE^VALUE^... for lookup in table
 ;
 ; VFDTABLE=[Required] File 21631 Table name or IEN
 ;
 Q:$G(VFDTABLE)=""  Q:$G(VFDRSLT)=""  Q:$G(VFDNPUT)=""
 K @VFDRSLT
 ; 6/3/2011 - Fileman lookup is failing
 I 'VFDTABLE S VFDTABLE=$O(^VFD(21631,"B",VFDTABLE,0))
 ;E  S VFDTABLE=$$FIND1^DIC(21631,,"X",VFDTABLE,"B") ;Convert to IEN
 Q:VFDTABLE<1  ;Table not found
 ;
 N VFDC,VFDI,VFDJ  F VFDI=1:1 Q:'$D(@VFDNPUT@(VFDI))  D
 .S @VFDRSLT@(VFDI)=0
 .F VFDJ=1:1:$L(@VFDNPUT@(VFDI),U) D  Q:@VFDRSLT@(VFDI)
 ..S VFDC=$P(@VFDNPUT@(VFDI),U,VFDJ) Q:VFDC=""
 ..I $D(^VFD(21631,VFDTABLE,1,"B",VFDC)) S @VFDRSLT@(VFDI)=1
 ..Q
 .Q
 Q
 ;
ISPTED(VFDRSLT,VFDNPUT,VFDTOPIC) ;[Public] Does patient have patient education topic in range?
 ; VFDRSLT=[Required] $NAME of return list
 ;                    1^DT of education or 0 if not
 ;
 ; VFDNPUT=[Required] $NAME of input list (Or array by reference)
 ;                    @VFDNPUT@(I)=Patient DFN^[optional] visit IEN^[optional] start dt^[optional] end dt
 ;
 ; VFDTOPIC=[Require] EDUCATION TOPIC to check, name or IEN
 ;
 I $L($G(VFDRSLT)),$L($G(VFDNPUT)),$L($G(VFDTOPIC)) K @VFDRSLT
 E  Q  ;Missing or invalid parameter
 I VFDTOPIC,VFDTOPIC=+VFDTOPIC
 E  S VFDTOPIC=$$FIND1^DIC(9999999.09,,"X",VFDTOPIC,"B") ;Convert to IEN
 Q:'(VFDTOPIC>0)  ;Topic not found
 ;
 N VFDI,VFDDFN,VFDEDT,VFDSDT,VFD,VFDT,VFDVIEN
 F VFDI=1:1 Q:'$D(@VFDNPUT@(VFDI))  D
 .S VFDDFN=+@VFDNPUT@(VFDI),VFDVIEN=$P(@VFDNPUT@(VFDI),U,2)
 .S VFDSDT=$P(@VFDNPUT@(VFDI),U,3),VFDEDT=$P(@VFDNPUT@(VFDI),U,4)
 .S:'VFDEDT VFDEDT=9999999
 .S (VFD,VFDT)=0 F  S VFDT=$O(^PXRMINDX(9000010.16,"IP",VFDTOPIC,VFDDFN,VFDT)) Q:VFD!'VFDT  D
 ..I '(VFDT<VFDSDT),'(VFDT>VFDEDT) S VFD=VFDT
 ..Q
 .S @VFDRSLT@(VFDI)=$S(VFD:"1^"_VFD,1:0)
 .Q
 Q
IS21640(VFDRSLT,VFDNPUT,VFDTABLE) ;For each VISIT in @VFDNPUT,
 ; does any 21640.01 value (SNOMED code) for that VISIT exist in VFDTABLE
 ;
 ; VFDRSLT=[Required] $NAME of return list
 ;                    1 or 0
 ;
 ; VFDNPUT=[Required] $NAME of input list of VISIT IENs
 ; VFDTABLE=[Required] File 21631 Table name or IEN
 ;
 I $L($G(VFDTABLE)),$L($G(VFDRSLT)),$L($G(VFDNPUT)) K @VFDRSLT
 E  Q  ;Missing or invalid parameter
 I VFDTABLE,VFDTABLE=+VFDTABLE
 E  S VFDTABLE=$$FIND1^DIC(21631,,"X",VFDTABLE,"B") ;Convert to IEN
 Q:'(VFDTABLE>0)  ;Table not found
 ; 
 N VFDA,VFDHIT,VFDI,VFDVIEN,VFDX,VFDY
 F VFDI=1:1 Q:'$D(@VFDNPUT@(VFDI))  D
 .S VFDVIEN=@VFDNPUT@(VFDI)
 .S (VFDA,VFDHIT)=0 ;Initialize hit=false
 .F  S VFDA=$O(^VFD(21640.01,"AD",VFDVIEN,VFDA)) Q:'VFDA!VFDHIT  D
 ..S VFDX(1)=$$GET1^DIQ(21640.01,VFDA,.01) ;SNOMED code
 ..D ISINTBL($NA(VFDY),$NA(VFDX),VFDTABLE)
 ..S VFDHIT=$G(VFDY(1))
 ..Q
 .S @VFDRSLT@(VFDI)=VFDHIT
 .Q
 Q
