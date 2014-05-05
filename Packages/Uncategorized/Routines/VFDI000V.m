VFDI000V ;DSS/SGM - VXVISTA SUPPORT UTILITIES ; 3/29/2013 18:35
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via the VFDI0000 routine
 ;See documentation at end of this routine
 ;
 Q
 ;-------  BOOLEAN EVALUATION OF VALID VXVISTA VERSION FORMAT  --------
VALID() ;
 ; V - req - version number or Build name
 ; Return 1 if valid, 0 if not valid
 ; This does not completely replace the KIDS Build name check.  If you
 ; call this then it expects an acceptable vxVistA version number
 ; also vxVistA does not support the V,T,B syntax of version number
 N L,VER
 ; extract version number from Build name (must have at least 1 '.')
 S VER=$G(V) S:V["*" VER=$P(V,"*",2) S:V[" " VER=$P(V," ",$L(V," "))
 I VER?1.4N1"."1.2N Q 1
 I VER?1.4N1"."1.2N1"."1.2N Q 1
 Q 0
 ;
 ;------------------  RETURN VXVISTA VERSION NUMBER  ------------------
VER() ;
 ; MAJ - opt - Boolean flag, if true only return major portion of
 ;             current vxVistA version, else return entire version
 ; Return: current vxVistA version number  or
 ;                  0^msg if parameter exists but is not valued
 ;                 -1^msg if parameter definition does not exist
 ;                 -2^msg otherwise
 ;
 N X,Y,Z,DIERR,VFDE,VFDER,VFDNM
 S VFDNM="VFD VXVISTA VERSION"
 S X=$$GET^XPAR("SYS",VFDNM,1)
 ; return vxVistA version from parameter value
 I X>0 Q $S('$G(MAJ):X,1:$P(X,".",1,2))
 ; else return a specific error message
 S X=$$FIND1^DIC(8989.51,,"QX",VFDNM,"B",,"VFDER")
 I X>0 Q "0^"_$$STR(3,VFDNM)
 I '$D(DIERR) Q "-1^"_$$STR(2)
 Q "-1^"_$$STR(1)
 ;
 ;------------- RETURN OR CHECK FOR VXVISTA VERSION NUMBER ------------
VERCK() ;
 ; documentation extensive, see DOC2 at end of routine
 N A,B,I,J,M,S,X,Y,Z,ERR,SYS,VAL,VER
 S MIN=$G(MIN),MAX=$G(MAX),WR=$G(WR)
 ; validate we have a vxVistA system
 S SYS=$$VER I SYS<1 D  G VERCKOUT
 . S VAL=$P(SYS,U,2),VFDRT(2)="   "_VAL,VAL="-9^"_VAL
 . Q
 ; if MAJ then trim version variables
 I $G(MAJ) D
 . S SYS=$P(SYS,".",1,2),MIN=$P(MIN,".",1,2),MAX=$P(MAX,".",1,2)
 . Q
 I 'MIN,'MAX S VAL="-9^"_$$STR(9) G VERCKOUT
 S (VAL(0),VAL(1))=""
 I MIN D
 . I SYS=MIN S VAL(0)="E"
 . E  I $P(SYS,".",1,2)<$P(MIN,".",1,2) S VAL(0)="L"
 . E  I $P(SYS,".",1,2)>$P(MIN,".",1,2) S VAL(0)="G"
 . E  I $P(SYS,".",3)<$P(MIN,".",3) S VAL(0)="l"
 . E  S VAL(0)="g"
 . Q
 I MAX D
 . I SYS=MAX S VAL(1)="E"
 . E  I $P(SYS,".",1,2)>$P(MAX,".",1,2) S VAL(1)="G"
 . E  I $P(SYS,".",1,2)<$P(MAX,".",1,2) S VAL(1)="L"
 . E  I $P(SYS,".",3)>$P(MAX,".",3) S VAL(1)="g"
 . E  S VAL(1)="l"
 . Q
 S VAL="" D
 . I VAL(0)="L" S VAL=-1 Q  ;   system < minimum
 . I VAL(0)="l" S VAL=-1.1 Q  ; system < minimum, 3-dot piece only
 . I VAL(1)="G" S VAL=-2 Q  ;   system > maximum
 . I VAL(1)="g" S VAL=-2.1 Q  ; system > maximum, 3-dot piece only
 . I 'MAX S VAL=1 Q  ;          system >= minimum, no max check
 . I 'MIN S VAL=2 Q  ;          system <= maximum, no min check
 . S VAL=3 ;                    min <= sys <= max
 . Q
 I VAL<0 D
 . S VFDRT(2)=$$STR(5)
 . S VFDRT(3)=$$STR(6,MIN)
 . S VFDRT(4)=$$STR(7,MAX)
 . S VFDRT(5)=$$STR(8,SYS)
 . Q
 S J=$O(VFDRT("A"),-1) I J>1 S J=J+1,VFDRT(J)=""
VERCKOUT ;
 I $O(VFDRT(0)),'$D(VFDRT(1)) S VFDRT(1)=$$STR(4)
 I $G(WR) W ! F I=1:1 Q:'$D(VFDRT(I))  W !,VFDRT(I)
 Q VAL
 ;
 ;-------------  IS THIS A VXVISTA DSS-SUPPORTED ACCOUNT  -------------
VX() ;
 ; see DOC1 at end of routine
 N X,RET
 I '$$RTNTEST^VFDI0000("VFDXTX","X") S RET="VA"
 I '$D(RET),$G(VAPI)'="",$$X^VFDXTX(VAPI) S RET=1
 I '$D(RET) S X=$G(^%ZOSF("ZVX")) I X'="" D
 . I X="VXOS"!(X="VXS") S RET=X
 . E  S RET="VA"
 . Q
 I '$D(RET) S X=$$VER D
 . I X>0 S RET="VXOS" S:$T(^VFDI0004B)'="" RET="VXS" Q
 . I +X=0 S RET="VPART" Q
 . S RET="VA"
 . Q
 I $G(NUM) D
 . I RET=1 S RET=-2
 . I RET="VA" S RET=0
 . I RET="VXOS" S RET=1
 . I RET="VXS" S RET=2
 . I RET="VPART" S RET=-1
 . Q
 Q RET
 ;
 ;---------------------------------------------------------------------
STR(L,X) ;
 ;;Unexpected problems encountered
 ;;This does not appear to be a vxVistA system
 ;;Parameter | is not valued
 ;;   >>>>>>>>>>  ERROR - ERROR - ERROR  <<<<<<<<<<
 ;;   This expects a certain vxVistA system version
 ;;     Minimum vxVistA Version: |
 ;;     Maximum vxVistA Version: |
 ;;     Current System  Version: |
 ;;Either minimum or maximum or both values must be provided
 ;
 N T,Y S Y=$P($T(STR+L),";",3)
 S T=$P(Y,"|") S:$G(X)'="" T=T_X_$P(Y,"|",2)
 Q T
 ;
 ;--------------  DOCUMENTATION FOR SOME MODULES ABOVE  ---------------
DOC ; Description of vxVistA version numbers
 ;There is a major vxVistA version number format and a minor format.
 ;The major format is of the form nnnn.ss
 ;    A major version number indicates a complete release of a new
 ;    version of vxVistA.
 ;The minor format is of the form nnnn.ss.ss
 ;    A minor version number indicates that the major version of
 ;    vxVistA has been updated with patches and enhancements.  These
 ;    updates are exported via the KIDS Build process.  These updates
 ;    are similar of VA patches with one major exception.  The updates
 ;    are cumulative.  Each increment of minor version (3rd-dot piece)
 ;    includes all of the updates from previous minor versions for that
 ;    major version.  As a result, one does not need to install the
 ;    minor updates in sequential order.  Just install the latest minor
 ;    version update KIDS Build.
 ;
 ; nnnn.ss - the nnnn indicates the year that that version was released
 ;           the ss for the major version is just a sequence number
 ; nnnn.ss.ss - the 3rd-dot piece is also just a sequence number
 ;              indicating the ss-th update for that major version.
 ;
DOC1 ; for VX module
 ; VAPI - opt - value from supported/implementation-specific API table
 ;  NUM - opt - 2/26/2013 - if $G(NUM) return numeric value for vxVistA
 ; Below shows the value that the extrinsic function will return based
 ; upon the value of NUM.
 ; RETURN:   'NUM   NUM   Meaning of value
 ;          -----   ---   ----------------------------------------
 ;             VA    0    this is not a vxVistA system
 ;           VXOS    1    vxVistA Open Source
 ;            VXS    2    vxVistA with DSS,Inc maintenance support
 ;          VPART   -1    partial vxVistA system (eg. possibly OSEHRA)
 ;              1   -2    a Support API table value was passed**
 ;
 ;** - the supported API table code was actually executed.  This could
 ;     be used perhaps as a method to see if someone has paid
 ;     maintenance support for a specific interface.
 ;
DOC2 ; for VERCK module
 ; return or check vxVistA version number
 ; .VFDRT - opt - return message array if any anomalies encountered
 ;                If no errors, then no array is returned
 ;    MIN - opt - minimum vxversion to compare against target system
 ;    MAX - opt - maximum vxversion to compare against target system
 ;                REQUIRED: must past MIN or MAX or Both
 ;     WR - opt - Boolean, default 0, if TRUE, write to current device
 ;                contents of .VFDRT
 ;    MAJ - opt - if +MAJ then run all checks in this module using only
 ;                the major version (yyyy.ss)
 ; EXTRINSIC FUNCTION RETURNS
 ; ==========================
 ; vxVistA version numbers can be of the format nnnn.s or nnnn.s.s
 ;   nnnn.s is the major verison     nnnn.s.s is a minor version
 ; convert vxVistA version numbers for straight numeric checks
 ; -- SYS -- refers to the target system vxVistA version number
 ;
 ; RETURN: Numeric value indicating result of comparing the system
 ;         vxVersion against inputted minimum/maximum values
 ;  Return Value  Min/Max inputs     Meaning
 ;  ------------  -----------------------------------------
 ;        1       No max value,      major sys >= major min
 ;        1.1     No max value,      major sys  = major min
 ;                   3rd-dot piece     and sys >= min
 ;       -1       No max value,      major sys <  major min
 ;       -1.1     No max value,      major sys  = major min
 ;                   3rd-dot peice     and sys <  min
 ;        2       No min value,      major sys >= major max
 ;        2.1     No min value,      major sys  = major max
 ;                   3rd-dot piece     and sys >= max
 ;       -2       No min value,      major sys <  major max
 ;       -2.1     No min value,      major sys  = major max
 ;                   3rd-dot peice     and sys <  max
 ;        3       Both max & min,    min <= sys <= max
 ;       -9^msg   Problem or error(s) encountered
