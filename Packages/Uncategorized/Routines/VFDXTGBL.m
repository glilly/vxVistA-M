VFDXTGBL ;DSS/PDW - GLOBAL UTILITIES13 JAN 2009 
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
GBL2GBL ;compare same global across two name spaces.
 S GBL="LEX(757.02)",GBLT=$E(GBL,1,$L(GBL)-1)
 S NS1="USER",NS2="VOS"
 S G1="^"_GBL
 F I=0:1 W:'(I#1000) "." S G1=$Q(@G1) Q:G1'[GBLT  S G2="^|NS2|"_$E(G1,2,99) D
 .I $D(@G2),@G1=@G2 Q
 .W !!,NS1,G1,?30,@G1,!,NS2,?30,$S($D(@G2):@G2,1:"none")
 Q 
