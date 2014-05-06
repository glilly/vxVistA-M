VFDXX2 ;DSS/LM - Exception handler; 3/6/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
HL7(VFDXIEN) ;[Public] Reprocess HL7 message for exception (non-interactive)
 ; VFDXIEN=[Required] VXVISTA EXCEPTION internal entry number (File 21603 IEN)
 ; 
 ; Returns:
 ;        0=Success
 ;  -1^Text=Failure
 ;
 I '$G(VFDXIEN) Q "-1^Missing or invalid VXVISTA EXCEPTION IEN"
 N VFDERR,VFDHL,VFDHLO,VFDMID,VFDQUIET,VFDR,VFDRSLT,VFDRTN,VFDX,VFDXX
 D GETS^DIQ(21603,VFDXIEN,"*","I","VFDXX") S VFDR=$NA(VFDXX(21603,VFDXIEN_","))
 S VFDMID=@VFDR@(.04,"I"),VFDHL=@VFDR@(1.02,"I"),VFDHLO=@VFDR@(1.03,"I")
 I $L(VFDMID)!VFDHL!VFDHLO
 E  Q "-1^Insufficient data in exception--Cannot identify HL7 message"
 ;
 I 'VFDHL,'VFDHLO D  Q:'VFDX "-1^Invalid or ambiguous message control ID"_VFDMID
 .S VFDX=$$FIND(VFDMID) Q:'VFDX
 .S @$S(+VFDX=773:"VFDHL=$P(VFDX,U,2)",1:"VFDHLO=$P(VFDX,U,2)")
 .Q
 ; 
 ; HL with File 773 IEN
 I VFDHL D  Q VFDRSLT
 .S VFDQUIET=1,VFDRTN=$$RTN773^VFDXX1(VFDHL)
 .I '$L(VFDRTN) S VFDRSLT="-1^Processing routine not found" Q
 .S VFDRSLT=$$REPROC^HLUTIL(VFDHL,VFDRTN) Q:'VFDRSLT  ;Success
 .S VFDRSLT="-1^Error reprocessing HL 1.6 message"
 .Q
 ; HLO with File 778 IEN
 I VFDHLO D  Q VFDRSLT
 .S VFDRSLT=$$REPROC^HLOAPI3(VFDHLO,.VFDERR)
 .I VFDRSLT=1 S VFDRSLT=0 Q  ;Success
 .S VFDRSLT="-1^Error reprocessing HLO message: "_$G(VFDERR)
 .Q
 Q "-1^Unexpected error" ;Unreachable
 ;
FIND(VFDMID) ;[Private] Find an unambiguous message control ID
 ; VFDMID=[Required] Message control ID
 ; 
 ; Returns FILE#^IEN or NULL
 ; 
 Q:'$L($G(VFDMID)) "" N VFDRSLT
 S VFDRSLT=$$FIND1^DIC(773,,"X",VFDMID,"C")
 I VFDRSLT>0 Q "773^"_VFDRSLT
 S VFDRSLT=$$FIND1^DIC(778,,"X",VFDMID,"B")
 I VFDRSLT>0 Q "778^"_VFDRSLT
 Q "" ;Unsuccessful
