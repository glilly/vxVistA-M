VFDXTRU1 ;DSS/SGM - ROUTINE UTILITIES ; 07/28/2011 18:27
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;THIS ROUTINE SHOULD ONLY BE INVOKED VIA THE VFDXTRU ROUTINE
 ;
 ;DBIA# Supported References
 ;----- -----------------------------------------------
 ;10026 ^DIR
 ;      ^DIC
 ;      ^DIC: $$FIND1, $$GET1
 ;      ^DIQ: $$GET1
 ;      $$CJ^XLFSTR
 ;      ^%ZOSF - all node can be referenced
 ;      RTN^XTRUTL1
 ;
ASK() ; >>>>>  ASK FOR METHOD TO GET LIST OF ROUTINES
 ;
 ;  VFDR - opt - named reference to put list of routines (@VFDR@(name))
 ;               default to ^UTILITY($J)
 ;NOINIT - opt - Boolean, default to 0, if '$G(NOINIT) then K @VFDR
 ;               prior to getting list of routines
 ;SOURCE - opt - null or F or B or 9.6_ien>0
 ;               null is default, ask for method
 ;               F = use routine selecter   B = ask for Build file name
 ;               +SOURCE = Build file ien
 ;Extrinsic Function returns
 ;  if problems, return -1, -2, or -3
 ;  -1 if source="" and no method selected
 ;  else return number of routines selected
 ;Return @VFDR@(n) where if n=0 @vfdr@(0)=p1^p2^p3^p4^p5
 ;p1=tot # rtns   p2=pkg name  p3=pkg nmsp  p4=build ien  p5=build name
 ;if n'=0 @vfdr@(routine name)=""
 ;NOTES: this will K ^UTILITY($J) if VFDR'=$NA(^UTILITY($J)) or 'NOINIT
 ;
 N I,X,Y,Z,TOT,UTL
 S NOINIT=+$G(NOINIT),SOURCE=$G(SOURCE),VFDR=$G(VFDR)
 I SOURCE="" S SOURCE=$$DIR^VFDXTR09(3) I +SOURCE=-1 Q SOURCE
 I VFDR="" S VFDR=$NA(^UTILITY($J))
 S UTL=$NA(^UTILITY($J)) K:'NOINIT @VFDR,@UTL K:UTL'=VFDR @UTL
 I SOURCE="F" S TOT=$$RSEL(VFDR)
 I SOURCE'="F" S TOT=$$BLD(VFDR,+SOURCE)
 I VFDR'=UTL K @UTL
 Q TOT
 ;
ASKPATH() ; >>>>> interactive entry to prompt for path name
 ;
 ; syntax of path is not verified
 ; VPATH - opt - default path
 ; return user input or <null>
 ;
 S VPATH=$G(VPATH) S:VPATH="" VPATH=$$PATH^VFDXTRU2
 Q $$DIR^VFDXTR09(5)
 ;
BLD(VFDR,VAL,KU) ; >>>>>  GET LIST OF ROUTINES FROM BUILD FILE
 ;
 ; VFDR - opt - named reference to place routine names, @vfdr@(name)=""
 ;              default to ^UTILITY($J)
 ;  VAL - opt - I +VAL>0, then val=<file 9.6 ien>, else ask for Build
 ;   KU - opt - Boolean, I KU K ^UTILITY($J) prior to getting routines
 ; Extrinsic function returns -1^[message] OR total number of routines
 ;   Also return @vfdr@(0) = p1^p2^p3^p4^p5^p6 where
 ;   p1 = total # routines   p2 = build ien       p3 = build name
 ;   p4 = build namespace    p5 = build version   p6 = patch#
 ;
 N I,X,Y,Z,TOT,UTL,VFDVAL,VIEN,VRET
 S VIEN=0,VFDR=$G(VFDR),VAL=$G(VAL),KU=$G(KU)
 I VAL<1 D  I Y<1 Q -1
 .N DIC,DTOUT,DUOUT
 .S DIC=9.6,DIC(0)="QAEMZ" D ^DIC S:Y>0 VAL=+Y
 .Q
 S VFDVAL=VAL D BLDNM
 S X=$G(VFDVAL(0)) I X'="" Q "-1^"_X
 ;
 S UTL=$NA(^UTILITY($J)) K:$G(KU) @UTL
 D RTN^XTRUTL1(VFDVAL("IEN"))
 S (X,TOT)=0
 F  S X=$O(@UTL@(X)) Q:X=""  S TOT=TOT+1 S:UTL'=VFDR @VFDR@(X)=""
 I VFDR'="",UTL'=VFDR K @UTL
 S Z=TOT F X="IEN","BLD","NMSP","VER","PATCH" S Z=Z_U_VFDVAL(X)
 S @VFDR@(0)=Z
 Q TOT
 ;
BLDNM ; >>>>>  GET BUILD FILE NAME AND DATA
 ;
 ; VFDVAL - req - BUILD file name lookup value
 ;                This is also the return variable named reference
 ;   if problems, return VFDVAL(0) = error message
 ;                 VFDVAL(1)       = ien^buildname^nmsp^ver^patch
 ;   else return   VFDVAL("BLD")   = build name
 ;                       ("IEN")   = build file ien
 ;                       ("NMSP")  = package namespace
 ;                       ("PATCH") = patch number
 ;                       ("VER")   = version
 ;
 N A,I,X,Y,Z,BLD,DIERR,VAL,VFDA,VFDER
 I $G(VFDVAL)="" S VFDVAL(0)=$P($$ERR(7),U,2) Q
 S VAL=$S(+VFDVAL:"`"_VFDVAL,1:VFDVAL)
 D FIND^DIC(9.6,,"@;.01;1I;4","APQX",VAL,,,,,"VFDA","VFDER")
 I $D(DIERR) S VFDVAL(0)=$P($$ERR(2),U,2) Q
 I +$G(VFDA("DILIST",0))'=1 S VFDVAL(0)=$P($$ERR(1),U,2) Q
 S X=VFDA("DILIST",1,0)
 S A=+X,VFDVAL("IEN")=+X
 S Y=$P(X,U,2),A=A_U_Y,VFDVAL("BLD")=Y
 S Z="" S:Y["*" Z=$P(Y,"*") S VFDVAL("NMSP")=Z,A=A_U_Z
 S Z=$P(Y,"*",3),VFDVAL("PATCH")=Z,$P(A,U,5)=Z
 S Y=$P(X,U,4),VFDVAL("VER")=Y,$P(A,U,4)=Y,VFDVAL(1)=A
 S Z="",Y=(+X)_"," I $P(X,U,3) S Z=$$GET1^DIQ(9.6,Y,"1:1","E",,"VFDER")
 S VFDVAL("PKG")=Z,$P(VFDVAL(1),U,3)=Z
 Q
 ;
MSG(STR,CJ) ; >>>>>  WRITE MESSAGE HEADER
 ;
 S CJ=$G(CJ) S:CJ="" CJ=" " D WR1(STR,CJ,2) Q
 ;
ROUDSP ; >>>>>  DISPLAY LIST OF ROUTINES
 ;
 ; VFDR - req - named ref containing routine names @vfdr@(name)=value
 ;   Default to ^UTILITY($J).  Value is null or characters to add to
 ;   beginning of routine name in display
 ; TITLE - opt - title to display before list of routines 
 ;
 N I,X,Y,Z,SP,TOT
 I TITLE'="" D WR1(TITLE," ",1,,12)
 S (X,TOT)=0,$P(SP," ",15)=""
 W ! F  S X=$O(@VFDR@(X)) Q:X=""  S Y=@VFDR@(X) D
 .S Z=X,TOT=1+TOT
 .I Y?1P,Y'=" " S Z=Y_X,TOT(Y)=1+$G(TOT(Y))
 .W $E(Z_SP,1,10) W:$X>70 !
 .Q
 W !!,"Total number of routines: "_TOT
 I $O(TOT(0)) S X=0 D
 .F  S X=$O(TOT(X)) Q:X=""  W !,"Total routines with "_X_":    "_TOT(X)
 .Q
 I TITLE'="" D WR1(,,-1,1,2)
 Q
 ;
ROUSEE ; >>>>>  ASK TO SEE SELECTED ROUTINES
 ;
 ;   VFDR - opt - named reference, default to ^UTILITY($J)
 ;                expects list of routine names @VFDR@(X)
 ; TITLE - opt - title to display before list of routines
 ;
 N I,X,Y,Z
 S VFDR=$G(VFDR) S:VFDR="" VFDR=$NA(^UTILITY($J))
 D:$$DIR^VFDXTR09(2)=1 ROUDSP
 Q
 ;
RSEL(VFDG,KU) ; >>>>>  CALL M ROUTINE SELECTOR
 ;
 ; VFDG - opt - named reference to place routine names, @vfdg@(name)=""
 ;   KU - opt - Boolean, I KU K ^UTILITY($J) prior to getting routines
 ;
 N I,X,Y,Z,TOT,UTL
 S KU=$G(KU),UTL=$NA(^UTILITY($J)) K:KU @UTL
 X $$ZOSF^VFDXTRU("RSEL")
 S VFDG=$G(VFDG),(X,TOT)=0
 F  S X=$O(@UTL@(X)) Q:X=""  S TOT=TOT+1 S:VFDG'="" @VFDG@(X)=""
 I TOT,VFDG'="" S @VFDG@(0)=TOT
 I VFDG'="",UTL'=VFDG K @UTL
 Q TOT
 ;
WR1(X,CJ,SLF,ELD,LINE) ; called from within this routine
WR ; >>>>>  COMMON SCREEN WRITE UTILITY
 ;
 ;    X - req - string to write out
 ;   CJ - opt - single char to use in center justifying
 ;  SLF - opt - # of leading line feeds, default to 1
 ;             if SLF<0 then no leading line feeds
 ;  ELF - opt - # of ending line feeds, default to 0
 ; LINE - opt - if 1 then write a dashed line before write x
 ;              if 2 then write a dashed line after write x
 ;
 N I,L,Y,Z
 S X=$G(X) S:$E(X)'=" " X=" "_X S:$E(X,$L(X))'=" " X=X_" "
 S $P(L,"-",80)=""
 S CJ=$G(CJ),LINE=$G(LINE)
 S SLF=$G(SLF) S:'SLF SLF=1
 I SLF>0 F I=1:1:SLF W !
 I LINE[1 W L,!
 S Y=X S:CJ'="" Y=$$CJ^XLFSTR(X,80,CJ) W Y
 I LINE[2 W !,L
 I $G(ELF) F I=1:1:ELF W !
 Q
 ;
ZOSF() ; >>>>>  RETURN CONTENTS OF ^%ZOSF NODE
 ;
 ;;N DIF,XCNP K @VFDR S XCNP=0,DIF=$TR(VFDR,")",",") ZR  
 ;;N %,XCM,XCN,DIE S DIE=$TR(VFDR,")",","),XCN=0 
 N I,X,Y,Z
 S NODE=$G(NODE) I NODE="" Q ""
 S Z=$G(^%ZOSF(NODE)) I NODE="" Q ""
 I "^LOAD^SAVE^"'[(U_NODE_U) Q Z
 I $G(VFDR)="" Q Z
 I NODE="LOAD" S Y=$P($T(ZOSF+2),";",3)_Z
 I NODE="SAVE" S Y=$P($T(ZOSF+3),";",3)_Z
 Q Y
 ;
 ; >>>>>>>>>>   Private Subroutines for VFDXTR*   <<<<<<<<<<
 ;
ERR(A) ;
 N T
 I A=1 S T="KIDS Build file with value "_VAL_" not found"
 I A=2 S T="Error getting data from Build record number "_VAL
 I A=3 S T="No routines found in KIDS Build IEN: "_VAL
 I A=4 S T="No value for path received"
 I A=5 S T="No host files server (HFS) name received"
 I A=6 S T="No value for the ROOT parameter received"
 I A=7 S T="No input value received"
 Q "-1^"_T
 ;
UP(A) Q $$UP^XLFSTR(A)
