VFDMERU ;DSS/WLC - PATIENT (#2) file merge utility
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ; This routine is a pre-merge routine to clean up data in the PATIENT (#2) file
 ; before performing the merge process on two DFNs.  Initially, this routine will
 ; mark the VFD index records for MRN to indicate these as non-defaults.  The 
 ; 'merged into' record will contain the only default MRN.  Any default entries in the 
 ; 'merged from' recrd will be changed to indicate no default.  In this way, the display
 ; inside Vx-CPRS will display the E-MRN for the 'merged into' record only.
 Q
 ;
EN(VFDX) ;
 N X,XDRFR
 I '$D(@VFDX) Q
 S XDRFR=$O(@VFDX@(""))  ; extract FROM record
 S VFDREC=0 F X=1:1 S VFDREC=$O(^DPT(XDRFR,21600,VFDREC)) Q:'VFDREC  D
 . S $P(^DPT(XDRFR,21600,VFDREC,0),U,4)=""
 Q
 ;
 
