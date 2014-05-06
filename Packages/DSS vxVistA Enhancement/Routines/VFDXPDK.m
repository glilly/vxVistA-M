VFDXPDK ;DSS/SMP - Add Builds to a Batch From KIDS ;12/19/2012 16:10
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
16 ; ADD EXISTING BUILDS TO A BATCH
 ; *** DOES NOT UPDATE 21692 ***
 N VFDLIST,FILE,EXCP,X,Y,Z,I,C,CNT,FILE,IN,IOPAR,IOUPAR,LIST,OPEN,POP,TEMP
 N MISS,ADD,KIDS,NM,DUOUT,LIST
 D BTCHLIST(PID) I $G(LIST) D PURGE Q:$G(DUOUT)
 D LIST^VFDXPDC(PATH,,.VFDLIST) Q:'$D(VFDLIST)
 ;D FLIST^VFDXPD0(.VFDLIST,PATH,0,.VFDXERR) Q:'$D(VFDLIST)
 S FILE="" F  S FILE=$O(VFDLIST(FILE)) Q:FILE=""  D
 .N L1,L2,L3,OUTPUT,TEMP
 .I $$UP^XLFSTR(FILE)'[".KID" S EXCP(FILE)="" Q
 .S OPEN=$$OPEN^VFDXPDC(PATH,FILE,"OUTPUT","R")
 .U IO R L1:DT,L2:DT,L3:DT
 .I L3'["**KIDS**" D CLOSE^VFDXPDC("OUTPUT"),WR^VFDXPDL(4,FILE) S VFDERR=1 Q
 .F I=1:1 U IO R TEMP(I):DT Q:TEMP(I)=""
 .D CLOSE^VFDXPDC("OUTPUT") U IO
 .D FILECHK1^VFDXPDL
 S NM="" F  S NM=$O(KIDS(NM)) Q:NM=""  D
 .N IEN S IEN=$$FIND1^VFDXPDA(21692,,"XO",,,NM)
 .I IEN<1 S MISS(NM)="" Q
 .I '$D(LIST(IEN)) S ADD(IEN)=NM,ADD("B",NM)=IEN
 S X=0 F  S X=$O(ADD("B",X)) Q:X=""  D MULT(X)
 I $D(EXCP) D EXCP Q:$G(DUOUT)
 I $D(MISS) D MISS Q
 D:$D(ADD) UPDATE
 I '$D(EXCP),'$D(MISS),'$D(ADD) D
 .W !!!,"All of the builds are already in the batch "_PID(0),!
 .S ADD(0)="E" S ADD=$$DIR^VFDXPDA(.ADD)
 Q
 ;
BTCHLIST(PID) ;
 N X,OUT S LIST=0
 S OUT=$$GETS^VFDXPDA("OUT",21692.1,PID,"1*","I") I OUT=1 D
 .S X=0 F  S X=$O(OUT(21692.11,X)) Q:'X  S LIST(+X)="",LIST=LIST+1
 Q
 ;
EXCP ;
 N X,Y,DIR
 W !!!,"*** There are some files in this directory that are not .KID files. ***"
 S DIR(0)="Y",DIR("B")="YES"
 S DIR("A")="Would you like to display these files"
 S X=$$DIR^VFDXPDA(.DIR) W !! I X<1 S:X<0 DUOUT=1 Q
 S X="" F  S X=$O(EXCP(X)) Q:X=""  W ?5,X,!
 D CONT^VFDXPDA
 Q
 ;
MISS ; Display builds that are not in 21692
 N X
 W !!!,"*** There are one or more builds in these files that are not in file 21692:",!!
 S X="" F  S X=$O(MISS(X)) Q:X=""  W ?5,X,!
 W !,"Please add these to 21692 and try again.",!
 D CONT^VFDXPDA
 Q
 ;
MULT(NM) ; Check for missing builds that are listed as multibuilds
 ; ex.  ICD and ICPT are installed as part of LEX patches, but are not
 ;      listed in the LEX KID file
 ;
 N X,Y,Z,LIST
 D FIND^DIC(21692,,,"P",NM,,"AIN",,,"LIST","VFDERR")
 S X=0 F  S X=$O(LIST("DILIST",X)) Q:'X  D
 .N IEN,BUILD S IEN=+LIST("DILIST",X,0),BUILD=$P(LIST("DILIST",X,0),U,2)
 .Q:$D(ADD(IEN))
 .S ADD(IEN)=BUILD,ADD("B",BUILD)=IEN,ADD("C",BUILD)=""
 Q
 ;
PURGE ; Remove builds from the batch
 N X,DA,DIK,DIR
 W !!!,"*** You have selected a batch that already has builds associated with it."
 S DIR(0)="Y",DIR("B")="YES"
 S DIR("A")="Would you like to remove these patches before adding to the batch"
 S X=$$DIR^VFDXPDA(.DIR) I X<1 S:X<0 DUOUT=1 Q
 S DIK="^VFDV(21692.1,"_PID_",1,",DA(1)=PID
 S DA=0 F  S DA=$O(LIST(DA)) Q:'DA  D ^DIK K LIST(DA)
 Q
 ;
UPDATE ;
 N X,CNT,DIR,VFDFDA,VFDIEN,VFDERR S CNT=1
 W !!,"The following builds will be added to "_PID(0)_":",!!
 ;W !!,"These are the builds that will be added to "_PID(0)_":",!!
 S DIR(0)="Y",DIR("B")="YES"
 S DIR("A")="Do you want to add these builds to the batch "_PID(0)
 S X="" F  S X=$O(ADD("B",X)) Q:X=""  W ?5,X,!
 S X=$$DIR^VFDXPDA(.DIR)
 I X<1 S:X<0 DUOUT=1 D  Q
 .W !!,"No builds were added to "_PID(0),! D CONT^VFDXPDA
 S X=0 F  S X=$O(ADD(X)) Q:'X  D
 .Q:$D(LIST(X))
 .S VFDFDA(21692.11,"+"_CNT_","_PID_",",.01)=X,VFDIEN(CNT)=X,CNT=CNT+1
 D UPDATE^DIE(,"VFDFDA","VFDIEN","VFDERR")
 I '$D(VFDERR) D
 .W !!,"Successfully added the following builds to "_PID(0)_":",!!
 .S X="" F  S X=$O(ADD("B",X)) Q:X=""  D
 ..W ?5,X
 ..I $D(ADD("C",X)) W ?45,"** Not Listed in KIDs **"
 ..W !
 .W !,"Successfully added "_(CNT-1)_" build(s) to "_PID(0),!!
 .D CONT^VFDXPDA
 Q
