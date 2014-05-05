VFDZXTPAR ;DSS/PDW - ROUTINE TO HANDLE SYSTEM UTILITIES FOR XPAR PARAMETERS
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 Q
VFDXTPAR ;DSS/PDW - ROUTINE TO HANDLE SYSTEM UTILITIES FOR XPAR PARAMETERS
 ;;
 Q
SYSPARUP ; update System Kernel Parameters to new domain 
 ;of system entity parameters with bogus values
 N DOM,DOMNOW,PARNM,G,LN,DOMNM
 S DOM=$$GET1^DIQ(8989.3,"1,",.01,"I") ;Ker Par ==> Domain
 S DOMNM=$$GET1^DIQ(8989.3,"1,",.01) ;Ker Par ==> Domain
 S DOMNOW=DOM_";DIC(4.2,",G=$NA(^TMP($J,"XPAR"))
 K @G
 D TXT
 K DIR S DIR(0)="YO",DIR("A")="Do you wish to proceed? " D ^DIR
 Q:Y'=1
 ;count entries
 S IEN=0 F I=0:1 S IEN=$O(^XTV(8989.5,IEN)) Q:IEN'>0
 W !!,"Parameters to check: ",I,!
 ;loop B index store in @g  (^TMP)
 W !,"Gathering parameters that are system",!
 S PARNM=""
 F I=0:1 S PARNM=$O(^XTV(8989.5,"B",PARNM)) Q:PARNM=""  I PARNM[";DIC(4.2," D
 .N J S J=0 F  S J=$O(^XTV(8989.5,"B",PARNM,J)) Q:J'>0  S @G@(J)=""
 ;
 S J=0 F  S J=$O(@G@(J)) Q:J'>0  D PARUP(J)
LIST ;
 K DIR S DIR(0)="YO^",DIR("A")="Do you wish to reprint the above list? " D ^DIR
 Q:Y'=1
 S LN=0 F  S LN=$O(@G@("X",LN)) Q:LN'>0  W !,@G@("X",LN)
 G LIST
 Q
PARUP(J) ;UPDATE: pull, test, create, delete
 N VAL,PARE,PARI ;PARE() EXTERNAL PARI() INTERNAL
 D GETS^DIQ(8989.5,J_",","@;.01;.02;.03;1","IE","VAL","MSG")
 F FLD=.01,.02,.03,1 S PARI(FLD)=$G(VAL(8989.5,J_",",FLD,"I")),PARE(FLD)=$G(VAL(8989.5,J_",",FLD,"E"))
 I PARI(.01)=DOMNOW Q  ;this sys par is already pointing to the new domain already switched
 ; skip two parameters
 Q:PARE(.02)=""  ;found some parameters without a definition value
 I PARE(.02)="GMV DLL VERSION" W !,PARE(.02) Q
 I PARE(.02)="GMV GUI VERSION" W !,PARE(.02) Q
 ; if new syspar exists keep it with its new value
 W !," ",$G(LN)+1
 I $D(^XTV(8989.5,"AC",PARI(.02),DOMNOW,PARI(.03))) I 1 ;exists delete
 E  D PARADD(.PARI,.PARE) 
 D PARDEL(.PARI,.PARE)
 Q
PARADD(PARI,PARE) ;
 D EN^XPAR(DOMNOW,PARI(.02),PARI(.03),PARE(1),.error)
 S LN=$G(LN)+1,@G@("X",LN)="A^"_DOMNM_U_PARE(.02)_U_PARE(.03)_U_PARE(1)
 W !,"A^"_DOMNM_U_PARE(.02)_U_PARE(.03)_U_PARE(1)
 Q
PARDEL(PARI,PARE) ;
 D EN^XPAR(PARI(.01),PARI(.02),PARI(.03),"@",.error)
 S LN=$G(LN)+1,@G@("X",LN)="D^"_PARE(.01)_U_PARE(.02)_U_PARE(.03)_U_PARE(1)
 W !,"D^"_PARE(.01)_U_PARE(.02)_U_PARE(.03)_U_PARE(1)
 Q
TXT ;
 W @IOF,!!
 W "The new domin is ",DOMNM
 F I=0:1 S X=$P($T(TXT1+I),";;",2) Q:X="END"  W !,X
 Q
TXT1 ;;
 ;;This will change 'SYS' PARAMETERS to the 
 ;;new DOMAIN in the Kernel Site Parameter file.
 ;;
 ;;Some parameters are not editable and they will remain.
 ;;
 ;;A second run will reveal those that were not changed.
 ;;
 ;;The parameters GMV DLL VERSION & GMV GUI VERSION are
 ;;not changed per instructions.
 ;;
 ;;END
 Q
SAVE M ^PWXTV895=^XTV(8989.5) W !,"^PWXTV895 SAVED" Q
RESTORE I $D(^PWXTV895)=10 K ^XTV(8989.5) M ^XTV(8989.5)=^PWXTV895 W !,"RESTORED" Q
