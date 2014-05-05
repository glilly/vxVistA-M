VFDXTRU ;DSS/SGM - ROUTINE UTILITIES ; 07/28/2011 14:37
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#   Description
 ;------  -------------------------------------------------------
 ;        $$CJ^XLFSTR
 ;        ^%ZOSF - all nodes can be referenced
 ;
 ;
 ;=============  ASK FOR METHOD TO GET LIST OF ROUTINES  ==============
ASK(VFDR,NOINIT,SOURCE) ;  7/28/2011 - DEPRECATED - see ^VFDXTR
 ; select routines from routine selector or get from Build file
 Q $$ASK^VFDXTRU1
 ;
 ;=========================  ASK FOR FILENAME  ========================
ASKFILE() ;  7/28/2011 - DEPRECATED - see ^VFDXTR
 ;  file not verified as to whether it exists or not
 ;  return user input or (null or -n if problems)
 Q $$DIR^VFDXTR09(4)
 ;
 ;====================  ASK FOR PATH OR DIRECTORY  ====================
ASKPATH(VPATH) ;  7/28/2011 - DEPRECATED - see ^VFDXTR
 ; syntax of path is not verified
 ; VPATH - opt - default path
 ; return user input or <null>
 Q $$ASKPATH^VFDXTRU1
 ;
 ;===============  GET LIST OF ROUTINES FROM BUILD FILE  ==============
BLD(VFDR,VAL,KU) ;
 Q $$BLD^VFDXTRU1($G(VFDR),$G(VAL),$G(KU))
 ;
 ;=====================  GET BUILD NAME AND DATA  =====================
BLDNM(VFDVAL) ;
 Q $$BLDNM^VFDXTRU1(.VFDVAL)
 ;
ROUDSP(VFDR,TITLE) ;
 S VFDR=$G(VFDR),TITLE=$G(TITLE) D ROUDSP^VFDXTRU1
 Q
 ;
 ;==================  ASK TO VIEW SELECTED ROUTINES  ==================
ROUSEE(VFDR,TITLE) ;
 S VFDR=$G(VFDR),TITLE=$G(TITLE) D ROUSEE^VFDXTRU1
 Q
 ;
 ;==================== COMMON SCREEN WRITE UTILITY ====================
WR(X,CJ,SLF,ELF,LINE) ;
 D WR^VFDXTRU1
 Q
 ;================  RETURN THE CONTENTS OF ^%ZOSF NODE  ===============
ZOSF(NODE) ;
 Q $$ZOSF^VFDXTRU1
 ;
 ;====================== DISPLAY LIST OF ROUTINES =====================
 ; R - opt - named reference which contains routine names
 ;  Default to ^UTILITY($J)
 ; TITLE - opt - title to display before list of routines 
 ;Expects @R@(routine name)=value
 ;  value is usually null.  If it is equal to a single punctuation char
 ;    then append that char to beginning of routine name
 ;
LIST(R,TITLE) ; display list of routines
 N I,X,Y,Z,SP,TOT
 S TITLE=$G(TITLE) I TITLE'="" D WR(TITLE," ",1,,12)
 S (X,TOT)=0,$P(SP," ",15)=""
 W ! F  S X=$O(@R@(X)) Q:X=""  S Y=@R@(X) D
 .S Z=X,TOT=1+TOT
 .I Y?1P,Y'=" " S Z=Y_X,TOT(Y)=1+$G(TOT(Y))
 .W $E(Z_SP,1,10) W:$X>70 !
 .Q
 W !!,"Total number of routines: "_TOT
 I $O(TOT(0)) S X=0 D
 .F  S X=$O(TOT(X)) Q:X=""  W !,"Total routines with "_X_":    "_TOT(X)
 .Q
 I TITLE'="" D WR(,,-1,1,2)
 Q
 ;
 ;
 ;===================== CALCULATE SIZE OF ROUTINE =====================
SIZE(X,VFDS) ; calculate size of routine
 ; either X or VFDS is required.
 ; X = routine name
 ; VFDS() contains routine at @vfds@(n) or @vfds@(n,0) where
 ;  @vfds@(n) is the nth line of the routine for n=1,2,3,4,...
 ; If $G(VFDS)'=""&($O(@VFDS@(0))=1) then ignore X even if passed
 ; Else get the routine X
 ; Return execute_size^comment_size^total_size^#_lines
 N I,L,Y,Z,VRTN,ZTOT
 S X=$G(X),VFDS=$G(VFDS) I VFDS'="" M VRTN=@VFDS
 I $O(VRTN(0))'=1,X'="" D  I '$D(VRTN) Q ""
 .K VRTN S Z=$$ZOSF^VFDVZOSF("LOAD",,X,,"VRTN")
 .I Z'=1 K VRTN
 .Q
 I '$D(VRTN(1)) Q ""
 F I=1:1:4 S ZTOT(I)=0
 F I=1:1 Q:'$D(VRTN(I))  D
 .S L=$G(VRTN(I)) S:L="" L=$G(VRTN(I,0)) Q:L=""
 .S Y=$L(L)+2,ZTOT(1)=ZTOT(1)+Y,ZTOT(4)=ZTOT(4)+1
 .I L?1" ;".E,$E(L,3)'=";" S ZTOT(3)=ZTOT(3)+Y
 .E  I L?1" ."." "1";".E S ZTOT(3)=ZTOT(3)+Y
 .E  S ZTOT(2)=ZTOT(2)+Y
 .Q
 Q ZTOT(1)_U_ZTOT(2)_U_ZTOT(3)_U_ZTOT(4)
