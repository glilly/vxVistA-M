VFDXTPT1 ;DSS/RAC - Pointer Tool ;03/01/2013@1630
 ;;2011.1.2;DSS,INC VXVISTA SUPPORTED;;01 Dec 2009;Build 2
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;VFDXTPT modified to change the ignore file list to file range
 ; added IEN count and look for a specific Entry IEN.
 ; changed report display.
 Q
PTR ;[Public]
 ;
 W !,"This option classifies actual pointers-in to a file."
 W !,"It produces a cross-listing of entries in the original file,"
 W !,"and entries or sub-entries that point to the given entries.",!
  I '($T(XALL^SISFIND)]"") D  Q
 .W !!,"This procedure requires routine ^SISFIND, tag XALL (not found)."
 .Q
 N VFDDUZ
 I $G(DUZ)>.9 S VFDDUZ=DUZ(0),DUZ(0)="@"
 I '($G(DUZ(0))="@") W !,"PROGRAMMER ACCESS DUZ(0)=""@"" is required" Q
 N DIC,X,Y S DIC=1,DIC(0)="AEQMZ" D ^DIC Q:Y<0
 N VFDA,VFDFILE,VFDXFILE,VFDFGL,VFDPFIL,VFDIEN,VFDPFLD,VFDPSUM,VFDG,VFDS
 N VFDP,VFDP4,VFDX,VFDFLST,VFDLST,VFDNCHK,VFDLIST,VFDNODOT
 N VFDRSLTS ,VFDVAL
 S VFDRSLTS=$NA(^TMP("VFDXTPT1",$J)) K @VFDRSLTS
 S VFDFILE=+Y,VFDXFILE=$P(Y,U,2),VFDFGL=$$ROOT^DILFD(VFDFILE,,1)
 D FILELST($NA(VFDLST)) ;Look in Files default ALL
 ;
 W !,"Display record IEN number?"
 N DIRUT,DTOUT,DUOUT
 S DIR(0)="Y",DIR("B")="No" D ^DIR
 Q:$D(DTOUT)!$D(DUOUT)!$D(DIRUT)
 S VFDIEN=Y
 W !
 ;
 W !,"Search for a specific Entry IEN value zero for or all?"
 N DIR,DIRUT,DTOUT,DUOUT
 S DIR(0)="N",DIR("B")=0 D ^DIR
 Q:$D(DTOUT)!$D(DUOUT)!$D(DIRUT)
 S VFDVAL=Y
 ;
DEV ;
 N %ZIS,POP
 W !
 S %ZIS="Q",%ZIS("A")="(queuing recommended) Select DEVICE: ",%ZIS("B")=""
 D ^%ZIS Q:POP
 I $G(IO("Q")) N ZTDESC,ZTRTN,ZTSAVE,ZTSK D  Q  ;If queued
 .S ZTDESC="VFD Pointers Analysis",ZTSAVE("VFD*")="",ZTRTN="DQ^VFDXTPT1"
 .D ^%ZTLOAD K IO("Q") D HOME^%ZIS
 .Q
 ; Fall through to DQ, if not queued
 D WAIT^DICD W !
 ;
DQ ;[Private] From PTR
 U IO S VFDA=0
 F  S VFDA=$O(@VFDFGL@(VFDA)) Q:'VFDA  D A1(VFDFILE,VFDA) ;Classify one entry
 ; Classification complete
 D ADSP(VFDRSLTS)
 I $D(VFDDUZ) S DUZ(0)=VFDDUZ
 Q
 ;
DDNAME(VFDD) ;[Public] Name of File or Field
 ; VFDD=[Required] File or Field#
 Q:'$G(VFDD) ""
 I $G(^DIC(VFDD,0))]"" Q $P(^DIC(VFDD,0),U)
 I $G(^DD(VFDD,0))]"" Q $P(^DD(VFDD,0),U)
 Q ""
 ;
FILELST(LIST) ;[Private] Populate list of files or subfiles to ignore
 ; LIST=[Required] $NAME of return list
 S:'$L($G(LIST)) LIST=$NA(VFDLST) ;Default
 N DIRUT,DIROUT,DTOUT,DUOUT,DIR,Y,Y1,Y2 S DIR("A")="DD#",DIR(0)="LC^1:9999999999:9"
 S DIR("B")="999999999",ALL=0
 W !!,"Look in ALL or range (1-999) of files/sub-files "_$P(VFDFILE,U,2)_": "
 W !,"Enter file or subfile number, or press <ENTER> to quit.",!
 ;
DLP ; 
 D ^DIR Q:$D(DIRUT)
 I Y[999999999 S @LIST@(999999999)="",ALL=1 Q ; ALL files
 I Y["," D
 . S J=1
 . F  S X=$P(Y,",",J) Q:X=""   D
 . . S:X["-" Y1=$P(X,"-",1)-.999,Y2=$P(X,"-",2)
 . . S:X'["-" Y1=X-.0009,Y2=Y1+1
 . . F  S Y1=$O(^DD(VFDFILE,0,"PT",Y1)) Q:'Y1!(Y1>Y2)  S @LIST@(Y1)=""
 . . S J=J+1
 . . Q
 . Q
 W !
 Q
 ;
A1(VFDFILE,VFDA) ;[Public] - Process one entry in target file
 ; Normally called by VFDA, however, can be invoked independently 
 ;   VFDFILE=[Required] Target file number (pointed-to file)
 ;   VFDA=[Required] Entry (IEN) in file VFDFILE
 ;
 I $G(VFDFILE),$G(VFDA) S (VFDPFIL,VFDPSUM)=0
 E  Q
 I '$L($G(VFDRSLTS)) S VFDRSLTS=$NA(^TMP("VFDXTPT1","A1",$J))
 I $D(VFDLST(999999999)) S VFDPFIL=0  D
 .  F  S VFDPFIL=$O(^DD(VFDFILE,0,"PT",VFDPFIL)) Q:'VFDPFIL  D
 . . S VFDPFLD=0 F  S VFDPFLD=$O(^DD(VFDFILE,0,"PT",VFDPFIL,VFDPFLD)) Q:'VFDPFLD  D A1P
 . . W:'$D(ZTQUEUED)&'$G(VFDNODOT) "."
 . . Q
 E  D
 . S VFDPFIL=0 F  S VFDPFIL=$O(VFDLST(VFDPFIL)) Q:'VFDPFIL  D
 . . Q:'$D(^DD(VFDFILE,0,"PT",VFDPFIL))
 . . S VFDPFLD=0 F  S VFDPFLD=$O(^DD(VFDFILE,0,"PT",VFDPFIL,VFDPFLD)) Q:'VFDPFLD  D A1P
 . . W:'$D(ZTQUEUED)&'$G(VFDNODOT) "."
 . . Q
 . Q
 Q
 ;
A1P ;[Private] Called by VFDA1 - Process one pointer
 S VFDP4=$P($G(^DD(VFDPFIL,VFDPFLD,0)),U,4)
 S VFDS=$P(VFDP4,";"),VFDP=$P(VFDP4,";",2) Q:'$L(VFDS)!'VFDP
 N VFDCMD
 S VFDCMD="D VFDCMD^VFDXTPT1"
 D XALL^SISFIND(,VFDPFIL,.VFDCMD)
 Q
 ;
ADSP(VFDRSLTS) ;[Private] Display results - Called by PTR
 ; VFDRSLT=[Required] $NAME of results array to be displayed
 ; 
 N CNT,VFDA,VFDFILE,VFDIENS,VFDPFIL,VFDPFLD,VFDX
 S VFDFILE=0 
 F  S VFDFILE=$O(@VFDRSLTS@(VFDFILE)) Q:'VFDFILE  D
 .W !,$TR($J("",$G(IOM,80))," ","-")
 .S VFDA=0
 .F  S VFDA=$O(@VFDRSLTS@(VFDFILE,VFDA)) Q:'VFDA  D
 ..I VFDVAL'=0,VFDVAL'=VFDA Q
 ..W !,"Entry# "_VFDA_"  "_$$GET1^DIQ(VFDFILE,VFDA,.01),"    Points to File (#"_VFDFILE_") "_$P($G(^DIC(VFDFILE,0)),U)
 ..S VFDPFIL=0
 ..F  S VFDPFIL=$O(@VFDRSLTS@(VFDFILE,VFDA,VFDPFIL)) Q:'VFDPFIL  D
 ...W !,?3,VFDPFIL_"  "_$$DDNAME(VFDPFIL)
 ...S VFDPFLD=0 
 ...F  S VFDPFLD=$O(@VFDRSLTS@(VFDFILE,VFDA,VFDPFIL,VFDPFLD)) Q:'VFDPFLD  D
 ....W ?50,"Field=("_VFDPFLD_") "_$P($G(^DD(VFDPFIL,VFDPFLD,0)),U)
 ....S (CNT,VFDIENS)=0 
 ....F  S VFDIENS=$O(@VFDRSLTS@(VFDFILE,VFDA,VFDPFIL,VFDPFLD,VFDIENS)) Q:VFDIENS=""  D
 .....W:VFDIEN !,?7,"IEN Value="""_VFDIENS_""""
 .....S CNT=CNT+1
 .....Q
 ....W !,?10,"Record Count ",CNT,!
 ...Q
 ..W $TR($J("",$G(IOM,80))," ","-")
 ..Q
 .Q
 ;
 Q
 ;
C1(VFDFILE,VFDA) ;[Private] From DQC - Process one entry in target file
 ; Normally called by PTR, however, can be invoked independently
 ; 
 ; VFDFILE=[Required] Target file number (pointed-to file)
 ; VFDA=[Required] Entry (IEN) in file VFDFILE
 ;
 I $G(VFDFILE),$G(VFDA) S (VFDPFIL,VFDPSUM)=0
 E  Q
 N VFDFAIL S VFDFAIL=0 W:'$D(ZTQUEUED) "+"
 I '$L($G(VFDRSLTS)) S VFDRSLTS=$NA(^TMP("VFDXTPT1","LMC1",$J)) ;Do not kill
 F  S VFDPFIL=$O(^DD(VFDFILE,0,"PT",VFDPFIL)) Q:'VFDPFIL!VFDFAIL  D
 .S VFDPFLD=0 F  S VFDPFLD=$O(^DD(VFDFILE,0,"PT",VFDPFIL,VFDPFLD)) Q:'VFDPFLD  D C1P
 .W:'$D(ZTQUEUED)&'$G(VFDNODOT) "."
 .Q
 S:'VFDFAIL @VFDRSLTS@("UNREFERENCED",VFDA)=""
 I 'VFDFAIL W:'$D(ZTQUEUED) ! W "Entry IEN="_VFDA_" '"_$$GET1^DIQ(VFDFILE,VFDA,.01),"' has no pointers-in.",!
 Q
 ;
C1P ;[Private] Called by LMC1 - Process one pointer
 ;
 S VFDP4=$P($G(^DD(VFDPFIL,VFDPFLD,0)),U,4)
 S VFDS=$P(VFDP4,";"),VFDP=$P(VFDP4,";",2) Q:'$L(VFDS)!'VFDP
 N VFDCMD
 S VFDCMD="S:$P($G(^(SIS(SISN),VFDS)),U,VFDP)=VFDA VFDFAIL=1"
 D XALL^SISFIND(,VFDPFIL,.VFDCMD)
 Q
 ;
VFDCMD ;
 I VFDVAL=0 I $P($G(^(SIS(SISN),VFDS)),U,VFDP)=VFDA S @VFDRSLTS@(VFDFILE,VFDA,VFDPFIL,VFDPFLD,$$CIENS^SISFIND(SISIENS))=""
 E  I $P($G(^(SIS(SISN),VFDS)),U,VFDP)=VFDA S:VFDA=VFDVAL @VFDRSLTS@(VFDFILE,VFDA,VFDPFIL,VFDPFLD,$$CIENS^SISFIND(SISIENS))=""
 Q
