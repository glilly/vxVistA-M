VFDDGPM0 ;DSS/LM - Pre-load admission visits ; 05/09/2013 10:00
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  Supported Description
 ; ----  ---------------------
 ;       Direct global read of file 405 ^DGPM(ien,0)
 ;
 Q
 ;
 ;Routine to be deprecated once vxVistA 2013.0 Open Source is released
 ;see post^vfddgpm
 ;
EN ;Main entry
 N DGPMCA,DGPMDA,X S DGPMDA=0
 F  S DGPMDA=$O(^DGPM(DGPMDA)) Q:'DGPMDA  S X=$G(^(DGPMDA,0)) D:X
 .I $P(X,U,2)=1,$S($G(VFDALL):1,1:'$P(X,U,17)) S DGPMCA=DGPMDA D 1^VFDDGPM2
 .I $G(VFDECHO) U IO(0) W "."
 .Q
 Q
EN2 ; Alternate entry - Process ALL admission movements, whether or not
 ; a corresponding discharge exists
 ; 
 N VFDALL S VFDALL=1 D EN
 Q
