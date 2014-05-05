VFDSURU ;DSS/LM - Surveillance HL7 Message Routers and Generators ;April 4, 2011
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
GENERATE(HL,HLA,HLRESLT,HLARYTYP) ;Wraps GENERATE^HLMA with copied HL* vars.
 S HLRESLT="" Q:'$G(HL("EID"))!'$D(HLA)  ;Caller logs error
 N HLEXROU ;Necessary
 D GENERATE^HLMA(HL("EID"),$G(HLARYTYP,"LM"),1,.HLRESLT)
 Q
MAX(J,K) ;[Private] Return maximum of J,K
 S J=$G(J),K=$G(K)
 Q $S(J>K:J,1:K)
 ;
SUPHI(VFDIEN) ;[Private] - Return 1 [True] iff PHI should be suppressed
 ; VFDIEN=[Required] Protocol IEN
 ;
 Q:'($G(VFDIEN)>0) 0 N VFDLIST,X,Y
 D ENVAL^XPAR(.VFDLIST,"VFD HL7 SUPPRESS PHI FOR EVENT")
 S X=$NA(VFDLIST),Y=0
 F  S X=$Q(@X) Q:X=""  I @X=VFDIEN S Y=1 Q
 Q Y
 ;
