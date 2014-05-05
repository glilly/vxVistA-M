VFDXPDE ;DSS/SGM - PATCH UTIL REPORTS ;03 Oct 2010 23:07
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked by the ^VFDXPD routine
 ;ICR #  SUPPORTED REFERENCES
 ;-----  ---------------------------------------------------
 ; 2607  BROWSE^DDBR
 ;10086  ^%ZIS
 ;10089  ^%ZISC
 ;
6 ; PRE/POST REPORT
 D 6^VFDXPDE1 S X="No Pre/Post instructions found"
 D RPT^VFDXPD0(.RPT,,X)
 Q
 ;
7 ; BUILDS IN BATCH REPORT
 D 7^VFDXPDE1 S X="No Builds found for batch profile"
 D RPT^VFDXPD0(.RPT,,X)
 Q
 ;
11 ; RETRIEVE REPORT
 D 11^VFDXPDE1
 S X="No Builds found requiring patches or files to be retrieved"
 D RPT^VFDXPD0(.RPT,X)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ASKRPT(TXT) ; ask for output device and write RPT
 ; .RPT - req - RPT(n)=text
 N I,J,X,Y,Z,OUT
 I '$O(RPT(0)) W !!?3,$G(TXT),! Q
 S OUT=$$OUT Q:OUT<1
 I OUT<2 D BROWSE^DDBR("RPT","N") Q
 W ! S I=0 F  S I=$O(RPT(I)) Q:'I  W !,RPT(I)
 D:OUT=3 ^%ZISC
 Q
 ;
COMMON(TXT) ;  ask for output device and write RPT
 ; .RPT - req - RPT(n)=text
 N I,J,X,Y,Z,OUT
 I '$O(RPT(0)) W !!?3,$G(TXT),! Q
 S OUT=$$OUT Q:OUT<1
 I OUT<2 D BROWSE^DDBR("RPT","N") Q
 W ! S I=0 F  S I=$O(RPT(I)) Q:'I  W !,RPT(I)
 D:OUT=3 ^%ZISC
 Q
 ;
 ;=====================================================================
 ;                 REPORTS CALLED FROM OTHER ROUTINES
 ;    VFDLOC - req - named reference that contains the data
 ;       OUT - opt - value of $$OUT below
 ;=====================================================================
 ;
 ;--------------------  REPORTS FROM VFDXPDE  --------------------
ERR1(VFDLOC) ; MISSING PATCH REPORT
 N I,J,X,Y,Z,RPT
 Q:$G(VFDLOC)=""  Q:'$D(@VFDLOC)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
INC(X) S N=N+1,RPT(N)=X Q
 ;
OUT() ; select output form
 N X,Y,Z
 S Z(0)="SO^1:Fileman Browser;2:Terminal;3:HFS Device"
 S Z("A")="Select display mode",Z("B")=1
 S Z("?",1)="Enter 1 to display the text in Fileman's Browser"
 S Z("?",2)="Enter 2 to display the text on the screen"
 S Z("?",3)="Enter 3 to send to a HFS file"
 S Z("?")="   "
 S X=$$DIR^VFDXPDA(.Z) I X<1 Q X
 Q $S(X<1:0,X<3:X,1:$$OUTHFS)
 ;
OUT1() ; see if should ask for HFS file name
 S OUT=+$G(OUT) S:30[OUT OUT=$S(OUT=3:$$OUTHFS,1:$$OUT) Q OUT
 ;
OUTHFS() ;
 N X,Y,Z,%ZIS,POP
 W !!,"Select your HFS Device File name",!!
 S %ZIS("B")="HFS" D ^%ZIS I POP D ^%ZISC Q 0
 U IO
 Q 3
 ;
RPT(TYPE) ; write out contents of RPT()
 ; type = 1:browser  2:screen  3:hfs file
 N I,J,X,Y,Z
 Q:$O(RPT(""))=""  I $G(TYPE)<2 D BROWSE^DDBR("RPT","N") Q
 W ! S I=0 F  S I=$O(RPT(I)) Q:'I  W !,RPT(I)
 D:TYPE=3 ^%ZISC
 Q
