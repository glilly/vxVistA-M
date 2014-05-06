VFDSD ;DSS/PDW - PATIENT LIST BY SCHED PROVIDER;14 Jan 2009 16:54
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
SCHPATLK(VFDRSLT,VFDINFO) ;RPC: VFD SD SCHED PROV PAT LIST
 ; get patient list for a scheduling provider 
 ; VFDINFO(n) = p1^p2  for n=0,1,2,3,...  where
 ;   P1 := mnemonic    p2 := value of that label
 ;         acceptable mnemonics:
 ;           LOC - opt - hospital location ien (#44) [0,1, or more]
 ;           PRV - opt - scheduling provider duz [0,1, or more]
 ;           SDT - opt - appointment starting date
 ;                       default to TODAY
 ;           EDT - opt - appointment ending date
 ;                       default to TODAY at midnight
 ;          TEST - opt - check to see if local field for scheduling
 ;                 provider exists on this system.  If TEST label
 ;                 received, ignore all other labels
 ;Return VFDRSLT(n) = p1^p2^p3 for n=0,1,2,3,... where
 ;  if error condition then return VFDRSLT(1) = -1^error message
 ;  else p1 := patient dfn;patient name
 ;       p2 := clinic ifn;clinic name
 ;       p3 := appt date/time (FM);external appt date/time
 ;  If input TEST mnemonic then return VFDRSLT(1) = 1 or -1^err msg
 ;  Patient appointmets returned presorted first by patient name and
 ;    then by appt date/time 
 ;
 D SCHPATLK^VFDSD1(.VFDRSLT,.VFDINFO) ;Call subroutine to perform work
 Q
