VFDADR ;DSS/LM - VFD ADDRESS file API support ; 07/20/2012 10:05
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;See also routine ^VFDPSUTL for related APIs
 ;This routine is the only supported entry point for VFDADR* routines
 ;
 Q
 ;
SITE(VFDFILE,VFDIEN,VFDFLD) ; Return IEN for OUTPATIENT SITE (File 59)
 ; entry for given file and entry number.
 ; VFDFILE - Req - File number
 ;  VFDIEN - Req - Entry number
 ;     If VFDFILE is a subfile, VFDIEN must be an IENS
 ; VFDFLD - opt - Field number
 ; Returns a File 59 internal entry number, or -1^Error Text
 Q $$SITE^VFDADR1(.VFDFILE,.VFDIEN,.VFDFLD)
 ;
ADR(VFDFILE,VFDIEN,VFDFLD,VFDPKG) ; Return IEN for VFD ADDRESS (#21612)
 ; entry for given file and entry number.
 ; VFDFILE - Req - File number
 ;  VFDIEN - Req - Entry number
 ;     If VFDFILE is a subfile, VFDIEN must be an IENS
 ; VFDFLD - opt - Field number
 ; VFDPKG - opt - Package prefix, default=PS
 ; Returns a File 21612 internal entry number, or -1^Error Text
 Q $$ADR^VFDADR1(.VFDFILE,.VFDIEN,.VFDFLD,.VFDPKG)
 ;
LIST(VFDRSLT,VFDDATA) ; RPC: VFD ADDRESS LIST
 ; .VFDDATA - Req - vfddata(#) = <order ien #100>^<key word>
 ; .VFDRSLT - Return array - see RPC definition for details
 D LIST^VFDADR2(.VFDRSLT,.VFDDATA)
 Q
