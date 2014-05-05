VFDXPD01 ;DSS/SMP - COMMON APIS FOR VFDXPD CONT. ; 01/31/2012 10:25
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD0 routine
 ;
 ;----------------  ASK FOR DEVICE AND DISPLAY REPORT  ----------------
ASKRPT ;
 N I,J,X,Y,Z
 I '$O(RPT(0)) W:$G(TXT)'="" !!?3,TXT,! Q
 ; select output form
 I '$G(OUT) S OUT=$$DIR^VFDXPD0(8) Q:OUT<1
 I OUT=3 Q:'$$OUTHFS
 I OUT=1 D BROWSE^DDBR("RPT","N") Q
 I OUT=2 S Z=$$OUTTERM Q:Z<0  W !
 W ! S I=0 F  S I=$O(RPT(I)) Q:'I  W RPT(I),!
 I OUT=2 R !!?5,"Press any key to continue  ",X:DTIME
 D:OUT=3!($G(Z)) ^%ZISC
 Q
 ;
 ;------------------  GET A LIST OF KIDS HFS FILES  -------------------
FLIST ;
 ; Return VFLIST(filename_root,file_extension)=full filename
 ;  Or errors in VFDXERR()
 N X,VEXT
 S VEXT("DAT")="" I '$G(DATONLY) S (VEXT("KID"),VEXT("TXT"))=""
 I $G(PATH)="" S VFDXERR(1)=$$ERRMSG(1) Q
 S X=$$FILELIST^VFDXPDC(.VFDLIST,PATH,.VEXT,"DM",,.VFDXERR)
 S:'X VFDXERR(1)=$$ERRMSG(2)
 Q
 ;
 ;---------------  FIND/ADD A STUB BUILD NAME TO FILE 21692  ---------------
FINDBLD() ;
 I $G(VFDNAME)="" Q $$ERRMSG(5)
 N I,J,X,Y,Z,VFDNM,VFDX
 S VFDNM=VFDNAME D PARSENM M VFDNAME=VFDNM S X=$G(VFDNM("BLD"))
 I X="" Q $$ERRMSG(3)
 S Z="",Y=$O(^VFDV(21692,"B",X,0)) S:Y Z=$O(^VFDV(21692,"B",X,Y))
 I Y,Z="" Q Y ; found existing entry
 I Y,Z Q $$ERRMSG(4)_X
 S VFDX(.01)=X,VFDNM=X
 S VFDX(.02)=DT
 S VFDX(.03)=DUZ
 S VFDX(.1)="u"
 S VFDX(.06)=+VFDNM("VER")
 S VFDX(.061)=+VFDNM("PATCH")
 S VFDX(.07)=+VFDNM("SEQ")
 S Z=VFDNM("PKG") S:Z'="" VFDX(.05)=Z
 S Y=$$UPDATE^VFDXPDA(21692,"+1,",.VFDX)
 I Y<1 Q $P(Y,U,2)
 S Y=$O(^VFDV(21692,"B",VFDNM,0))_U_VFDNM,VFDNAME("IEN")=+Y
 Q Y
 ;
 ;------------  FIND ALL INSTALLS FOR A SINGLE BUILD NAME  ------------
INSTLIST() ;
 ; VFDAX - req - return array passed by name
 ; VFDNM - req - name of Build to find in INSTALL file
 ;   ACT - opt - flag to affect return behavior
 ;     ACT=1 return 1 if last entry in 9.7 has status of 3
 ;                  2 if last entry in 9.7 has status of 1 and the
 ;                    previous entry has a stat of 3
 ;                  0 for any other case
 ;     ACT=2 return seq#^build name for last seq# installed for pkg*ver
 ;           else return ""
 ;  FLGS - opt - flags value for FIND^DIC; default to PQX
 ;  FILT - opt - string of codes to screen to use to include search
 ;               results in return - codes are internal STATUS codes
 ;Extrinsic function returns:
 ;  # recs or 0 or -1^msg or if ACT'="" then
 ; @VFDRET@(ien) = p1^p2^p3^p4^p5^p6^p7  where
 ;   p1 = ien                    p5 = external date loaded
 ;   p2 = build name             p6 = internal date install completed
 ;   p3 = status (internal)      p7 = external date install completed
 ;   p4 = internal date loaded
 ; Note: date subscript is date install complete, but if not then
 ;       date install loaded
 ; VFDRET("STAT",int_status,fm_date,ien)=""
 ; VFDRET("LAST",0) = latest date ^ ien  (see note)
 ; VFDRET("LAST",1) = latest install completed date ^ ien
 N A,I,J,X,Y,Z,CDATE,FLDS,IEN,LAST,LDATE,REC,SCR,STAT,VFDZ
 I $G(VFDAX)="" Q -1
 K @VFDAX
 S FLDS="@;.01;.02I;2I;2;17I;17"
 S FLGS=$G(FLGS) S:FLGS="" FLGS="PQX"
 S FILT=$G(FILT),ACT=$G(ACT)
 I FILT'="" S SCR="I $P(^(0),U,9)'="""","""_FILT_"""[$P(^(0),U,9)"
 S REC=$$FIND^VFDXPDA("VFDZ",9.7,,FLDS,FLGS,VFDNM,,,$G(SCR))
 I REC<1 Q REC
 S (LAST,LAST(0))=""
 S I=0 F  S I=$O(VFDZ(I)) Q:'I  S X=VFDZ(I,0) D
 .S IEN=+X,STAT=+$P(X,U,3),CDATE=+$P(X,U,6),LDATE=+$P(X,U,4)
 .S J=CDATE S:'J J=LDATE
 .S @VFDAX@(IEN)=X
 .S @VFDAX@("STAT",STAT,J,IEN)=""
 .I J>LAST(0) S LAST(0)=J_U_IEN
 .I CDATE>LAST S LAST=CDATE_U_IEN
 .Q
 S @VFDAX@("LAST",0)=LAST(0),@VFDAX@("LAST",1)=LAST
 I ACT>0 S REC=$S(ACT=1:$$ACT1,ACT=2:$$ACT2,1:REC)
 Q REC
 ;
 ;-----------  CONVERT HUMAN READABLE DATE/TIME TO FILEMAN  -----------
HTFM(DATE) ; Convert human readable date/time to FM
 ; DATE - req - date(time) in human readable format
 ; Extrinsic function returns FM date.time or -1
 ; Expands FM acceptable input formats especially in the time part
 ; Does not handle gmt time format
 N A,B,I,L,X,Y,Z,SP,STOP,TIME,VERR,VFD
 S DATE=$G(DATE) I DATE="" Q -1
 I DATE?.E1L.E S DATE=$$UP^XLFSTR(DATE)
 ; check to see if date is formatted like AUG 17, 2011
 I DATE?3A1" "2N1", "4N S $P(DATE,",",2)=$P(DATE,", ",2)
 S TIME=""
 I DATE["@" S TIME=$P(DATE,"@",2),DATE=$P(DATE,"@")
 E  I DATE["/",DATE[" " S TIME=$P(DATE," ",2,9),DATE=$P(DATE," ")
 I TIME="",DATE[" " S Y="",(SP,STOP)=0 D
 .F I=$L(DATE):-1:1 S X=$E(DATE,I) D  Q:STOP
 ..I X=" " S SP=1+SP I SP=2 S STOP=1 Q
 ..I X=" ",Y?.E1N.E S STOP=1 Q
 ..; check for trailing am pm
 ..I "APM."[X S Y=X_Y S:Y?.E1N.E Y="",STOP=1 Q
 ..I X'?1(1N,1":") S Y="",STOP=1 Q
 ..S Y=X_Y
 ..I $L($TR(Y,"APM.:"))>6 S Y="",STOP=1
 ..Q
 .I Y'="" S TIME=Y,DATE=$P(DATE," "_Y)
 .Q
 I TIME'="" S Y=$TR(TIME,":. ") D
 .S Z="" F I=$L(Y),$L(Y)-1 S A=$E(Y,I) S:A?1U Z=A_Z
 .S:Z'="" Y=$P(Y,Z) S L=$L(Y)
 .I $E(Z)="P",135[L S Y=(12+$E(Y))_$E(Y,2,5),L=L+1
 .I $E(Z)="A",135[L S Y=0_Y,L=L+1
 .I L=2 S Y=Y_"00",L=L+2
 .S TIME=Y
 .Q
 S:TIME'="" DATE=$TR(DATE," .","//")_"@"_TIME
 D DT^DILF("ST",DATE,.VFD,,"VERR")
 Q VFD_U_DATE
 ;
 ;---------  GET LAST INSTALL FOR A BUILD NAME OR INSTALL IEN  --------
LAST ;
 ;Get list of installed builds or last only
 ;Do with param passing unless LAST=1 then extrinsic function
 ;  VFDNM - req - name or portion of INSTALL name or 9.7_ien
 ;   LAST - opt - null or 1,2,3 ; default to null
 ;     *** Expects VFDNM is exact name of the Build to find ***
 ;     Extrinsic function returns p1^p2^p3^p4 where
 ;       p1 = Build name   p2 = 9.7 ien
 ;       p3 = FM date;external date/time
 ;       p4 = 9.7 internal status;external status
 ;     LAST = 1 return value for last install where 123[status
 ;     LAST = 2 return value for last install where status=0
 ;     LAST = 3 return VALUE for last install where 123[status, but if
 ;              there are none, then return last INSTALL whose status=0
 ;.VFDBLD - Return array of all values found.
 ;     If problems, return VFDBLD(1)=-1^message
 ;     Else return VFDBLD(ien) = p1^p2^p3
 ;       VFDBLD("B",p1,ien)=""
 ;       VFDBLD("D",+p2,ien)=internal status
 ;       VFDBLD("S",+p3,+p2,ien)=""
 ;         p1 = install name
 ;         p2 = FM internal date;external date depending upon STATUS
 ;              Status      Field Value of Date
 ;              Completed   INSTALL COMPLETE TIME (#17)
 ;              Started     INSTALL START TIME (#11)
 ;              Loaded      DATE LOADED (#2)
 ;         p3 = internal status;external status
 ;
 ;  Number increased from default (100) to 1000 by SMP 11/09/11
 ;
 ;
 N I,J,X,Y,Z,FLD,FLAG,STAT,VFDAT,VFDERR
 S LAST=$G(LAST) I $G(VFDNM)="" S VFDBLD(1)="-1^"_$$ERRMSG(6) G LASTOUT
 I 123'[LAST S LAST="",VFDBLD(1)="-1^"_$$ERRMSG(7) G LASTOUT
 ; name^statuses^load d/t^start d/t^install complete d/t
 ; p1=ien                p2=name          p3=int_status
 ; p5=int_load_dt        p6=ext_load_dt
 ; p7=int_start_dt       p8=ext_start_dt
 ; p9=int_complete_dt   p10=ext_complete_dt
 S FLD="@;.01;.02I;2I;2;11I;11;17I;17"
 ;S FLAG="AMOPQ" I LAST S FLAG="AMPX"
 S FLAG="AMOPQ" I LAST S FLAG="AMP"
 S X=$$FIND^VFDXPDA("VFDAT",9.7,,FLD,FLAG,VFDNM,1000)
 I X<1 S VFDBLD(1)=$S(X=0:"",1:X) G LASTOUT
 D STATUS(.STAT)
 S I=0 F  S I=$O(VFDAT(I)) Q:'I  S Z=VFDAT(I,0) D
 .N Y,NM,DC,DL,DS,ST
 .S NM=$P(Z,U,2),ST=$P(Z,U,3)
 .; DL = loaded dt    DS = started dt    DC = completed dt
 .S DL(0)=$P(Z,U,4),DL=$E(DL(0),1,12)_";"_$P($P(Z,U,5),":",1,2)
 .S DS(0)=$P(Z,U,6),DS=$E(DS(0),1,12)_";"_$P($P(Z,U,7),":",1,2)
 .S DC(0)=$P(Z,U,8),DC=$E(DC(0),1,12)_";"_$P($P(Z,U,9),":",1,2)
 .I ST=4 S Y="",Y(0)=0
 .I ST<1 S Y=DL,Y(0)=+DL(0)
 .I ST=3 S Y=DC,Y(0)=DC(0)
 .I ST=2 S Y=DS,Y(0)=DS(0)
 .I ST=1 S:DS(0) Y=DS,Y(0)=DS(0) I 'DS(0) S Y=DL,Y(0)=DL(0)
 .S VFDBLD(+Z)=NM_U_Y_U_ST_";"_STAT(ST)
 .S VFDBLD("B",NM,+Z)=""
 .S VFDBLD("D",Y(0),+Z)=ST
 .S VFDBLD("S",ST,Y(0),+Z)=""
 .Q
 ;
LASTOUT ;
 Q:'LAST  N INS,LOAD
 ; return extrinsic function value
 ; above code ensures that we have a VFDBLD()
 S Z="",X=$NA(VFDBLD("D"," "))
 I 13[LAST F  S X=$Q(@X,-1) Q:X=""  Q:$QS(X,1)'="D"  D
 .I @X>0,123[@X S I=$QS(X,3),Z=$$LZ
 .Q
 I Z'="" Q Z
 I 23'[LAST Q "-1^"_$$ERRMSG(8)
 ; should only be looking for LOADED Installs
 S I=0,Y=$O(VFDBLD("S",0," "),-1) I Y S I=$O(VFDBLD("S",0,Y," "),-1)
 S Z=$S(I>0:$$LZ,1:"-1^"_$$ERRMSG(8))
 Q Z
 ;
LZ() Q $P(VFDBLD(I),U)_U_I_U_$P(VFDBLD(I),U,2,3)
 ;
 ;--------------  PARSE A BUILD NAME INTO ITS COMPONENTS  -------------
PARSENM ;
 ; VFDNM - req - Build name
 ;   FLG - opt - if FLG=1 then old method indication ext. funct. call
 ;               if FLG>1 then ALWAYS return all data even if null
 ; If ext funct the return "" or pkg^ver^patch^seq^build name
 ; If DO then return VFDNM(sub)=value where sub will be
 ;    PKG   VER   PATCH   SEQ  BLD
 ;    if problems then $O(VFDNM(0))=""
 ; Version will have a decimal value
 ; if name from mailman patch message it will contain SEQ #
 N I,L,X,Y,Z,RET S RET=""
 I $G(VFDNM)="" G PAROUT
 S X=$$UP^VFDXPD0(VFDNM)
 I $G(FLG)>1 D
 .S RET="^^^^"
 .F Z="PKG","VER","PATCH","SEQ","BLD" S VFDNM(Z)=""
 .Q
 F I=1:1:5 S Z(I)=""
 I X["*" D
 .S Z(1)=$P(X,"*")
 .S Z(2)=$P(X,"*",2) I Z(2)'["." S Z(2)=Z(2)_".0"
 .S Z(3)=+$P(X,"*",3)
 .S Z(4)=$P(X,"SEQ #",2)
 .S Z(5)=Z(1)_"*"_Z(2)_"*"_Z(3)
 .Q
 I X'["*" D
 .S L=$L(X," ")
 .S Z(1)=$P(X," ",1,L-1)
 .S Z(2)=$P(X," ",L)
 .I Z(2)'["." S Y=+Z(2),Y(0)=$P(Z(2),Y,2,99),Z(2)=Y_".0"_Y(0)
 .S Z(3)=""
 .S Z(4)=""
 .S Z(5)=Z(1)_" "_Z(2)
 .Q
 I Z(2)'?1.N1"."1.N,Z(2)'?1.N1"."1.N1"."1.N G PAROUT
 I X["*",Z(3)'?1.N G PAROUT
 S Y="PKG^VER^PATCH^SEQ^BLD"
 I '$Q F I=1:1:5 S Z=$P(Y,U,I),VFDNM(Z)=Z(I)
 E  S RET="" F I=1:1:5 S $P(RET,U,I)=Z(I)
PAROUT ;
 Q:$Q RET Q
 ;
 ;----------------  CREATE OR EDIT A PROCESSING GROUP  ----------------
PID(EDIT,SCR,VNEW) ;
 ;INPUT PARAMS:
 ; edit - opt - Boolean, default to 0, if 1 edit processing group date
 ;  scr - opt - Boolean, if +SCR, filter out completed batches
 ; vnew - opt - Boolean, if +VNEW allow creation of a new batch
 ;Return file 21692.1 ien or -1
 N I,J,X,Y,Z,DIC,VFDX
 S DIC=21692.1,DIC(0)="QAEM"
 S VNEW=$G(VNEW) I $G(VNEW) S DIC(0)="QAEML",VNEW=21692.1
 I $G(SCR) S DIC("S")="I '$P(^(0),U,3)"
 I $G(EDIT) S DIC("DR")=.02
 S VFDX=$$DIC^VFDXPDA(.DIC,VNEW) I VFDX<0 S VFDX=$S(VFDX=-1:0,1:-1)
 S Z=".02;.03"
 I VFDX>0,$G(EDIT),'$P(VFDX,U,3) S X=$$DIE^VFDXPDA(21692.1,+VFDX,Z)
 Q $P(VFDX,U,1,2)
 ;
 ;--------------------------  MISCELLANEOUS  --------------------------
OUT() ; select output device type
 S OUT=$$DIR^VFDXPD0(8) S:OUT<0 OUT=0 Q OUT
 ;
OUTHFS() ; enter hfs filename
 N %ZIS,POP S OUT=3
 W !!,"Select your HFS Device File name",!!
 S %ZIS("B")="HFS" D ^%ZIS I POP D ^%ZISC S OUT=0
 I OUT U IO
 Q OUT
 ;
OUTTERM() ; set 132 column mode if necessary
 N I,X,Y,Z,%ZIS,IOP,POP
 W !! S Z=$$DIR^VFDXPD0(13) I Z<0 Q -1
 I Z=0 Q 0 ; 80-col
 S %ZIS="",IOP=";C-VT132;132;9999" D ^%ZIS I POP Q -1
 Q 1
 ;
STAT(IEN,VAL) ; return Build Description (#21692) status
 ;Extrinsic function returns single letter STATUS
 ;If BATCH() is defined use it.
 ; IEN - opt - pointer to file 21692
 ; VAL - opt - internal value 21692 STATUS field
 N I,J,X,Y,Z,VFDR
 S IEN=$G(IEN),VAL=$G(VAL)
 I VAL="",'IEN Q -1
 I VAL="" S X=$P($G(BATCH(IEN)),U,7) I X'="" S VAL=X
 I VAL="" S VAL=$$GET1^VFDXPDA(21692,IEN_",",.1,"I") I +VAL=-1 Q -1
 Q $S(VAL'?1N:VAL,1:$E("KMP",VAL))
 ;
 ;
STATUS(VFDSTAT) ; get the list of STATUSes (#.02) from INSTALL file
 N I,J,X,Y,Z,VTMP,VFDER
 D FIELD^DID(9.7,.02,,"POINTER","VTMP","VFDER")
 F I=1:1 S X=$P(VTMP("POINTER"),";",I) Q:X=""  D
 .S Y=$P(X,":",2),X=+X,Y=$S(X'=3:$P(Y," "),1:$P(Y," ",2))
 .S VFDSTAT(+X)=Y
 .Q
 Q
 ;
 ;=====================================================================
ACT1() ; last INSTALL with newest complete date
 N X,Y,Z
 I 'LAST Q 0
 I $P(LAST,U,2)=$P(LAST(0),U,2) Q 1
 I LAST>LAST(0) Q 1
 ; at this point the record with the latest date does not have stat=3
 S X=$P(LAST,U,2),Y=$P(VFDZ(X),U,3) I Y'=1 Q 0
 S X=$P(LAST(0),U,2),Y=$P(VFDZ(X),U,3) I Y'=3 Q 0
 Q 1
 ;
ACT2() ; get the last sequence number installed
 ; assumes patches installed in proper sequence, so no check for
 ; last install date
 N I,J,X,Y,Z,NM,SEQ,STAT
 S SEQ="",I=0 F  S I=$O(VFDZ(I)) Q:'I  S X=VFDZ(I,0) D
 .S NM=$P(X,U,2),STAT=$P(X,U,3),Y=""
 .I NM["*" S J=$O(^VFDV(21692,"AE",NM,0)) S:J Y=^(J)
 .I Y'="",STAT=3,Y>SEQ!(SEQ="") S SEQ=Y_U_NM
 .Q
 Q SEQ
 ;
ERRMSG(A,B) ;
 ;;No path value received
 ;;No KIDS files found in the directory
 ;;Unable to parse name properly
 ;;Duplicate records exists in file 21692 for 
 ;;No Build name received
 ;;No INSTALL name or ien received
 ;;Invalid input parameter received
 ;;No INSTALL records found matching input criteria
 I +$G(A) Q $P($T(ERRMSG+A),";",3)
 Q
 ;
VFDXREF(VFDPARAM) ;
 ; Sets or Kills the "AVFD" cross-reference in the install file
 ; VFDPARAM - req - flag to affect which commands are executed
 ;      = "S" sets the x-ref
 ;      = "K" kills the x-ref
 ;
 ; EXPECTED VARIABLES
 ; X(1) = NAME (.01, 0;1)
 ; X(2) = STATUS (.02, 0;9)
 ; X(3) = PACKAGE FILE LINK (1, 0;4)
 ; X(4) = INSTALL COMPLETE TIME (17, 1;3)
 ; X(5) = SEQ# (62, 6;2)
 ; 
 ; TIME SHOULD CORRESPOND TO THE STATUS
 ; i.e., if STATUS = 0 (Loaded) Time should be the time loaded, not the time installed
 N Y,VFD,OUT,FIELD S VFD=X(1) D PARSENM^VFDXPD0(.VFD,2) Q:VFD("PKG")=""
 S VFD("SEQ")=$S($G(X(5))>0:X(5),1:+VFD("SEQ"))
 I VFD["*",VFD("SEQ")=0 D
 .D FIND^VFDXPDA("OUT",21692,,"@;.07","X",VFD,,"B",,)
 .S VFD("SEQ")=+$G(OUT("ID",1,.07)) K OUT
 I +$G(X(2))'=3 S Y=+$G(X(2)) D
 .S FIELD=$S(Y=0:2,Y=1:2,Y=2:11,1:17)
 .D FIND^VFDXPDA("OUT",9.7,,"@;"_FIELD_"I","X",VFD,,"B",,)
 .S X(4)=+$G(OUT("ID",1,FIELD)) K OUT
 I $G(VFDPARAM)="S" D
 .S ^XPD(9.7,"AVFD",VFD("PKG"),+VFD("VER"),"S",VFD("SEQ"),+$G(X(2)),+$G(X(4)),DA)=""
 .S ^XPD(9.7,"AVFD",VFD("PKG"),+VFD("VER"),"D",+$G(X(2)),+$G(X(4)),VFD("SEQ"),DA)=""
 I $G(VFDPARAM)="K" D
 .K ^XPD(9.7,"AVFD",VFD("PKG"),+VFD("VER"),"S",VFD("SEQ"),+$G(X(2)),+$G(X(4)),DA)
 .K ^XPD(9.7,"AVFD",VFD("PKG"),+VFD("VER"),"D",+$G(X(2)),+$G(X(4)),VFD("SEQ"),DA)
 Q
 ;
