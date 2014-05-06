VFDPSB ;DSS/LM - vxBCMA to vxPAMS interface ; 6/23/2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EVENT(VFDRSLT,VFDIEN,VFDSCAN,VFDTAB) ;{REMOTE PROCEDURE} VFD BCMA EVENT
 ; 
 ; VFDIEN=[Required] BCMA MEDICATION LOG internal entry number
 ; VFDSCAN=[Required] Scan code of medication associated with the log entry
 ; VFDTAB=[Required for unit dose or PB] "UDTAB" = unit dose.
 ;                                       Else, IV/IVPB ward stock scan.
 ; 
 ; VFDRSLT=Return value by reference: 0=Success or "-1^Text" for error
 ; 
 D EVENT^VFDPSB1(.VFDRSLT,.VFDIEN,.VFDSCAN,.VFDTAB)
 Q
