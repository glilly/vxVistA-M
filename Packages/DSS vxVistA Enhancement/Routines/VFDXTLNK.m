VFDXTLNK ;DSS/PDW - REPORT ERRORS - ; 8/10/09 12:30PM
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;CONSILIDATED ERROR REPORTER
 ;ICR#  Supported Description
 ;----  ---------------------------------------------------------------
 ;      DIQ     $$GET1
 ;      DIE
BRKLNK ;delete broken pointer values of logical link field 770.7
 ;gather protocols with broken pointers & delete value
 N DA,PTR,LNK
 S DA=0 F  S DA=$O(^ORD(101,DA)) Q:DA'>0  D
 . S PTR=$$GET1^DIQ(101,DA_",",770.7,"I") Q:+PTR=0
 . S LNK=$$GET1^DIQ(870,PTR_",",.01) Q:LNK'=""
 . W !,DA,?10,PTR,?30,LNK
 . S DIE=101,DR="770.7///@" D ^DIE
 Q
GET(REC,DLM,XX) ; where XX = VAR_"="_I  ex: XX="PATNM=1"
 ; Set VAR = piece I of REC using delimiter DLM
 N Y,I S Y=$P(XX,"="),I=$P(XX,"=",2),@Y=$P(REC,DLM,I)
 Q
SET(REC,DLM,XX) ; where XX = VAR_U_I  ex: XX="1=PATNUM"
 ; Set VAR into piece I of REC using delimiter DLM
 N Y,I S I=$P(XX,"="),Y=$P(XX,"=",2)
 I Y'=+Y,Y'="" S $P(REC,DLM,I)=$G(@Y) I 1
 E  S $P(REC,DLM,I)=YOUT ;
 Q
