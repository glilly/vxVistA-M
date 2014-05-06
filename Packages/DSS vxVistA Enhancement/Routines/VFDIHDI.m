VFDIHDI ;DSS/WLC - Post Initialization routine for Standardized files;02/07/08
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ; First kill off affected 9 nodes in Data Dictionary
 N VFDFLE,VFDFLD,I
 S VFDFLE=120.49999
 F  S VFDFLE=$O(^DD(VFDFLE)) Q:VFDFLE>120.54  S VFDFLD=0 F  S VFDDLF=$O(^DD(VFDFLE,VFDFLD)) Q:'VFDFLD  K ^DD(VFDFLE,VFDFLD,9)
 ; Now setup up Trigger cross-reference for VUID in standard files 120.51-120.53
 N VFDCNT,VFDGLB,VFDDATA
 F VFDFLE=120.51:.01:120.53 D
 . S VFDCNT=1 F I=1:1 Q:$P($T(T+((VFDCNT*2)-1)),";;",2)=""  D
 . . S VFDGLB=$P($T(T+((VFDCNT*2)-1)),";;",2),VFDDATA=$P($T(T+(VFDCNT*2)),";;",2),VFDCNT=VFDCNT+1
 . . S @VFDGLB=VFDDATA
 Q
 ; Trigger the cross-reference for each file.
 F DIK=120.51:.01:120.53 D IXALL^DIK
 Q
 ;
T ; Global reference on first line of pair, Data on second
 ;;^DD(VFDFLE,.01,1,21600,0)
 ;;^^TRIGGER^FILE^99.99
 ;;^DD(VFDFLE,.01,1,21600,1)
 ;;X ^DD(VFDFLE,.01,1,21600,1.3) I X S X=DIV S Y(1)=$S($D(^GMRD(VFDFLE,D0,"VUID")):^("VUID"),1:"") S X=$P(Y(1),U,1),X=X S DIU=X K Y S X=DIV S X=$$VUIDG^VFDHDIA(VFDFLE) I X>0 X ^DD(VFDFLE,.01,1,21600,1.4)
 ;;^DD(VFDFLE,.01,1,21600,1.3)
 ;;K DIV S DIV=X,D0=DA,DIV(0)=D0 S Y(0)=X S Y(1)=$S($D(^GMRD(VFDFLE,D0,"VUID")):^("VUID"),1:"") S X=$P(Y(1),U,1)=""
 ;;^DD(VFDFLE,.01,1,21600,1.4)
 ;;S DIH=$G(^GMRD(VFDFLE,DIV(0),"VUID")),DIV=X S $P(^("VUID"),U,1)=DIV,DIH=FILE,DIG=99.99 D ^DICR
 ;;^DD(VFDFLE,.01,1,21600,2)
 ;;Q
 ;;^DD(VFDFLE,.01,1,21600,"CREATE CONDITION")
 ;;VUID=""
 ;;^DD(VFDFLE,.01,1,21600,"CREATE VALUE")
 ;;S X=$$VUIDG^VFDHDIA(VFDFLE) I X>0
 ;;^DD(VFDFLE,.01,1,21600,"DELETE VALUE")
 ;;NO EFFECT
 ;;^DD(VFDFLE,.01,1,21600,"DT")
 ;;3080207
 ;;^DD(VFDFLE,.01,1,21600,"FIELD")
 ;;VUID
 ;;
 
 
 
 
