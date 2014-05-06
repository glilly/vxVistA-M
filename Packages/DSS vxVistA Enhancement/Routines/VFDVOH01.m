VFDVOH01 ;DSS/SGM - MESSAGE FORWARDER FILTERS ; 09 Apr 2013  10:33 AM
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine should only be invoked via the ^VFDVOH routine
 ;
 ;====== Parse ORMSG Array To Extract Commonly Referenced Items =======
 ;
PARSE(VFDA) ;
 ; VFDA           = (placer) order id - ORC.2
 ; VFDA("CLASS")  = patient class, inpat or outpat - PV1.2
 ;                  if not value, default to (O)utpatient
 ; VFDA("DFN")    = patient DFN - PID.3
 ; VFDA("ORDCC")  = order control code - ORC.1
 ; VFDA("PKREF")  = package reference - ORC.3
 ; VFDA("PSAUTO") = value exists IF $$PSAUTO called
 ; VFDA("TASK")   = 0:do not tasked; 1:process via tasked schedule
 ;
 N A,I,X,Z,FS,SEG S FS=$$FS^VFDVOHU
 K VFDA S VFDA=""
 F X="CLASS","DFN","ORDCC","PKREF" S VFDA(X)=""
 S VFDORD("TASK")=1
 S I=0 F  S I=$O(VFDVMSG(I)) Q:'I  S Z=VFDVMSG(I),SEG=$P(Z,FS) D
 . I SEG="ORC",$G(VFDA)="" D
 . . S VFDA=$P($P(Z,FS,3),U) ; placer order# may have ';'-pieces
 . . S VFDA("ORDCC")=$P(Z,FS,2)
 . . S VFDA("PKREF")=$P($P(Z,FS,4),U)
 . . Q
 . I SEG="PID" S VFDA("DFN")=$P(Z,FS,4)
 . I SEG="PV1" S X=$P(Z,FS,3) S:X="" X="O" S VFDA("CLASS")=X
 . Q
 I VFDVTO="PS" D PSAUTO(.VFDA)
 Q
 ;
 ;=============== Filters For CPRS-Pharmacy HL7 Messages ==============
 ;
PS() ; filters for CPRS-pharmacy HL7 messages
 ; D DEBUG^VFDVOH(,"PS")
 ; 2011.1.2 T7 - fix for mixed inpatient/outpatient site; new logic,
 ;               only do something if $D(VFDRTN)
 ; RETURN: 0:don't do anything;  1~<argument of DO command>
 N A,I,X,Y,Z,CHK,FAIL,RTN,VFDRTN,VMSG
 S FAIL=0
 Q:'$G(VFDORD) 0
 Q:'$D(VFDORD("CLASS")) 0
 Q:$G(VFDORD("ORDCC"))="" 0
 ; screen out non-VA Meds
 Q:$$GETFLD("ZRN",1)="ZRN" 0
 ; reset VFDORD("CLASS") based upon logic used in PV1^PSJHL4
 I VFDORD("CLASS")="O" D
 . S X=$$GETFLD("OBR",4)
 . I X'="",X'="-1^NO SEG","ABNPUV"[$E(X,$L(X)) S VFDORD("CLASS")="I" Q
 . S X=$G(VFDORD("PKREF")) ; ORC.3
 . I X'="","ABNPUV"[$E(X,$L(X)) S VFDORD("CLASS")="I" Q
 . S CHK=$$GETFLD("RXO",2) ; RXO.1
 . Q:CHK="-1^NO SEG"
 . S CHK=$S($P(CHK,U,5)="IV":"IV",1:$P(CHK,U,4))
 . I CHK="IV" S VFDORD("CLASS")="I" Q
 . I 'CHK S VFDORD("CLASS")="I" Q
 . I $P($G(^PS(50.7,CHK,0)),U,3)=1 S VFDORD("CLASS")="I" Q
 . Q
 I VFDORD("CLASS")="O" D  ; outpatient order
 . ; check for auto-complete parameter
 . Q:$G(VFDORD("PSAUTO"))'=1
 . Q:'$$RTN("RELEASE^VFDPSOR")
 . ; NW = new order   XO = edit/change (for renew)
 . ; for new script (NW), ORC.3 must be <null> or ##S
 . ; for renew (RNW), ORC.3 should be a number only
 . S X=VFDORD("ORDCC") I X'="NW",X'="XO" Q
 . S Y=VFDORD("PKREF") I X="NW",Y'="",$E(Y,$L(Y))'="S" Q
 . ; checks for when auto-renewing is allowed
 . I X="XO",$E(Y,$L(Y))="S" Q
 . ;Check for "E" for changes to orders (Edits)
 . I X="XO",$$GETFLD("ZRX",4)'="E",$$GETFLD("ZRX",4)'="R" Q
 . S VFDRTN="RELEASE^VFDPSOR"
 . Q
 ;
 I VFDORD("CLASS")="I" D  ; inpatient
 . Q
 I $G(VFDRTN)="" Q 0
 Q "1~"_VFDRTN
 ;
 ;=======================  PRIVATE SUBROUTINES  =======================
 ;
GET1(FILE,IEN,FLD,FLG) ;
 N I,J,X,Y,Z,DIERR,VFDERR
 S IEN=+$G(IEN)_"," S:$G(FLG)="" FLG="I"
 S X=$$GET1^DIQ(FILE,IEN,FLD,FLG,,"VFDERR")
 S:$D(DIERR) X=-1
 Q X
 ;
GETFLD(SEG,PIECE) ; get one field value from HL7 message
 ; Returns: value or -1^NO SEG if segment not found
 ;          or -ERR (this should never happen)
 Q $$GET1^VFDVOHU(.VFDVMSG,$G(SEG),$G(PIECE))
 ;
PARM(ENT,PARM) S:$G(ENT)="" ENT="SYS" Q $$GET^XPAR(ENT,PARM)
 ;
PSAUTO(VFDA) ; check to see if AUTO-COMPLETE of OP order to be done
 ; .VFDA - req - VFDORD() from VFDVOH
 ; division setting overrides system
 ; RETURN: 0: auto-complete not to be done
 ;         1: auto-complete to be done in foreground
 ;    <null>: parameter has no value set
 N I,J,X,Y,Z,RET,VFDIV
 S RET=$$PARM("SYS","VFDVOH PSO AUTO")
 I $G(VFDA) D
 . ; get division to see if division overrides
 . S X=$$GET1(100,+VFDA,6) I X'?1.N1";SC(" Q  ; order has no location
 . S Y=$$GET1(44,+X,3)
 . I 'Y S Y=$$GET1(44,+X,"3.5:.07") I 'X Q  ;   loc has no division
 . S VFDIV=Y,Y=$$PARM("DIV.`"_(+Y),"VFDVOH PSO AUTO")
 . I Y'="" S RET=Y
 . Q
 S VFDA("PSAUTO")=RET
 S VFDA("TASK")=(RET'=1)
 Q
 ;
RTN(R) Q $T(@R)'=""
