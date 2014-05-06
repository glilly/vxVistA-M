VFDHSTV ;DSS/WLC - Update Standardized Vitals files;
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ;
 N X,Y,ACT,AFILE,CNT,I,DA,DIR,DIROUT,DIRUT,DTOUT,DUOUT,MAX,NCNT,VFDFLE,VFDXUMF,XUMF
FILE ;
 K DIR,AFILE S CNT=2,NCNT=0
 S DIR("A",1)="    Select File"
 S DIR("A",2)=""
 S X=120.509 F  S X=$O(^DD(X)) Q:X>120.6  D
 .S NCNT=NCNT+1,CNT=CNT+1
 .S AFILE(NCNT)=X
 .S DIR("A",CNT)=$J(NCNT,2)_". "_$O(^DD(X,0,"NM",""))
 .S $E(DIR("A",CNT),29)="(file# "_X_")"
 .Q
 S X=DIR("A",CNT),MAX=$P($P(X,"#",2),"-",1),MAX=$E(MAX,1,$L(MAX)-1)
 S CNT=CNT+1,DIR("A",CNT)="   "
 S DIR(0)="NO^1:"_(NCNT),DIR("A")="    Enter Number to Edit"
 W ! D ^DIR Q:$D(DIRUT)
 S FILE=AFILE(+Y),VFDFLE=FILE,XUMF=1,VFDXUMF=1
 D ADD
 G FILE
 ;
ADD ; ADD/EDIT
 N DIC,DIE,DLAYGO,FLD,REC
 S DIC("DR")="",FLD=0
 F  S FLD=$O(^DD(FILE,FLD)) Q:'FLD  S DIC("DR")=DIC("DR")_FLD_";"
 S DIC=FILE,DLAYGO=1,DIC(0)="BELMAO" D ^DIC
 S REC=+Y Q:'REC!($P(Y,U,3))
 S DIE=FILE,DA=+Y,DR=DIC("DR") D ^DIE
 Q
 ;
 
 
