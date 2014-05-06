VFDI0004C ;DSS/SGM -VFD KERNEL 2011.1.1 ENV/PRE/POST ; 11/30/2012 20:10
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 86
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
ENV ; environmental check
 Q
 ;
PRE ; pre-installation
 N X,CACHE
 Q:'$$VX  
 D ZOSF
 Q
 ;
POST ; post-installation
 N X,CACHE
 Q:'$$VX
 D POST1 ; rename %-routine source code to %-routine name
 I $T(EN^VFDPSOLL)'="" D POST^VFDPSOLL
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
POST1 ; rename kernel routines to corresponding %-name routine
 ;;ZOSVONT^%ZOSV
 ;;ZISTCP^%ZISTCP
 ;;ZTMS^%ZTMS
 ;;ZTMS2^%ZTMS2
 ;
 N I,X,Y,Z,FR,TO
 F I=1:1 S X=$P($T(POST1+I),";",3,99) Q:X=""  D
 . S FR=$P(X,U),TO=$P(X,U,2)
 . I FR="ZOSVONT",'CACHE Q
 . N I S Z=$$RTNCOPY^VFDI0000(FR,TO)
 . Q
 Q
 ;
VX() ; boolean return if this a vxvista system
 ;  also initialize local vars: CACHE
 N X,Y S (X,CACHE)=0
 I $T(VX^VFDI0000)'="" D
 . I $T(CACHE^VFDI0000)'="" S CACHE=$$CACHE^VFDI0000
 . S X=($$VX^VFDI0000["VX")
 . Q
 Q X
 ;
ZOSF ; check to see if %ZOSF nodes need updating
 ;;TEST;I X?1(1"%",1A).ANP,$D(^$ROUTINE(X))
 ;;ZVX;VXOS
 ;
 N I,N,X,Y,CUR
 F I=1:1 S N=$P($T(ZOSF+I),";;",2,99) Q:N=""  D
 . S X=$P(N,";"),Y=$P(N,";",2,99)
 . Q:X=""!(Y="")  S CUR=$G(^%ZOSF(X))  Q:CUR=Y
 . I X="TEST",'CACHE Q
 . I X="ZVX",CUR="" S ^%ZOSF(X)=Y
 . Q
 Q
