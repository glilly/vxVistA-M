VFDHDIV ;DSS/WLC - Update Standardized Vitals files;
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ;
 N ACT,AFILE,CNT,I,DIR,DIRUT,DTOUT,DUOUT,DA,MAX,NCNT,X,Y
FILE ;
 S NCNT=1
 K DIR,AFILE S CNT=1 S DIR("A",CNT)="                                   Select File",CNT=CNT+1
 F I=1,2 S DIR("A",CNT)="",CNT=CNT+1
 S X=120.509 F  S X=$O(^DD(X)) Q:X>120.6  S AFILE(NCNT)=X,DIR("A",CNT)=NCNT_".  FILE #"_X_" - "_$O(^DD(X,0,"NM","")),CNT=CNT+1,NCNT=NCNT+1
 S Y=$O(DIR("A",9999),-1),X=DIR("A",Y),MAX=$P($P(X,"#",2),"-",1),MAX=$E(MAX,1,$L(MAX)-1)
 F I=1,2 S DIR("A",CNT)="",CNT=CNT+1
 S DIR(0)="NO^1:"_(NCNT-1),DIR("A")="Enter File Number"
 U 0 W # D ^DIR Q:$D(DIRUT)
 S FILE=AFILE(+Y),XUMF=1,VFDXUMF=1
 D ADD
 G FILE
 ;
ADD ; ADD/EDIT
 N DIC,DIE,DLAYGO,DR,DIRUT,DTOUT,REC S DIC("DR")=""
 S FLD=0 F  S FLD=$O(^DD(FILE,FLD)) Q:'FLD  D
 . S DIC("DR")=DIC("DR")_FLD_";"
 S DIC=FILE,DLAYGO=1,DIC(0)="BELMAO" D ^DIC Q:$D(DTOUT)
 S REC=+Y Q:'REC!($P(Y,U,3))
 K DIE S DIE=FILE,DA=+Y,DR=DIC("DR") D ^DIE
 Q
 ;
 
 
