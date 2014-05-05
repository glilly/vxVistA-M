VFDXXPST ;DSS/LM - Exception handler - Post-install ; 3/10/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
EN ;[Public] - VFD EXCEPTIONS 1.0 (T4+) Post-install
 ;
 D PID
 ; Additional post-install here
 Q
PID ;[Private] Confirm or create VFD HL7 PID application in File 21603.1
 ;
 N VFDFDA
 S VFDFDA(21603.1,"?+1,",.01)="VFD HL7 PID"
 S VFDFDA(21603.1,"?+1,",1)="D EN1^VFDXXPID"
 D UPDATE^DIE(,$NA(VFDFDA))
 Q
