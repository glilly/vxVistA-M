VFDTIUTL ;DSS/LM - Miscellaneous TIU utilities ;15 June 2011
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 Q
SIGN ;[Private] From SIGN^TIUSRVP2 - Notify when document is signed...
 ; Tasks a process to unwind notification protocol
 ;
 N VFDTIUDA,ZTDESC,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTSK
 S VFDTIUDA=$G(TIUDA) ;TIU DOCUMENT IEN (from RPC)
 S ZTDESC="Signed document notification"
 S ZTDTH=$H,ZTIO="",ZTSAVE("VFDTIUDA")="",ZTRTN="DQSIGN^VFDTIUTL"
 D ^%ZTLOAD
 Q
DQSIGN ;[Private] From SIGN^VFDTIUTL -
 ; Unwinds extended action protocol VFD TIU SIGNED DOCUMENT in background.
 ; Variable VFDTIUDA=TIU DOCUMENT IEN passed in the environment
 ;
 N X S X=$$FIND1^DIC(101,,"X","VFD TIU SIGNED DOCUMENT","B")_";ORD(101," ;Find
 D EN1^XQOR:X ;Unwind
 K VFDTIUDA ;Cleanup
 Q
