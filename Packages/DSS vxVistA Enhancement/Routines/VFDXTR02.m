VFDXTR02 ;DSS/SGM - MODIFIED XTVNUM FOR DSS ; 07/29/2011 11:13
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;  This is a clone of the XTVNUM program to reset the version#
 ;  of routines.  Some of the differences from XTVNUM:
 ;  1. extraneous code removed
 ;  2. Check for third line to start with these characters
 ;     " ;Copyright"
 ;     If 3rd line does not start, then insert copyright statement
 ;     Else replace copyright statement on 3rd line
 ;
 ;DBIA# Supported References
 ;----- ------------------------------
 ;10005 DT^DICRW
 ;10086 HOME^%ZIS
 ;10103 $$FMTE^XLFDT
 ;10104 $$UP^XLFSTR
 ;
 ;Routine cloned, then enhanced from the XTVNUM routine
 ;XTVNUM ;SF-ISC/RWF - TO UPDATE THE VERSION NUMBER ;04/05/99  08:35
 ;;7.3;TOOLKIT;**20,39**;Apr 25, 1995
 ;
 ; VFDCH = 1-4
 ;  1:New version#  2:Add a patch#  3:First line date  4:Copyright only
 ; VFDCH(node) = value   where
 ;       BLD   = Build name
 ;       COPY  = 1 if copyright to be added
 ;       DATE  = external date for 1st or 2nd line
 ;       IEN   = Build file ien
 ;     NPATCH  = user entered new patch number
 ;       NVER  = user entered new version number
 ;       PKG   = PACKAGE file prefix (namespace)
 ;      PATCH  = Build patch number
 ;       VER   = Build version number
 N I,X,Y,Z,VFDCH,VFDY,VROOT,XTVCH,XTV
 Q:$$ZOSF^VFDXTRU("OS")'["OpenM"
 D DT^DICRW,HOME^%ZIS W @IOF
 S VROOT=$NA(^UTILITY($J))
 S Y="BLD^COPY^DATE^IEN^NMSP^PKG^PATCH^VER"
 F I=1:1:$L(Y,U) S X=$P(Y,U,I),VFDCH(X)=""
 S X="Update Routine Version, Patch, 1st Line Date, Copyright"
 D WR(X,"-") I $O(RTN(0))'="" D
 . K @VROOT S:$D(RTN(0))#2=0 RTN(0)="" M @VROOT=RTN
 E  S Z=$$ASK^VFDXTR(VROOT) I Z<1 G KILL
 S Z=@VROOT@(0)
 S VFDCH("IEN")=$P(Z,U,2)
 S VFDCH("BLD")=$P(Z,U,3)
 S VFDCH("PKG")=$P(Z,U,4)
 S VFDCH("VER")=$P(Z,U,5)
 S VFDCH("PATCH")=$P(Z,U,6)
 ; routine update option
 S X=$$DIR(6) Q:X<1  S VFDCH=X S:X=4 VFDCH("COPY")=1
 ; if ch<4 then ask if copyright update
 I X<4 S X=$$DIR(7) Q:X<0  S VFDCH("COPY")=X
 ; ask for new version number
 I VFDCH=1 S X=$$DIR(8) S:X>0 VFDCH("NVER")=X I X'>0 G KILL
 ; ask for patch number
 I VFDCH=2 S X=$$DIR(9) S:X>0 VFDCH("NPATCH")=X I X'>0 G KILL
 ; ask for date
 I 13[VFDCH D  G:X<0 KILL
 .S X=$$DIR(10) I X<1 S X=-1 Q
 .S VFDCH("DATE")=$TR($$FMTE^XLFDT(X,9),"@"," ")
 .Q
 ; ask for package name
 I VFDCH=1 D  I X<1 G KILL
 .K VFDA S X=$$DIR(11,.VFDY) S:X>0 VFDCH("NPKG")=VFDY_U_$P(VFDY(0),U,3)
 .Q
 ; see list of routines selected
 S X=$$DIR(2) D:X>0 ROUDSP^VFDXTRU(VROOT) I X<0 G KILL
 ; continue
 I $$DIR(1)=1 D UPD,LIST
 ;
KILL K ^UTILITY($J),^TMP($J)
 Q
 ;
 ;-----------------------  Private Subroutines  -----------------------
 ;
COPY() ; return current up-to-date copyright statement
 ;;Document Storage Systems Inc. All Rights Reserved
 N X,Y S Y=1700+$E(DT,1,3)
 S X=" ;Copyright 1995-"_Y_","_$P($T(COPY+1),";",3)
 Q X
 ;
DIR(N,VFDY) Q $$DIR^VFDXTR09(N,.VFDY)
 ;
LIST ;
 ;;* - routines which had no action taken
 ;;@ - routines which for which the application had a problem
 D ROUDSP^VFDXTRU(VROOT)
 F I=1,2 W !,$TR($T(LIST+I),";"," ")
 Q
 ;
UP(X) Q $S(X?.E1L.E:$$UP^XLFSTR(X),1:X)
 ;
UPD ; actually update the routines
 N I,J,L,X,Y,Z,COM,COPY,DOIT,L2,L3,L3U,LOAD,PKG,SAVE,VFDR
 S VFDR=$NA(^TMP("VFDXTR02",$J))
 S LOAD=$$ZOSF^VFDXTRU("LOAD")
 S SAVE=$$ZOSF^VFDXTRU("SAVE")
 S COPY=$$COPY,COPY(0)=$$UP(COPY)
 S COM="DOCUMENT STORAGE SYSTEMS"
 S X=0 F  S X=$O(@VROOT@(X)) Q:X=""  D
 .I X="VFDXTR02" S @VROOT@(X)="*" Q
 .S DOIT=0 X LOAD
 .; date stamp the first line
 .I VFDCH=3,VFDCH("DATE")'="" D
 ..S L=@VFDR@(1,0),Y=$P(L,";",1,2)_" ; "_VFDCH("DATE")
 ..S @VFDR@(1,0)=Y,DOIT=1
 ..Q
 .; change version number on second line
 .I VFDCH=1,+VFDCH("NVER"),VFDCH("DATE")'="" D
 ..S Y=VFDCH("NPKG"),PKG=$P(Y,U,2) S:PKG="" PKG=$P(Y,U,3) Q:PKG=""
 ..S Z=" ;;"_VFDCH("NVER")_";"_PKG_";;"_VFDCH("DATE")
 ..S @VFDR@(2,0)=Z,DOIT=1
 ..Q
 .; add patches
 .S L2=@VFDR@(2,0)
 .I VFDCH=2,+VFDCH("NPATCH") D
 ..K Z S L=$TR($P(L2,";",5),"*")
 ..I $L(L) F J=1:1:$L(L,",") S Y=$P(L,",",2) S:Y Z(J)=Y,Z("B",Y)=J
 ..S Y=VFDCH("NPATCH") Q:$D(Z("B",Y))  S J=1+$O(Z("A"),-1),Z(J)=Y
 ..S Y="",J=0 F  S J=$O(Z(J)) Q:'J  S Y=Y_Z(J)_","
 ..S Y=$E(Y,1,$L(Y)-1) Q:Y=""
 ..S $P(L2,";",5)="**"_Y_"**",@VFDR@(2,0)=L2,DOIT=1
 ..Q
 .; add copyright statement
 .I +VFDCH("COPY") D
 ..S L3=$G(@VFDR@(3,0)),L3U=$$UP(L3),L=2.1
 ..Q:L3U=COPY(0)
 ..I L3="" S L=3
 ..E  I $P($P(L3U,";",2)," ")="COPYRIGHT",L3U[COM S L=3
 ..S DOIT=1,@VFDR@(L,0)=COPY
 ..Q 
 .I DOIT>0 X SAVE
 .I DOIT<1 S @VROOT@(X)=$S('DOIT:"@",1:"*")
 .Q
 K @VFDR
 Q
 ;
WR(STR,CH) D WR^VFDXTRU($G(STR),$G(CH)) Q
