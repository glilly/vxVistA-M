VFDXTR01 ;DSS/SGM - VARIOUS ROUTINE UTILITIES ; 06/20/2011 13:20
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXTR routine
 ;
 ; ICR#  Supported Description
 ;-----  ---------------------------------------------------
 ;
 Q
 ;
 ; >>>>>>>>>>  DELETE SELECTED ROUTINES  <<<<<<<<<<
 ;
DEL ;
 N I,J,X,Y,Z,DEL,ROU
 Q:'$$ASK^VFDXTRU("ROU")
 D ROUSEE^VFDXTRU("ROU","ROUTINES TO BE DELETED")
 Q:$O(ROU(0))=""  Q:$$DIR^VFDXTR09(1)'=1
 W !!,"Deleting these routines . . . ",!
 S DEL=$$ZOSF^VFDXTRU("DEL"),X=0
 F  S X=$O(ROU(X)) Q:X=""  X DEL W $E(X_"          ",1,10) I $X>70 W !
 Q
 ;
 ; >>>>>>>>>>  OLD ROUTINE SIZE UTILITY  <<<<<<<<<<
 ;
SIZEOLD ;
 ;This program will calculate routine size per the 3/2007 VA
 ;Programming SAC.  20K total size, 15K executable code size,
 ;5K minimum comment size.
 ;
 N I,X,Y,Z,CH,TMP,UTL
 S UTL=$NA(^UTILITY($J)) K @UTL
 S TMP=$NA(^TMP($J)) K @TMP
 ; ask for routine selection and get routines
 Q:$$ASK^VFDXTRU<1  S CH=$$DIR^VFDXTR09(12) I CH'="N",CH'="S" Q
 W @IOF,"Calculating ... ",!
 S X=0 F  S X=$O(@UTL@(X)) Q:X=""  S @UTL@(X)=$$SIZE^VFDXTRU(X)
 D LIST
 Q
 ;
 ;======================== PRIVATE SUBROUTINES ========================
 ;
LIST ; display routine size
 ;;|Routine   | Total Size |Execute Size|Comment Size|Number Lines|
 ;;|----------|------------|------------|------------|------------|
 ; TOT = total number of routine
 ; TOT(1) = total size of all routines
 ; TOT(2) = total number of lines
 ; SORT() = rtn ^ exe size ^ non size ^ tot size ^ # lines
 N I,J,L,X,Y,Z,SP,TOT
 I $O(@UTL@(0))="" W !!,"No routine names found in "_UTL Q
 D WR^VFDXTRU("Routine List","-",1,1)
 I CH'="S" S (I,X)=0 F  S X=$O(@UTL@(X)) Q:X=""  S Y=^(X) D
 .S I=I+1,^TMP($J,1,I)=X_U_Y
 .Q
 I CH="S" D SORT
 S (TOT,TOT(1),TOT(2))=0,$P(SP," ",15)=""
 S L(1)=$P($T(LIST+1),";",3),L(2)=$P($T(LIST+2),";",3)
 W !!,?4,L(1),!?4,L(2)
 F I=1:1 S X=$G(^TMP($J,1,I)) Q:X=""  D
 .S Y="    |"_$P(X,U),$E(Y,16)="|"
 .S TOT=TOT+1 F J=2,3,4,5 D
 ..S A=$P(X,U,J),T=$J($FN(A,","),10)
 ..I J=2 S TOT(1)=TOT(1)+A S:A>20000 T=T_"*"
 ..I J=3,A>15000 S T=T_"*"
 ..I J=5 S TOT(2)=TOT(2)+A
 ..S Y=Y_$E(T_SP,1,12)_"|"
 ..Q
 .W !,Y
 .Q
 W !?4,L(2)
 S Y="    |"_$J($FN(TOT,","),9)_" |"_$J($FN(TOT(1),","),11)_" |"
 S Y=Y_"            |            |"_$J($FN(TOT(2),","),11)_" |"
 W !,Y
 Q
 ;
SORT ; sort routine list by inverse size order
 N I,N,R,X,Y,Z,SZ
 S X=0 F  S X=$O(@UTL@(X)) Q:X=""  S Y=^(X),SZ=$P(Y,U) D
 .S ^TMP($J,0,-SZ,X)=X_U_Y
 .Q
 S I=0,N="" F  S N=$O(^TMP($J,0,N)) Q:'N  S X=0 D
 .F  S X=$O(^TMP($J,0,N,X)) Q:X=""  S I=I+1,Y=^(X),^TMP($J,1,I)=Y
 .Q
 Q
