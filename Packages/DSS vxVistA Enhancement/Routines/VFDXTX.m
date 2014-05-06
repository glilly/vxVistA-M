VFDXTX ;DSS/LM - Implementation-specific API support ; 05/01/2012 11:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Line tags above the Private Subroutines may be called from external
 ; references
 ;
 Q
 ;
 ;sgm - 9/21/2011 - allowed X to be called as extrinsic function
X(VFDAPI,VFDNOX,VFDY) ;
 ; Xecute an implementation-specific or supported API
 ; VFDAPI - req - Supported API exact name
 ; VFDNOX - opt - Boolean, default to 0
 ;                If 1 return execute string, do not execute
 ;  .VFDY - opt - return array - If this API actually executes the
 ;                API's M code --AND-- that M code sets the VFDY
 ;                variable or array, then it will be returned.
 ;                This X API does not set nor kill VFDY.
 ;
 ; EXTRINSIC FUNCTION
 ;   If 'VFDNOX then execute string and return either:
 ;     1: M code actually did something
 ;     0: if no M code or M execute code is "Q"
 ;     if the code executed from the API Table sets the variable VFDY
 ;        --AND-- if $G(VFDY)'="" then return the value of VFDY
 ;
 ; LOCAL VARIABLES
 ;   VFDX will be the M code to be executed which was obtained from the
 ;   Supported API tables.
 ;
 N VIEN,RTN,VFDX
 S (VIEN,RTN,VFDX)="",VFDAPI=$G(VFDAPI),VFDNOX=$G(VFDNOX)
 I VFDAPI'="" S VIEN=$O(^VFD(21614.1,"B",VFDAPI,0))
 ; check for implementation specific xecute first, then check for
 ; supported API default xecute
 I VIEN D
 . D GETCODE(21614,1),GETRTN(21614)
 . D:VFDX="" GETCODE(21614.1,2) D:RTN="" GETRTN(21614.1)
 . I VFDX'="",RTN'="" D
 . . N X S X=RTN X ^%ZOSF("TEST") E  S VFDX=""
 . . Q
 . I VFDX'="",'VFDNOX X VFDX
 . Q
 I 'VFDNOX S VFDX=$S(VFDX="":0,$G(VFDY)'="":VFDY,1:1)
 Q:$Q VFDX
 Q
 ;
TOHEX(X) ; String to hex
 ; X - req - ASCII string to be converted to hex
 ; 
 N %,Y
 S Y="" F %=1:1:$L($G(X)) S Y=Y_$TR($J($$CNV^XLFUTL($A($E(X,%)),16),2)," ",0)
 Q Y
 ;
FRHEX(X) ; Hex to string
 ; X - req - Hex string to be converted to decimal
 ; 
 N %,Y
 S Y="" F %=1:2:$L($G(X)) S Y=Y_$C($$DEC^XLFUTL($E(X,%,%+1),16))
 Q Y
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
GETCODE(F,N) S VFDX=$G(^VFD(F,VIEN,N)) S:VFDX="Q" VFDX="" Q
GETRTN(F) S:RTN="" RTN=$P($G(^VFD(F,VIEN,0)),U,5) Q
 ;
DIM(X) ; Check X in ^DIM
 ; X - req - Non-empty M code string to check
 I $L($G(X)) D ^DIM Q $D(X)
 Q 0
