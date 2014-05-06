VFDADR1 ;DSS/LM - VFD ADDRESS file API support ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ;
 Q
SITE(VFDFILE,VFDIEN,VFDFLD,VFDRCR) ;[Private] Return IEN of corresponding OUTPATIENT SITE (File 59) entry
 ; for given file and entry number.
 ;
 ; Continuation of SITE^VFDADR()
 ; VFDRCR=[Private] Recursion counter
 ;
 I $G(VFDFILE),$G(VFDIEN),VFDFILE>0,VFDIEN>0,VFDFILE=+VFDFILE N VFD,VFDY ;IEN may be IENS
 E  Q "-1^Invalid or missing parameter"
 S VFDFLD=$G(VFDFLD),VFDRCR=+$G(VFDRCR),VFDY=""
 I VFDRCR>2 Q "-1^Unsupported recursion."
 ; Case 0 - Input file is 59
 Q:VFDFILE=59 $S($D(^PS(59,VFDIEN)):VFDIEN,1:"-1^Entry "_VFDIEN_" does not exist in the OUTPATIENT SITE file") ; Trivial case
 ; Case 1 - Input file points to File 59 directly
 I $D(^DD(59,0,"PT",VFDFILE)) D  Q $S($L(VFDY):VFDY,1:"-1^Not found")
 .I 'VFDFLD S VFDFLD=$O(^DD(59,0,"PT",VFDFILE,"")) I VFDFLD,$O(^DD(59,0,"PT",VFDFILE,VFDFLD)) D  Q
 ..S VFDY="-1^Field# required when more than one path exists"
 ..Q
 .I 'VFDFLD S VFDY="-1^Could not compute Field#" Q
 .S VFDY=$$GET1^DIQ(VFDFILE,VFDIEN,VFDFLD,"I")
 .Q
 ; Case 2 - Input is File 4 and entry is resolvable through forward pointer
 ;          from File 59 REALATED INSTITUTION field# 100 (Index "D")
 ; 
 I VFDFILE=4 D  Q $S($L(VFDY):VFDY,1:"-1^Not found")
 .S VFDY=$O(^PS(59,"D",VFDIEN,0))
 .I VFDY,$O(^PS(59,"D",VFDIEN,VFDY)) S VFDY="-1^More than one File 59 entry has RELATED INSTITUTION=IEN: "_VFDIEN
 .Q
 ; Case 3 - Input points to a File 4 entry that satisfies case 2
 I $D(^DD(4,0,"PT",VFDFILE)) D  Q $S($L(VFDY):VFDY,1:"-1^Not found")
 .I 'VFDFLD S VFDFLD=$O(^DD(4,0,"PT",VFDFILE,"")) I VFDFLD,$O(^DD(4,0,"PT",VFDFILE,VFDFLD)) D  Q
 ..S VFDY="-1^Field# required when more than one path exists"
 ..Q
 .Q:$L(VFDY)  I 'VFDFLD S VFDY="-1^Could not compute Field#" Q
 .S VFD=$$GET1^DIQ(VFDFILE,VFDIEN,VFDFLD,"I") ;File 4 IEN
 .I VFD S VFDY=$$SITE^VFDADR1(4,VFD,,VFDRCR+1)
 .Q
 ; 
 ; Case 4 - Input does not point to File 4 or File 59
 ;          =OR= available ointer to File 4 does not resolve target
 Q "-1^Unable to compute target entry from File "_VFDFILE_", entry "_VFDIEN_$S(VFDFLD:", using field# "_VFDFLD,1:"")_"."
 ;
ADR(VFDFILE,VFDIEN,VFDFLD,VFDPKG,VFDRCR) ;[Private] Return IEN of corresponding VFD ADDRESS (File 21612) entry
 ; for given file and entry number.
 ;
 ; Continuation of ADR^VFDADR()
 ; VFDRCR=[Private] Recursion counter
 ;
 I $G(VFDFILE),$G(VFDIEN),VFDFILE>0,VFDIEN>0,VFDFILE=+VFDFILE N VFD,VFDY ;IEN may be IENS
 E  Q "-1^Invalid or missing parameter"
 S VFDFLD=$G(VFDFLD),VFDPKG=$G(VFDPKG),VFDRCR=+$G(VFDRCR),VFDY=""
 I VFDRCR>2 Q "-1^Unsupported recursion."
 ; 7/19/2010 - Insert new case, using File 21612 pointer to File 4
 I VFDFILE=4 S VFDY=$$AP4(+VFDIEN,$S(VFDPKG="PS":1,VFDPKG="LR":2,VFDPKG="RA":3,1:"")) Q:VFDY>0 VFDY
 ; 7/19/2010 - End insert
 ; Case 0 - Input file is 21612
 Q:VFDFILE=21612 $S($D(^VFD(21612,VFDIEN)):VFDIEN,1:"-1^Entry "_VFDIEN_" does not exist in the VFD ADDRESS file") ; Trivial case
 ; Case 1 - Input file points to File 21612 directly
 I $D(^DD(21612,0,"PT",VFDFILE)) D  Q $S($L(VFDY):VFDY,1:"-1^Not found")
 .I VFDFILE=4 D   Q:$L(VFDY)  ; Case 1A (special)
 ..S:VFDPKG=""&'VFDFLD VFDPKG="PS" ;Default
 ..S VFD=$S(VFDPKG="PS":1,VFDPKG="LR":2,VFDPKG="RA":3,1:"")
 ..S:'VFDFLD VFDFLD="21612.0"_VFD
 ..I VFDFLD="21612.0" S VFDY="-1^Unknown PACKAGE" Q
 ..; Check for contradiction
 ..I VFD,VFD'=+$P(VFDFLD,".",2) S VFDY="-1^Field# contradicts PACKAGE ID"
 ..Q
 .I 'VFDFLD S VFDFLD=$O(^DD(21612,0,"PT",VFDFILE,"")) I VFDFLD,$O(^DD(21612,0,"PT",VFDFILE,VFDFLD)) D  Q
 ..S VFDY="-1^Field# required when more than one path exists"
 ..Q
 .Q:$L(VFDY)  I 'VFDFLD S VFDY="-1^Could not compute Field#" Q
 .S VFDY=$$GET1^DIQ(VFDFILE,VFDIEN,VFDFLD,"I")
 .Q
 ; Case 2 - Input file points to File 4
 N VFDA
 I $D(^DD(4,0,"PT",VFDFILE)) D  Q $S($L(VFDY):VFDY,1:"-1^Not found") ;Direct pointer to INSTITUTION
 .I 'VFDFLD S VFDFLD=$O(^DD(4,0,"PT",VFDFILE,"")) I VFDFLD,$O(^DD(4,0,"PT",VFDFILE,VFDFLD)) D  Q
 ..S VFDY="-1^Field# required when more than one path exists"
 ..Q
 .I 'VFDFLD S VFDY="-1^Could not compute Field#" Q
 .S VFDA=$$GET1^DIQ(VFDFILE,VFDIEN,VFDFLD,"I")
 .I 'VFDA S VFDY="-1^No operational path to target from File "_VFDFILE_", field# "_VFDFLD Q
 .S VFDY=$$ADR^VFDADR1(4,VFDA,,.VFDPKG,VFDRCR+1)
 .Q
 ; Case 3 - Other supported files (Field# required)
 I 'VFDFLD Q "-1^"_$S(VFDRCR:"No useable recursive path to target via File "_VFDFILE,1:"Field# required for indirect path")
 N VFDPFILE S VFD=$P($G(^DD(VFDFILE,VFDFLD,0)),U,2) I VFD["P"
 E  Q "-1^Field# "_VFDFLD_" is not a pointer in File "_VFDFILE_"."
 S VFDPFILE=+$P(VFD,"P",2) I 'VFDPFILE Q "-1^Anomalous DD for File "_VFDFILE_", field# "_VFDFLD
 S VFDA=$$GET1^DIQ(VFDFILE,VFDIEN,VFDFLD,"I")
 I VFDA Q $$ADR^VFDADR1(VFDPFILE,VFDA,,.VFDPKG,VFDRCR+1)
 ; 
 Q "-1^General failure"
 ;
AP4(VFDNIEN,VFDUSAGE) ;[Private] - Return VFD ADDRESS IEN, given -
 ;                                 INSTITUTION IEN and ASSOCIATED USAGE
 ;
 ; VFDNIEN=[Required] File 4 IEN
 ; VFDUSAGE=[Required] Code# of usage, e.g. 1=RX PRINT
 ;
 I $G(VFDNIEN)>0,$L($G(VFDUSAGE)) N VFDY
 E  Q ""
 D:'(VFDUSAGE=+VFDUSAGE)  Q:'(VFDUSAGE=+VFDUSAGE) "" ;Resolve SET code
 .N VFD D FIELD^DID(21612.04,.02,"N","POINTER",$NA(VFD))
 .S VFD=$G(VFD("POINTER")),VFD=$E(VFD,$F(VFD,VFDUSAGE)-$L(VFDUSAGE)-2)
 .S:VFDUSAGE=$$EXTERNAL^DILFD(21612.04,.02,,VFD) VFDUSAGE=VFD ;Exact match
 .Q
 S VFDY=$O(^VFD(21612,"VFD",VFDNIEN,VFDUSAGE,""))
 Q $S($O(^(VFDY))="":VFDY,1:"")
 ;
