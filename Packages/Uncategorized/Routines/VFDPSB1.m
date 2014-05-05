VFDPSB1 ;DSS/LM - vxBCMA to vxPAMS interface ; 6/23/2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EVENT(VFDRSLT,VFDIEN,VFDSCAN,VFDTAB) ;Implement RPC: VFD BCMA EVENT
 ; See EVENT^VFDPSB for documentation
 ; 
 I $G(VFDIEN)>0
 E  S VFDRSLT="-1^Invalid required parameter: BCMA MEDICATION LOG IEN." Q
 I $L($G(VFDSCAN))
 E  S VFDRSLT="-1^Invalid required parameter: Scanned medication code." Q
 I $D(^PSB(53.79,VFDIEN)) S VFDTAB=$G(VFDTAB)
 E  S VFDRSLT="-1^Referenced BCMA MEDICATION LOG entry does not exist." Q
 S VFDRSLT=0 I VFDTAB="UDTAB" N VFD50IEN,VFDLIST,VFDNDC
 E  D OTHER(.VFDRSLT,.VFDIEN,.VFDSCAN,.VFDTAB) Q
 ; UNIT DOSE case - Resolve DRUG IEN -
 D SCANMED^PSBRPC2(.VFDLIST,VFDSCAN,VFDTAB)
 I $G(VFDLIST(0))<0 S VFDRSLT="-1^Dispense drug lookup failed." Q
 I $G(VFDLIST(0))>1 S VFDRSLT="-1^Unable to determine exact medication." Q
 S VFD50IEN=$P($G(VFDLIST(1)),U,2) I VFD50IEN>0
 E  S VFDRSLT="-1^Unexpected failure resolving unit dose dispense drug." Q
 ; DRUG IEN resolved.
 S VFDNDC=$$NDC(VFD50IEN,VFDSCAN)
 D FILE ;File AUDIT LOG entry
 ;
 D SCHEDULE
 ;
 Q
OTHER(VFDRSLT,VFDIEN,VFDSCAN,VFDTAB) ; Non-unit dose medications
 ; IV, Piggyback, ward stock, etc.
 ; 
 S VFDRSLT="-1^Not implemented.  This RPC version supports 'unit dose' only." Q
 ; Remove the preceding line when non-unit dose interface is ready
 ; 
 Q
NDC(VFDDIEN,VFDSCAN) ;[Private]   Match SYNONYM or DRUG to NDC
 ; VFDDIEN=[Required] File 50 (DRUG) IEN
 ; VFDSCAN=[Required] Raw scan code (See EVENT^VFDPSB documentation)
 ; 
 ; Returns corresponding NDC or the empty string, if NDC cannot be resolved.
 ; 
 I $G(VFDDIEN)>0 S VFDSCAN=$G(VFDSCAN) N VFDIENS,VFDNDC,VFDR,VFDSYN
 E  Q ""
 D GETS^DIQ(50,VFDDIEN,"9*","E",$NA(VFDSYN)) S (VFDIENS,VFDNDC)=""
 F  S VFDIENS=$O(VFDSYN(50.1,VFDIENS)) Q:'VFDIENS  D  Q:VFDNDC]""
 .S VFDR=$NA(VFDSYN(50.1,VFDIENS)) Q:'(@VFDR@(.01,"E")=VFDSCAN)
 .S VFDNDC=@VFDR@(2,"E")
 .Q
 S:'(VFDNDC]"") VFDNDC=$$GET1^DIQ(50,VFDDIEN,31) ;DRUG NDC
 Q VFDNDC
 ;
FILE ;[Private] File AUDIT LOG entry for scan data
 ; Variables VFDIEN, VFDSCAN, and VFDNDC are required.
 ; 
 I $G(VFDIEN) S VFDSCAN=$G(VFDSCAN),VFDNDC=$G(VFDNDC)
 E  Q  ;Invalid context
 N VFDFDA,VFDR S VFDR=$NA(VFDFDA(53.799,"+1,"_VFDIEN_","))
 S @VFDR@(.01)=$$NOW^XLFDT
 S @VFDR@(.02)=$G(DUZ,.5)
 S @VFDR@(.03)="Data for vxPAMS"
 S @VFDR@(21600.01)=VFDSCAN
 S @VFDR@(21600.02)=VFDNDC
 ;
 N VFDIENR D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR)) ;File AUDIT LOG entry
 Q
SCHEDULE ;[Private] Schedule task to interface data to vxPAMS.
 ;
 N ZTDESC,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTSK
 S ZTDESC="vxVistA to vxPAMS BCMA Interface"
 S ZTDTH=$H,ZTIO="",ZTRTN="DQ^VFDPSB2",ZTSAVE("VFD*")=""
 D ^%ZTLOAD
 Q
