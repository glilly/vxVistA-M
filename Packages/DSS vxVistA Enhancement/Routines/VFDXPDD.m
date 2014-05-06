VFDXPDD ;DSS/SGM - PATCH UTIL OPTS FOR 21692.x FILES ;07 Oct 2010 15:52
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked from the ^VFDXPD routine
 ;
2 ;====================  EDIT A PATCH DESCRIPTION  ====================
 N I,X,Y,Z,DA,DIC
 F  D  Q:$G(DA)<1
 .K X,Y,Z,DA,DIC
 .S DIC=21692,DIC(0)="QAELMZ",DA=+$$DIC^VFDXPDA(.DIC,21692) Q:DA<1
 .D DDS^VFDXPDA(21692,"[VFDXPD EDIT]",DA)
 .Q
 Q
 ;
4 ;================== CREATE/EDIT A PROCESSING BATCH ==================
 ; choices Add, Edit, Delete, Worksheet
 N X F  S X=$$DIR^VFDXPD0(1) Q:X=-1  D @X
 Q
 ;
41(Y) Q $D(^VFDV(21692.1,PID,1,Y))
 ;
A ; manually add an existing build to a batch
 N X,Y,DA,DIC
 F  D  Q:Y<1
 .K X,Y,DA,DIC
 .S DIC="^VFDV(21692.1,PID,1,",DIC(0)="QAEML",DA(1)=PID
 .S DIC("A")="Select BUILD to add to a batch: "
 .S DIC("S")="I '$D(^VFDV(21692.1,PID,1,+Y))"
 .S Y=$$DIC^VFDXPDA(.DIC,21692.1,.DA)
 .Q
 Q
 ;
D ; delete builds from batch
 N X,Y,DA,DIC,DIE,DR,VIEN
 F  D  Q:$G(VIEN)<1
 .K X,Y,D0,DA,DIC,DIE,DR,VIEN
 .S DIC="^VFDV(21692.1,PID,1,",DIC(0)="QAEM",DA(1)=PID
 .S DIC("A")="Select BUILD to remove from batch: "
 .S (DA,VIEN)=+$$DIC^VFDXPDA(.DIC,,.DA)
 .I DA>0 S DIE=DIC,DR=.01 D ^DIE
 .Q
 Q
 ;
E ; edit a patch description that is part of a batch
 N X,Y,DA,DIC
 F  D  Q:$G(DA)<1
 .K X,Y,DA,DIC
 .S DIC="^VFDV(21692,",DIC(0)="QAEML",DIC("DR")=""
 .S DIC("S")="I $D(^VFDV(21692.1,PID,1,+Y))"
 .S DIC("A")="Select a BUILD that is part of the batch: "
 .S DA=+$$DIC^VFDXPDA(.DIC,21692)
 .I DA>0 D DDS^VFDXPDA(21692,"[VFDXPD EDIT]",DA)
 .Q
 Q
 ;
W ; create/edit a Build Description and add to batch
 ;  this option creates "worksheet" entries indicating items to be
 ;  retrieved from the internal VA LAN
 N X,Y,DA,DIC,VFDA,VFDT,VFDX
 S VFDT="" F  D  Q:$G(DA)<1
 .K X,Y,DA,DIC,VFDA,VFDX
 .I VFDT="" S X=$$DIR^VFDXPD0(3) Q:X=-1  S VFDT=X
 .S DIC="^VFDV(21692,",DIC("DR")=""
 .S Y="",DIC("A")="Select a worksheet BUILD: "
 .I VFDT="C" S Y=21692,DIC(0)="QAEMLZX"
 .I VFDT="E" S DIC(0)="QAEMZ",DIC("S")="I $D(^VFDV(21692.1,PID,1,+Y))"
 .D DIC^VFDXPDA(.DIC,Y,,"VFDA",1) S DA=+$O(VFDA(0)) Q:DA<1
 .D DDS^VFDXPDA(21692,"[VFDXPD WORKSHEET]",DA)
 .Q:$$41(DA)
 .; ask if want to add to batch
 .I "u"'[$P($G(VFDA(DA,0)),U,10) Q:'$$DIR^VFDXPD0(2)
 .W !?3,"Adding "_$P(VFDA(DA,0),U)_" to batch"
 .S VFDX(1,.01)=DA,Y=","_PID_","
 .S X=$$UPDDINUM^VFDXPDA(21692.11,Y,.VFDX) W:X<1 !!?3,$P(X,U,2)
 .Q
 Q
 ;
 ;=======================  FILE 21692 FIELD .01  ======================
XR ; M xref to simulate trigger function
 ; field .02 (0;2) - date entered
 ; field .03 (0;3) - entered by
 ; field .05 (0;5) - package
 ; field .06 (0;6) - version
 ; field .061(0;9) - patch#
 ; field .07 (0;7) - seq#
 ; field .1  (0;10)- status
 ; field .9  (DESC;1) - patch description
 N I,Y,Z,D0,DIC,DIE,DR,DTOUT,DUOUT,VFDA,VFDIEN,VFDX,VFNEW,VFOLD
 S VFDIEN=$G(DA),VFDX=X N X,DA Q:'VFDIEN
 S Z=$G(^VFDV(21692,VFDIEN,0))
 S VFOLD(.02)=$P(Z,U,2),VFOLD(.03)=$P(Z,U,3),VFOLD(.05)=$P(Z,U,5)
 S VFOLD(.06)=$P(Z,U,6),VFOLD(.061)=$P(Z,U,9),VFOLD(.07)=$P(Z,U,7)
 S VFOLD(.1)=$P(Z,U,10),VFOLD(.9)=$P($G(^VFDV(21692,VFDIEN,"DESC")),U)
 D PARSENM^VFDXPD0(.VFDX)
 S Y=VFDX("PKG") I Y'="" S VFNEW(.05)=Y
 S Y=VFDX("VER") I Y'="" S VFNEW(.06)=+Y
 S Y=VFDX("PATCH") I Y'="" S VFNEW(.061)=+Y
 S Y=VFDX("SEQ") I Y'="" S VFNEW(.07)=+Y
 I 'VFOLD(.02) S VFDA(.02)=DT
 I 'VFOLD(.03),$G(DUZ),$D(^VA(200,DUZ,0)) S VFDA(.03)=DUZ
 I VFOLD(.1)="" S VFDA(.1)="u"
 I VFOLD(.9)="" S VFDA(.9)="<not entered>"
 S Y=$E($G(VFNEW(.05)),1,6) I Y'="",Y?1U1.5UN S VFDA(.05)=Y
 S Y=$G(VFNEW(.06)) I Y'="",$S(Y:1,1:VFOLD(.06)="") S VFDA(.06)=Y
 S Y=$G(VFNEW(.061)) I Y'="",$S(Y:1,1:VFOLD(.061)="") S VFDA(.061)=Y
 S Y=$G(VFNEW(.07)) I Y'="",$S(Y:1,1:VFOLD(.07)="") S VFDA(.07)=Y
 I $D(VFDA) S Y=$$FILE^VFDXPDA(21692,VFDIEN,.VFDA)
 Q
