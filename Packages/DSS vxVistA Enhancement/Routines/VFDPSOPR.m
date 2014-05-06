VFDPSOPR ;DSS/SMP;07/11/2013
 ;;2011.1.2;VENDOR - DOCUMENT STORAGE SYS;;02 Oct 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;--------------------------------------
 ; ICR # | Supported Reference
 ;-------|------------------------------
 ;  2051 |^DIC: $$FIND1
 ;  2336 |^XPAREDIT: GETENT, BLDLST
 ; 10026 |^DIR
 Q
 ;
EN ;
 ; p1 := optional - entity(s) - if not passed, set to "USR" for
 ;                  current user
 ; p2 := required - parameter name
 ; p3 := optional - instance
 ; p4 := required - value - see XPAR documentation
 ;
 N X,Y,Z,I,PAR,PARAM,VFDFLAG
 S PARAM="VFD PSO PROCESSING OPTION"
 S PAR=$$FIND1^DIC(8989.51,,,PARAM,,,"VFDERR")_U_PARAM
 F  D  Q:$G(VFDFLAG)
 .N INPUT,DIRUT,DEL,ENT,RET,JUST1,VFDRET,FLAG
 .W #,$$CJ^XLFSTR("Parameter: "_PARAM,80),!!!
 .D GETENT^XPAREDIT(.ENT,.PAR,.JUST1) I ENT="" S VFDFLAG=1 Q
 .S X=ENT_"~"_PARAM D GET1^VFDCXPR(.RET,X)
 .I $$CURRENT(RET) D  Q:$D(DEL)!($D(FLAG))
 ..S Z=$$ASKDEL I Z=-1 S FLAG=1 Q
 ..I Z="D" S DEL=1 D:$$SURE(2) DEL^VFDCXPR(.VFDRET,X_"~1~"_RET) D
 ...I VFDRET=1 W !!,"*** Successfully Deleted ***",!! S VFDFLAG=$$CR
 .F I=1:1:4 D  Q:$G(FLAG)
 ..S $P(INPUT,";",I)=$$ASKOPT($P($T(DATA+I),";;",2,99),$P(RET,";",I))
 ..S FLAG=$D(DIRUT)
 .Q:$G(FLAG)
 .I '$$UPDATE(INPUT) D  Q
 ..W !!,"*** No Updates Performed ***",!! S VFDFLAG=$$CR
 .W !! Q:FLAG  I +RET=-1 D ADD^VFDCXPR(.VFDRET,X_"~1~"_INPUT)
 .E  D CHG^VFDCXPR(.VFDRET,X_"~1~"_INPUT)
 .I VFDRET=1 W "*** Successfully Updated ***",!! S VFDFLAG=$$CR
 Q
 ;
ASKDEL() ; Ask the user if they want to edit or delete
 N DIR,X,Y,DTOUT,DUOUT,DIRUT
 S DIR(0)="SA^E:EDIT;D:DELETE;Q:QUIT"
 S DIR("A")="Do you wish to EDIT or DELETE?  "
 D ^DIR W !!
 I $D(DIRUT)!(Y="Q") Q -1
 Q Y
 ;
ASKOPT(TXT,DEFAULT) ;
 N DIR,X,Y,DTOUT,DUOUT
 ;S DIR(0)="Y",DIR("A")="Would you like to show the "_TXT_" option"
 S DIR(0)="Y",DIR("A")="Should the "_TXT_" option be visible"
 S DIR("B")=$S(DEFAULT=1:"YES",1:"NO") D ^DIR W !
 Q Y
 ;
CURRENT(VALUE) ; Show user the current value of the parameter
 N X,Y,Z,I
 I +VALUE=-1 W !!!,"There is no current value for this entity.",!! Q 0
 W !!!,"The current values for this entity are:",!!
 F I=1:1:4 W ?5,$P($T(DATA+I),";;",2)_" Option",?45,$S($P(VALUE,";",I):"YES",1:"NO"),!
 W !!
 Q 1
 ;
SURE(LINE) ;
 ;;update
 ;;delete
 N X,Y,DIR,TXT
 S TXT=$P($T(SURE+LINE),";;",2)
 S DIR(0)="Y",DIR("A")="Are you sure that you want to "_TXT
 S DIR("B")="NO" D ^DIR W !
 Q Y
 ;
UPDATE(INPUT) ;
 N I
 W !!,"You are about to update the parameter VFD PSO PROCESSING OPTION with"
 W !,"the following values:",!!
 F I=1:1:4 W ?5,$P($T(DATA+I),";;",2)_" Option",?45,$S($P(INPUT,";",I):"YES",1:"NO"),!
 Q $$SURE(1)
 ;
CR() ;
 N X,Y,DIR,DIRUT,DTOUT,DUOUT
 S DIR(0)="E" D ^DIR
 Q $D(DIRUT)
 ;
DATA ;
 ;;In-House
 ;;Print Script
 ;;Clinic
 ;;e-Pharm
 Q
