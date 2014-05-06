VFDDFN ;DSS/LM,JG - Utilities supporting PATIENT lookup ; 4/9/2012 14:45
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; See also routine ^VFDWDPT, ^VFDPT
 ;ICR #  SUPOORTED DESCRIPTION
 ;-----  --------------------------------
 ; 2263  $$GET^XPAR
 ;10103  $$DT^XLFDT
 ;10104  $$UP^XLFSTR
 ;10112  $$SITE^VASITE
 ;       $$BROKER^XWBLIB
 ;
 ;EXTERNAL CALLS INTO THIS ROUTINE
 ;--------------------------------
 ;PIDQ^VADPT6 calls $$ID
 ;
 Q
 ;------------------------   PROGRAMMER APIS   ------------------------
ID(DFN,LOC,TYPE,XDT,NOERR,CASE) ; Return PATIENT alternate ID
 ; DFN - req - Patient IEN
 ; LOC - opt - File 9999999.06 IEN (or File 4 IEN) or if "*" then look
 ;             for any location.  Default to +$$SITE^VASITE()
 ;TYPE - opt - #.05 subfield value to match.  Default to either the
 ;             DEFAULT (active) entry or the "MRN" Type Alternate ID
 ; XDT - opt - Fileman Date.Time.  Defaults to TODAY. Screen out based
 ;             upon EXPIRATION DATE in ALTERNATE ID field #.03
 ;NOERR - opt - Boolean, default to 0 - if NOERR then return null
 ;              instead of -1^msg - this is for M-to-M only, not RPC
 ;CASE - opt - allows for programmer to override the default behaviors
 ;             including the value of the parameter VFD PATIENT ID.
 ;             CASE must be a single digit, 1-9
 ;
 ;Extrinsic function returns: Alternate Patient ID or "-1^message"
 ;Significant updates
 ;  4/13/2010 - New Parameter Definition VFD PATIENT ID
 ;  3/29/2012 - OSEHRA compatibility
 ;   A. New input parameter [CASE]
 ;   B. Default to case 1 is CASE is not explicitly sent
 ;   C. New Parameter Definition [VFD PATIENT ID LABEL]
 ;      if this parameter is valued and the parameter VFD PATIENT ID is
 ;      not valued, the default behavior is case 6
 ;
 ;Values for CASE or Parameter Definition VFD PATIENT ID
 ;------------------------------------------------------
 ;Case 1: preserve the VA VistA behavior of always displaying SSN
 ;Case 2: if no SSN exists, then display *DFN*
 ;        -- all cases below refer to values in the Alt Id Mult --
 ;Case 3: If MRN value, else null
 ;Case 4: If MRN value, else default alt id, else value if only one
 ;           record exists in alt id, else *DFN*
 ;Case 5: If MRN value, else default alt id, else value if only one
 ;           record exists in alt id, else -1^msg.
 ;Case 6: If MRN value, else default alt id, else *DFN*
 ;Case 7: If MRN value, else default alt id, else SSN
 ;Case 8: If MRN value, else default alt id, else null
 ;Case 9: If default Alt Id, else MRN, else -1^msg
 ;
 G ID^VFDDFN01
 ;
DFN(AID,LOC,TYPE,XDT) ; Return PATIENT IEN
 ; AID - req - Aternate ID value to match
 ; For definition of LOC,TYPE,XDT see ID
 ; Extrinsic function returns DFN or -1^Text
 ; OSEHRA compliance not considered since Alt ID not VA
 ; LOC,TYPE,XDT filters same as in ID (see ID1)
 ; Logic:
 ;   Only 1 patient with AID value, return DFN
 ;   Check alternate IDs marked as default
 ;     If only one DFN with AID marked as default, return DFN
 G DFN^VFDDFN01
 ;
 ;-----------------------   REMOTE PROCEDURES   -----------------------
RPCID(VFDAT,DFN,LOC,TYPE,XDT,CASE) ; RPC: VFD PATIENT ID
 N X,Y,Z
 S X=$$ID($G(DFN),$G(LOC),$G(TYPE),$G(XDT),,$G(CASE))
 S:X="" X=-1 S VFDAT=X
 Q
 ;
RPCIDL(VFDAT) ; RPC: VFD PATIENT ID LABEL
 N PARM D PARM^VFDDFN01 S VFDAT=PARM_U_PARM("LABEL")
 Q
