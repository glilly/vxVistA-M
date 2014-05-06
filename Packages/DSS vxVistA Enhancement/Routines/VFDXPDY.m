VFDXPDY ;DSS/SMP - XPD INSTALL BUILD OPTION MODIFIED ; 03/14/2013 15:35
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD routine
 ;This is a modification of the XPD INSTALL BUILD option
 ; a) It assumes all loaded builds are to be installed
 ; b) Using the installation order report, FOR loop through all loaded
 ;    builds and install them
 ; c) If the AUTO-INSTALL flag is set in file 21692 then set up local
 ;    variables up through the device prompt
 ; d) If the AUTO-INSTALL flag is not set in file 21692 then jump into
 ;    the VFD line label in XPDI after the point where you would have
 ;    selected a Build to install.
 ;
13 ; For loop on builds in a batch and invoke VFD^XPDI
 N I,J,X,Y,Z,EQ,POST,VFDI,VFDINST
 N IORPT
 I $G(DUZ(0))'="@" N VFDUZ M VFDUZ=DUZ S DUZ(0)="@"
 ;I $T(VFD^XPDI)="" D WR(5) Q
 I $$BATCH<1 D WR(6) Q
 S X=$P($G(^VA(200,+$G(DUZ),0)),U)
 I '$$LOCK D WR(8,X) Q
 S $P(EQ,"=",80)=""
 ; VFDINST(order#)=Build name
 W @IOF,$$CJ^XLFSTR(PID(0),80),! G:$$DIR^VFDXPD0(11)'=1 X13
 ; $$QA resets the VFDINST(order#) - see line tag
 S X=$$QA I X<1 S Y=$S(X<0:7,1:1) D WR(Y) G X13
 S VFDI=0 F  S VFDI=$O(VFDINST(VFDI)) Q:'VFDI  D  Q:'VFDI
 .N VFDAUTO S VFDAUTO=$$AUTO($P(VFDINST(VFDI),U))
 .; quit if already installed
 .Q:+$P(VFDINST(VFDI),U,4)  S I=+$P(VFDINST(VFDI),U,2)
 .S Z="Installing "_$P(VFDINST(VFDI),U)
 .W !,$$CJ^XLFSTR(Z,80),!
 .I '$D(^XTMP("XPDI",I)) D WR(2) S VFDI=0
 .E  I $$INST(I)<1 S VFDI=0
 .I $D(POST(VFDI)) D  Q
 ..W !,EQ,!!!,"  ",$P(VFDINST(VFDI),U)_" has a post-install step that must be performed now."
 ..S VFDI=0 W !! D CR
 .W !,EQ,! D CR S:X=-1 VFDI=0
 .Q
X13 D UNLOCK
 I $D(VFDUZ) K DUZ M DUZ=VFDUZ
 Q
 ;
 ;EN ; FOR loop to install all loaded KIDS Builds
 ;; snippets of this code taken from EN^XPDI
 ;N I,J,X,Z,NM,VFDI,VFDQUIT
 ;N %,Y,DIR,DIRUT,POP,XPD,XPDA,XPDD,XPDIJ,XPDDIQ,XPDIT,XPDIABT,XPDNM
 ;N XPDNOQUE,XPDPKG,XPDREQAB,XPDST,XPDSET,XPDSET1,XPDT,XPDQUIT,XPDQUES
 ;N ZTSK
 ;S (VFDQUIT,XPDST)=0
 ;F  S XPDST=$O(^XTMP("XPDI",XPDST)) Q:'XPDST!VFDQUIT  D
 ;.K XPDT W:$Y>2 @IOF
 ;.Q:$$CK(XPDST,1)<1  Q:'$$XPDT(XPDST)
 ;.S X=$$DIR^VFDXPD0(5) I X<1 S:X<0 VFDQUIT=1 Q
 ;.L +^XPD(9.7,XPDST,0):1 E  W !,"Being accessed by another user" Q
 ;.D VFD^XPDI
 ;.Q
 ;Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
BATCH() ; get list of Builds to install
 ; set VFDINST(order#)=Build name
 ; PID is the IEN of the patch group
 N X,Y,Z K VFDINST
 D VFDSORT^VFDXPDG2($NA(VFDINST),PID,0,,0,"I")
 S X="" F  S X=$O(VFDINST(X)) Q:X=""  D
 .I $P(VFDINST(X),U,4)="YES" S POST(X)=""
 .S VFDINST(X)=$P(VFDINST(X),U)
 Q $O(VFDINST(" "),-1)
 ;
CK(Y,SCR) ; check to see if KIDS accepts this as a good install
 ; install lookup screening logic:
 ; I '$P(^(0),U,9),$D(^XPD(9.7,"ASP",Y,1,Y)),$D(^XTMP("XPDI",Y))
 ;N I,X,Z
 N X,Z
 S X=$G(^XPD(9.7,Y,0)),NM=$P(X,U)
 I NM="" W !!,NM D WR(3) Q -1
 I '$G(SCR),$P(X,U,9)!'$D(^XPD(9.7,"ASP",XPDST,I,Y)) Q 0
 Q 1
 ;
CR S X=$$DIR^VFDXPD0("CR") Q
 ;
INST(VFDXPDST) ; snippets of this code taken from EN^XPDI
 N I,J,X,Z,NM,VFDXPDT
 ;N %,Y,DIR,DIRUT,POP,XPD,XPDA,XPDD,XPDIJ,XPDDIQ,XPDIT,XPDIABT,XPDNM
 ;N XPDNOQUE,XPDPKG,XPDREQAB,XPDSET,XPDSET1,XPDT,XPDQUIT,XPDQUES
 ;N ZTSK
 I $$CK(VFDXPDST,1)<1 Q -1
 I $$XPDT(VFDXPDST)<1 Q -1
 I $$DIR^VFDXPD0(5)<1 Q -1
 L +^XPD(9.7,VFDXPDST,0):1 E  D WR(4) Q -1
 D EN^XPDI
 Q 1
 ;
LOCK() L +^XTMP("VFDXPD-INSTALL",+PID):2 Q $T
UNLOCK L -^XTMP("VFDXPD-INSTALL",+PID) Q
 ;
QA() ;
 N I,X,Y,Z,ERR
 Q:'$D(VFDINST) -1
 S (I,ERR)=0
 F  S I=$O(VFDINST(I)) Q:'I  D
 .N IEN,RET
 .D LAST^VFDXPD0(.RET,VFDINST(I),3) S IEN=$O(RET("B",VFDINST(I),""))
 .I 'IEN S VFDINST(I)=VFDINST(I)_"^-1",ERR=ERR+1 Q
 .S Z=$G(RET(IEN)),Y=$P($P(Z,U,3),";")
 .I 30[Y&(Y'="") S VFDINST(I)=VFDINST(I)_U_IEN_U_$P(Z,U,2,99)
 .E  S VFDINST(I)=VFDINST(I)_"^-1",ERR=ERR+1
 Q:ERR -ERR
 ;
 S I=0 F  S I=$O(VFDINST(I)) Q:'I  Q:'$P(VFDINST(I),U,4)
 I I F  S I=$O(VFDINST(I)) Q:'I  Q:+$P(VFDINST(I),U,4)
 Q I<1
 ;
WR(T,X) W !,$TR($T(WR+T),";"," ")_$G(X),!  Q
 ;;Some Builds have already been installed out of sequence
 ;;No transport global found for this Build
 ;;**ERROR in Install, Remove the Distribution and reload it**
 ;;Being accessed by another user
 ;;The XPDI routine has not been properly modified for this option
 ;;No Builds found for this Batch Processing Group
 ;;One or more Builds in Processing Group are not in the INSTALL file!
 ;;This batch is currently being processed by 
 ;;The following patches need to be installed before the batch:  
 ;;The following patches have already been installed:  
 ;;The following patches have already been loaded: 
 ;
XPDT(XPDST) ; taken from XPDT^XPDI1
 ; expects NM=build name
 N A,I,X,Y,Z
 S I=0,Z=1
 F  S I=$O(^XPD(9.7,"ASP",XPDST,I)) Q:'I  S Y=+$O(^(I,0)) D  Q:'Z
 .I $$CK(Y)<1 S Z=0 W !,"Remove Distribution "_NM K VFDXPDT Q
 .S VFDXPDT(I)=Y_U_NM,(VFDXPDT("DA",Y),VFDXPDT("NM",NM))=I
 .Q
 I '$O(VFDXPDT(0)) S Z=0
 S:$D(VFDXPDT(2)) NM=$P(VFDXPDT(1),U,2)
 Q Z
 ;
AUTO(NM) ;
 N IEN
 S IEN=$G(BATCH("B",NM)) Q:'IEN 0
 Q:+$$GET1^VFDXPDA(21692,IEN,.18,"I")<0 0
 Q 1
