VFDFCNT ;DSS/RAC - File and record counts ;03/25/2013@1000
 ;;2011.1.3;DSS,INC VXVISTA SUPPORTED;;01 Dec 2009;Build 2
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ; Count the number of files and the records in each file.
 Q
EN ;[Public]
 ;
 W !,"List files and the number of records in that file.  Continue?"
 N DIR,DIRUT,DTOUT,DUOUT
 S DIR(0)="Y",DIR("B")=0 D ^DIR
 Q:$D(DTOUT)!$D(DUOUT)!$D(DIRUT)
 S VFDVAL=Y
 ;
DEV ;
 N %ZIS,POP
 W !
 S %ZIS="Q",%ZIS("A")="(queuing recommended) Select DEVICE: ",%ZIS("B")=""
 D ^%ZIS Q:POP
 I $G(IO("Q")) N ZTDESC,ZTRTN,ZTSAVE,ZTSK D  Q  ;If queued
 .S ZTDESC="VFD File Analysis",ZTSAVE("VFD*")="",ZTRTN="DQ^VFDFCNT"
 .D ^%ZTLOAD K IO("Q") D HOME^%ZIS
 .Q
 ; Fall through to DQ, if not queued
 D WAIT^DICD W !
 ;
DQ ;[Private] From PTR
 U IO S VFDA=1.99
 F  S VFDA=$O(^DD(VFDA)) Q:'VFDA  D
 .S VFDNM="",VFDNM=$O(^DD(VFDA,0,"NM",VFDNM))
 .Q:'$D(^DIC(VFDA,0,"GL"))
 .S VFDGL=@(^DIC(VFDA,0,"GL")_"0)")
 .Q:'$D(VFDGL)
 .S VFDRC=$P(VFDGL,U,4)
 .W !,VFDA,?15,$E(VFDNM,1,22),?47,^DIC(VFDA,0,"GL"),?68,VFDRC
 .Q
 Q
