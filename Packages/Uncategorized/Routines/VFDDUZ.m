VFDDUZ ;DSS/LM - Utilities supporting NEW PERSON LOOKUP ;June 5, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
FIND1(VFDVAL,VFDTYP,VFDLOC) ;[Public] - Lookup NEW PERSON using "AVFD" index
 ; 
 ; VFDVAL=[Required] Alternate ID value to look up
 ; VFDTYP=[Optional] Type of value (OTHER DATA #.05 subfield)
 ;                   Default is ALL types
 ; VFDLOC=[Optional] LOCATION IEN (#.01 subfield - DINUM'ed to File 4)
 ;                   Default is ALL locations
 ; 
 ; Return DUZ=NEW PERSON IEN (exact match required) or NULL
 ; 
 Q $$FIND1^VFDDUZ1(.VFDVAL,.VFDTYP,.VFDLOC)
 ;
ID(VFDRSLT,VFDDUZ) ;[Public] - Implements remote procedure VFD USER ID
 ; Wraps DSIC (VFDC) USER ID and appends additional data for DPS and NPI.
 ; 
 ; VFDRSLT=[Required] Return array name or reference
 ; VFDDUZ=[Required] NEW PERSON internal entry number
 ; 
 ; Format of return data:  See ID^DSICDUZ (aka VFDCDUZ)
 ; 
 ;     ^-piece 1 will have the ID mnemonic
 ;     ^-piece 2 will have ID value
 ;     ^-piece 3 and 4 See ID^DSICDUZ (ID^VFDCDUZ)
 ;     
 ;     The NPI value will be either 1) from the VA field 41.99,
 ;     or 2) from the ALTERNATE ID multiple, in that precedence order.
 ;     
 ;     The DPS value will be from the ALTERNATE ID multiple.
 ;     
 ; 
 ; The return will always be in ARRAY format.  This wrapper does does NOT
 ; support extrinsic function return.
 ; 
 I '$L($G(VFDRSLT)) S VFDRSLT=$NA(VFDRSLT)
 I '($T(ID^VFDCDUZ)]"") S @VFDRSLT@(1)="-1^This RPC requires routine VFDCDUZ" Q
 D ID^VFDDUZ1(.VFDRSLT,.VFDDUZ)
 Q
