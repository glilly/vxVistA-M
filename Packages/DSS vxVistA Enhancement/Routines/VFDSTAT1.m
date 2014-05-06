VFDSTAT1 ;DSS/LM - Statistics, continued ;24 Mar 2011 17:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
LR1 ;[Public] - Lab statistics for ARRA 173.02(n)
 N DIR,DIRUT,VFDEDT,VFDSDT,X,Y
 S DIR(0)="D:O",DIR("A")="START DATE" D ^DIR Q:$D(DIRUT)
 S VFDSDT=$S(Y>0:+Y-.000001,1:0)
 S DIR(0)="D:O",DIR("A")="END DATE" D ^DIR Q:$D(DIRUT)
 S VFDEDT=$S(Y>0:+Y,1:9999999)
 N %ZIS,POP S %ZIS="" D ^%ZIS Q:POP
 ;
 ; Acquire data
 N VFDA,VFDI,VFDA,VFDJ,VFDDEN,VFDNUM,VFDORD,VFDORF,VFDSPEC,VFDTEST,VFDZ
 S (VFDDEN,VFDNUM)=0
 S VFDA=VFDSDT F  S VFDA=$O(^LRO(69,"B",VFDA)) Q:'VFDA!(VFDA>VFDEDT)  D  ;DATE ORDERED
 .S VFDSPEC=0 F  S VFDSPEC=$O(^LRO(69,VFDA,1,VFDSPEC)) Q:'VFDSPEC  D  ;SPECIMEN
 ..S VFDTEST=0 F  S VFDTEST=$O(^LRO(69,VFDA,1,VFDSPEC,2,VFDTEST)) Q:'VFDTEST  D  ;TEST
 ...S VFDZ=$G(^LRO(69,VFDA,1,VFDSPEC,2,VFDTEST,0))
 ...Q:$P(VFDZ,U,9)="CA"  ;Cancelled
 ...S VFDORD=$P(VFDZ,U,7) Q:'VFDORD  ;OERR INTERNAL FILE #
 ...S VFDORF=$G(^OR(100,VFDORD,4))
 ...S VFDDEN=VFDDEN+1
 ...Q:'($P(VFDORF,";",4)="CH")  ;ORDER : PACKAGE REFERENCE
 ...S VFDNUM=VFDNUM+1
 ...Q
 ..Q
 .Q
 ;
 ; Prepare report
 U IO
 I VFDDEN=0 W !,"No lab test orders found in specified date range." Q
 W !,VFDNUM," Results found for ",VFDDEN," lab tests ordered in specified date range."
 Q
