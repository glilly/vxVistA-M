VFDXPDH ;DSS/SGM - LAST PATCH INSTALLED ;07 Oct 2010 15:52
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via ^VFDXPD
 ;
 ;=============  DELETE ROUTINES ASSOCIATED WITH BATCH  ==============
DEL ; delete routines associated with a VFD BATCH Profile
 ;;Delete the following routines
 ;;To remain implementation independent, you will be prompted to
 ;;select these routines.  Then you will be prompted as to whether or
 ;;not to continue with the deletion.  Copy the list of the routines
 ;;to the clipboard.  Then paste it at the routine prompt.
 ;;
 Q:'$G(PID)
 N I,J,X,Y,Z,DEL,RTN,SP,STAR
 S $P(SP," ",16)="",STAR=""
 ; get routines
 S I=0 F  S I=$O(BATCH(I)) Q:'I  S J=0 D
 .F  S J=$O(^VFDV(21692,I,4,J)) Q:'J  S X=^(J,0) D
 ..S RTN(X)="" S:$E(X,$L(X))="*" STAR=1
 ..Q
 .Q
 W !! S X=0 F  S X=$O(RTN(X)) Q:X=""  D WR
 Q:$$DIR^VFDXPD0(9)'=1
 ; routine groups, use M-implementation specific delete utility
 I STAR D
 .S X=$$DIR^VFDXPD0(10)
 .S X=0 F  S X=$O(RTN(X)) Q:X=""  W !,X
 .K ^UTILITY($J) X ^%ZOSF("RSEL")
 .K RTN S X=0 F  S X=$O(^UTILITY($J,X)) Q:X=""  S RTN(X)=""
 .K ^UTILITY($J)
 .Q
 ; now delete the routines
 I $O(RTN(0))'="" D  Q
 .S DEL=^%ZOSF("DEL") W !!,"Deleting routines . . . ",!
 .S X=0 F  S X=$O(RTN(X)) Q:X=""  D WR X DEL
 .Q
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
WR W $E(X_SP,1,10) W:$X>71 ! Q
