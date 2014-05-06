VFDCVT0 ;DSS/WLC - DRIVER EVENTS FOR APPT RPC ROUTINES ;06/06/2006 14:57
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Driver events for Appointment RPC calls
 ; This routine is a re-write of the VFDCVST calls formerly defined within
 ; CORE RPCs.  The re-write has been done to incorporate the new
 ; Replacement Scheduling Application (RSA) APIs.
 ; 
APPT(RET,DATA,SCR) ; rpc: VFDC GET SCHED APPTS
 ;      
 ; Retrieve Appointment data
 N VFDR,ASCR,I
 S DATA=$G(DATA),SCR=$G(SCR)
 S (RET,VFDR)=$NA(^TMP("VFDC",$J,"APPT")) K @VFDR
 ;
 ; convert screens to array
 K ASCR
 I SCR'="" D
 . F I=1:1:$L(SCR,";") D
 . . N VFD1,VFD2,VFD3
 . . S VFD1=$P(SCR,";",I)
 . . S VFD2=$P(VFD1,U,1),VFD3=$P(VFD1,U,2)
 . . ; convert to internal for stop codes
 . . S VFD3=$S(VFD2="S":$O(^DIC(40.7,"C",VFD3,"")),1:VFD3)
 . . S ASCR(VFD2,VFD3)=""
 D APPT^VFDCVT1(.VFDR,DATA,.ASCR)
 Q
 ;
VST(RETX,DFN,BEG,END,ZLOC,CAT,SCR) ; RPC:  VFDC GET VISITS ONLY
 ; this gets visits only
 N VFDR
 S (RETX,VFDR)=$NA(^TMP("VFDC",$J,"VSIT"))
 N I,J F I=1:1:6 S J=$P("DFN^BEG^END^ZLOC^CAT^SCR",U,I),@J=$G(@J)
 D VS^VFDCVT3(.VFDR,DFN,BEG,END,ZLOC,CAT,SCR)
 Q
 ;
VSIT(RETV,DATA,SCR) ; RPC:  VFDC GET VISITS/APPOINTMENT
 ; visits and appointments
 N VFDR
 S (RETV,VFDR)=$NA(^TMP("VFDC",$J,"RET"))
 S SCR=$G(SCR)
 D VSIT^VFDCVT1(.VFDR,DATA,.SCR)
 Q
 ;
APPL(VFDC,SDT,EDT,DATA)  ; RPC:  VEJDSD GET SCHEDULED APPTS
 ; This gets active sceduled appts for one or more clinics
 N VFDR
 S (VFDC,VFDR)=$NA(^TMP("VEJD",$J))
 S SDT=$G(SDT),EDT=$G(EDT)
 D APPL^VFDCVT2(VFDC,SDT,EDT,DATA)
 Q
 ;       
