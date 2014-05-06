VFDDNST ;DSS/LM - Utilities supporting INSTITUTION lookup ;June 5, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ; 
 Q
INST(VFDFN,VFDDT,VFDTYPE) ;[Public] - Institution associated with VISIT or MOVMENT
 ; VFDFN=[Required] PATIENT (File 2) IEN (DFN)
 ; VFDDT=[Optional] FileMan DATE (default=TODAY) or "LAST"
 ; VFDTYPE=[Optional] "I" or "O" for inpatient or outpatient
 ; 
 ; Returns INSITUTION IEN
 ;
 I $G(VFDFN) S VFDDT=$G(VFDDT,$$DT^XLFDT),VFDTYPE=$E($G(VFDTYPE))
 I $T,"IO"[VFDTYPE N VFDY S VFDY=""
 E  Q ""
 I "I"[VFDTYPE N DFN,VAIP,VAROOT,VFD D
 .S DFN=VFDFN,VAIP("D")=$P(VFDDT,"."),VAROOT=$NA(VFD)
 .D IN5^VADPT S VFDY=$$W2I(+$G(VFD(17,4)))
 .Q
 Q:VFDY!(VFDTYPE="I") VFDY
 ; 
 N VFDNVDT,VFDVIEN
 S VFDNVDT=$S(VFDDT:9999999-$P(VFDDT,"."),1:$O(^AUPNVSIT("AA",VFDFN,"")))
 S VFDVIEN=$O(^AUPNVSIT("AA",VFDFN,VFDNVDT,""))
 Q $$V2I(VFDVIEN)
 ;
M2I(VFDGPM) ;[Public] - Institution for PATIENT MOVEMENT
 ; VFDGPM=[Required] PATIENT MOVEMENT (File 405) IEN
 ; 
 ; Returns INSITUTION IEN for PATIENT and MOVEMENT DATE corresponding
 ; to the given movement IEN.
 ;
 I $G(VFDGPM) N DFN,VAIP,VAROOT,VFD
 E  Q ""
 S DFN=$$GET1^DIQ(405,VFDGPM,.03,"I")
 S VAIP("D")=$P($$GET1^DIQ(405,VFDGPM,.01,"I"),"."),VAROOT=$NA(VFD)
 D IN5^VADPT
 Q $$W2I(+$G(VFD(17,4)))
 ;
L2I(VFDHL) ;[Public] - Institution for HOSPITAL LOCATION
 ; VFDHL=[Required] HOSPITAL LOCATION (File 44) IEN
 ; 
 ; Returns INSITUTION IEN
 ; 
 I $G(VFDHL) N VFDY S VFDY=$$GET1^DIQ(44,+VFDHL,3,"I")
 E  Q ""
 Q $S(VFDY:VFDY,1:$$GET1^DIQ(44,+VFDHL,"3.5:.07","I"))
 ;
W2I(VFDWL) ;[Public] - Institution for WARD LOCATION
 ; VFDWL=[Required] WARD LOCATION (File 42) IEN
 ; 
 ; Returns INSITUTION IEN
 ; 
 I $G(VFDWL) N VFDHL S VFDHL=$$GET1^DIQ(42,+VFDWL,44,"I")
 E  Q ""
 Q $S(VFDHL:$$L2I(VFDHL),1:"")
 ;
V2I(VFDVIEN) ;[Public] - Institution for VISIT
 ; VFDVIEN=[Required] VISIT (File 9000010) IEN
 ; 
 ; Returns INSITUTION IEN
 ; 
 I $G(VFDVIEN) N VFDHL S VFDHL=$$GET1^DIQ(9000010,+VFDVIEN,.22,"I")
 E  Q ""
 I VFDHL Q $S(VFDHL:$$L2I(VFDHL),1:"")
 N VFDPIEN ; Try parent visit
 S VFDPIEN=$$GET1^DIQ(9000010,+VFDVIEN,.12,"I") Q:'VFDPIEN!(VFDPIEN=VFDVIEN) ""
 Q $$V2I(VFDPIEN)
 ;
